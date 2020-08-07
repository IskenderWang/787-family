# CONSTANTS

var RAD2DEG = 57.2957795;
var DEG2RAD = 0.0174532925;

var vnav = {
	init : func { 
        me.UPDATE_INTERVAL = 0.001; 
        me.loopid = 0; 

		setprop("/controls/cdu/vnav/cruise-mode", 0);
		setprop("/autopilot/vnav/vnav-mode", "wp-mode");

        me.reset(); 
}, 
	update : func {

var altitudeft = getprop("/instrumentation/altimeter/indicated-altitude-ft");

var targetaltft = getprop("/controls/navigation/vnav/wp1alt");

# VNAV Autopilot Properties

if ((getprop("/autopilot/locks/altitude") == "vnav") and (getprop("/autopilot/vnav/vnav-mode") == "crz-altitude-hold")) setprop("/autopilot/locks/vnav", "crz");
elsif ((getprop("/autopilot/locks/altitude") == "vnav") and (getprop("/autopilot/vnav/vnav-mode") == "wp-mode")) setprop("/autopilot/locks/vnav", "wp");
else setprop("/autopilot/locks/vnav", "");

# Check for Cruise Mode

if (getprop("/controls/cdu/vnav/start-crz") == getprop("/controls/navigation/vnav/wp1id")) {
setprop("/autopilot/vnav/vnav-mode", "crz-altitude-hold");
}

if (getprop("/autopilot/vnav/vnav-mode") == "crz-altitude-hold") {

if (getprop("/controls/cdu/vnav/end-crz") == getprop("/controls/navigation/vnav/wp1id")) {
setprop("/autopilot/vnav/vnav-mode", "wp-mode");
}
}

if (getprop("/autopilot/vnav/vnav-mode") == "wp-mode") {
if (getprop("/controls/navigation/vnav/wp1alt") != nil) {
if (getprop("/controls/navigation/vnav/wp1alt") <= 0) {
setprop("/autopilot/vnav/vertical-speed-fps", 0);
} else {
if ((targetaltft != nil) and (getprop("/autopilot/route-manager/wp/dist") != nil)) {

setprop("/autopilot/vnav/vertical-speed-fps", (getprop("/velocities/groundspeed-kt") * (targetaltft - altitudeft)) / (3600 * getprop("/autopilot/route-manager/wp/dist")));
if (getprop("/autopilot/vnav/vertical-speed-fps") > 50){
setprop("/autopilot/vnav/vertical-speed-fps", 50);
}
} else setprop("/autopilot/vnav/vertical-speed-fps", 0);
}
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

setlistener("sim/signals/fdm-initialized", func
 {
 vnav.init();
 print("Autopilot ........... Initialized");
 });

