var copilot = {
	init : func { 
        me.UPDATE_INTERVAL = 1.73; 
        me.loopid = 0; 
		# Initialize state variables
		me.V1announced = 0;
		me.VRannounced = 0;
		me.V2announced = 0;
		if (getprop("velocities/airspeed-kt") < 50) { me.flightphase = 0; }
		else { me.flightphase = 1; }	
		## me.flightphase = 0 => Take-off
		## me.flightphase = 1 => Landing
		me.touchdown = 0;
		me.under60 = 0;
		
        me.reset(); 
        screen.log.write("Virtual Co-pilot .... Initialized", 1, 1, 1);
        screen.log.write("Copilot: Hi there!", 0, 0.584, 1);
	print("Virtual Co-pilot .... Initialized");

# Initialize Copilot Voice Settings
props.globals.getNode("sim/sound/active").setBoolValue(0);
props.globals.getNode("sim/sound/active-flaps").setBoolValue(0);
props.globals.getNode("sim/sound/v1").setBoolValue(0);
props.globals.getNode("sim/sound/v2").setBoolValue(0);
props.globals.getNode("sim/sound/vr").setBoolValue(0);
props.globals.getNode("sim/sound/toflaps10").setBoolValue(0);
props.globals.getNode("sim/sound/toflaps0").setBoolValue(0);
props.globals.getNode("sim/sound/gearsup").setBoolValue(0);
props.globals.getNode("sim/sound/gearsdown").setBoolValue(0);
props.globals.getNode("sim/sound/touchdown").setBoolValue(0);
props.globals.getNode("sim/sound/under60").setBoolValue(0);
props.globals.getNode("sim/sound/off").setBoolValue(0);
props.globals.getNode("sim/sound/landflaps10").setBoolValue(0);
props.globals.getNode("sim/sound/landflaps20").setBoolValue(0);
props.globals.getNode("sim/sound/landflaps30").setBoolValue(0);
props.globals.getNode("sim/sound/landflapsfull").setBoolValue(0);

setprop("controls/switches/copilot/slow",0);

# Copilot Settings
	var flaps = getprop("controls/switches/copilot/flaps");
	var gear = getprop("controls/switches/copilot/gear");
	var lights = getprop("controls/switches/copilot/lights");
	var airspeed = getprop("controls/switches/copilot/airspeed");
	var phase = getprop("controls/switches/copilot/phase");

if (flaps == 1) {
props.globals.getNode("sim/sound/active-flaps").setBoolValue(1); }
else {
props.globals.getNode("sim/sound/active").setBoolValue(1); }

if ((flaps == 1) and (me.flightphase == 0)) {
setprop("/controls/flight/flaps", 0.22);
screen.log.write("Copilot: 5 Degrees Take-off Flaps Set", 0, 0.584, 1);
} 

if ((flaps == 1) and (me.flightphase == 1)) {
setprop("/controls/flight/flaps", 0);
} 

if ((gear == 1) and (me.flightphase == 1)) {
setprop("/controls/gear/gear-down", 0);
}

if (lights == 1) {
setprop("/controls/lighting/nav-lights", 1);
setprop("/controls/lighting/logo", 1);
setprop("/controls/lighting/beacon", 1);
} 

}, 
	update : func {
	var active = getprop("controls/switches/copilot/active");

if (active == 1) {

        var airspeed = getprop("velocities/airspeed-kt");
        var flapspos = getprop("/controls/flight/flaps");
        var altitude = getprop("/position/altitude-agl-ft");
	var gearpos = getprop("/controls/gear/gear-down");
		var V1 = getprop("/instrumentation/fmc/vspeeds/V1");
		var V2 = getprop("/instrumentation/fmc/vspeeds/V2");
		var VR = getprop("/instrumentation/fmc/vspeeds/VR");

# Copilot Settings
	var announce = getprop("controls/switches/copilot/announce");
	var flaps = getprop("controls/switches/copilot/flaps");
	var gear = getprop("controls/switches/copilot/gear");
	var lights = getprop("controls/switches/copilot/lights");
	var slow = getprop("controls/switches/copilot/slow");
	var rollspeed = getprop("/gear/gear/rollspeed-ms");
	var phase = getprop("controls/switches/copilot/phase");

# Reference Speed Announcements	
	
        if ((announce != 0) and (airspeed != nil) and (V1 != nil) and (airspeed > V1) and (me.V1announced == 0)) {
            me.announce("V1!");
			me.V1announced = 1;
props.globals.getNode("sim/sound/v1").setBoolValue(1);
        } elsif ((announce != 0) and (airspeed != nil) and (VR != nil) and (airspeed > VR) and (me.VRannounced == 0)) {
            me.announce("VR!");
props.globals.getNode("sim/sound/vr").setBoolValue(1);
			me.VRannounced = 1;
        } elsif ((announce != 0) and (airspeed != nil) and (V2 != nil) and (airspeed > V2) and (me.V2announced == 0)) {
            me.announce("V2!");
			me.V2announced = 1;
props.globals.getNode("sim/sound/v2").setBoolValue(1);
        }

# Control Flaps agiainst airspeed

if (flaps == 1) {

# Take-off Flaps
## Less than 180 knots --> 20 degrees
## 180 to 220 knots --> 10 degrees
## More than 220 knots --> Full retracted
###########################################
##Above data erroneous
##Takeoff at flaps5
if (me.flightphase == 0) {

  if ((airspeed >= 180) and (flapspos == 0.22)) {
    setprop("/controls/flight/flaps", 0.033);
    screen.log.write("Copilot: 180 knots, Flaps set to 1 Degree", 0, 0.584, 1); 
}

  if ((airspeed >= 220) and (flapspos == 0.033)) {
    setprop("/controls/flight/flaps", 0);
    screen.log.write("Copilot: 220 knots, Flaps Retracted", 0, 0.584, 1); 
    props.globals.getNode("sim/sound/toflaps0").setBoolValue(1);
}

  if ((airspeed >= getprop("instrumentation/b787-fmc/speeds/flaps1")) and (flapspos == 0) and (altitude >=10000)) {
    me.flightphase = 1; }

} else {

# Landing Flaps
## More than 250 knots --> Full retracted
## 220 to 250 knots --> 10 degrees
## 200 to 220 knots --> 20 degrees
## 180 to 200 knots --> 30 degrees
## Less than 180 knots --> Full Extended
###########################################
##Above values are now obsolete
##Copilot now lowers flaps based on both speed and weight

  if ((airspeed < getprop("instrumentation/b787-fmc/speeds/flaps1")) and (flapspos == 0)) {
    setprop("/controls/flight/flaps", 0.033);
    screen.log.write("Copilot: Flaps set to 1 Degrees", 0, 0.584, 1);
}

  if ((airspeed < getprop("instrumentation/b787-fmc/speeds/flaps5")) and (flapspos == 0.033)) {
    setprop("/controls/flight/flaps", 0.22);
    screen.log.write("Copilot: Flaps set to 5 Degrees", 0, 0.584, 1); 
}

  if ((airspeed < getprop("instrumentation/b787-fmc/speeds/flaps10")) and (flapspos == 0.22)) {
    setprop("/controls/flight/flaps", 0.5);
    screen.log.write("Copilot: Flaps set to 10 Degrees", 0, 0.584, 1); 
}

  if ((airspeed < getprop("instrumentation/b787-fmc/speeds/flaps15")) and (flapspos == 0.5)) {
    setprop("/controls/flight/flaps", 0.666);
	screen.log.write("Copilot: Flaps set to 15 Degrees", 0, 0.584, 1);
}

if ((airspeed < getprop("instrumentation/b787-fmc/speeds/flaps25")) and (flapspos == 0.666)) {
    setprop("/controls/flight/flaps", 0.833);
	screen.log.write("Copilot: Flaps set to 25 Degrees", 0, 0.584, 1);
}

if (((airspeed < getprop("instrumentation/b787-fmc/speeds/flaps35")) or airspeed < 143) and (flapspos == 0.833)) {
    setprop("/controls/flight/flaps", 1);
    screen.log.write("Copilot: Full Flaps Extended", 0, 0.584, 1); 
}

  if ((airspeed < 30) and (flapspos == 1)) { 
    setprop("/controls/flight/flaps", 0);
    me.flightphase = 0; }

} } 

# Control Gear Position

if ((gear == 1) and (me.flightphase == 0) and (altitude >= 50) and (gearpos == 1)) {
setprop("/controls/gear/gear-down", 0); 
screen.log.write("Copilot: Gears Up", 0, 0.584, 1);
props.globals.getNode("sim/sound/gearsup").setBoolValue(1);
} 

if ((gear == 1) and (me.flightphase == 1) and (altitude < 4000) and (gearpos == 0)) {
setprop("/controls/gear/gear-down", 1); 
screen.log.write("Copilot: 4000 ft, Gears Down", 0, 0.584, 1);
} 

# Control Aircraft Lighting

if (lights == 1) {

if (altitude <= 10000) {
setprop("/controls/lighting/landing-lights[0]", 1);
setprop("/controls/lighting/landing-lights[1]", 1);
setprop("/controls/lighting/landing-lights[2]", 1); 
}
else {
setprop("/controls/lighting/landing-lights[0]", 0);
setprop("/controls/lighting/landing-lights[1]", 0);
setprop("/controls/lighting/landing-lights[2]", 0); 
}

if (airspeed > 30) { setprop("/controls/lighting/strobe", 1); } 
else { setprop("/controls/lighting/strobe", 0); } } }

# Control Speedbrakes and Reversers on Touchdown

if (slow == 1) {

# Activate Reversers and Spoilers on Touchdown
if ((me.flightphase == 1) and (rollspeed >= 5) and (me.touchdown == 0)) {
reversethrust.togglereverser();
setprop("/controls/engines/engine/throttle", 1);
setprop("/controls/engines/engine[1]/throttle", 1);
screen.log.write("Copilot: Touchdown! Engaging Thrust Reversers and Speedbrakes", 0, 0.584, 1);
props.globals.getNode("sim/sound/touchdown").setBoolValue(1);
me.touchdown = 1;
}

# Disengage Reversers and Spoilers under 60 knots after Touchdown
 if ((airspeed <= 70) and (me.touchdown == 1) and (me.under60 == 0)) {
 reversethrust.togglereverser();
 setprop("/controls/engines/engine/throttle", 0);
 setprop("/controls/engines/engine[1]/throttle", 0);
 screen.log.write("Copilot: 70 knots, Disengaging Thrust Reversers and Retracting Speedbrakes", 0, 0.584, 1);
 me.under60 = 1;
 }

 if ((airspeed <= 10) and (me.under60 ==1)) {
 setprop("/controls/flight/flaps", 0);
 setprop("/controls/switches/copilot/active", 0);
 screen.log.write("Virtual Co-pilot Deactivated...", 1, 1, 1);
 props.globals.getNode("sim/sound/off").setBoolValue(1);
 }

}

# Control Window Heating and Anti-icing in extreme temperatures

if ((getprop("/environment/temperature-degc") <= 0) and (getprop("/controls/switches/copilot/pneu") == 1)) {
setprop("/controls/window-heat/engage", 1);
setprop("/controls/ice/eng1/anti-ice", 1);
setprop("/controls/ice/eng2/anti-ice", 1);
setprop("/controls/ice/wing/anti-ice", 1);
} else {
setprop("/controls/window-heat/engage", 0);
setprop("/controls/ice/eng1/anti-ice", 0);
setprop("/controls/ice/eng2/anti-ice", 0);
setprop("/controls/ice/wing/anti-ice", 0);
}

# Control Pneumatics (AC Packs and Bleed Air) according to pump temperatures

if (getprop("/controls/switches/copilot/pneu") == 1) {
setprop("controls/pressurization/pack[0]/pack-on", 1);
setprop("controls/pressurization/pack[1]/pack-on", 1);
if (getprop("/engines/APU/running") == 1) {
setprop("controls/pneumatic/APU-bleed",1);
} else {
setprop("controls/pneumatic/APU-bleed",0);
}
if (getprop("/engines/engine/running") == 1) {
setprop("controls/pneumatic/engine/bleed",1);
} else {
setprop("controls/pneumatic/engine/bleed",0);
}
if (getprop("/engines/engine[1]/running") == 1) {
setprop("controls/pneumatic/engine[1]/bleed",1);
} else {
setprop("controls/pneumatic/engine[1]/bleed",0);
}
}

# Control Altimeter
if (getprop("/controls/switches/copilot/altimeter") == 1){

if (getprop("/instrumentation/altimeter/indicated-altitude-ft") < 18000){
setprop("/instrumentation/altimeter/setting-inhg", getprop("/environment/pressure-sea-level-inhg"));
}
else {
setprop("/instrumentation/altimeter/setting-inhg", 29.92);
}
}

# Manage Airspeed Setting
if (getprop("/controls/switches/copilot/airspeed") == 1){


# Determine the phase of flight

if ((getprop("/instrumentation/altimeter/indicated-altitude-ft") < 10000) and (getprop("/velocities/vertical-speed-fps") > -25) and phase != 5)
	setprop("controls/switches/copilot/phase", 0);	# climbing under 10,000
elsif ((getprop("/instrumentation/altimeter/indicated-altitude-ft") >= 10000) and (getprop("/instrumentation/altimeter/indicated-altitude-ft") < 26000) and (getprop("/velocities/vertical-speed-fps") > -25) and (phase != 4)  and (phase != 5))
	setprop("controls/switches/copilot/phase", 1);	# climbing between 10,000 and FL260
elsif ((getprop("/instrumentation/altimeter/indicated-altitude-ft") >= 26000) and (getprop("/instrumentation/altimeter/indicated-altitude-ft") < 30000) and (getprop("/velocities/vertical-speed-fps") > -25) and (phase != 4))
	setprop("controls/switches/copilot/phase", 2);	# climbing between FL260 and FL300
elsif ((getprop("/instrumentation/altimeter/indicated-altitude-ft") >= 30000) and (getprop("/velocities/vertical-speed-fps") > -25) and (phase != 4))
	setprop("controls/switches/copilot/phase", 3);	# climb/cruising at or above FL300
elsif ((altitude >= 11000) and (getprop("/velocities/vertical-speed-fps") <= -25) and ((phase == 3) or (phase == 4)))
	setprop("controls/switches/copilot/phase", 4);	# descending above 11,000
elsif ((getprop("/autopilot/route-manager/wp-last/dist") != nil) and (getprop("/autopilot/route-manager/wp-last/dist") < 33) and ((phase == 4) or (phase == 5)))
	setprop("controls/switches/copilot/phase", 5);	# approach

# Adjust airspeed/mach based on phase
	
if ((phase == 0) or (phase == 4)){
	setprop("/autopilot/settings/target-speed-kt", 250);
	setprop("/autopilot/panel/auto-throttle", 1);
	setprop("/autopilot/panel/speed-mode", "ias");
}
elsif (phase == 1){
	setprop("/autopilot/settings/target-speed-kt", 300);
	setprop("/autopilot/panel/auto-throttle", 1);
	setprop("/autopilot/panel/speed-mode", "ias");
}
elsif (phase == 2){
	setprop("/autopilot/settings/mach-speed", 0.8);
	setprop("/autopilot/panel/auto-throttle", 1);
	setprop("/autopilot/panel/speed-mode", "mach");
}
elsif (phase == 3){
	setprop("/autopilot/settings/mach-speed", 0.85);
	setprop("/autopilot/panel/auto-throttle", 1);
	setprop("/autopilot/panel/speed-mode", "mach");
}
elsif (phase == 5){
	setprop("/autopilot/settings/target-speed-kt", getprop("/instrumentation/b787-fmc/speeds/ap"));
	setprop("/autopilot/panel/auto-throttle", 1);
	setprop("/autopilot/panel/speed-mode", "ias");
	if (altitude < 5000)
		setprop("/controls/switches/copilot/airspeed", 0);
}
}

# Manage Autopilot
# NOTE: You MUST have a route in the route manager to use this feature

if (getprop("/controls/switches/copilot/autopilot") == 1){

	# Takeoff assist
	if ((airspeed != nil) and (VR != nil) and (airspeed > VR) and (altitude < 50) and (me.flightphase == 0)){
		setprop("/autopilot/route-manager/active", 1);	#activate route manager
		setprop("/autopilot/route-manager/current-wp", 1);	#set target to first waypoint
		setprop("/autopilot/settings/target-pitch-deg", 10);
		setprop("/autopilot/locks/altitude", "pitch-hold");
		setprop("/autopilot/locks/heading", "wing-leveler");
	}
	# Activate LNAV and VNAV
	elsif ((airspeed != nil) and (V2 != nil) and (airspeed > V2) and (me.flightphase == 0) and (altitude >= 500)){
		setprop("/autopilot/locks/heading", "true-heading-hold");
		setprop("/autopilot/locks/altitude", "vnav");
	}
	# Intercept ILS
	elsif ((me.flightphase == 1) and (getprop("/autopilot/route-manager/wp-last/dist") != nil) and (getprop("/autopilot/route-manager/wp-last/dist") < 10) and (altitude > 200) and (getprop("/instrumentation/nav/in-range"))){
		setprop("/autopilot/locks/heading", "nav1-hold");
		if (getprop("/instrumentation/nav/gs-in-range")){
				setprop("/autopilot/locks/altitude", "gs1-hold");
		}
	}
	# Autoland
	elsif ((me.flightphase == 1) and (altitude <= 200) and (getprop("/instrumentation/nav/gs-in-range")) and (getprop("/gear/gear[1]/rollspeed-ms") == 0) and (getprop("/gear/gear[2]/rollspeed-ms") == 0)){
		setprop("/autopilot/locks/speed", "");
		# Determine if LOC tracking is good enough for autoland, and land the plane if it is
		if ((getprop("/instrumentation/nav/heading-needle-deflection-norm") > -0.25) and (getprop("/instrumentation/nav/heading-needle-deflection-norm") < 0.25)){
			setprop("/autopilot/locks/heading", "wing-leveler");
			setprop("/autopilot/settings/vertical-speed-fpm", -40);
			setprop("/autopilot/locks/altitude", "vertical-speed-hold");
			setprop("/controls/autobrake/setting", 1);
			# Reduce throttles to idle once in ground effect
			if (altitude < 50){
				setprop("/controls/engines/engine/throttle", (getprop("/controls/engines/engine/throttle") / 2));
				setprop("/controls/engines/engine[1]/throttle", (getprop("/controls/engines/engine[1]/throttle") / 2));
			}
		}
		# If LOC tracking is not good enough, then disengage AP management, AP, and AT, and tell the pilot to land
		else{
			setprop("/autopilot/locks/heading", "");
			setprop("/autopilot/locks/altitude", "");
			screen.log.write("Copilot: This one doesn't look too easy...", 0, 0.584, 1);
			screen.log.write("Copilot: AP disengaged.  You have the plane.", 0, 0.584, 1);
			screen.log.write("Virtual Copilot has abandoned you during a difficult landing.", 1, 1, 1);
			setprop("/controls/switches/copilot/autopilot", 0);
		}
	}
	# Disengage AP Management on touchdown
	elsif ((me.flightphase == 1) and (getprop("/gear/gear[1]/rollspeed-ms") > 0) and (getprop("/gear/gear[2]/rollspeed-ms") > 0)){
		setprop("/autopilot/locks/heading", "");
		setprop("/autopilot/locks/altitude", "");
		setprop("/autopilot/settings/target-speed-kt", 20);	#for easy taxiing with AT
		setprop("/controls/switches/copilot/autopilot", 0);
	}
}
},
	announce : func(msg) {
        screen.log.write(msg, 1, 0, 0);
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
