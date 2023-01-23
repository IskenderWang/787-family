var icing = {
    init : func {
        me.UPDATE_INTERVAL = 5;
        me.loopid = 0;

        me.icewarnw = 0;
        me.icewarne1 = 0;
        me.icewarne2 = 0;
        me.icewarn_windscreen = 0;
        me.icewarn_probes = 0;

        setprop("/controls/ice/wing/temp", getprop("/environment/temperature-degc") );
        setprop("/controls/ice/eng1/temp", getprop("/environment/temperature-degc") );
        setprop("/controls/ice/eng2/temp", getprop("/environment/temperature-degc") );
        setprop("/controls/ice/windscreen/center_temp", getprop("/environment/temperature-degc") );
        setprop("/controls/ice/windscreen/sides_temp", getprop("/environment/temperature-degc") );
        setprop("/controls/ice/probes/temp", getprop("/environment/temperature-degc"));

        setprop("/controls/ice/wing/anti-ice-setting", 1.0);
        setprop("/controls/ice/eng1/anti-ice-setting", 1.0);
        setprop("/controls/ice/eng2/anti-ice-setting", 1.0);
        setprop("/controls/ice/windscreen/anti-ice", 0.0);
        setprop("/controls/ice/windscreen/anti-ice-backup", 0.0);
        setprop("/controls/ice/probes/anti-ice", 0.0);

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
        var wingicesetting = getprop("/controls/ice/wing/anti-ice-setting");
        var eng1icesetting = getprop("/controls/ice/eng1/anti-ice-setting");
        var eng2icesetting = getprop("/controls/ice/eng2/anti-ice-setting");

        # The windscreen setting is omitted because the switch directly controls the heaters.

        # These probes are always heated when the engines are on (no AutoAntiIce required)
        var probesetting =
            getprop("/controls/engines/eng[0]/running")
            or getprop("/controls/engine/eng[1]/running");

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

        # Probe heaters
        if (probesetting == 0)
            setprop("/controls/ice/probes/anti-ice", 0);
        else
            setprop("/controls/ice/probes/anti-ice", 1);

        # Calculate temperatures, cooling, and heating using heat energy
        ################################################################

        # Get the temperatures of the parts
        var wing_temp = getprop("/controls/ice/wing/temp");
        var eng1_temp = getprop("/controls/ice/eng1/temp");
        var eng2_temp = getprop("/controls/ice/eng2/temp");
        var windscreen_center_temp = getprop("/controls/ice/windscreen/center_temp");
        var windscreen_sides_temp = getprop("/controls/ice/windscreen/sides_temp");
        var probes_temp = getprop("/controls/ice/probes/temp");

        # Heat energy: Calculated as mass * specific heat capacity * degrees °K.
        var wing_heat_energy = 850 * 897 * (wing_temp + 273.15);
        var eng1_heat_energy = 367 * 897 * (eng1_temp + 273.15);
        var eng2_heat_energy = 367 * 897 * (eng2_temp + 273.15);
        var windscreen_center_heat_energy = 119 * 753 * (windscreen_center_temp + 273.15);
        var windscreen_sides_heat_energy = 123 * 753 * (windscreen_sides_temp + 273.15);
        var probes_heat_energy = 10 * 897 * (probes_temp + 273.15);

        # Air affects all parts even if the heaters are on, the heaters can heat the part
        # afterwards. This method also heats the parts when TAT > part's temperature. The cooling
        # affected to each part by the TAT takes into account the part's surface area.
        wing_heat_energy -= (tat - wing_temp) * 743845 / -100;
        eng1_heat_energy -= (tat - eng1_temp) * 680125 / -100;
        eng2_heat_energy -= (tat - eng2_temp) * 680125 / -100;
        windscreen_center_heat_energy -= (tat - windscreen_center_temp) * 78215 / -100;
        windscreen_sides_heat_energy -= (tat - windscreen_sides_temp) * 78215 / -100;
        probes_heat_energy -= (tat - probes_temp) * 5000 / -100;

        # Wing heaters
        #=============
        if (getprop("/controls/ice/wing/anti-ice") == 1) {
            wing_heat_energy += 967000;

            # Simulates the system not heating the part once it reaches 15°C
            if (wing_heat_energy > 219699967)
                wing_heat_energy = 219699967;
        }

        wing_temp = wing_heat_energy / 850 / 897 - 273.15; # Back into °C

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
            eng1_heat_energy += 986000;

            # Simulates the system not heating the part once it reaches 35°C
            if (eng1_heat_energy > 101442672)
                eng1_heat_energy = 101442672;
        }

        eng1_temp = eng1_heat_energy / 367 / 897 - 273.15; # Back into °C

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
            eng2_heat_energy += 986000;

            # Simulates the system not heating the part once it reaches 35°C
            if (eng2_heat_energy > 101442672)
                eng2_heat_energy = 101442672;
        }

        eng2_temp = eng2_heat_energy / 367 / 897 - 273.15; # Back into °C

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
            windscreen_center_heat_energy += 105000;
            windscreen_sides_heat_energy += 105000;

            # Simulates the system not heating the part once it reaches 15°C
            if (windscreen_center_heat_energy > 25820257)
                windscreen_center_heat_energy = 25820257;
            if (windscreen_sides_heat_energy > 26688165)
                windscreen_sides_heat_energy = 26688165;
        }

        # TODO: Make secondary run only when primary fails
        if (getprop("/controls/ice/windscreen/anti-ice-backup") == 1) {
            windscreen_center_heat_energy += 105000;

            # Simulates the system not heating the part once it reaches 15°C
            if (windscreen_center_heat_energy > 25820257)
                windscreen_center_heat_energy = 25820257;
        }

        windscreen_center_temp = windscreen_center_heat_energy / 119 / 753 - 273.15; # Back into °C
        windscreen_sides_temp = windscreen_sides_heat_energy / 123 / 753 - 273.15; # Back into °C

        # Handle windscreen ice alert
        if ((windscreen_center_temp <= 0) and (me.icewarn_windscreen == 0)) {
            screen.log.write("Windscreen Ice Alert!", 1, 0, 0);
            sysinfo.log_msg("[HEAT] Ice detected on Windscreen", 1);
            me.icewarn_windscreen = 1;
        }
        if ((windscreen_center_temp > 0) and (me.icewarn_windscreen == 1))
            me.icewarn_windscreen = 0;

        # Probe heaters
        #==============
        if (getprop("/controls/ice/probes/anti-ice") == 1) {
            probes_heat_energy += 7500;

            # Simulates the system not heating the part once it reaches 15°C
            if (probes_heat_energy > 2584706)
                probes_heat_energy = 2584706;
        }

        probes_temp = probes_heat_energy / 10 / 897 - 273.15; # Back into °C

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
        setprop("/controls/ice/windscreen/center_temp", windscreen_center_temp);
        setprop("/controls/ice/windscreen/sides_temp", windscreen_sides_temp);
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
