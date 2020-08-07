var mcp = {
	init : func { 
        me.UPDATE_INTERVAL = 0.01; 
        me.loopid = 0; 

# Initialize Panel Settings

setprop("/autopilot/panel/auto-throttle", 0);
setprop("/autopilot/panel/master", 0);
setprop("/autopilot/panel/speed-mode", "ias");
setprop("/autopilot/panel/larm", 1);
setprop("/autopilot/panel/rarm", 1);
setprop("/autopilot/panel/hdg", "hdg");
setprop("/autopilot/panel/alt", "alt");
setprop("/autopilot/settings/vertical-speed-fpm", 0);

        me.reset(); 
}, 
	update : func {
	
	# Convert actual code to dialog display text
	
	## Vertical Autopilot Settings
	if (getprop("/autopilot/panel/alt") == "alt") {
		if (getprop("/autopilot/panel/alt-ind") == "hold")
			setprop("/autopilot/dialog/alt", "HOLD");
		else
			setprop("/autopilot/dialog/alt", "FLCH");
	} elsif (getprop("/autopilot/panel/alt") == "vs") {
		setprop("/autopilot/dialog/alt", "V/S");
	} elsif (getprop("/autopilot/panel/alt") == "vnav") {
		setprop("/autopilot/dialog/alt", "VNAV");
	} elsif (getprop("/autopilot/panel/alt") == "app") {
		setprop("/autopilot/dialog/alt", "APP");
	}

	## Lateral Autopilot Settings
	if (getprop("/autopilot/panel/hdg") == "hdg") {
		setprop("/autopilot/dialog/hdg", "HOLD");
	} elsif (getprop("/autopilot/panel/hdg") == "lnav") {
		setprop("/autopilot/dialog/hdg", "LNAV");
	} elsif (getprop("/autopilot/panel/hdg") == "loc") {
		setprop("/autopilot/dialog/hdg", "LOC");
	}
	
	## Speed Modes
	
	if (getprop("/autopilot/panel/speed-mode") == "ias") {
		setprop("/autopilot/dialog/spd", "IAS");
		setprop("/autopilot/dialog/spd-ias-hide", 0);
		setprop("/autopilot/dialog/spd-mach-hide", 1);
	}	else {
		setprop("/autopilot/dialog/spd", "MACH");
		setprop("/autopilot/dialog/spd-ias-hide", 1);
		setprop("/autopilot/dialog/spd-mach-hide", 0);
	}
		
	## Master Text
	
	if (getprop("/autopilot/panel/master") == 1)
		setprop("/autopilot/dialog/ap", "AP: ON");
	else
		setprop("/autopilot/dialog/ap", "AP: OFF");
		
	## Auto-Throttle Text
	
	if (getprop("/autopilot/panel/auto-throttle") == 1)
		setprop("/autopilot/dialog/at", "A/T: ON");
	else
		setprop("/autopilot/dialog/at", "A/T: OFF");
		
	## Flight Director Text
	
	if (getprop("/autopilot/flightdirector") == 1)
		setprop("/autopilot/dialog/fd", "FD: ON");
	else
		setprop("/autopilot/dialog/fd", "FD: OFF");
	
	
	if (getprop("/autopilot/internal/target-climb-rate-fps") != nil)
		setprop("/autopilot/internal/climb-rate-difference", getprop("/autopilot/internal/target-climb-rate-fps") - getprop("/velocities/vertical-speed-fps"));

# Connect L and R arms to AP throttle props

if ((getprop("/autopilot/panel/larm") == 1) and (getprop("/autopilot/locks/speed") == "speed-with-throttle")) setprop("/autopilot/speed/lthrottle", "ias");
elsif ((getprop("/autopilot/panel/larm") == 1) and (getprop("/autopilot/locks/speed") == "mach")) setprop("/autopilot/speed/lthrottle", "mach");
else setprop("/autopilot/speed/lthrottle", "");

if ((getprop("/autopilot/panel/rarm") == 1) and (getprop("/autopilot/locks/speed") == "speed-with-throttle")) setprop("/autopilot/speed/rthrottle", "ias");
elsif ((getprop("/autopilot/panel/rarm") == 1) and (getprop("/autopilot/locks/speed") == "mach")) setprop("/autopilot/speed/rthrottle", "mach");
else setprop("/autopilot/speed/rthrottle", "");

if ((getprop("/connection/fgfscopilot/connected") != 1) and ((getprop("/controls/switches/copilot/autopilot") != 1) or (getprop("controls/switches/copilot/active") != 1))) {

# Speed Models (convert panel props to generic)

if ((getprop("/autopilot/panel/auto-throttle") == 1) and (getprop("/autopilot/panel/speed-mode") == "ias")) setprop("/autopilot/locks/speed", "speed-with-throttle");
elsif ((getprop("/autopilot/panel/auto-throttle") == 1) and (getprop("/autopilot/panel/speed-mode") == "mach")) setprop("/autopilot/locks/speed", "mach");
else setprop("/autopilot/locks/speed", "");

# Master Autopilot controls (convert panel props to generic)

if (getprop("/autopilot/panel/master") == 1) {

	## Vertical Autopilot Settings
	if (getprop("/autopilot/panel/alt") == "alt") {
		setprop("/autopilot/locks/altitude", "altitude-hold");
	} elsif (getprop("/autopilot/panel/alt") == "vs") {
		setprop("/autopilot/locks/altitude", "vertical-speed-hold");
	} elsif (getprop("/autopilot/panel/alt") == "vnav") {
		setprop("/autopilot/locks/altitude", "vnav");
	} elsif (getprop("/autopilot/panel/alt") == "app") {
		setprop("/autopilot/locks/altitude", "gs1-hold");
	} else setprop("/autopilot/locks/altitude", "");

	## Lateral Autopilot Settings
	if (getprop("/autopilot/panel/hdg") == "hdg") {
		setprop("/autopilot/locks/heading", "dg-heading-hold");
	} elsif (getprop("/autopilot/panel/hdg") == "lnav") {
		setprop("/autopilot/locks/heading", "true-heading-hold");
	} elsif (getprop("/autopilot/panel/hdg") == "loc") {
		setprop("/autopilot/locks/heading", "nav1-hold");
	} else setprop("/autopilot/locks/heading", "");

} else {
	setprop("/autopilot/locks/altitude", "");
	setprop("/autopilot/locks/heading", "");
}

}

# Flight Level Change and Altitude Hold Lights

if ((getprop("/autopilot/panel/alt") == "alt") and (getprop("/autopilot/settings/target-altitude-ft") != nil) and (getprop("/instrumentation/altimeter/indicated-altitude-ft") != nil)) {

	if (math.abs(getprop("/autopilot/settings/target-altitude-ft") - getprop("/instrumentation/altimeter/indicated-altitude-ft")) <= 500)
		setprop("/autopilot/panel/alt-ind", "hold");
	else
		setprop("/autopilot/panel/alt-ind", "flch");

} else
	setprop("/autopilot/panel/alt-ind", "");

# Vertical Speed FDM Display

if (getprop("/autopilot/settings/vertical-speed-fpm") >= 0) setprop("/autopilot/panel/disp-vs", getprop("/autopilot/settings/vertical-speed-fpm"));
else setprop("/autopilot/panel/disp-vs", -1 * getprop("/autopilot/settings/vertical-speed-fpm"));

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
 mcp.init();
 sysinfo.log_msg("[AP] Systems Check ....... OK", 0);
 });

