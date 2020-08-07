var fuelsystem = {
	init : func { 
        me.UPDATE_INTERVAL = 0.1; 
        me.loopid = 0; 

setprop("consumables/fuel/tank[0]/selected", 0);
setprop("consumables/fuel/tank[2]/selected", 0);
setprop("consumables/fuel/tank[1]/selected", 0);

setprop("/controls/jettison/setting", 0);

        me.reset(); 
}, 
	update : func {

var tank1kg = getprop("/consumables/fuel/tank/level-kg");
var tank2kg = getprop("/consumables/fuel/tank[1]/level-kg");
var tankckg = getprop("/consumables/fuel/tank[2]/level-kg");

var tank1lbs = getprop("/consumables/fuel/tank/level-lbs");
var tank2lbs = getprop("/consumables/fuel/tank[1]/level-lbs");
var tankclbs = getprop("/consumables/fuel/tank[2]/level-lbs");

setprop("/controls/fuel/lbsx1000", (tank1lbs + tank2lbs + tankclbs)/1000);
setprop("/controls/fuel/ctank", tankclbs/1000);
setprop("/controls/fuel/ltank", tank1lbs/1000);
setprop("/controls/fuel/rtank", tank2lbs/1000);

# Fail Fuel Pumps if Overheated

if (getprop("/controls/pneumatic/temp/fuel-pump-left") >= 200) {
setprop("consumables/fuel/tank[0]/selected", 0);
}
if (getprop("/controls/pneumatic/temp/fuel-pump-center") >= 200) {
setprop("consumables/fuel/tank[2]/selected", 0);
}
if (getprop("/controls/pneumatic/temp/fuel-pump-right") >= 200) {
setprop("consumables/fuel/tank[1]/selected", 0);
}

# Cross Feed

if (getprop("/controls/fuel/x-feed") == 1) {

if (tank1kg > tank2kg) {
setprop("/consumables/fuel/tank/level-kg", tank1kg - 5);
setprop("/consumables/fuel/tank[1]/level-kg", tank2kg + 5);
}

if (tank1kg < tank2kg) {
setprop("/consumables/fuel/tank/level-kg", tank1kg + 5);
setprop("/consumables/fuel/tank[1]/level-kg", tank2kg - 5);
}

}

# Fuel Dump (Advanced Fuel Jettison System :P)

if (getprop("/controls/jettison/arm") == 1) {

var jettisonsetting = getprop("/controls/jettison/setting");

if (jettisonsetting == 0) {
fuelloss = 2;
}
if (jettisonsetting == 1) {
fuelloss = 5;
}
if (jettisonsetting == 2) {
fuelloss = 10;
}

if (getprop("/controls/jettison/lnozzle") == 1) {
if (tank1kg > 100) {
setprop("/consumables/fuel/tank/level-kg", tank1kg - fuelloss);
}
if (tankckg > 100) {
setprop("/consumables/fuel/tank[2]/level-kg", tankckg - (fuelloss / 2));
}
}

if (getprop("/controls/jettison/rnozzle") == 1) {
if (tank2kg > 100) {
setprop("/consumables/fuel/tank[1]/level-kg", tank2kg - fuelloss);
}
if (tankckg > 100) {
setprop("/consumables/fuel/tank[2]/level-kg", tankckg - (fuelloss / 2));
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
 fuelsystem.init();
 print("Fuel System ......... Initialized");
 sysinfo.log_msg("[FUEL] Systems Check ..... OK", 0);
 });
