################################################################################
#
# Boeing Vertical Situation Display
#-------------------------------------------------------------------------------
#
# VSD FUNCTIONS:
#
#	> draw_terrain
#		> angle - returns angle of terrain line
#		> length - returns length of terrain line
#		> color - returns color of terrain line
#
#	> draw_profile
#		> angle - returns angle of active climb profile
#		> full_length - returns length of profile line
#		> coll_length - returns length of 'red' line (collision warning)
#
#	> draw_wppath
#		> angle - retuns angle of vnav climb profile
#		> length - returns length of vnav profile line
#
#	> set_screen_size - automatically sets screen size values
#
#	> set_vnav_info - sets vnav altitudes and ids to prop tree
#
################################################################################


var RAD2DEG = 57.2957795;
var DEG2RAD = 0.016774532925;
var NM2FT = 6076.11549;
var FT2NM = 0.000164579;
var KTS2FPS = 1.68780986;
var vsd_tree = "/instrumentation/vsd/";
var rte_tree = "/autopilot/route-manager/";

var xy_scale = 1.712250712;

var sqr = func(n) return n * n; 

    var vsd = {
       init : func {
            me.UPDATE_INTERVAL = 0.01;
            me.loopid = 0;
            
            me.count = 39;
            me.collide = 0;
            
            setprop(vsd_tree~ "hor_range", 30);
            setprop(vsd_tree~ "alt_range", 10000);
            
            setprop(vsd_tree~ "alt_mode", "AUTO");

            me.reset();
		},
       update : func {

			# Main Loop Function here
			
			var altitude = getprop("instrumentation/altimeter/indicated-altitude-ft");
			
			# Set VSD Screen Size
			
			set_screen_size(altitude, getprop(vsd_tree~ "alt_mode"));
			
			var heading = getprop("/orientation/heading-deg");
			
			var pos_lat = getprop("/position/latitude-deg");
			
			var pos_lon = getprop("/position/longitude-deg");
			
			var range = getprop(vsd_tree~ "hor_range");
			
			var alt_range = getprop(vsd_tree~ "alt_range");
			
			setprop(vsd_tree~ "profile/altitude-norm", altitude / alt_range);
			
			var interval = range / 40; # there're 40 points on the VSD
			
			# This is just for the OSGText Range Display
			
			setprop(vsd_tree~ "alt_5", int(alt_range / 100) * 100);
			setprop(vsd_tree~ "alt_4", int(alt_range * 0.008333) * 100);
			setprop(vsd_tree~ "alt_3", int(alt_range * 0.006667) * 100);
			setprop(vsd_tree~ "alt_2", int(alt_range * 0.005001) * 100);
			setprop(vsd_tree~ "alt_1", int(alt_range * 0.003333) * 100);
			setprop(vsd_tree~ "alt_0", int(alt_range * 0.001667) * 100);
			
			# Start by getting the elevation of 40 points right in front of you for upto the given range
			
			var elevation_distance = interval * me.count;
			
			var elevation_offset_x = elevation_distance * math.sin(heading);
			
			var elevation_offset_y = elevation_distance * math.cos(heading);
			
			var elevation = get_elevation(pos_lat + (elevation_offset_y / 60), pos_lon + (elevation_offset_x / 60));
			
			setprop(vsd_tree~ "point[" ~ me.count ~ "]/elevation-ft", elevation);
			
			setprop(vsd_tree~ "point[" ~ me.count ~ "]/translate-norm", elevation / alt_range);
			
#			if ((elevation < 0) and (getprop(vsd_tree~ "point[" ~ (me.count - 1) ~ "]/elevation-ft") != nil))
#				elevation = getprop(vsd_tree~ "point[" ~ (me.count - 1) ~ "]/elevation-ft");
			
			var next_elevation = elevation;
			
			if ((getprop(vsd_tree~ "point[" ~ (me.count + 1) ~ "]/elevation-ft") != nil) and (getprop(vsd_tree~ "point[" ~ (me.count + 1) ~ "]/elevation-ft") >= 0))			
				next_elevation = getprop(vsd_tree~ "point[" ~ (me.count + 1) ~ "]/elevation-ft");
				
			# Now, just to get the right values and call the functions
			
			## DRAW TERRAIN
			
			### ANGLE
			
			setprop(vsd_tree~ "point[" ~ me.count ~ "]/angle-deg", draw_terrain.angle(elevation, next_elevation, alt_range));
			
			### LENGTH
			
			setprop(vsd_tree~ "point[" ~ me.count ~ "]/length", draw_terrain.length(elevation, next_elevation, alt_range));
			
			### COLO(U)R
			
			setprop(vsd_tree~ "point[" ~ me.count ~ "]/color", draw_terrain.color(altitude, elevation));
						
			
			## DRAW PROFILE
			
			### ANGLE
			
			var profile_angle = draw_profile.angle(alt_range, range);
			
			setprop(vsd_tree~ "profile/angle-deg", profile_angle);
			
			### FULL LENGTH
			
			var full_length = draw_profile.full_length(profile_angle, altitude, alt_range, range);
			
			setprop(vsd_tree~ "profile/length", full_length);
			
			### CHECK FOR POSSIBLE COLLISION AND SET LENGTH
			
#			if ((check_collision(elevation_distance, elevation, altitude, profile_angle, alt_range, range)) and (me.collide == 0)) {
			
#				setprop(vsd_tree~ "collision/height", elevation / alt_range);
				
#				setprop(vsd_tree~ "collision/distance", elevation_distance / range);
				
#				setprop(vsd_tree~ "collision/length", draw_profile.coll_length(elevation_distance / range, elevation / alt_range, profile_angle, altitude, full_length, alt_range, range));
				
#				me.collide = 1;
			
#			} elsif (me.collide == 0) {
			
#				setprop(vsd_tree~ "collision/height", 0);
				
#				setprop(vsd_tree~ "collision/distance", 0);
				
#				setprop(vsd_tree~ "collision/length", 0);
			
#			}
			
			# Increment/Reset me.count
			
			# VNAV Altitudes Placer
			
			## First VNAV Point
			
			if (getprop(rte_tree~ "route/num") > 0) {

			var current_wp = getprop(rte_tree~ "current-wp");
			
			if (getprop(rte_tree~ "route/wp[" ~ current_wp ~ "]/id") != nil) {
				
				setprop(vsd_tree~ "vnav/wp[" ~ current_wp ~ "]/id", getprop(rte_tree~ "route/wp[" ~ current_wp ~ "]/id"));
				
				var wp_altitude = getprop(rte_tree~ "route/wp[" ~ current_wp ~ "]/altitude-ft");
				
				setprop(vsd_tree~ "vnav/wp[" ~ current_wp ~ "]/altitude-ft", wp_altitude);
				
				var y_norm = wp_altitude / alt_range;
				
				setprop(vsd_tree~ "vnav/wp[" ~ current_wp ~ "]/y_norm", y_norm);
				
				var gps_distance = getprop("/instrumentation/gps/wp/leg-distance-nm");
				
				var x_norm = gps_distance / range;
				
				setprop(vsd_tree~ "vnav/wp[" ~ current_wp ~ "]/x_norm", x_norm);
				
				var angle = RAD2DEG * math.atan2(x_norm * xy_scale, y_norm);
				
				setprop(vsd_tree~ "vnav/wp[" ~ current_wp ~ "]/angle", angle);
				
				var length = math.sqrt(sqr(x_norm) + sqr(y_norm));
				
				setprop(vsd_tree~ "vnav/wp[" ~ current_wp ~ "]/length", length);
				
				# Check for visibility
				
				if ((x_norm <= 1) and (y_norm) <= 1)
					setprop(vsd_tree~ "vnav/wp[0]/visible", 1);
				else
					setprop(vsd_tree~ "vnav/wp[0]/visible", 0);
				
				for (var n = (current_wp + 1); n < (current_wp + 7); n += 1) {
			
					if (getprop(rte_tree~ "route/wp[" ~ n ~ "]/id") != nil) {
					
						setprop(vsd_tree~ "vnav/wp[" ~ n ~ "]/id", getprop(rte_tree~ "route/wp[" ~ n ~ "]/id"));
					
						var wp_altitude = getprop(rte_tree~ "route/wp[" ~ n ~ "]/altitude-ft");
				
						setprop(vsd_tree~ "vnav/wp[" ~ n ~ "]/altitude-ft", wp_altitude);
				
						var y_norm = wp_altitude / alt_range;
				
						setprop(vsd_tree~ "vnav/wp[" ~ n ~ "]/y_norm", y_norm);
				
						var wp_distance = getprop(rte_tree~ "route/wp[" ~ (n - 1) ~ "]/leg-distance-nm");
				
						var last_norm = getprop(vsd_tree~ "vnav/wp[" ~ (n - 1) ~ "]/x_norm");
				
						var x_norm = (wp_distance / range) + last_norm;
				
						setprop(vsd_tree~ "vnav/wp[" ~ n ~ "]/x_norm", x_norm);
				
						var angle = RAD2DEG * math.atan2(x_norm * xy_scale, y_norm);
				
						setprop(vsd_tree~ "vnav/wp[" ~ n ~ "]/angle", angle);
				
						var length = math.sqrt(sqr(xy_scale * x_norm) + sqr(y_norm));
				
						setprop(vsd_tree~ "vnav/wp[" ~ n ~ "]/length", length);
						
						# Check for visibility
						
						if ((x_norm <= 1) and (y_norm) <= 1)
							setprop(vsd_tree~ "vnav/wp[" ~ n ~ "]/visible", 1);
						else
							setprop(vsd_tree~ "vnav/wp[" ~ n ~ "]/visible", 0);
					
					}
				
				}
				
			} else {
			
			for (var n = 0; n < 6; n += 1)
				
				setprop(vsd_tree~ "vnav/wp[" ~ n ~ "]/visible", 0);
			
			}
			
			}
			
			me.incr_count();

		},
		incr_count : func {
			me.count -= 1;
			if (me.count < 0) {
				me.count = 39; # Reset count to start over again
				me.collide = 0;	
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
    
    var draw_terrain = {
    	angle : func(curr_elevation, next_elevation, screen_top) {
    		
    		var delta_alt = next_elevation - curr_elevation;
    		
    		var y = (delta_alt / screen_top) / xy_scale;
    		
    		var slope = RAD2DEG * math.atan2(0.025, y); # 0.025 (1/40) is way to get all conversions into norms than actual units
    			
    		return slope;
    	},
    	length : func(curr_elevation, next_elevation, screen_top) {
    		
    		var delta_alt = next_elevation - curr_elevation;
    		
    		var y = (delta_alt / screen_top) / xy_scale;
    		
    		return 0.86 * math.sqrt(sqr(0.025) + sqr(y)); # Pythagorean theorm and the 0.9's just a factor... I like to tune stuff in nasal instead of xml now. ;)
    	},
    	color : func(altitude, elevation) {
    	
    		var terrain_color = "green";
    	
    		if ((altitude - elevation) < 1000)
    			terrain_color = "red";
    		elsif ((altitude - elevation) < 2000)
    			terrain_color = "orange";
    		elsif ((altitude - elevation) < 3000)
    			terrain_color = "yellow";
    		
    		if (elevation == 0)
    			terrain_color = "blue";
    		
    		return terrain_color;
    	}
    };
    
    var draw_profile = {
    	angle : func(screen_top, range) {
    	
    		var climb_rate = getprop("/velocities/vertical-speed-fps");
    		
    		var groundspeed = KTS2FPS * getprop("/velocities/groundspeed-kt");
    		
    		var y = (climb_rate / screen_top);
    		
    		var x = (groundspeed / (range * NM2FT));
    		
    		return (RAD2DEG * math.atan2(x,y)) - 90;
    	},
    	full_length : func(angle, altitude, screen_top, range) {
    	
    			var linelength = 0; # Initialize it as 0

					if (angle > 0) # Climbing
					{

					var y_available = (screen_top - altitude) / screen_top;

					} else { # Descending

					var y_available = altitude / screen_top;

					}
					
					var y_projection = math.sqrt(2) * math.sin(DEG2RAD * angle);

					if (y_available > y_projection) # Here, the line exceeds over the edge, not the top
						linelength = 1 / math.cos(angle);
					else # Here, it exceeds over vertically
						linelength = y_available / math.sin(angle);
    		
    		return linelength;
    	},
    	coll_length : func(coll_dist, coll_alt, angle, altitude, full_length, screen_top, range) {
    		
    		var delta_y = ((coll_alt - altitude) * FT2NM) / screen_top;
    		
    		var x = (coll_dist / range);
    		
    		var length_to_collide = math.sqrt(sqr(delta_y) + sqr(x)); # Aha! Pythagorean theorm again. :P
    		
    		return full_length - length_to_collide;
    	}
    };
    
    var set_screen_size = func (altitude, mode){
    
    	if (mode == "AUTO") {
    		
    		# Vertical Size
    		
    		if (altitude < 10000)
    			setprop(vsd_tree~ "alt_range", 10000);
    		else
    			setprop(vsd_tree~ "alt_range", altitude);
    		
    	} elsif (mode == "FL150")
    		
    		setprop(vsd_tree~ "alt_range", 15000);
    	
    	elsif (mode == "FL300")
    	
    		setprop(vsd_tree~ "alt_range", 30000);
    		
    	else
    		
    		setprop(vsd_tree~ "alt_range", 45000);
    	
    }
    
    var check_collision = func (distance, elevation, altitude, profile_angle, screen_top, range) {
    
    	var profile_height = (altitude / screen_top) + ((distance / range) * math.tan(profile_angle));
    	
    	if (elevation > profile_height)
    		return 1;
    	else
    		return 0;
    
    }
    
    var get_elevation = func (lat, lon) {

    var info = geodinfo(lat, lon);
       if (info != nil) {var elevation = info[0] * 3.2808399;}
       else {var elevation = -1.0; }

    return elevation;
    }

setlistener("sim/signals/fdm-initialized", func
 {
 vsd.init();
 print("VSD Instrument ...... Initialized");
 });
