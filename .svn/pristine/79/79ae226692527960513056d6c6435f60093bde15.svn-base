# Boeing 787-8 Hydraulic Pump System
# by Omega Pilot (MIA0001)

var hydraulics = {
	init : func { 
        me.UPDATE_INTERVAL = 0.5; 
        me.loopid = 0; 

	me.ratannounce = 0;

setprop("/controls/hydraulic/system[0]/engine-pump", 1);
setprop("/controls/hydraulic/system[1]/engine-pump", 1);
setprop("/controls/hydraulic/system[2]/electric-pump", 1);
setprop("/controls/hydraulic/system[3]/electric-pump", 0);
setprop("controls/electric/external-power", 1);

# Initialize Settings

setprop("/controls/hydraulic/system[0]/setting", 2);
setprop("/controls/hydraulic/system[1]/setting", 0);
setprop("/controls/hydraulic/system[2]/setting", 2);
setprop("/controls/hydraulic/system[3]/setting", 0);

        me.reset(); 
}, 
	update : func {

var setting0 = getprop("/controls/hydraulic/system[0]/setting");
var setting1 = getprop("/controls/hydraulic/system[1]/setting");
var setting2 = getprop("/controls/hydraulic/system[2]/setting");
var setting3 = getprop("/controls/hydraulic/system[3]/setting");

# Initialize Auto Hydraulic Control System

## AUTO CONTROL LOGIC
### System 0 will only run when system 1 is turned off or vice versa. 1 of the systems will turn down when their temperature goes above 70 degrees C. System 0 and 1 (the engine systems) control the same thing and so do systems 2 and 3. System 2 and 3 will also interchange but at 70 degrees C too. The AutoTempControl is to turn off a system when it overheats.


var AutoTempControl = func(system_no) {

# Set Control Property Tree
var hydTree = "/controls/hydraulic/system[" ~ system_no ~ "]/";

if (getprop("/environment/temperature-degc") <= 5) {
setprop(hydTree ~ "engine-pump", 0);
setprop(hydTree ~ "electric-pump", 0);
} else {
setprop(hydTree ~ "engine-pump", 1);
setprop(hydTree ~ "electric-pump", 1);
}
};

# Connect the Hydraulic Setting Knobs to Pump Controls

## Setting 0 > OFF
## Setting 1 > AUTO (recommended)
## Setting 2 > ON

if (setting0 == 0) {
setprop("/controls/hydraulic/system[0]/engine-pump", 0);
} elsif (setting0 == 1) {
if (getprop("/controls/hydraulic/system[1]/engine-pump") == 1) {
setprop("/controls/hydraulic/system[0]/engine-pump", 0);
} else {
setprop("/controls/hydraulic/system[0]/engine-pump", 1);
}
AutoTempControl(0);
} elsif (setting0 == 2) {
setprop("/controls/hydraulic/system[0]/engine-pump", 1);
}

if (setting1 == 0) {
setprop("/controls/hydraulic/system[1]/engine-pump", 0);
} elsif (setting1 == 1) {
if (getprop("/controls/hydraulic/system[0]/engine-pump") == 1) {
setprop("/controls/hydraulic/system[1]/engine-pump", 0);
} else {
setprop("/controls/hydraulic/system[1]/engine-pump", 1);
}
AutoTempControl(1);
} elsif (setting1 == 2) {
setprop("/controls/hydraulic/system[1]/engine-pump", 1);
}

if (setting2 == 0) {
setprop("/controls/hydraulic/system[2]/electric-pump", 0);
} elsif (setting2 == 1) {
if (getprop("/controls/hydraulic/system[3]/electric-pump") == 1) {
setprop("/controls/hydraulic/system[2]/electric-pump", 0);
} else {
setprop("/controls/hydraulic/system[2]/engine-pump", 1);
}
AutoTempControl(2);
} elsif (setting2 == 2) {
setprop("/controls/hydraulic/system[2]/electric-pump", 1);
}

if (setting3 == 0) {
setprop("/controls/hydraulic/system[3]/electric-pump", 0);
} elsif (setting3 == 1) {
if (getprop("/controls/hydraulic/system[2]/electric-pump") == 1) {
setprop("/controls/hydraulic/system[3]/electric-pump", 0);
} else {
setprop("/controls/hydraulic/system[3]/engine-pump", 1);
}
AutoTempControl(3);
} elsif (setting3 == 2) {
setprop("/controls/hydraulic/system[3]/electric-pump", 1);
}

# Set Hydraulic failures and overheats according to pump temperature

if ( getprop("/controls/pneumatic/temp/hyd-sys2-elec") >= 120 ) {
setprop("/controls/hydraulic/system[2]/electric-pump", 0);
}
if ( getprop("/controls/pneumatic/temp/hyd-sys3-elec") >= 120 ) {
setprop("/controls/hydraulic/system[3]/electric-pump", 0);
}
if ( getprop("/controls/pneumatic/temp/hyd-sys0-eng") >= 120 ) {
setprop("/controls/hydraulic/system[0]/engine-pump", 0);
}
if ( getprop("/controls/pneumatic/temp/hyd-sys1-eng") >= 120 ) {
setprop("/controls/hydraulic/system[1]/engine-pump", 0);
}

# Set Power from Engines to separate property in /controls/hydraulic

if ( getprop("/engines/engine/n2") >= 30 ) {
eng2input = 28;
} else {
eng2input = 0;
}

if ( getprop("/engines/engine[1]/n2") >= 30 ) {
eng1input = 28;
} else {
eng1input = 0;
}

if ( getprop("/engines/APU/running") == 1 ) {
apuinput = 28;
} else {
apuinput = 0;
}

if ( getprop("/controls/switch/battery-switch") == 1 ) {
batinput = 12;
} else {
batinput = 0;
}

if ((getprop("controls/electric/external-power") == 1 ) and (getprop("/position/altitude-agl-ft") <= 40)) {
extinput = 32;
} else {
extinput = 0;
}

if (( getprop("/controls/electric/ram-air-turbine") == 1 ) and (getprop("/velocities/airspeed-kt") >= 100)) {
ratinput =12;
} else {
ratinput = 0;
}

totalinput = extinput + eng1input + eng2input + apuinput + batinput + ratinput;

# Announce if power is low and RAT is required

if ((totalinput < 28) and (me.ratannounce != 1) and (getprop("/position/altitude-agl-ft") >= 100) and (getprop("/controls/electric/ram-air-turbine") != 1)) {
screen.log.write("Your Plane doesn't seem the getting enough power.", 1, 0, 0);
screen.log.write("Look up at the Overhead Panel and Turn the Ram Air Turbine On...", 1, 0, 0);
me.ratannounce = 1;
}

# Central Hydraulics System 2 (Priority = 1)
# Central Hydraulics System 3 (Priority = 2)

## Both Electric Pumps are connected to the same Central System

if ((totalinput >= 12) and ((getprop("/controls/hydraulic/system[2]/electric-pump") == 1) or (getprop("/controls/hydraulic/system[3]/electric-pump") == 1))) {
setprop("/controls/hydraulic/serviceable/system2", 1 );
setprop("/controls/hydraulic/serviceable/system3", 1 );
totalinput = totalinput - 12;
} else {
setprop("/controls/hydraulic/serviceable/system2", 0 );
setprop("/controls/hydraulic/serviceable/system3", 0 );
}

# Central Hydraulics System 0 (Priority = 3)

if ((totalinput >= 28) and (getprop("/controls/hydraulic/system[0]/engine-pump") == 1)) {
setprop("/controls/hydraulic/serviceable/system0", 1 );
totalinput = totalinput - 28;
} else {
setprop("/controls/hydraulic/serviceable/system0", 0 );
}

# Central Hydraulics System 1 (Priority = 4)

if ((totalinput >= 28) and (getprop("/controls/hydraulic/system[1]/engine-pump") == 1)) {
setprop("/controls/hydraulic/serviceable/system1", 1 );
totalinput = totalinput - 28;
} else {
setprop("/controls/hydraulic/serviceable/system1", 0 );
}

# Connect Hydraulic Control to Flight Controls

var system0 = getprop("/controls/hydraulic/serviceable/system0");
var system1 = getprop("/controls/hydraulic/serviceable/system1");
var system2 = getprop("/controls/hydraulic/serviceable/system2");
var system3 = getprop("/controls/hydraulic/serviceable/system3");

## Connect System 0 and 1 to Flaps and Spoilers

if ((system0 == 1) or (system1 == 1)) {
setprop("/sim/failure-manager/controls/flight/flaps/serviceable", 1);
setprop("/sim/failure-manager/controls/flight/speedbrake/serviceable", 1);

# Fail Gear System only if Gear is Down, when it's up it assumes alternate gravity Gear
if (getprop("/gear/gear/position-norm") == 1) {
setprop("/gear/servicable", 0);
}

} else {
setprop("/sim/failure-manager/controls/flight/flaps/serviceable", 0);
setprop("/sim/failure-manager/controls/flight/speedbrake/serviceable", 0);
setprop("/gear/servicable", 1);
}

## Connect System 2 to Ailerons

if (system2 == 1) {
setprop("/sim/failure-manager/controls/flight/aileron/serviceable", 1);
} else {
setprop("/sim/failure-manager/controls/flight/aileron/serviceable", 0);
}

## Connect System 3 to Rudder and Elevators

if (system3 == 1) {
setprop("/sim/failure-manager/controls/flight/rudder/serviceable", 1);
setprop("/sim/failure-manager/controls/flight/elevator/serviceable", 1);
} else {
setprop("/sim/failure-manager/controls/flight/rudder/serviceable", 0);
setprop("/sim/failure-manager/controls/flight/elevator/serviceable", 0);
}

if ((getprop("/controls/hydraulic/system[2]/electric-pump") == 1) or (getprop("/controls/hydraulic/system[3]/electric-pump") == 1)) {
setprop("/controls/hydraulic/systemc", 1);
} else {
setprop("/controls/hydraulic/systemc", 0);
}

if ((getprop("/controls/hydraulic/system/engine-pump") == 1) or (getprop("/controls/hydraulic/system[1]/engine-pump") == 1)) {
setprop("/controls/hydraulic/systeme", 1);
} else {
setprop("/controls/hydraulic/systeme", 0);
}

if (getprop("/controls/hydraulic/fail/system0") == 1)
	setprop("/controls/hydraulic/serviceable/system0", 0);
	
if (getprop("/controls/hydraulic/fail/system1") == 1)
	setprop("/controls/hydraulic/serviceable/system1", 0);

if (getprop("/controls/hydraulic/fail/system2") == 1)
	setprop("/controls/hydraulic/serviceable/system2", 0);

if (getprop("/controls/hydraulic/fail/system2") == 1)
	setprop("/controls/hydraulic/serviceable/system3", 0);


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
 hydraulics.init();
 print("Hydraulic System .... Initialized");
 sysinfo.log_msg("[HYD] Systems Check ...... OK", 0);
 });
