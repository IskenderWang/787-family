var icing = {
    init : func {
        me.UPDATE_INTERVAL = 5;
        me.loopid = 0;

        # Ice warnings
        me.icewarnw = 0;
        me.icewarne1 = 0;
        me.icewarne2 = 0;
        me.icewarn_windscreen = 0;
        me.icewarn_probes = 0;

        # Failure warnings
        me.failwarn_wing = 0;
        me.failwarn_eng1 = 0;
        me.failwarn_eng2 = 0;
        me.failwarn_wscreen_p = 0;
        me.failwarn_wscreen_b = 0;
        me.failwarn_probes = 0;

        # Temperatures
        setprop("/controls/ice/wing/temp", getprop("/environment/temperature-degc") );
        setprop("/controls/ice/eng1/temp", getprop("/environment/temperature-degc") );
        setprop("/controls/ice/eng2/temp", getprop("/environment/temperature-degc") );
        setprop("/controls/ice/windscreen/center_temp", getprop("/environment/temperature-degc") );
        setprop("/controls/ice/windscreen/sides_temp", getprop("/environment/temperature-degc") );
        setprop("/controls/ice/probes/temp", getprop("/environment/temperature-degc"));

        # Anti-ice settings
        setprop("/controls/ice/wing/anti-ice-setting", 1.0);
        setprop("/controls/ice/eng1/anti-ice-setting", 1.0);
        setprop("/controls/ice/eng2/anti-ice-setting", 1.0);
        setprop("/controls/ice/windscreen/primary", 0.0);
        setprop("/controls/ice/windscreen/backup", 0.0);
        setprop("/controls/ice/probes/anti-ice", 0.0);

        # Failure states and legends
        setprop("/controls/ice/wing/failed", 0.0);
        setprop("/controls/ice/eng1/failed", 0.0);
        setprop("/controls/ice/eng2/failed", 0.0);
        setprop("/controls/ice/windscreen/primary-failed", 0.0);
        setprop("/controls/ice/windscreen/backup-failed", 0.0);
        setprop("/controls/ice/probes/failed", 0.0);

        # Icing situation on each part
        me.wscreen_c_icing = 0;
        me.probes_icing = 0;
        me.eng1_icing = 0;
        me.eng2_icing = 0;
        me.wing_icing = 0;

        me.reset();
    },
    update : func {
        # Get information
        #################

        # Calculate TAT Value [ SAT + RR ], where RR = TAS^2 / 87^2
        setprop(
            "/controls/ice/tat",
            getprop("/environment/temperature-degc") + math.pow(getprop("/velocities/uBody-fps") * 0.5924838, 2) / 7569
        );
        var tat = getprop("/controls/ice/tat");

        # Anti-Ice Control System knobs. These have an 'auto' option, so some logic further ahead is
        # required to handle that.
        var wingicesetting =
            getprop("/controls/ice/wing/anti-ice-setting")
            * !getprop("/controls/ice/wing/failed")
            * !!(getprop("/systems/electrical/left-bus") or getprop("/systems/electrical/right-bus"));

        var eng1icesetting =
            getprop("/controls/ice/eng1/anti-ice-setting")
            * !getprop("/controls/ice/eng1/failed")
            * (getprop("/engines/engine[0]/n1") >= 30.0);
        var eng2icesetting =
            getprop("/controls/ice/eng2/anti-ice-setting")
            * !getprop("/controls/ice/eng2/failed")
            * (getprop("/engines/engine[1]/n1") >= 30.0);

        # Windscreen primary heaters
        setprop(
            "/controls/ice/windscreen/anti-ice",
            getprop("/controls/ice/windscreen/primary")
            * !getprop("/controls/ice/windscreen/primary-failed")
            * !!(getprop("/systems/electrical/left-bus") or getprop("/systems/electrical/right-bus"))
        );

        # Windscreen backup heaters
        setprop(
            "/controls/ice/windscreen/anti-ice-backup",
            getprop("/controls/ice/windscreen/backup")
            * !getprop("/controls/ice/windscreen/backup-failed")
            * getprop("/controls/ice/windscreen/primary-failed")
            * !!(getprop("/systems/electrical/left-bus") or getprop("/systems/electrical/right-bus"))
        );

        # Probe heaters
        setprop(
            "/controls/ice/probes/anti-ice",
            !(getprop("/engines/engine[0]/cutoff") or getprop("/engines/engine[1]/cutoff"))
            * !getprop("/controls/ice/probes/failed")
            * !!(getprop("/systems/electrical/left-bus") or getprop("/systems/electrical/right-bus"))
        );

        # Determine if we're on icing conditions and their severity
        ###########################################################

        var rain = getprop("/environment/rain-norm");
        var raining = 0;
        if (rain != nil)
            raining = rain;
        else
            rain = 0;

        var snow = getprop("/environment/snow-norm");
        var snowing = 0;
        if (snow != nil)
            snowing = snow;
        else
            snow = 0;

        var clouds = 0;
        var cloud_severity = 0;
        for (i = 0; i < 5; i = i + 1) {
            # Scan each cloud layer to determine if we're in or near clouds.
            var coverage = getprop("/environment/clouds/layer["~ i ~"]/coverage");

            var pos = getprop("/position/altitude-ft");

            var under = getprop("/environment/clouds/layer["~ i ~"]/elevation-ft")
                - getprop("/environment/clouds/layer["~ i ~"]/thickness-ft");
            var above = getprop("/environment/clouds/layer["~ i ~"]/elevation-ft")
                + getprop("/environment/clouds/layer["~ i ~"]/thickness-ft");

            cloud_severity = 0;
            if (pos > under or pos < above)
                if (coverage == "few")
                    cloud_severity = 0.25;
                elsif (coverage == "scattered")
                    cloud_severity = 0.5;
                elsif (coverage == "broken")
                    cloud_severity = 0.75;
                else # overcast
                    cloud_severity = 1.0;

            if (pos > under - 1500 or pos < above + 1500) {
                clouds = 1;
                break;
            }
        }

        var visibility = getprop("/environment/ground-visibility-m");
        var too_foggy = visibility <= 1600;
        var fog_severity = 1 - visibility / 1600;
        fog_severity = math.clamp(fog_severity, 0, 1);

        var icing_conditions = tat < 10 and (raining or snowing or clouds or too_foggy);

        var icing_severity = rain;
        icing_severity += snow * 2;
        icing_severity += cloud_severity;
        icing_severity += fog_severity;

        if (icing_severity > 1)
            icing_severity = 1;

        # Control activation of heating elements
        ########################################

        # Wing heaters
        if (wingicesetting == 0)
            setprop("/controls/ice/wing/anti-ice", 0);
        elsif (wingicesetting == 1)
            setprop("/controls/ice/wing/anti-ice", icing_conditions);
        else
            setprop("/controls/ice/wing/anti-ice", 1);

        # Engine 1 heaters
        if (eng1icesetting == 0)
            setprop("/controls/ice/eng1/anti-ice", 0);
        elsif (eng1icesetting == 1)
            setprop("/controls/ice/eng1/anti-ice", icing_conditions);
        else
            setprop("/controls/ice/eng1/anti-ice", 1);

        # Engine 2 heaters
        if (eng2icesetting == 0)
            setprop("/controls/ice/eng2/anti-ice", 0);
        elsif (eng2icesetting == 1)
            setprop("/controls/ice/eng2/anti-ice", icing_conditions);
        else
            setprop("/controls/ice/eng2/anti-ice", 1);

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
        # part_temp += me.UPDATE_INTERVAL * (me.UPDATE_INTERVAL * (tat - part_temp) * part_surface_area * 100) / mass / specific_heat_capacity_of_material;

        wing_temp      += me.UPDATE_INTERVAL * (me.UPDATE_INTERVAL * (tat - wing_temp     ) * 14.887 * 100) / 850 / 897;
        eng1_temp      += me.UPDATE_INTERVAL * (me.UPDATE_INTERVAL * (tat - eng1_temp     ) * 13.603 * 100) / 367 / 897;
        eng2_temp      += me.UPDATE_INTERVAL * (me.UPDATE_INTERVAL * (tat - eng2_temp     ) * 13.603 * 100) / 367 / 897;
        wscreen_c_temp += me.UPDATE_INTERVAL * (me.UPDATE_INTERVAL * (tat - wscreen_c_temp) * 1.564  * 100) / 119 / 753;
        wscreen_s_temp += me.UPDATE_INTERVAL * (me.UPDATE_INTERVAL * (tat - wscreen_s_temp) * 1.622  * 100) / 123 / 753;
        probes_temp    += me.UPDATE_INTERVAL * (me.UPDATE_INTERVAL * (tat - probes_temp   ) * 0.1    * 100) / 10  / 897;

        # For the effect of the heating elements, all parts use the following formula:
        #part_temp += me.UPDATE_INTERVAL * (heating_power * me.UPDATE_INTERVAL) * mass * specific_heat_capacity_of_material;

        # Wing heaters
        #=============
        if (getprop("/controls/ice/wing/anti-ice") == 1 and wing_temp < 15.0 )
            wing_temp += me.UPDATE_INTERVAL * (48000 * me.UPDATE_INTERVAL) / 850 / 897;

        # Handle wing heater failure alert
        if (getprop("/controls/ice/wing/failed") == 1 and me.failwarn_wing == 0)
            sysinfo.log_msg("[HEAT] Wing heaters failure", 1);
        me.failwarn_wing = getprop("/controls/ice/wing/failed");

        # Engine 1 heaters
        #=================
        if (getprop("/controls/ice/eng1/anti-ice") == 1 and eng1_temp < 35.0)
            eng1_temp += me.UPDATE_INTERVAL * (72000 * me.UPDATE_INTERVAL) / 367 / 897;

        # Handle engine 1 heater failure alert
        if (getprop("/controls/ice/eng1/failed") == 1 and me.failwarn_eng1 == 0)
            sysinfo.log_msg("[HEAT] Engine 1 heater failure", 1);
        me.failwarn_eng1 = getprop("/controls/ice/eng1/failed");

        # Engine 2 heaters
        #=================
        if (getprop("/controls/ice/eng2/anti-ice") == 1 and eng2_temp < 35.0)
            eng2_temp += me.UPDATE_INTERVAL * (72000 * me.UPDATE_INTERVAL) / 367 / 897;

        # Handle engine 2 heater failure alert
        if (getprop("/controls/ice/eng2/failed") == 1 and me.failwarn_eng2 == 0)
            sysinfo.log_msg("[HEAT] Engine 2 heater failure", 1);
        me.failwarn_eng2 = getprop("/controls/ice/eng2/failed");

        # Windscreen primary & secondary heaters
        #=======================================
        if (getprop("/controls/ice/windscreen/anti-ice") == 1) {
            if (wscreen_c_temp < 15.0)
                wscreen_c_temp += me.UPDATE_INTERVAL * (5100 * me.UPDATE_INTERVAL) / 119 / 753;

            if (wscreen_s_temp < 15.0)
                wscreen_s_temp += me.UPDATE_INTERVAL * (5300 * me.UPDATE_INTERVAL) / 123 / 753;
        }

        if (getprop("/controls/ice/windscreen/anti-ice-backup") == 1 and wscreen_c_temp < 15)
            wscreen_c_temp += me.UPDATE_INTERVAL * (5100 * me.UPDATE_INTERVAL) / 119 / 753;

        # Handle windscreen heaters failure alert
        # Primary
        if (getprop("/controls/ice/windscreen/primary-failed") == 1 and me.failwarn_wscreen_p == 0)
            sysinfo.log_msg("[HEAT] Primary windscreen heaters failure", 1);
        me.failwarn_wscreen_p = getprop("/controls/ice/windscreen/primary-failed");
        # Backup
        if (getprop("/controls/ice/windscreen/backup-failed") == 1 and me.failwarn_wscreen_b == 0)
            sysinfo.log_msg("[HEAT] Backup windscreen heaters failure", 1);
        me.failwarn_wscreen_b = getprop("/controls/ice/windscreen/backup-failed");

        # Probe heaters
        #==============
        if (getprop("/controls/ice/probes/anti-ice") == 1 and probes_temp < 15.0)
            probes_temp += me.UPDATE_INTERVAL * (350 * me.UPDATE_INTERVAL) * 10 * 897;

        # Handle probes heaters failure alert
        if (getprop("/controls/ice/probes/failed") == 1 and me.failwarn_probes == 0)
            sysinfo.log_msg("[HEAT] Probe heaters failure", 1);
        me.failwarn_probes = getprop("/controls/ice/probes/failed");

        # Export temperatures
        #####################

        setprop("/controls/ice/wing/temp", wing_temp);
        setprop("/controls/ice/eng1/temp", eng1_temp);
        setprop("/controls/ice/eng2/temp", eng2_temp);
        setprop("/controls/ice/windscreen/center_temp", wscreen_c_temp);
        setprop("/controls/ice/windscreen/sides_temp", wscreen_s_temp);
        setprop("/controls/ice/probes/temp", probes_temp);

        # Calculate icing severity on each part
        #######################################

        if (wscreen_c_temp <= 0)
            me.wscreen_c_icing += (icing_severity) / 120 * me.UPDATE_INTERVAL;
        else
            me.wscreen_c_icing -= (wscreen_c_temp) / 120 * me.UPDATE_INTERVAL;
        me.wscreen_c_icing = math.clamp(me.wscreen_c_icing, 0, 1);

        if (probes_temp <= 0)
            me.probes_icing += (icing_severity) / 120 * me.UPDATE_INTERVAL;
        else
            me.probes_icing -= (probes_temp) / 120 * me.UPDATE_INTERVAL;
        me.probes_icing = math.clamp(me.probes_icing, 0, 1);

        if (eng1_temp <= 0)
            me.eng1_icing += (icing_severity) / 120 * me.UPDATE_INTERVAL;
        else
            me.eng1_icing -= (eng1_temp) / 120 * me.UPDATE_INTERVAL;
        me.eng1_icing = math.clamp(me.eng1_icing, 0, 1);

        if (eng2_temp <= 0)
            me.eng2_icing += (icing_severity) / 120 * me.UPDATE_INTERVAL;
        else
            me.eng2_icing -= (eng2_temp) / 120 * me.UPDATE_INTERVAL;
        me.eng2_icing = math.clamp(me.eng2_icing, 0, 1);

        if (wing_temp <= 0)
            me.wing_icing += (icing_severity) / 120 * me.UPDATE_INTERVAL;
        else
            me.wing_icing -= (wing_temp) / 120 * me.UPDATE_INTERVAL;
        me.wing_icing = math.clamp(me.wing_icing, 0, 1);

        # Export icing
        setprop("/controls/ice/wing/icing", me.wing_icing);
        setprop("/controls/ice/eng1/icing", me.eng1_icing);
        setprop("/controls/ice/eng2/icing", me.eng2_icing);
        setprop("/controls/ice/windscreen/center_icing", me.wscreen_c_icing);
        setprop("/controls/ice/probes/icing", me.probes_icing);

        # Alert pilot of icing
        ######################

        # Handle wing icing alert
        if ((me.wing_icing <= 0.05) and (me.icewarnw == 0)) {
            screen.log.write("Wing Ice Alert!", 1, 0, 0);
            sysinfo.log_msg("[HEAT] Ice Detected on Wings", 1);
            me.icewarnw = 1;
        }
        if ((me.wing_icing > 0.05) and (me.icewarnw == 1))
            me.icewarnw = 0;

        # Handle eng1 icing alert
        if ((me.eng1_icing <= 0.05) and (me.icewarne1 == 0)) {
            screen.log.write("Engine 1 Ice Alert!", 1, 0, 0);
            sysinfo.log_msg("[HEAT] Ice Detected on Engine 1", 1);
            me.icewarne1 = 1
        }
        if ((me.eng1_icing > 0.05) and (me.icewarne1 == 1))
            me.icewarne1 = 0;

        # Handle eng2 icing alert
        if ((me.eng2_icing <= 0.05) and (me.icewarne1 == 0)) {
            screen.log.write("Engine 2 Ice Alert!", 1, 0, 0);
            sysinfo.log_msg("[HEAT] Ice Detected on Engine 2", 1);
            me.icewarne2 = 1
        }
        if ((me.eng2_icing > 0.05) and (me.icewarne1 == 1))
            me.icewarne2 = 0;

        # Handle windscreen ice alert
        if ((me.wscreen_c_icing <= 0.05) and (me.icewarn_windscreen == 0)) {
            screen.log.write("Windscreen Ice Alert!", 1, 0, 0);
            sysinfo.log_msg("[HEAT] Ice detected on Windscreen", 1);
            me.icewarn_windscreen = 1;
        }
        if ((me.wscreen_c_icing > 0.05) and (me.icewarn_windscreen == 1))
            me.icewarn_windscreen = 0;

        # Handle probes ice alert
        if ((me.probes_icing <= 0.05) and (me.icewarn_probes == 0)) {
            screen.log.write("Pitot & AoA probes Ice Alert!", 1, 0, 0);
            sysinfo.log_msg("[HEAT] Ice detected on pitot & AoA probes", 1);
            me.icewarn_probes = 1;
        }
        if ((me.probes_icing > 0.05) and (me.icewarn_probes == 1))
            me.icewarn_probes = 0;

        # Create consequences for icing
        ###############################

        # Windscreen ice and fog.
        setprop("/environment/aircraft-effects/fog-level", me.wscreen_c_icing);
        setprop("/environment/aircraft-effects/frost-level", me.wscreen_c_icing);

        # Probes? (Not implemented yet)

        # Set Engine Failures in case of Heavy Ice.
        if (me.eng1_icing >= 0.95)
            setprop("/controls/engines/engine/cutoff", 1);

        if (me.eng2_icing <= 0.95)
            setprop("/controls/engines/engine[1]/cutoff", 1);

        # Set Wing Lift and Drag Coefficients according to icing.
        setprop("/controls/ice/wing/lift-coefficient", 1 + me.wing_icing / -2);
        setprop("/controls/ice/wing/drag-coefficient", 1 + me.wing_icing / 2);
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
