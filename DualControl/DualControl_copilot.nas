    var dualcontrol_copilot = {
       init : func {
            me.UPDATE_INTERVAL = 0.01;
            me.loopid = 0;
            me.reset();
    },
       update : func {

# Transmit all Switch properties to /sim/multiplay/generic

## Lighting Controls from the Overhead Panel

setprop("/sim/multiplay/generic/int[30]", getprop("controls/lighting/cockpit"));
setprop("/sim/multiplay/generic/int[31]", getprop("controls/lighting/beacon"));
setprop("/sim/multiplay/generic/int[32]", getprop("controls/lighting/strobe"));
setprop("/sim/multiplay/generic/int[33]", getprop("controls/lighting/nav-lights"));
setprop("/sim/multiplay/generic/int[34]", getprop("controls/lighting/wing-lights"));
setprop("/sim/multiplay/generic/int[35]", getprop("controls/lighting/logo"));
setprop("/sim/multiplay/generic/int[36]", getprop("controls/lighting/taxi-lights"));
setprop("/sim/multiplay/generic/int[37]", getprop("controls/lighting/landing-lights[0]"));

# Get Properties from pilot's /sim/multiplay/generic and convert to local

## Find Multiplayer Pilot Index

var n = 0;

while (getprop(""))

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
 dualcontrol_copilot.init();
 });
