var heating = {
	init : func { 
        me.UPDATE_INTERVAL = 2; 
        me.loopid = 0; 
	me.icewarn = 0;
setprop("/controls/window-heat/temp", getprop("/environment/temperature-degc") );

        me.reset(); 
}, 
	update : func {

var outsidetemp = getprop("/environment/temperature-degc");
var windowtemp = getprop("/controls/window-heat/temp");

if ((getprop("/controls/window-heat/engage") == 0) or (outsidetemp > 15)) {

if (outsidetemp > windowtemp) {
windowtemp = windowtemp + 0.5;

if ((windowtemp <= -20) and (me.icewarn == 0)) {
screen.log.write("You window seems to getting foggy due to the Low Temperature.", 1, 0, 0);
screen.log.write("You might want to turn on the Window Heating from the Overhead Panel.", 1, 0, 0);
sysinfo.log_msg("[HEAT] Window Ice Detected", 1);
me.icewarn = 1;
}

}

if (outsidetemp < windowtemp) {
windowtemp = windowtemp - 0.5;
}

} else {

if (windowtemp < 15) {
windowtemp = windowtemp + 0.25;
}

}

setprop("/controls/window-heat/temp", windowtemp);
setprop("/controls/window-heat/fog", windowtemp / -45);

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
 heating.init();
 print("Heating System ...... Initialized");
 });
