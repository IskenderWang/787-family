var autobrake = {
	init : func { 
        me.UPDATE_INTERVAL = 0.5; 
        me.loopid = 0; 
	me.fullthrottle = 0;
setprop("/controls/autobrake/setting", 0);

        me.reset(); 
}, 
	update : func {

var absetting = getprop("/controls/autobrake/setting");

if ((getprop("/velocities/airspeed-kt") >= 40) and (getprop("gear/gear[0]/rollspeed-ms") > 5)) {

# ABS LOW 1
if (absetting == 1) {
setprop("controls/gear/brake-left", 0.2);
setprop("controls/gear/brake-right", 0.2);
}

# ABS LOW 2
if (absetting == 2) {
setprop("controls/gear/brake-left", 0.4);
setprop("controls/gear/brake-right", 0.4);
}

# ABS MED 3
if (absetting == 3) {
setprop("controls/gear/brake-left", 0.6);
setprop("controls/gear/brake-right", 0.6);
}

# ABS HIGH 4
if (absetting == 4) {
setprop("controls/gear/brake-left", 0.8);
setprop("controls/gear/brake-right", 0.8);
}

# ABS MAX 5
if (absetting == 5) {
setprop("controls/gear/brake-left", 1);
setprop("controls/gear/brake-right", 1);
}

# ABS RTO
if (absetting == 6) {
if (getprop("controls/engines/engine[0]/throttle") >= 0.9) {
me.fullthrottle = 1;
}

if ((me.fullthrottle == 1) and (getprop("controls/engines/engine[0]/throttle") <= 0.6)) {
setprop("controls/gear/brake-left", 1);
setprop("controls/gear/brake-right", 1);
me.fullthrottle = 0;
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
 autobrake.init();
 print("Autobrake System .... Initialized");
 sysinfo.log_msg("[ABS] Autobrake System Initialized", 0); 
 });
