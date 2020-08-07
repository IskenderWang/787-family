    var tcas = {
       init : func {
            me.UPDATE_INTERVAL = 0.05;
            me.loopid = 0;
            
            setprop("/instrumentation/ndfull/range", 32);
            
            me.reset();
    },
       update : func {

	var altitude = getprop("/position/altitude-ft");

    var pos_lat = getprop("/position/latitude-deg");
    var pos_lon = getprop("/position/longitude-deg");

	var range = getprop("/instrumentation/ndfull/range");
	
	# Multiplayer TCAS
	
	for (var n = 0; n < 30; n += 1) {
	
		if (getprop("ai/models/multiplayer[" ~ n ~ "]/valid") and (getprop("ai/models/multiplayer[" ~ n ~ "]/callsign") != nil)) {
		
			var mp_lat = getprop("ai/models/multiplayer[" ~ n ~ "]/position/latitude-deg");
			var mp_lon = getprop("ai/models/multiplayer[" ~ n ~ "]/position/longitude-deg");
			var x_dist = (mp_lon - pos_lon) * 60;
			var y_dist = (mp_lat - pos_lat) * 60;
			
			var distance =  math.sqrt((x_dist*x_dist) + (y_dist*y_dist));
			
			setprop("instrumentation/mptcas/mp[" ~ n ~ "]/distance-nm", distance);
			
			setprop("instrumentation/mptcas/mp[" ~ n ~ "]/bearing-defl",Deflection((57.2957795 * math.atan2(x_dist, y_dist)), 60));

			setprop("instrumentation/mptcas/mp[" ~ n ~ "]/bearing-deg" ,(57.2957795 * math.atan2(x_dist, y_dist)));
			
			var vsfps = getprop("ai/models/multiplayer[" ~ n ~ "]/velocities/vertical-speed-fps");
			
			var altitudediff = getprop("ai/models/multiplayer[" ~ n ~ "]/position/altitude-ft") - altitude;
			
			## The new NDs only use planar calculations
			
			setprop("instrumentation/mptcas/mp[" ~ n ~ "]/xoffset", (mp_lon - pos_lon) * 60 / range);
			setprop("instrumentation/mptcas/mp[" ~ n ~ "]/yoffset", (mp_lat - pos_lat) * 60 / range);
			
			setprop("instrumentation/mptcas/mp[" ~ n ~ "]/callsign", getprop("ai/models/multiplayer[" ~ n ~ "]/callsign"));
			
			setprop("instrumentation/mptcas/mp[" ~ n ~ "]/altitude-ft", getprop("ai/models/multiplayer[" ~ n ~ "]/position/altitude-ft"));
			
			setprop("instrumentation/mptcas/mp[" ~ n ~ "]/tas-kt", getprop("ai/models/multiplayer[" ~ n ~ "]/velocities/true-airspeed-kt"));
			
			
			if (vsfps < -8)
				setprop("instrumentation/mptcas/mp[" ~ n ~ "]/phase", "descend");
			elsif (vsfps >= 8)
				setprop("instrumentation/mptcas/mp[" ~ n ~ "]/phase", "climb");
			else
				setprop("instrumentation/mptcas/mp[" ~ n ~ "]/phase", "level");
				
			if ((distance <= 3) and (altitudediff <= 1000))
				setprop("instrumentation/mptcas/mp[" ~ n ~ "]/color", "red");
			elsif ((distance <= 5) and (altitudediff <= 2000))
				setprop("instrumentation/mptcas/mp[" ~ n ~ "]/color", "orange");
			elsif ((distance <= 10) and (altitudediff <= 3000))
				setprop("instrumentation/mptcas/mp[" ~ n ~ "]/color", "yellow");
			else
				setprop("instrumentation/mptcas/mp[" ~ n ~ "]/color", "cyan");
			
			if (distance <= 32)
				setprop("/instrumentation/mptcas/mp[" ~ n ~ "]/show-half", 1);
			else
				setprop("/instrumentation/mptcas/mp[" ~ n ~ "]/show-half", 0);
				
			if ((math.abs((mp_lon - pos_lon) * 60) <= range) and (mp_lat - pos_lat <= range) and (pos_lat - mp_lat >= (range * -0.8)))
				setprop("/instrumentation/mptcas/mp[" ~ n ~ "]/show", 1);
			else
				setprop("/instrumentation/mptcas/mp[" ~ n ~ "]/show", 0);
				
		} else
			setprop("/instrumentation/mptcas/mp[" ~ n ~ "]/show", 0);
	
	}
	
	# AI TCAS
	
	for (var n = 0; n < 30; n += 1) {
	
		if (getprop("ai/models/aircraft[" ~ n ~ "]/valid") and (getprop("ai/models/aircraft[" ~ n ~ "]/callsign") != nil)) {
		
			var ai_lat = getprop("ai/models/aircraft[" ~ n ~ "]/position/latitude-deg");
			var ai_lon = getprop("ai/models/aircraft[" ~ n ~ "]/position/longitude-deg");
			
			var x_dist = (ai_lon - pos_lon) * 60;
			var y_dist = (ai_lat - pos_lat) * 60;
			
			var distance =  math.sqrt((x_dist*x_dist) + (y_dist*y_dist));
			
			setprop("instrumentation/mptcas/ai[" ~ n ~ "]/distance-nm", distance);
			
			var vsfps = getprop("ai/models/aircraft[" ~ n ~ "]/velocities/vertical-speed-fps");
			
			setprop("instrumentation/mptcas/ai[" ~ n ~ "]/bearing-defl",Deflection((57.2957795 * math.atan2(x_dist, y_dist)), 60));

			setprop("instrumentation/mptcas/ai[" ~ n ~ "]/bearing-deg" ,(57.2957795 * math.atan2(x_dist, y_dist)));
			
			var altitudediff = getprop("ai/models/aircraft[" ~ n ~ "]/position/altitude-ft") - altitude;
			
			## The new NDs only use planar calculations
			
			setprop("instrumentation/mptcas/ai[" ~ n ~ "]/xoffset", x_dist / range);
			setprop("instrumentation/mptcas/ai[" ~ n ~ "]/yoffset", y_dist / range);
			
			if (vsfps < -8)
				setprop("instrumentation/mptcas/ai[" ~ n ~ "]/phase", "descend");
			elsif (vsfps >= 8)
				setprop("instrumentation/mptcas/ai[" ~ n ~ "]/phase", "climb");
			else
				setprop("instrumentation/mptcas/ai[" ~ n ~ "]/phase", "level");
				
			if ((distance <= 3) and (altitudediff <= 1000))
				setprop("instrumentation/mptcas/ai[" ~ n ~ "]/color", "red");
			elsif ((distance <= 5) and (altitudediff <= 2000))
				setprop("instrumentation/mptcas/ai[" ~ n ~ "]/color", "orange");
			elsif ((distance <= 10) and (altitudediff <= 3000))
				setprop("instrumentation/mptcas/ai[" ~ n ~ "]/color", "yellow");
			else
				setprop("instrumentation/mptcas/ai[" ~ n ~ "]/color", "cyan");
				
			if ((math.abs((ai_lon - pos_lon) * 60) <= range) and (ai_lat - pos_lat <= range) and (pos_lat - ai_lat >= (range * -0.8)))
				setprop("/instrumentation/mptcas/ai[" ~ n ~ "]/show", 1);
			else
				setprop("/instrumentation/mptcas/ai[" ~ n ~ "]/show", 0);
				
			if (distance <= 32)
				setprop("/instrumentation/mptcas/ai[" ~ n ~ "]/show-half", 1);
			else
				setprop("/instrumentation/mptcas/ai[" ~ n ~ "]/show-half", 0);
				
			setprop("instrumentation/mptcas/ai[" ~ n ~ "]/callsign", getprop("ai/models/aircraft[" ~ n ~ "]/callsign"));
			
			setprop("instrumentation/mptcas/ai[" ~ n ~ "]/altitude-ft", getprop("ai/models/aircraft[" ~ n ~ "]/position/altitude-ft"));
			
			setprop("instrumentation/mptcas/ai[" ~ n ~ "]/tas-kt", getprop("ai/models/aircraft[" ~ n ~ "]/velocities/true-airspeed-kt"));
				
		} else
			setprop("/instrumentation/mptcas/ai[" ~ n ~ "]/show", 0);
	
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

setlistener("sim/signals/fdm-initialized", func
 {
 tcas.init();
 sysinfo.log_msg("[TCAS] Systems Check ..... OK", 0);
 });
