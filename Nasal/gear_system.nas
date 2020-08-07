var g_tree = "/systems/gears/";

    var gears = {
       init : func {
            me.UPDATE_INTERVAL = 0.01;
            me.loopid = 0;
            
            setprop("/controls/gear-failures/gear[0]/stuck-pos", 99);
            setprop("/controls/gear-failures/gear[1]/stuck-pos", 99);
            setprop("/controls/gear-failures/gear[2]/stuck-pos", 99);
            
            setprop("/fdm/jsbsim/gear/unit[0]/z-position", -143.36872);
            setprop("/fdm/jsbsim/gear/unit[1]/z-position", -153.63242);
            setprop("/fdm/jsbsim/gear/unit[2]/z-position", -153.63242);
            
            # 787 nose gear has no brakes
            setprop("/fdm/jsbsim/gear/unit[0]/dynamic_friction_coeff", 0.5);
            setprop("/fdm/jsbsim/gear/unit[0]/static_friction_coeff", 0.62);
            setprop("/fdm/jsbsim/gear/unit[0]/rolling_friction_coeff", 0.02);
            setprop("/fdm/jsbsim/gear/unit[0]/side_friction_coeff", 0.5);
            setprop("/fdm/jsbsim/gear/unit[0]/pos-norm", 1);
            setprop("/controls/gear-failures/gear[0]/break", 0);
            setprop("/controls/gear-failures/gear[0]/burst", 0);
	    
            setprop("/fdm/jsbsim/gear/unit[1]/dynamic_friction_coeff", 0.5);
            setprop("/fdm/jsbsim/gear/unit[1]/static_friction_coeff", 0.62);
            setprop("/fdm/jsbsim/gear/unit[1]/rolling_friction_coeff", 0.02);
            setprop("/fdm/jsbsim/gear/unit[1]/side_friction_coeff", 0.5);
            setprop("/fdm/jsbsim/gear/unit[1]/pos-norm", 1);
            setprop("/controls/gear-failures/gear[1]/break", 0);
            setprop("/controls/gear-failures/gear[1]/burst", 0);
            
            setprop("/fdm/jsbsim/gear/unit[2]/dynamic_friction_coeff", 0.5);
            setprop("/fdm/jsbsim/gear/unit[2]/static_friction_coeff", 0.62);
            setprop("/fdm/jsbsim/gear/unit[2]/rolling_friction_coeff", 0.02);
            setprop("/fdm/jsbsim/gear/unit[2]/side_friction_coeff", 0.5);
            setprop("/fdm/jsbsim/gear/unit[2]/pos-norm", 1);
            setprop("/controls/gear-failures/gear[2]/break", 0);
            setprop("/controls/gear-failures/gear[2]/burst", 0);

            me.reset();
    },
       update : func {

		for (var n = 0; n < 3; n += 1) {

			# Gear failures are based on airspeed, compression-ft and wow
			
			## Airspeed based failures
		
			### Gear gets stuck if airspeed exceeds 270 knots and gears are down
		
			if ((getprop("/gear/gear[" ~ n ~ "]/position-norm") != 0) and (getprop("/velocities/airspeed-kt") >= 270) and (getprop("/controls/gear-failures/gear[" ~ n ~ "]/stuck-pos") == 99))
				setprop("/controls/gear-failures/gear[" ~ n ~ "]/stuck-pos", getprop("/gear/gear[" ~ n ~ "]/position-norm"));
			
			if (getprop("/controls/gear-failures/gear[" ~ n ~ "]/stuck-pos") != 99)
				me.stuck(n, getprop("/controls/gear-failures/gear[" ~ n ~ "]/stuck-pos"));
				
			### Gear breaks off if airspeed exceeds 330 knots and gears are down
			
			if ((getprop("/gear/gear[" ~ n ~ "]/position-norm") != 0) and (getprop("/velocities/airspeed-kt") >= 330))
				setprop("/controls/gear-failures/gear[" ~ n ~ "]/break", 1);
				
			## Compression based failures
			
			### Burst tires if compression exceeds 1.5 (wow, that's a hard landing!)
			
			if (getprop("/fdm/jsbsim/gear/unit[" ~ n ~ "]/compression-ft") >= 1.8)
				setprop("/controls/gear-failures/gear[" ~ n ~ "]/burst", 1);
			
			### Break off if compression exceeds 2.2 (DUDE, THAT'S LIKE A CRASH!)
			
			if (getprop("/fdm/jsbsim/gear/unit[" ~ n ~ "]/compression-ft") >= 3)
				setprop("/controls/gear-failures/gear[" ~ n ~ "]/break", 1);
				
			## Wow and Speed based failures
			
			### Burst the tires if you're on ground faster than 220 Knots
			
			if (getprop("/fdm/jsbsim/gear/unit[" ~ n ~ "]/wow") and (getprop("/velocities/airspeed-kt") >= 220))
				setprop("/controls/gear-failures/gear[" ~ n ~ "]/burst", 1);	
				
			# Call the Break and Burst Functions
			
			if (getprop("/controls/gear-failures/gear[" ~ n ~ "]/break") == 1)
				me.break_off(n);
				
			if (getprop("/controls/gear-failures/gear[" ~ n ~ "]/burst") == 1)
				me.burst(n);
		
		}

    },
    
    	# Gear Specific Functions
    	
    	stuck : func(gear_unit, stuck_pos) {
    	
    	# Keep the gear unit at the given position
    	
    	setprop("/fdm/jsbsim/gear/unit[" ~ gear_unit ~ "]/pos-norm", stuck_pos);
    	
    },
    	break_off : func(gear_unit) {
    	
    	# Oooh, this is bad... Set Gear positions to 0, they're not there dude!
    	
    	setprop("/fdm/jsbsim/gear/unit[" ~ gear_unit ~ "]/pos-norm", 0);
    	
    	setprop("/fdm/jsbsim/gear/unit[" ~ gear_unit ~ "]/z-position", -50);
    	
    	me.burst(gear_unit);
    	
    },
    	burst : func(gear_unit) {
    	
    	# This gear has no tires now! Assuming a medium friction coefficient 
    	# (e.g. steel on concrete)
    	
    	setprop("/fdm/jsbsim/gear/unit[" ~ gear_unit ~ "]/dynamic_friction_coeff", 0.4);
    	setprop("/fdm/jsbsim/gear/unit[" ~ gear_unit ~ "]/static_friction_coeff", 0.5);
    	setprop("/fdm/jsbsim/gear/unit[" ~ gear_unit ~ "]/rolling_friction_coeff", 0.4);
    	setprop("/fdm/jsbsim/gear/unit[" ~ gear_unit ~ "]/side_friction_coeff", 0.4);
    	
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
 gears.init();
 print("Gear System ......... Initialized");
 sysinfo.log_msg("[GEAR] Systems Check ..... OK", 0);
 });
