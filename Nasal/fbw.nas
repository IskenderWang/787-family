#########################################
## FLY BY WIRE SYSTEM FOR BOEING 787-8 ##
#########################################
## Designed by Omega Pilot, Redneck    ##
## and Bicyus			       ##
#########################################

# CONSTANTS

var RAD2DEG = 57.2957795;
var DEG2RAD = 0.0174532925;

var fbw = {
	
	init : func { 
		me.UPDATE_INTERVAL = 0.001; 
		me.loopid = 0; 

		me.throttle = 0;
		me.throttlefix = 0;
		me.throttleinit = 0;
		me.targetthrottle = 0;
		me.turnthrottlefix = 0;
		me.targetaileron = 0;
		me.targetelevator = 0;
		me.targetrudder = 0;
		me.adjustelevators = 0;
		me.stabilize = 0;

		me.stabpitch = 0;
		me.stabroll = 0;

		me.disconnectannounce = 0;

		## Initialize with FBW Activated

		setprop("/controls/fbw/active", 1);
		setprop("/controls/fbw/rudder", 1);
		setprop("/controls/fbw/yaw-damper", 1);
		setprop("/controls/fbw/bank-limit", 35);

		setprop("/controls/fbw/alpha-protect", 0);
		setprop("/controls/fbw/alpha-limit", 0);

		## Initialize Control Surfaces

		setprop("/fdm/jsbsim/fcs/aileron-fbw-output", 0);
		setprop("/fdm/jsbsim/fcs/rudder-fbw-output", 0);
		setprop("/fdm/jsbsim/fcs/elevator-fbw-output", 0);

		me.reset(); 
	},  #Init Function end

	update : func {

		var fcs = "/fdm/jsbsim/fcs/";

		## Fix Damp Rate according to Framerate

		if (getprop("/sim/frame-rate") != nil) var fpsfix = 25 / getprop("/sim/frame-rate");
		else fpsfix = 1;

		## Bank Limit Setting

		var banklimit = getprop("/controls/fbw/bank-limit");

		## Position and Orientation

		var altitudeagl = getprop("/position/altitude-agl-ft");

		var altitudemsl = getprop("/position/altitude-ft");

		var pitch = getprop("/orientation/pitch-deg");
		var roll = getprop("/orientation/roll-deg");

		var airspeedkt = getprop("/velocities/airspeed-kt");

		## Flight Control System Properties

		var elevtrim = getprop("/controls/flight/elevator-trim");
		var ailtrim = getprop("/controls/flight/aileron-trim");

		var aileronin = getprop(fcs~"aileron-cmd-norm");
		var elevatorin =  getprop(fcs~"elevator-cmd-norm");
		var rudderin = getprop(fcs~"rudder-cmd-norm");

		## FBW Output (actual surface positions)

		var aileronout = getprop(fcs~"aileron-fbw-output");
		var elevatorout =  getprop(fcs~"elevator-fbw-output");
		var rudderout = getprop(fcs~"rudder-fbw-output");

		## Engine Throttle Positions

		throttle0 = getprop("controls/engines/engine[0]/throttle");
		throttle1 = getprop("controls/engines/engine[1]/throttle");

		## This is where the FBW actually does it's job ;)

		### The Fly-by--wire only works when it is active. In the Boeing 787, pilots have
		### the option to disable fly-by-wire and use power-by-wire* in case of emergencies.
		### The Fly By Wire Configuration includes: On/Off, Bank Limit and Rudder Control.
		### The FBW Configs can be set in the FBW CONFIG Page in the CDU(s)

		## Turn on Fly By Wire only if we have power

		if (getprop("/systems/electrical/outputs/efis") != nil) {
			if ((getprop("/systems/electrical/outputs/efis") < 9) and (altitudeagl >= 200)) {

				setprop("/controls/fbw/active", 0);

				if (me.disconnectannounce == 0) {
					screen.log.write("Fly By Wire Disconnected!", 1, 0, 0);
					me.disconnectannounce = 1;
				}
			}
		}

		if (getprop("/controls/fbw/active")) {

			me.disconnectannounce = 0;

			## AILERON CONTROLS

			### Set Aileron Direction and Roll Direction

			if (roll < 0) var rolldir = -1;
			if (roll > 0) var rolldir = 1;
			if (roll == 0) var rolldir = 0;

			if (aileronin < 0) var ailerondir = -1;
			if (aileronin > 0) var ailerondir = 1;
			if (aileronin == 0) var ailerondir = 0;

			if (((roll <= banklimit) and (roll >= -banklimit)) or (rolldir != ailerondir)) {

				if (aileronin > aileronout) aileronout += 0.05 * fpsfix;

				if (aileronin < aileronout) aileronout -= 0.05 * fpsfix;

			} else {

				### Don't let the plane bank past the bank limit

				if (roll < -banklimit) me.targetaileron = -(roll + banklimit) * 0.025;
				if (roll > banklimit) me.targetaileron = -(roll - banklimit) * 0.025;

				if (aileronout < me.targetaileron) aileronout += 0.025 * fpsfix;
				if (aileronout > me.targetaileron) aileronout -= 0.025 * fpsfix;

			}

			## ELEVATOR CONTROLS

			if (elevatorin > elevatorout) elevatorout += 0.05 * fpsfix;
			if (elevatorin < elevatorout) elevatorout -= 0.05 * fpsfix;

			if ((elevatorin - elevatorout < 0.05) and (elevatorin - elevatorout > 0)) elevatorout += 0.01; 
			if ((elevatorout - elevatorin < 0.05) and (elevatorin - elevatorout < 0)) elevatorout -= 0.01; 

			## AUTO-STABILIZATION

			### Get the aircraft to maintain pitch and roll when stick is at the center

			if ((elevatorin <= 0.1) and (elevatorin >= -0.1) and (aileronin <= 0.1) and (aileronin >= -0.1)) {

				if (me.stabilize == 0) {
					setprop("/controls/fbw/stabpitch-deg", pitch);
					setprop("/controls/fbw/stabroll-deg", roll);
					me.stabilize = 1;
				}

				if ((airspeedkt >= 220) and (altitudeagl >= 3500) and (getprop("/autopilot/panel/master") != 1) and (getprop("/autopilot/hold/active") != 1) and (getprop("/connection/fgfscopilot/connected") != 1)) {
					setprop("/controls/fbw/autostable", 1);
				} 
				else {
					setprop("/controls/fbw/autostable", 0);
				}


			} else { 
				me.stabilize = 0;
				setprop("/controls/fbw/autostable", 0);
			}


			## THROTTLE CONTROLS

			### Disconnect Throttle fix if manually overridden

			if (throttle0 != me.throttle) {
				me.throttlefix = 0;
				me.turnthrottlefix = 0;
			}


			### Adjust throttle while turning

			if ((roll <= -5) or (roll >= 5)) {

				if (me.turnthrottlefix == 0) {
					me.throttleinit = throttle0;
					me.turnthrottlefix = 1;
				}

				me.targetthrottle = me.throttleinit + (me.throttleinit * math.sin(math.abs(roll * DEG2RAD)))/2;

				if (me.targetthrottle > throttle0) {
					throttle0 += 0.001 * fpsfix;
					throttle1 += 0.001 * fpsfix;
				} elsif (me.targetthrottle < throttle0) {
					throttle0 -= 0.001 * fpsfix;
					throttle1 -= 0.001 * fpsfix;
				} 

			} 


			if ((roll > -5) and (roll <= 5) and (me.turnthrottlefix == 1)) {

				if (throttle0 <= me.throttleinit - 0.05) {
					throttle0 += 0.001 * fpsfix;
					throttle1 += 0.001 * fpsfix;
				} elsif (throttle0 > me.throttleinit + 0.05) {
					throttle0 -= 0.001 * fpsfix;
					throttle1 -= 0.001 * fpsfix;
				} else me.turnthrottlefix = 0;
			}

			### Reduce throttle if aircraft is faster than 250 KIAS under 10000 ft

			if ((airspeedkt >= 250) and (altitudemsl <= 10000) and (throttle0 != 0) and (throttle1 != 0)) {
				throttle0 -= 0.001 * fpsfix;
				throttle1 -= 0.001 * fpsfix;
				me.throttlefix = 1;
			}

			if ((me.throttlefix == 1) and (airspeedkt < 245) and (altitudemsl <= 10000) and (throttle0 != 1) and (throttle1 != 1)) {
				throttle0 += 0.001 * fpsfix;
				throttle1 += 0.001 * fpsfix;
			}

			### Adjust Throttle to stay under Vne

			if ((airspeedkt >= 350) and (altitudemsl > 10000) and (throttle0 != 0) and (throttle1 != 0)) {
				throttle0 -= 0.001 * fpsfix;
				throttle1 -= 0.001 * fpsfix;
				me.throttlefix = 1;
			}

			if ((me.throttlefix == 1) and (airspeedkt < 340) and (altitudemsl > 10000) and (throttle0 != 1) and (throttle1 != 1)) {
				throttle0 += 0.001 * fpsfix;
				throttle1 += 0.001 * fpsfix;
			}

			### Adjust Throttle to keep from stalling

			if ((airspeedkt < 125) and (altitudeagl > 250) and (throttle0 != 1) and (throttle1 != 1)) {
				throttle0 += 0.001 * fpsfix;
				throttle1 += 0.001 * fpsfix;

				### Also help by pushing forward on the stick

				elevatorout += 0.02;
			}


			## BOEING 787-8 SPECIFIC > Trailing Edge Camber


			## ALPHA PROTECTION

			if ((getprop("/orientation/alpha-deg") != nil) and (getprop("/position/altitude-agl-ft") >= 1000)) {

				if (getprop("/orientation/alpha-deg") > 10) {
					setprop("/controls/fbw/alpha-protect", 1);
					setprop("/controls/fbw/alpha-limit", 10);

					throttle0 = 1;
					throttle1 = 1;

				} elsif (getprop("/orientation/alpha-deg") < -10) {
					setprop("/controls/fbw/alpha-protect", 1);
					setprop("/controls/fbw/alpha-limit", -10);
				} else setprop("/controls/fbw/alpha-protect", 0);

			} else setprop("/controls/fbw/alpha-protect", 0);

			## PROTECTION END TRIM FIX

			if (getprop("/controls/flight/elevator-trim") != nil) {
				if ((getprop("/controls/fbw/alpha-protect") == 0) and (getprop("/autopilot/panel/master") != 1) and (getprop("/autopilot/hold/active") != 1) and (getprop("/connection/fgfscopilot/connected") != 1)) {
					if (getprop("/controls/flight/elevator-trim") < 0) {
						setprop("/controls/flight/elevator-trim", getprop("/controls/flight/elevator-trim") + 0.005);
					} elsif (getprop("/controls/flight/elevator-trim") > 0) {
						setprop("/controls/flight/elevator-trim", getprop("/controls/flight/elevator-trim") - 0.005);
					}
				}
			}


			## RUDDER CONTROLS

			if (getprop("/controls/fbw/rudder")) {

				if ((roll < -5) or (roll > 5)) {
					me.targetrudder = aileronout / 2;

					if (me.targetrudder < rudderout) rudderout -= 0.015;
					if (me.targetrudder > rudderout) rudderout += 0.015;

				}
			}

			## YAW DAMPER

			if (getprop("/controls/fbw/yaw-damper")) {

				if (rudderin > rudderout) rudderout += 0.05 * fpsfix;

				if (rudderin < rudderout) rudderout -= 0.05 * fpsfix;

			} else {

				rudderout = rudderin;

			}

			# Transmit output signals to surfaces

			setprop(fcs~"aileron-fbw-output", aileronout);
			setprop(fcs~"elevator-fbw-output", elevatorout);
			setprop(fcs~"rudder-fbw-output", rudderout);

			setprop("controls/engines/engine[0]/throttle", throttle0);
			setprop("controls/engines/engine[1]/throttle", throttle1);

			me.throttle = throttle0; # This is to find out if the pilot moved the throttle


		} else {  # if not "/controls/fbw/active"

			# Transmit input signals directly to surfaces

			setprop(fcs~"aileron-fbw-output", aileronin);
			setprop(fcs~"elevator-fbw-output", elevatorin);
			setprop(fcs~"rudder-fbw-output", rudderin);

		}

	}, # Update Fuction end


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
###
# END fwb var
###

fbw.init();
print("Fly-By-Wire ......... Initialized");
sysinfo.log_msg("[FBW] Fly-by-Wire Engaged", 0);

# *Power-by-wire : corresponds to power steering in cars
