var icing = {
    init : func {
        me.UPDATE_INTERVAL = 5;
        me.loopid = 0;

        me.icewarnw = 0;
        me.icewarne1 = 0;
        me.icewarne2 = 0;
        me.icewarn_windscreen = 0;
        me.icewarn_probes = 0;
        me.failwarn_wscreen_p = 0;
        me.failwarn_wscreen_b = 0;

        setprop("/controls/ice/wing/temp", getprop("/environment/temperature-degc") );
        setprop("/controls/ice/eng1/temp", getprop("/environment/temperature-degc") );
        setprop("/controls/ice/eng2/temp", getprop("/environment/temperature-degc") );
        setprop("/controls/ice/windscreen/center_temp", getprop("/environment/temperature-degc") );
        setprop("/controls/ice/windscreen/sides_temp", getprop("/environment/temperature-degc") );
        setprop("/controls/ice/probes/temp", getprop("/environment/temperature-degc"));

        setprop("/controls/ice/wing/anti-ice-setting", 1.0);
        setprop("/controls/ice/eng1/anti-ice-setting", 1.0);
        setprop("/controls/ice/eng2/anti-ice-setting", 1.0);
        setprop("/controls/ice/windscreen/primary", 0.0);
        setprop("/controls/ice/windscreen/backup", 0.0);
        setprop("/controls/ice/probes/anti-ice", 0.0);

        setprop("/controls/ice/windscreen/primary-serviceable", 1.0);
        setprop("/controls/ice/windscreen/primary-legend", "AVAILABLE");
        setprop("/controls/ice/windscreen/backup-serviceable", 1.0);
        setprop("/controls/ice/windscreen/backup-legend", "AVAILABLE");

        me.reset();
    },
    update : func {
        # Get information
        #################

        # Calculate TAT Value [ TAT = static temp (1 + ((1.4 - 1) / 2) Mach^2) ]
        # note (1.4 - 1) / 2 = 0.2
        setprop(
            "/controls/ice/tat",
            getprop("/environment/temperature-degc") * (1 + 0.2 * getprop("/velocities/mach") * getprop("/velocities/mach"))
        );
        var tat = getprop("/controls/ice/tat");

        # Anti-Ice Control System knobs & switches.

        # These knobs have an 'auto' option, so some logic is required.
        var wingicesetting =
            getprop("/controls/ice/wing/anti-ice-setting")
            * (!!(getprop("/systems/electrical/left-bus") or getprop("/systems/electrical/right-bus")));

        var eng1icesetting =
            getprop("/controls/ice/eng1/anti-ice-setting")
            * (getprop("/engines/engine[0]/n1") >= 30.0);
        var eng2icesetting =
            getprop("/controls/ice/eng2/anti-ice-setting")
            * (getprop("/engines/engine[1]/n1") >= 30.0);

        # Activate the windscreen heaters only when the system is serviceable
        var windscreensetting_p =
            getprop("/controls/ice/windscreen/primary")
            * getprop("/controls/ice/windscreen/primary-serviceable")
            * (!!(getprop("/systems/electrical/left-bus") or getprop("/systems/electrical/right-bus")));

        # The backup system only kicks in when the primary fails
        var windscreensetting_b =
            getprop("/controls/ice/windscreen/backup")
            * getprop("/controls/ice/windscreen/backup-serviceable")
            * (!getprop("/controls/ice/windscreen/primary-serviceable"))
            * (!!(getprop("/systems/electrical/left-bus") or getprop("/systems/electrical/right-bus")));

        # These probes are always heated when the engines are on (no AutoAntiIce required)
        var probesetting =
            (!getprop("/engines/engine[0]/cutoff") or !getprop("/engines/engine[1]/cutoff"))
            * (!!(getprop("/systems/electrical/left-bus") or getprop("/systems/electrical/right-bus")));

        # Control activation of heating elements
        ########################################

        # Wing heaters
        if (wingicesetting == 0)
            setprop("/controls/ice/wing/anti-ice", 0);
        elsif (wingicesetting == 1)
            setprop("/controls/ice/wing/anti-ice", tat <= 0);
        else
            setprop("/controls/ice/wing/anti-ice", 1);

        # Engine 1 heaters
        if (eng1icesetting == 0)
            setprop("/controls/ice/eng1/anti-ice", 0);
        elsif (eng1icesetting == 1)
            setprop("/controls/ice/eng1/anti-ice", tat <= 0);
        else
            setprop("/controls/ice/eng1/anti-ice", 1);

        # Engine 2 heaters
        if (eng2icesetting == 0)
            setprop("/controls/ice/eng2/anti-ice", 0);
        elsif (eng2icesetting == 1)
            setprop("/controls/ice/eng2/anti-ice", tat <= 0);
        else
            setprop("/controls/ice/eng2/anti-ice", 1);

        # Windscreen primary heaters
        if (windscreensetting_p == 0)
            setprop("/controls/ice/windscreen/anti-ice", 0.0);
        else
            setprop("/controls/ice/windscreen/anti-ice", 1.0);

        # Windscreen backup heaters
        if (windscreensetting_b == 0)
            setprop("/controls/ice/windscreen/anti-ice-backup", 0.0);
        else
            setprop("/controls/ice/windscreen/anti-ice-backup", 1.0);

        # Probe heaters
        if (probesetting == 0)
            setprop("/controls/ice/probes/anti-ice", 0);
        else
            setprop("/controls/ice/probes/anti-ice", 1);

        # Calculate temperatures, cooling, and heating
        ##############################################

        # Get the temperatures of the parts
        var wing_temp = getprop("/controls/ice/wing/temp");
        var eng1_temp = getprop("/controls/ice/eng1/temp");
        var eng2_temp = getprop("/controls/ice/eng2/temp");
        var wscreen_c_temp = getprop("/controls/ice/windscreen/center_temp");
        var wscreen_s_temp = getprop("/controls/ice/windscreen/sides_temp");
        var probes_temp = getprop("/controls/ice/probes/temp");

        # Air affects all parts even if the heaters are on, the heaters can heat the part
        # afterwards. This method also heats the parts when TAT > part's temperature.
        # All parts use the following formula:
        # part_temp += me.UPDATE_INTERVAL * (me.UPDATE_INTERVAL * (tat - part_temp) * part_surface_area * 10) / mass / specific_heat_capacity_of_material;

        wing_temp      += me.UPDATE_INTERVAL * (me.UPDATE_INTERVAL * (tat - wing_temp     ) * 14.887 * 10) / 850 / 897;
        eng1_temp      += me.UPDATE_INTERVAL * (me.UPDATE_INTERVAL * (tat - eng1_temp     ) * 13.603 * 10) / 367 / 897;
        eng2_temp      += me.UPDATE_INTERVAL * (me.UPDATE_INTERVAL * (tat - eng2_temp     ) * 13.603 * 10) / 367 / 897;
        wscreen_c_temp += me.UPDATE_INTERVAL * (me.UPDATE_INTERVAL * (tat - wscreen_c_temp) * 1.564  * 10) / 119 / 753;
        wscreen_s_temp += me.UPDATE_INTERVAL * (me.UPDATE_INTERVAL * (tat - wscreen_s_temp) * 1.622  * 10) / 123 / 753;
        probes_temp    += me.UPDATE_INTERVAL * (me.UPDATE_INTERVAL * (tat - probes_temp   ) * 0.1    * 10) / 10  / 897;

        # For the effect of the heating elements, all parts use the following formula:
        #part_temp += me.UPDATE_INTERVAL * (heating_power * me.UPDATE_INTERVAL) * mass * specific_heat_capacity_of_material;

        # Wing heaters
        #=============
        if (getprop("/controls/ice/wing/anti-ice") == 1) {
            wing_temp += me.UPDATE_INTERVAL * (30000 * me.UPDATE_INTERVAL) / 850 / 897;

            # Simulates the system not heating the part once it reaches 15°C
            if (wing_temp >= 15.0)
                wing_temp = 15.0;
        }

        # Handle wing icing alert
        if ((wing_temp <= 0) and (me.icewarnw == 0)) {
            screen.log.write("Wing Ice Alert!", 1, 0, 0);
            sysinfo.log_msg("[HEAT] Ice Detected on Wings", 1);
            me.icewarnw = 1;
        }
        if ((wing_temp > 0) and (me.icewarnw == 1))
            me.icewarnw = 0;

        # Engine 1 heaters
        #=================
        if (getprop("/controls/ice/eng1/anti-ice") == 1) {
            eng1_temp += me.UPDATE_INTERVAL * (25000 * me.UPDATE_INTERVAL) / 367 / 897;

            # Simulates the system not heating the part once it reaches 35°C
            if (eng1_temp >= 35.0)
                eng1_temp = 35.0;
        }

        # Handle eng1 icing alert
        if ((eng1_temp <= 0) and (me.icewarne1 == 0)) {
            screen.log.write("Engine 1 Ice Alert!", 1, 0, 0);
            sysinfo.log_msg("[HEAT] Ice Detected on Engine 1", 1);
            me.icewarne1 = 1
        }
        if ((eng1_temp > 0) and (me.icewarne1 == 1))
            me.icewarne1 = 0;

        # Engine 2 heaters
        #=================
        if (getprop("/controls/ice/eng2/anti-ice") == 1) {
            eng2_temp += me.UPDATE_INTERVAL * (25000 * me.UPDATE_INTERVAL) / 367 / 897;

            # Simulates the system not heating the part once it reaches 35°C
            if (eng2_temp >= 35.0)
                eng2_temp = 35.0;
        }

        # Handle eng2 icing alert
        if ((eng2_temp <= 0) and (me.icewarne1 == 0)) {
            screen.log.write("Engine 2 Ice Alert!", 1, 0, 0);
            sysinfo.log_msg("[HEAT] Ice Detected on Engine 2", 1);
            me.icewarne2 = 1
        }
        if ((eng2_temp > 0) and (me.icewarne1 == 1))
            me.icewarne2 = 0;

        # Windscreen primary & secondary heaters
        #=======================================
        if (getprop("/controls/ice/windscreen/anti-ice") == 1) {
            wscreen_c_temp += me.UPDATE_INTERVAL * (4000 * me.UPDATE_INTERVAL) * 119 * 753;
            wscreen_s_temp += me.UPDATE_INTERVAL * (4000 * me.UPDATE_INTERVAL) * 123 * 753;

            # Simulates the system not heating the part once it reaches 15°C
            if (wscreen_c_temp >= 15.0)
                wscreen_c_temp = 15.0;
            if (wscreen_s_temp >= 15.0)
                wscreen_s_temp = 15.0;
        }

        if (getprop("/controls/ice/windscreen/anti-ice-backup") == 1) {
            wscreen_c_temp += me.UPDATE_INTERVAL * (4000 * me.UPDATE_INTERVAL) * 119 * 753;

            # Simulates the system not heating the part once it reaches 15°C
            if (wscreen_c_temp >= 15.0)
                wscreen_c_temp = 15.0;
        }

        # Handle windscreen ice alert
        if ((wscreen_c_temp <= 0) and (me.icewarn_windscreen == 0)) {
            screen.log.write("Windscreen Ice Alert!", 1, 0, 0);
            sysinfo.log_msg("[HEAT] Ice detected on Windscreen", 1);
            me.icewarn_windscreen = 1;
        }
        if ((wscreen_c_temp > 0) and (me.icewarn_windscreen == 1))
            me.icewarn_windscreen = 0;

        # Handle windscreen heaters failure alert
        # Primary
        if (getprop("/controls/ice/windscreen/primary-serviceable") == 0 and me.failwarn_wscreen_p == 0)
            sysinfo.log_msg("[HEAT] Primary windscreen heaters failure", 1);
        me.failwarn_wscreen_p = !getprop("/controls/ice/windscreen/primary-serviceable");
        # Backup
        if (getprop("/controls/ice/windscreen/backup-serviceable") == 0 and me.failwarn_wscreen_b == 0)
            sysinfo.log_msg("[HEAT] Backup windscreen heaters failure", 1);
        me.failwarn_wscreen_b = !getprop("/controls/ice/windscreen/backup-serviceable");

        setprop("/environment/aircraft-effects/fog-level", wscreen_c_temp / -25);
        setprop("/environment/aircraft-effects/frost-level", wscreen_c_temp / -30);

        # Probe heaters
        #==============
        if (getprop("/controls/ice/probes/anti-ice") == 1) {
            probes_temp += me.UPDATE_INTERVAL * (300 * me.UPDATE_INTERVAL) * 10 * 897;

            # Simulates the system not heating the part once it reaches 15°C
            if (probes_temp >= 15.0)
                probes_temp = 15.0;
        }

        # Handle probes ice alert
        if ((probes_temp <= 0) and (me.icewarn_probes == 0)) {
            screen.log.write("Pitot & AoA probes Ice Alert!", 1, 0, 0);
            sysinfo.log_msg("[HEAT] Ice detected on pitot & AoA probes", 1);
            me.icewarn_probes = 1;
        }
        if ((probes_temp > 0) and (me.icewarn_probes == 1))
            me.icewarn_probes = 0;

        # Export variables and warnings
        ###############################

        # Exporting nasal variables back to the property tree
        setprop("/controls/ice/wing/temp", wing_temp);
        setprop("/controls/ice/eng1/temp", eng1_temp);
        setprop("/controls/ice/eng2/temp", eng2_temp);
        setprop("/controls/ice/windscreen/center_temp", wscreen_c_temp);
        setprop("/controls/ice/windscreen/sides_temp", wscreen_s_temp);
        setprop("/controls/ice/probes/temp", probes_temp);

        # Set Engine Failures in case of Heavy Ice
        if (eng1_temp <= -30)
            setprop("/controls/engines/engine/cut-off", 1);

        if (eng2_temp <= -30)
            setprop("/controls/engines/engine[1]/cut-off", 1);

        # Change aerodynamics
        #####################

        # Set Wing Lift and Drag Coefficients according to temperature
        if (wing_temp >= 0) {
            setprop("/controls/ice/wing/lift-coefficient", 1);
            setprop("/controls/ice/wing/drag-coefficient", 1);
        } else {
            setprop("/controls/ice/wing/lift-coefficient", 1 + ( wing_temp / 80 ) );
            setprop("/controls/ice/wing/drag-coefficient", 1 - ( wing_temp / 80 ) );
        }
    },
    reset : func {
        me.loopid += 1;
        me._loop_(me.loopid);
    },
    _loop_ : func(id) {
        id == me.loopid or return;
        me.update();
        settimer(func { me._loop_(id); }, me.UPDATE_INTERVAL);
    }
};

setlistener("sim/signals/fdm-initialized", func {
    icing.init();
    print("Anti-Icing .......... Initialized");
    sysinfo.log_msg("[HEAT] System Check ...... OK", 0);
});
