var fmc = {
	autogen_alts: func {
	
		sysinfo.log_msg("[FMC] VNAV Altitudes Generated", 0);
		
		# This function is used to generate altitude recommendations for each waypoint.
		# This single function calls the functions autogen_climb_alts and autogen_descent_alts.
		# Those functions make calls to all other functions down to line 278.
		# You MUST search your destination in the EFB and caliberate the altimeter BEFORE running this.
		me.autogen_climb_alts();
		me.autogen_descent_alts();
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
	get_end_crz: func {
		var tod_wp = 0;
		var descent_distance = 0;
		for (var y = getprop("/autopilot/route-manager/route/num") - 2; y > 0; y -= 1){
			if (descent_distance < 124){
				descent_distance += getprop("/autopilot/route-manager/route/wp["~ y ~"]/leg-distance-nm");
				tod_wp = y;
			}
			else
				y = -1;
		}
		return tod_wp;
	},
	get_climb_vs: func(altitude) {
		var vs_climb = 0;
		if (altitude < 10000)
			vs_climb = 2750;
		elsif ((altitude >= 10000) and (altitude < 30000))
			vs_climb = 2250;
		else
			vs_climb = 1000;
		return vs_climb;
	},
	autogen_climb_alts: func {
		setprop("/instrumentation/b787-fmc/vnav-calcs/wp/altitude", getprop("/instrumentation/altimeter/indicated-altitude-ft"));
		var index = 0;
		var altitude = 1;
		var distance = 0;
		var factor = 0;
		var climb_gs = 0;
		var target_altitude = 1;
		var tod_wp = me.get_end_crz();
		var direction = me.get_dir();
		for (var x = 1; x < tod_wp; x += 1){
			index=(x - 1);
			altitude = getprop("/instrumentation/b787-fmc/vnav-calcs/wp["~ index ~"]/altitude");
			distance = getprop("/autopilot/route-manager/route/wp["~ index ~"]/leg-distance-nm");
			factor = math.ln(altitude);
			climb_gs = -314.287 + (75.242 *  factor);
			if (climb_gs < 310)
				climb_gs = 310;
			setprop("/instrumentation/b787-fmc/vnav-calcs/wp["~ x ~"]/climb-gs", climb_gs);
			setprop("/instrumentation/b787-fmc/vnav-calcs/wp["~ x ~"]/vs-climb", me.get_climb_vs(altitude));
			setprop("/instrumentation/b787-fmc/vnav-calcs/wp["~ x ~"]/distance", distance);
			target_altitude = me.get_climb_vs(altitude) * (60 * distance / climb_gs) + altitude;
			setprop("/instrumentation/b787-fmc/vnav-calcs/wp["~ x ~"]/altitude", me.round_climb_alts(target_altitude, direction));
		}
	},
	round_climb_alts: func(target_altitude, direction) {
		if (direction == "East"){
			if (target_altitude < 2000)
				target_altitude = 1000;
			elsif ((target_altitude >= 2000) and (target_altitude < 4000))
				target_altitude = 3000;
			elsif ((target_altitude >= 4000) and (target_altitude < 6000))
				target_altitude = 5000;
			elsif ((target_altitude >= 6000) and (target_altitude < 8000))
				target_altitude = 7000;
			elsif ((target_altitude >= 8000) and (target_altitude < 10000))
				target_altitude = 9000;
			elsif ((target_altitude >= 10000) and (target_altitude < 12000))
				target_altitude = 11000;
			elsif ((target_altitude >= 12000) and (target_altitude < 14000))
				target_altitude = 13000;
			elsif ((target_altitude >= 14000) and (target_altitude < 16000))
				target_altitude = 15000;
			elsif ((target_altitude >= 16000) and (target_altitude < 18000))
				target_altitude = 17000;
			elsif ((target_altitude >= 18000) and (target_altitude < 20000))
				target_altitude = 19000;
			elsif ((target_altitude >= 20000) and (target_altitude < 22000))
				target_altitude = 21000;
			elsif ((target_altitude >= 22000) and (target_altitude < 24000))
				target_altitude = 23000;
			elsif ((target_altitude >= 24000) and (target_altitude < 26000))
				target_altitude = 25000;
			elsif ((target_altitude >= 26000) and (target_altitude < 28000))
				target_altitude = 27000;
			elsif ((target_altitude >= 28000) and (target_altitude < 30000))
				target_altitude = 29000;
			elsif ((target_altitude >= 30000) and (target_altitude < 32000))
				target_altitude = 31000;
			elsif ((target_altitude >= 32000) and (target_altitude < 34000))
				target_altitude = 33000;
			elsif ((target_altitude >= 34000) and (target_altitude < 36000))
				target_altitude = 35000;
			elsif ((target_altitude >= 36000) and (target_altitude < 38000))
				target_altitude = 37000;
			elsif ((target_altitude >= 38000) and (target_altitude < 40000))
				target_altitude = 39000;
			else
				target_altitude = 41000;
		}
		else{
			if (target_altitude < 3000)
				target_altitude = 2000;
			elsif ((target_altitude >= 3000) and (target_altitude < 5000))
				target_altitude = 4000;
			elsif ((target_altitude >= 5000) and (target_altitude < 7000))
				target_altitude = 6000;
			elsif ((target_altitude >= 7000) and (target_altitude < 9000))
				target_altitude = 8000;
			elsif ((target_altitude >= 9000) and (target_altitude < 11000))
				target_altitude = 10000;
			elsif ((target_altitude >= 11000) and (target_altitude < 13000))
				target_altitude = 12000;
			elsif ((target_altitude >= 13000) and (target_altitude < 15000))
				target_altitude = 14000;
			elsif ((target_altitude >= 15000) and (target_altitude < 17000))
				target_altitude = 16000;
			elsif ((target_altitude >= 17000) and (target_altitude < 19000))
				target_altitude = 18000;
			elsif ((target_altitude >= 19000) and (target_altitude < 21000))
				target_altitude = 20000;
			elsif ((target_altitude >= 21000) and (target_altitude < 23000))
				target_altitude = 22000;
			elsif ((target_altitude >= 23000) and (target_altitude < 25000))
				target_altitude = 24000;
			elsif ((target_altitude >= 25000) and (target_altitude < 27000))
				target_altitude = 26000;
			elsif ((target_altitude >= 27000) and (target_altitude < 29000))
				target_altitude = 28000;
			elsif ((target_altitude >= 29000) and (target_altitude < 31000))
				target_altitude = 30000;
			elsif ((target_altitude >= 31000) and (target_altitude < 33000))
				target_altitude = 32000;
			elsif ((target_altitude >= 33000) and (target_altitude < 35000))
				target_altitude = 34000;
			elsif ((target_altitude >= 35000) and (target_altitude < 37000))
				target_altitude = 36000;
			elsif ((target_altitude >= 37000) and (target_altitude < 39000))
				target_altitude = 38000;
			else
				target_altitude = 40000;
		}
		return target_altitude;
	},
	get_descent_vs: func(descent_gs, altitude, index, elevation) {
		var vs_descent = descent_gs * (1/60) * ((-1 * (altitude - elevation)) / me.get_descent_distance(index));
		return vs_descent;
	},
	get_descent_distance: func(index) {
		var descent_distance = 0;
		for (var y = getprop("/autopilot/route-manager/route/num") - 2; y >= index; y -= 1){
			descent_distance += getprop("/autopilot/route-manager/route/wp["~ y ~"]/leg-distance-nm");
		}
		setprop("/instrumentation/b787-fmc/vnav-calcs/wp["~ (index + 1) ~"]/descent_distance", descent_distance);
		return descent_distance;
	},
	autogen_descent_alts: func {
		var index = 0;
		var distance = 0;
		var altitude = 1;
		var vs_descent = 0;
		var descent_gs = 0;
		var target_altitude = 1;
		var tod_wp = me.get_end_crz();
		var direction = me.get_dir();
		setprop("/instrumentation/gps/scratch/query", getprop("/autopilot/route-manager/destination/airport"));
		setprop("/instrumentation/gps/scratch/type", "airport");
		var elevation = getprop("/instrumentation/gps/scratch/altitude-ft");
		for (var z = tod_wp; z < getprop("/autopilot/route-manager/route/num"); z += 1){
			index = (z - 1);
			distance = getprop("/autopilot/route-manager/route/wp["~ index ~"]/leg-distance-nm");
			altitude = getprop("/instrumentation/b787-fmc/vnav-calcs/wp["~ index ~"]/altitude");
			descent_gs = -1.682 * math.pow(10, -7) * math.pow(altitude, 2) + 0.017 * altitude + 51.385;
			vs_descent = me.get_descent_vs(descent_gs, altitude, index, elevation);
			target_altitude = altitude + (vs_descent * (60 * distance) / descent_gs);
			setprop("/instrumentation/b787-fmc/vnav-calcs/wp["~ z ~"]/descent-gs", descent_gs);
			setprop("/instrumentation/b787-fmc/vnav-calcs/wp["~ z ~"]/vs-descent", vs_descent);
			setprop("/instrumentation/b787-fmc/vnav-calcs/wp["~ z ~"]/distance", distance);
			setprop("/instrumentation/b787-fmc/vnav-calcs/wp["~ z ~"]/altitude", me.round_descent_alts(target_altitude, direction));
		}
	},
	round_descent_alts: func(target_altitude, direction) {
		if (direction == "East"){
			if (target_altitude >= 38000)
				target_altitude = 39000;
			elsif ((target_altitude >= 36000) and (target_altitude < 38000))
				target_altitude = 37000;
			elsif ((target_altitude >= 34000) and (target_altitude < 36000))
				target_altitude = 35000;
			elsif ((target_altitude >= 32000) and (target_altitude < 34000))
				target_altitude = 33000;
			elsif ((target_altitude >= 30000) and (target_altitude < 32000))
				target_altitude = 31000;
			elsif ((target_altitude >= 28000) and (target_altitude < 30000))
				target_altitude = 29000;
			elsif ((target_altitude >= 26000) and (target_altitude < 28000))
				target_altitude = 27000;
			elsif ((target_altitude >= 24000) and (target_altitude < 26000))
				target_altitude = 25000;
			elsif ((target_altitude >= 22000) and (target_altitude < 24000))
				target_altitude = 23000;
			elsif ((target_altitude >= 20000) and (target_altitude < 22000))
				target_altitude = 21000;
			elsif ((target_altitude >= 18000) and (target_altitude < 20000))
				target_altitude = 19000;
			elsif ((target_altitude >= 16000) and (target_altitude < 18000))
				target_altitude = 17000;
			elsif ((target_altitude >= 14000) and (target_altitude < 16000))
				target_altitude = 15000;
			elsif ((target_altitude >= 12000) and (target_altitude < 14000))
				target_altitude = 13000;
			elsif ((target_altitude >= 10000) and (target_altitude < 12000))
				target_altitude = 11000;
			elsif ((target_altitude >= 8000) and (target_altitude < 10000))
				target_altitude = 19000;
			elsif ((target_altitude >= 6000) and (target_altitude < 8000))
				target_altitude = 7000;
			elsif ((target_altitude >= 4000) and (target_altitude < 6000))
				target_altitude = 5000;
			elsif ((target_altitude >= 2000) and (target_altitude < 4000))
				target_altitude = 3000;
			else
				target_altitude = 1000;
		}
		else{
			if (target_altitude >= 37000)
				target_altitude = 38000;
			elsif ((target_altitude >= 35000) and (target_altitude < 37000))
				target_altitude = 36000;
			elsif ((target_altitude >= 33000) and (target_altitude < 35000))
				target_altitude = 34000;
			elsif ((target_altitude >= 31000) and (target_altitude < 33000))
				target_altitude = 32000;
			elsif ((target_altitude >= 29000) and (target_altitude < 31000))
				target_altitude = 30000;
			elsif ((target_altitude >= 27000) and (target_altitude < 29000))
				target_altitude = 30000;
			elsif ((target_altitude >= 25000) and (target_altitude < 27000))
				target_altitude = 26000;
			elsif ((target_altitude >= 23000) and (target_altitude < 25000))
				target_altitude = 24000;
			elsif ((target_altitude >= 21000) and (target_altitude < 23000))
				target_altitude = 22000;
			elsif ((target_altitude >= 19000) and (target_altitude < 21000))
				target_altitude = 20000;
			elsif ((target_altitude >= 17000) and (target_altitude < 19000))
				target_altitude = 18000;
			elsif ((target_altitude >= 15000) and (target_altitude < 17000))
				target_altitude = 16000;
			elsif ((target_altitude >= 13000) and (target_altitude < 15000))
				target_altitude = 14000;
			elsif ((target_altitude >= 11000) and (target_altitude < 13000))
				target_altitude = 12000;
			elsif ((target_altitude >= 9000) and (target_altitude < 11000))
				target_altitude = 10000;
			elsif ((target_altitude >= 7000) and (target_altitude < 9000))
				target_altitude = 8000;
			elsif ((target_altitude >= 5000) and (target_altitude < 7000))
				target_altitude = 6000;
			elsif ((target_altitude >= 3000) and (target_altitude < 5000))
				target_altitude = 4000;
			else
				target_altitude = 2000;
		}
		return target_altitude;
	},
	
	copy_altitudes: func {
	
		for (var n = 0; n < getprop("/autopilot/route-manager/route/num"); n += 1) {
		
			if (getprop("/instrumentation/b787-fmc/vnav-calcs/wp[" ~ n ~ "]/altitude") != nil) {
				var vnav_altitude = getprop("/instrumentation/b787-fmc/vnav-calcs/wp[" ~ n ~ "]/altitude");
				
				setprop("/autopilot/route-manager/route/wp[" ~ n ~ "]/altitude-ft", vnav_altitude);
				
				}
		
		}
	
	},
	
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
			
			if (getprop(flightsDB ~ "route/pre") == 1) {
				setprop("/controls/cdu/display/l6", "Available");
			} else {
				setprop("/controls/cdu/display/l6", "Unavailable");
			}	

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
				
				} else { # If not, just put in the waypoints
			
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
