var warn = {
	init : func { 
        me.UPDATE_INTERVAL = 0.1; 
        me.loopid = 0; 
		
		me.mute = 0;
		
		setprop("/instrumentation/warn/master", 0);
		setprop("/instrumentation/warn/caution", 0);

        me.reset(); 
}, 
	update : func {

var master = 0;
var caution = 0;

# Master Warning Causes

## Engine Failures

if (getprop("/sim/failure-manager/engines/engine/serviceable") == 0) master = 1;
if (getprop("/sim/failure-manager/engines/engine[1]/serviceable") == 0) master = 1;

## Hydraulic Pump Faults

if (getprop("/controls/pneumatic/temp/hyd-sys2-elec") > 150) master = 1;
if (getprop("/controls/pneumatic/temp/hyd-sys3-elec") > 150) master = 1;
if (getprop("/controls/pneumatic/temp/hyd-sys0-eng") > 120) master = 1;
if (getprop("/controls/pneumatic/temp/hyd-sys1-eng") > 120) master = 1;

## Fuel Pump Faults

if (getprop("/controls/pneumatic/temp/fuel-pump-left") >= 200) master = 1;
if (getprop("/controls/pneumatic/temp/fuel-pump-center") >= 200) master = 1;
if (getprop("/controls/pneumatic/temp/fuel-pump-right") >= 200) master = 1;

## Critical Fuel Level

if (getprop("consumables/fuel/total-fuel-kg") <= 200) master = 1;

## Stall

if ((getprop("/velocities/airspeed-kt") < 120) and (getprop("/position/altitude-agl-ft") > 200)) master = 1;

# Master Caution Causes

## Fuel Imbalance

if (math.abs(getprop("/consumables/fuel/tank/level-kg") - getprop("/consumables/fuel/tank[1]/level-kg")) >= 1000) caution = 1;

## Hydraulic Pump Overheat

if (getprop("/controls/pneumatic/temp/hyd-sys2-elec") > 120) caution = 1;
if (getprop("/controls/pneumatic/temp/hyd-sys3-elec") > 120) caution = 1;
if (getprop("/controls/pneumatic/temp/hyd-sys0-eng") > 80) caution = 1;
if (getprop("/controls/pneumatic/temp/hyd-sys1-eng") > 80) caution = 1;

## Fuel Pump Overheat

if (getprop("/controls/pneumatic/temp/fuel-pump-left") >= 150) caution = 1;
if (getprop("/controls/pneumatic/temp/fuel-pump-center") >= 150) caution = 1;
if (getprop("/controls/pneumatic/temp/fuel-pump-right") >= 150) caution = 1;

## Ice Detected

if (getprop("/controls/ice/wing/temp") < 0) caution = 1;
if (getprop("/controls/ice/eng1/temp") < 0) caution = 1;
if (getprop("/controls/ice/eng2/temp") < 0) caution = 1;
if (getprop("/controls/window-heat/temp") < 0) caution = 1;

## Mach Trim Error

if (getprop("/controls/fbw/active") != 1) caution = 1;
 
## Low (not yet critical) Fuel

if (getprop("consumables/fuel/total-fuel-kg") <= 1000) caution = 1;

#------------------------------------------------#

setprop("/instrumentation/warn/master", master);
setprop("/instrumentation/warn/caution", caution);

if ((master == 1) and (me.mute == 0)) {
	setprop("/sim/sound/master-warn", 1);
}

if ((getprop("/instrumentation/warn/master-sound") == 0) and (me.mute == 0)) {
	me.mute == 1;
	setprop("/sim/sound/master-warn", 0);

}

if (master == 0) {
	setprop("/sim/sound/master-warn", 0);
	me.mute = 0;
	setprop("/instrumentation/warn/master-sound", 1);
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
 warn.init();
 });

