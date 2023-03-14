var fmc = {
    autogen_alts: func {
        if (getprop("/autopilot/route-manager/route/num") < 4) {
            sysinfo.log_msg("[FMC] VNAV Autogen needs at least 4 waypoints");
            return;
        }

        sysinfo.log_msg("[FMC] VNAV Altitudes Generated", 0);

        var cruise_alt = me.get_cruise_alt();

        me.fill_crs_alts(cruise_alt);
        me.gen_des_alts();
        me.gen_clb_alts(cruise_alt);
    },

    get_cruise_alt: func {
        var direction = me.get_dir();

        max_alt = 43000; # Maximum cruise altitude. (must be odd).
        min_alt = 35000; # Minimum cruise altitude. (must be odd).

        weight = getprop("/fdm/jsbsim/inertia/weight-lbs"); # Plane weight
        excess = weight - 295500; # Weight excess over the Operating Empty Weight
        offset = math.floor(excess / 36937.5, 1); # Flight Level offset based on weight

        var cruise_alt = max_alt - offset * 1000;

        if (
            ( direction == "East" and ((cruise_alt / 1000) & 1) != 1 ) or # East and is even.
            ( direction == "West" and ((cruise_alt / 1000) & 1) == 1 )    # West and is odd.
        ) {
            cruise_alt -= 1000;

            if (cruise_alt < min_alt)
                cruise_alt = min_alt + 1000;
        }

        cruise_alt = math.clamp(cruise_alt, min_alt, max_alt);

        return cruise_alt;
    },

    get_dir: func {
        # Determine direction of flight
        var direction = "";
        var start_long = getprop("/autopilot/route-manager/route/wp/longitude-deg");
        var total = getprop("/autopilot/route-manager/route/num") - 1;
        var end_long = getprop("/autopilot/route-manager/route/wp[" ~ total ~ "]/longitude-deg");

        if (end_long >= start_long)
            direction = "East";	# altitude recommendations will be rounded to nearest odd thousand
        else
            direction = "West";	# altitude recommendations will be rounded to nearest even thousand

        setprop("/instrumentation/b787-fmc/vnav-calcs/direction", direction);
        return direction;
    },

    fill_crs_alts: func(cruise_alt) {
        for (var i = 0; i < getprop("/autopilot/route-manager/route/num"); i += 1)
            setprop("/instrumentation/b787-fmc/vnav-calcs/wp["~ i ~"]/altitude", cruise_alt);
    },

    gen_des_alts: func {
        # We need the destination to be a valid airport, otherwise just cruise until the last wp.
        if (getprop("/autopilot/route-manager/destination/name") == "")
            return;

        wp_alt = getprop("/autopilot/route-manager/destination/field-elevation-ft");

        for (var i = getprop("/autopilot/route-manager/route/num") - 1; i > 0; i -= 1) {
            fmc_wp = "/instrumentation/b787-fmc/vnav-calcs/wp["~ i ~"]/";
            p = i + 1;
            wp_plus_one = "/autopilot/route-manager/route/wp["~ p ~"]/";

            # Final wp, the airport.
            if (i == (getprop("/autopilot/route-manager/route/num") - 1)) {
                setprop(fmc_wp ~ "altitude", wp_alt);
                continue;
            }

            # Create a 3° descent slope starting from the destination.
            wp_alt += (getprop(wp_plus_one ~ "leg-distance-nm") * 6076.115485564) * math.tan(3 / 57.295779513);
            wp_alt = math.round(wp_alt, 100);

            if (wp_alt > getprop(fmc_wp ~ "altitude"))
                return;

            setprop(fmc_wp ~ "altitude", wp_alt);
        }
    },

    gen_clb_alts: func(cruise_alt) {
        # We need the departure to be a valid airport, otherwise just cruise from the first wp.
        if (getprop("/autopilot/route-manager/departure/name") == "")
            return;

        wp_alt = getprop("/autopilot/route-manager/departure/field-elevation-ft");

        for (var i = 0; i < getprop("/autopilot/route-manager/route/num"); i += 1) {
            fmc_wp = "/instrumentation/b787-fmc/vnav-calcs/wp["~ i ~"]/";
            wp = "/autopilot/route-manager/route/wp["~ i ~"]/";

            # Initial wp, the airport.
            if (i == 0) {
                setprop(fmc_wp ~ "altitude", wp_alt);
                continue;
            }

            # Create a 5.5° climb slope starting from the departure.
            wp_alt += (getprop(wp ~ "leg-distance-nm") * 6076.115485564) * math.tan(5.5 / 57.295779513);
            wp_alt = math.round(wp_alt, 100);

            if (wp_alt > cruise_alt)
                return;

            if (wp_alt > getprop(fmc_wp ~ "altitude")) {
                cruise_low(i);
                return;
            }

            setprop(fmc_wp ~ "altitude", wp_alt);
        }
    },

    cruise_low: func(index) {
        fmc_wp = "/instrumentation/b787-fmc/vnav-calcs/wp["~ index ~"]/";
        p = index - 1;
        prv_wp = "/instrumentation/b787-fmc/vnav-calcs/wp["~ p ~"]/";

        var cruise_lvl = math.min(getprop(fmc_wp ~"altitude"), getprop(prv_wp ~"altitude"));

        # Floor to nearest 500 ft. (if 7900 ft, then 7500 ft)
        cruise_lvl = math.floor(cruise_lvl * 0.002) / 2000;

        setprop(fmc_wp ~"altitude", cruise_lvl);
        setprop(prv_wp ~"altitude", cruise_lvl);
    },

    copy_altitudes: func {
        for (var n = 0; n < getprop("/autopilot/route-manager/route/num"); n += 1) {
            if (getprop("/instrumentation/b787-fmc/vnav-calcs/wp[" ~ n ~ "]/altitude") != nil) {
                var vnav_altitude = getprop("/instrumentation/b787-fmc/vnav-calcs/wp[" ~ n ~ "]/altitude");

                setprop("/autopilot/route-manager/route/wp[" ~ n ~ "]/altitude-ft", vnav_altitude);
            }
        }
    },

    # End of VNAV autogen code
    ##########################

    calc_speeds: func {
        # Take-off and Approach Flap Extension Speeds

        var total_weight = getprop("/fdm/jsbsim/inertia/weight-lbs");

        ## FLAPS: 1 DEG
        setprop("/instrumentation/b787-fmc/speeds/flaps1", (2.8303320214779 * 0.0001 * total_weight) + 118.28007981769);

        ## FLAPS: 5 DEG
        setprop("/instrumentation/b787-fmc/speeds/flaps5", (2.6844176662278 * 0.0001 * total_weight) + 119.04376832572);

        ## FLAPS: 10 DEG
        setprop("/instrumentation/b787-fmc/speeds/flaps10", (2.4794813791967 * 0.0001 * total_weight) + 101.66786689933);

        ## FLAPS: 15 DEG
        setprop("/instrumentation/b787-fmc/speeds/flaps15", (2.3086744918531 * 0.0001 * total_weight) + 81.372486004066);

        ## FLAPS: 25 DEG
        setprop("/instrumentation/b787-fmc/speeds/flaps25", (2.5112138808426 * 0.0001 * total_weight) + 61.051881021611);

        ## FLAPS: 35 DEG
        setprop("/instrumentation/b787-fmc/speeds/flaps35", (1.7977818210994 * 0.0001 * total_weight) + 72.319797126439);

        # Appraoch Speed
        setprop("/instrumentation/b787-fmc/speeds/ap", (1.0044642857143 * 0.0001 * total_weight) + 101.84654017857);

        # Touchdown Speed
        setprop("/instrumentation/b787-fmc/speeds/td", (1.1160714285714 * 0.0001 * total_weight) + 85.385044642858);
    },

    parse_flightsDB: func {
        io.read_properties(getprop("/sim/aircraft-dir") ~ "/FMC-DB/FMC_Flights.xml", "/instrumentation/b787-fmc");

        sysinfo.log_msg("[FMC] Database Check ..... OK", 0);
    },

    search_flight: func(flightnum) {
        var flightsDB = "/instrumentation/b787-fmc/flightsDB/" ~ flightnum ~ "/";

        var airline = getprop("/instrumentation/b787-fmc/flightsDB/airline");

        # Check if the flight exists
        if (getprop(flightsDB ~ "depicao") != nil) {
            sysinfo.log_msg("[FMC] Found " ~ airline ~ " Flight " ~ flightnum, 0);

            # Display Flight Data in the CDU
            setprop("/controls/cdu/display/l1", flightnum);
            setprop("/controls/cdu/display/l2", getprop(flightsDB ~ "depicao"));
            setprop("/controls/cdu/display/l3", getprop(flightsDB ~ "arricao"));
            setprop("/controls/cdu/display/l4", getprop(flightsDB ~ "reg"));
            setprop("/controls/cdu/display/l5", getprop(flightsDB ~ "flight-time"));

            # Whether route is available

            if (getprop(flightsDB ~ "route/pre") == 1)
                setprop("/controls/cdu/display/l6", "Available");
            else
                setprop("/controls/cdu/display/l6", "Unavailable");
        } else {
            setprop("/controls/cdu/display/page", "DEP/ARR");
            sysinfo.log_msg("[FMC] Flight " ~ flightnum ~ " not found!", 0);
        }
    },

    confirm_flight: func(flightnum) {
        var fmcNode = props.globals.getNode("/instrumentation/b787-fmc/");

        if (fmcNode.getChild("flightsDB") != nil) {
            var airline = getprop("/instrumentation/b787-fmc/flightsDB/airline");

            var flightsDB = "/instrumentation/b787-fmc/flightsDB/" ~ flightnum ~ "/";

            sysinfo.log_msg("[FMC] Confirmed " ~ airline ~ " Flight " ~ flightnum, 0);
        } else {
            sysinfo.log_msg("[FMC] Confirmed " ~ flightnum, 0);
            return;
        }

        # Used to clear the current route entered
        setprop("/autopilot/route-manager/input", "@CLEAR");

        if (getprop(flightsDB ~ "route/pre") == 1) {
            # Enter Route from the Database
            var n = 0;
            while(getprop(flightsDB ~ "route/wp[" ~ n ~ "]/id") != nil) {
                # If vnav is available, enter vnav altitudes too
                if (getprop(flightsDB ~ "route/vnav") == 1) {
                    setprop("/autopilot/route-manager/input", "@INSERT999:" ~ getprop(flightsDB ~ "route/wp[" ~ n ~ "]/id") ~ "@" ~ getprop(flightsDB ~ "route/wp[" ~ n ~ "]/alt"));
                } else {
                    # If not, just put in the waypoints
                    setprop("/autopilot/route-manager/input", "@INSERT999:" ~ getprop(flightsDB ~ "route/wp[" ~ n ~ "]/id"));
                }

                n += 1;
            }
        }

        # If vnav is enabled, enter crz altitude and crz wps
        if (getprop(flightsDB ~ "route/vnav") == 1) {
            setprop("/controls/cdu/vnav/crz-altitude-ft", getprop(flightsDB ~ "route/crz-altitude-ft"));
            setprop("/controls/cdu/vnav/start-crz", getprop(flightsDB ~ "route/start-crz"));
            setprop("/controls/cdu/vnav/end-crz", getprop(flightsDB ~ "route/end-crz"));
        }

        # Set Departure and Arrival Airport
        setprop("/autopilot/route-manager/departure/airport", getprop(flightsDB ~ "depicao"));
        setprop("/autopilot/route-manager/destination/airport", getprop(flightsDB ~ "arricao"));

        # If a preset route doesn't exist, generate a route
        if (getprop(flightsDB ~ "route/pre") != 1)
            setprop("/autopilot/route-manager/input", "@ROUTE1")
    }
};
