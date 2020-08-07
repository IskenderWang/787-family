# CONSTANTS

var RAD2DEG = 57.2957795;
var DEG2RAD = 0.016774532925;
var htree = "/autopilot/hold/";

var hold = {
	init : func { 
        me.UPDATE_INTERVAL = 0.001; 
        me.loopid = 0; 
		setprop(htree ~"track-magnetic-deg", 0);
		setprop(htree ~"corrected-hold-time", 60);
		me.timer_started = 0;
		me.start_time = 0;
		setprop(htree ~"count", 0);
        me.reset(); 
}, 
	update : func {
	var hold_time = getprop(htree ~"hold-time");
	var hold_direction = getprop(htree ~"hold-direction");
	var hold_radial = getprop(htree ~"hold-radial");
	var hold_altitude = getprop(htree ~"altitude");
	var active = getprop(htree ~"active");
	var entry = getprop(htree ~"entry");
	var phase = getprop(htree ~"phase");
	var hdg = getprop("/orientation/heading-magnetic-deg");
	var fix = getprop(htree ~"fix");
	var brg = getprop("/instrumentation/gps[2]/scratch/mag-bearing-deg");
	var diff1 = hold_radial - brg;
	var diff2 = brg - hold_radial;
	var dist = getprop("/instrumentation/gps[2]/scratch/distance-nm");
	var gs = getprop("/velocities/groundspeed-kt");
	var leg_distance = (gs * (hold_time / 3600)) / 60;
	turn_diameter = ((gs * 120) / (3600 * math.pi)) / 60;
	var right1 = 45 + hold_radial;
	var right2 = 90 + hold_radial;
	var right3 = 180 + hold_radial;
	var left1 = hold_radial - 45;
	var left2 = hold_radial - 90;
	var left3 = hold_radial - 180;
	var count = getprop(htree ~"count");
	
	if (active != 1) {
		setprop("/autopilot/auto-hold/enable-track", 0);
		setprop(htree ~"count", 0);
		setprop(htree ~"phase", 0);
	}

	if ((fix != "") and (active == 1)) {
		if (right1 > 360)
			right1 = right1 - 360;
		if (right2 > 360)
			right2 = right2 - 360;
		if (right3 > 360)
			right3 = right3 - 360;
		if (left1 < 0)
			left1 = 360 - math.abs(left1);
		if (left2 < 0)
			left2 = 360 - math.abs(left1);
		if (left3 < 0)
			left3 = 360 - math.abs(left1);
		if (hold_direction == "Right"){
		var x = getprop("/instrumentation/gps[2]/scratch/longitude-deg");
		var y = getprop("/instrumentation/gps[2]/scratch/latitude-deg");
		var x1 = x + (turn_diameter * math.sqrt(2)) * math.sin(right1 * DEG2RAD);
		var y1 = y + (turn_diameter * math.sqrt(2)) * math.cos(right1 * DEG2RAD);
		var x2 = x + 2 * turn_diameter * math.sin(right2 * DEG2RAD);
		var y2 = y + 2 * turn_diameter * math.cos(right2 * DEG2RAD);
		var x3 = x2 + leg_distance * math.sin(right3 * DEG2RAD);
		var y3 = y2 + leg_distance * math.cos(right3 * DEG2RAD);
		var x4 = x1 + (leg_distance + 2 * turn_diameter) * math.sin(right3 * DEG2RAD);
		var y4 = y1 + (leg_distance + 2 * turn_diameter) * math.cos(right3 * DEG2RAD);
		var x5 = x + leg_distance * math.sin(right3 * DEG2RAD);
		var y5 = y + leg_distance * math.cos(right3 * DEG2RAD);
		var x6 = x5 + turn_diameter * math.sin(left1 * DEG2RAD);
		var y6 = y5 + turn_diameter * math.cos(left1 * DEG2RAD);
		var x7 = x5 + turn_diameter * math.sin(right2 * DEG2RAD);
		var y7 = y5 + turn_diameter * math.cos(right2 * DEG2RAD);
		var x8 = x5 + (leg_distance / 2) * math.sin(hold_radial);
		var y8 = y5 + (leg_distance / 2) * math.cos(hold_radial);
		}
		else{
			var x = getprop("/instrumentation/gps[2]/scratch/longitude-deg");
			var y = getprop("/instrumentation/gps[2]/scratch/latitude-deg");
			var x1 = x + (turn_diameter * math.sqrt(2)) * math.sin(left1 * DEG2RAD);
			var y1 = y + (turn_diameter * math.sqrt(2)) * math.cos(left1 * DEG2RAD);
			var x2 = x + 2 * turn_diameter * math.sin(left2 * DEG2RAD);
			var y2 = y + 2 * turn_diameter * math.cos(left2 * DEG2RAD);
			var x3 = x2 + leg_distance * math.sin(left3 * DEG2RAD);
			var y3 = y2 + leg_distance * math.cos(left3 * DEG2RAD);
			var x4 = x1 + (leg_distance + 2 * turn_diameter) * math.sin(left3 * DEG2RAD);
			var y4 = y1 + (leg_distance + 2 * turn_diameter) * math.cos(left3 * DEG2RAD);
			var x5 = x + leg_distance * math.sin(left3 * DEG2RAD);
			var y5 = y + leg_distance * math.cos(left3 * DEG2RAD);
			var x6 = x5 + turn_diameter * math.sin(right1 * DEG2RAD);
			var y6 = y5 + turn_diameter * math.cos(right1 * DEG2RAD);
			var x7 = x5 + turn_diameter * math.sin(left2 * DEG2RAD);
			var y7 = y5 + turn_diameter * math.cos(left2 * DEG2RAD);
			var x8 = x5 + (leg_distance / 2) * math.sin(hold_radial);
			var y8 = y5 + (leg_distance / 2) * math.cos(hold_radial);
		}
		setprop("/autopilot/auto-hold/point[0]/x", x);
		setprop("/autopilot/auto-hold/point[0]/y", y);
		setprop("/autopilot/auto-hold/point[1]/x", x1);
		setprop("/autopilot/auto-hold/point[1]/y", y1);
		setprop("/autopilot/auto-hold/point[2]/x", x2);
		setprop("/autopilot/auto-hold/point[2]/y", y2);
		setprop("/autopilot/auto-hold/point[3]/x", x3);
		setprop("/autopilot/auto-hold/point[3]/y", y3);
		setprop("/autopilot/auto-hold/point[4]/x", x4);
		setprop("/autopilot/auto-hold/point[4]/y", y4);
		setprop("/autopilot/auto-hold/point[5]/x", x5);
		setprop("/autopilot/auto-hold/point[5]/y", y5);
		
		
		if (diff1 <= 0)
			diff1 = 360 - math.abs(diff1);
		if (diff2 <= 0)
			diff2 = 360 - math.abs(diff2);

		# Disable Autopilot Controls while auto-holding

		setprop("/autopilot/panel/master", 0);
		setprop("/autopilot/locks/altitude", "");
		setprop("/autopilot/locks/heading", "");

		if (phase == 0) {
			if ((diff1 <= 110) or (diff2 <= 70)) {
				entry = 0; ## Direct Entry
				setprop(htree ~ "phase", 1);
				}
			elsif ((diff1 > 110) and (diff2 <= 180)) {
				entry = 2; ## Teardrop Entry
				setprop(htree ~ "phase", 7);
				}
			else{
				entry = 1; ## Parallel Entry
				setprop(htree ~ "phase", 7);	
				}
			setprop(htree ~"entry", entry);

		}
		elsif (phase == 7) { ## Fly Entry Phase
			if (flyto(y,x) == 0){
				if ((diff1 <= 110) or (diff2 <= 70)) {
					entry = 0; ## Direct Entry
					setprop(htree ~ "phase", 1);
					}
				elsif ((diff1 > 110) and (diff2 <= 180)) {
					entry = 2; ## Teardrop Entry
					setprop(htree ~ "phase", 7);
					}
				else{
					entry = 1; ## Parallel Entry
					setprop(htree ~ "phase", 7);	
					}
				setprop(htree ~"entry", entry);
			}
			if (entry == 1) { ## Parallel Entry
				if (flyto(y, x) == 1)
					setprop(htree ~"phase", 8);


			} else { ## Teardrop (entry 2)

				if (flyto(y, x) == 1)
					setprop(htree ~"phase", 4);

			}

		}

# HOLD POINTS LAYOUT ###########
#       5           FIX        #
#    4                  1      #
#       3            2         #
################################

		elsif (phase == 1) { ## Fly to Fix
		if (flyto(y,x) == 0){
				if ((diff1 <= 110) or (diff2 <= 70)) {
					entry = 0; ## Direct Entry
					setprop(htree ~ "phase", 1);
					}
				elsif ((diff1 > 110) and (diff2 <= 180)) {
					entry = 2; ## Teardrop Entry
					setprop(htree ~ "phase", 7);
					}
				else{
					entry = 1; ## Parallel Entry
					setprop(htree ~ "phase", 7);	
					}
				setprop(htree ~"entry", entry);
			}
			if (flyto(y,x) == 1){
				setprop(htree ~"phase", 3);
			}
		}
		elsif (phase == 2) { ## Fly to point 1
		setprop(htree ~"count", 1);
			if (flyto(y1,x1) == 1)
				setprop(htree ~"phase", 3);
				
		}
		elsif (phase == 3) { ## Fly to point 2
			if (flyto(y2,x2) == 1)
				setprop(htree ~"phase", 4);
		}
		elsif (phase == 4) { ## Fly to point 3
		setprop(htree ~"count", 1);
			if (flyto(y3,x3) == 1)
				setprop(htree ~"phase", 6);
		}
		elsif (phase == 5) { ## Fly to point 4
			if (flyto(y4,x4) == 1)
				setprop(htree ~"phase", 1);
		}
		elsif (phase == 6) { ## Fly to point 5
			if (flyto(y5,x5) == 1)
				setprop(htree ~"phase", 1);
		}
		elsif (phase == 8){
		setprop(htree ~"count", 1);
			if (flyto(y6, x6) == 1)
				setprop(htree ~"phase", 9);
		}
		elsif (phase == 9){
			if (flyto(y7, x7) == 1)
				setprop(htree ~"phase", 10);
		}
		elsif (phase == 10){
			if (flyto(y8, x8) == 1)
				setprop(htree ~"phase", 1);
		}
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

var flyto = func(target_lat, target_lon) {

 var pos_lat = getprop("/position/latitude-deg");
 var pos_lon = getprop("/position/longitude-deg");
 
 # Calculate Required Track for leg

 var track_deg = 90 - (57.2957795 * math.atan2(target_lat - pos_lat, target_lon - pos_lon));

 if (track_deg < 0)
	track_deg = 360 + track_deg;
#var track = getprop("instrumentation/gps/indicated-track-magnetic-deg");
 #var track_error_deg = track_deg - track;
 #if ((track_error_deg < 0) and (track > 180))
#	track_error_deg = math.abs(track_error_deg) - 180;
 setprop("/autopilot/auto-hold/track-error-deg", -Deflection(track_deg, 180));
 setprop("/autopilot/auto-hold/track", track_deg);
 setprop("/autopilot/auto-hold/enable-track", 1);

 # Check if Target is Reached

 if ((pos_lat <= target_lat + 0.0167) and (pos_lat >= target_lat - 0.0167) and (pos_lon <= target_lon + 0.0167) and (pos_lon >= target_lon - 0.0167)) {
  return 1; # Return 1 if reached
  setprop("/autopilot/auto-hold/enable-track", 0);
 } else return 0; # Return 0 is not reached

}
var plot_hold = func(){
		var x = getprop("/autopilot/auto-hold/point[0]/x");
		var y = getprop("/autopilot/auto-hold/point[0]/y");
		var x1 = getprop("/autopilot/auto-hold/point[1]/x");
		var y1 = getprop("/autopilot/auto-hold/point[1]/y");
		var x2 = getprop("/autopilot/auto-hold/point[2]/x");
		var y2 = getprop("/autopilot/auto-hold/point[2]/y");
		var x3 = getprop("/autopilot/auto-hold/point[3]/x");
		var y3 = getprop("/autopilot/auto-hold/point[3]/y");
		var x4 = getprop("/autopilot/auto-hold/point[4]/x");
		var y4 = getprop("/autopilot/auto-hold/point[4]/y");
		var x5 = getprop("/autopilot/auto-hold/point[5]/x");
		var y5 = getprop("/autopilot/auto-hold/point[5]/y");

		setprop("/autopilot/route-manager/input", "@INSERT99:" ~ x ~"," ~y);
		setprop("/autopilot/route-manager/input", "@INSERT99:" ~ x1 ~"," ~y1);
		setprop("/autopilot/route-manager/input", "@INSERT99:" ~ x2 ~"," ~y2);
		setprop("/autopilot/route-manager/input", "@INSERT99:" ~ x3 ~"," ~y3);
		setprop("/autopilot/route-manager/input", "@INSERT99:" ~ x4 ~"," ~y4);
		setprop("/autopilot/route-manager/input", "@INSERT99:" ~ x5 ~"," ~y5);
}
setlistener("sim/signals/fdm-initialized", func
 {
 hold.init();
 });
