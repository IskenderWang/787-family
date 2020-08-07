var surge = {
	init : func { 
        me.UPDATE_INTERVAL = 0.05; 
        me.loopid = 0; 
	me.time = 0;
	me.flash = 5;
	me.surgewarn = 0;
	setprop("/sim/sound/surge", 0);
        me.reset(); 
}, 
	update : func {

if ((getprop("engines/engine/n1") > 70) and ((getprop("/velocities/airspeed-kt") > 400) or (getprop("/environment/rain-norm") > 0.9) or (getprop("/environment/snow-norm") > 0.7))) {
me.time = me.time + 0.05;
# Set Engine Failure if Surge lasts longer than 8 seconds
if (me.time >= 8) {
setprop("/sim/failure-manager/engines/engine/serviceable", 0);
setprop("/sim/failure-manager/engines/engine[1]/serviceable", 0);
}
# Engine Surge Flash
if (me.flash == 5) {
setprop("controls/surge/flash",1);
me.flash = 0;
} else {
setprop("controls/surge/flash",0);
}
me.flash = me.flash + 1;
# Engine Surge Warning
if (me.surgewarn == 0) {
screen.log.write("Engine Surge!", 1, 0, 0);
sysinfo.log_msg("[ENG] Engine Surge Warning", 2);
me.surgewarn = 1;
}
# Engine Surging Sound
setprop("/sim/sound/surge", 1);
} else {
me.time = 0;
setprop("/sim/sound/surge", 0);
setprop("controls/surge/flash",0);
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
 surge.init();
 });
