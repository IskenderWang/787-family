var pneumatic = {
	init : func { 
        me.UPDATE_INTERVAL = 3; 
        me.loopid = 0; 
setprop("/controls/pneumatic/temp/hyd-sys2-elec", getprop("/environment/temperature-degc") );
setprop("/controls/pneumatic/temp/hyd-sys3-elec", getprop("/environment/temperature-degc") );
setprop("/controls/pneumatic/temp/hyd-sys0-eng", getprop("/environment/temperature-degc") );
setprop("/controls/pneumatic/temp/hyd-sys1-eng", getprop("/environment/temperature-degc") );

setprop("/controls/pneumatic/temp/fuel-pump-left", getprop("/environment/temperature-degc") );
setprop("/controls/pneumatic/temp/fuel-pump-center", getprop("/environment/temperature-degc") );
setprop("/controls/pneumatic/temp/fuel-pump-right", getprop("/environment/temperature-degc") );
setprop("/controls/pneumatic/equip-cooling", 1);

# Initialize by starting up Engine Bleeds and Pack 1

setprop("/controls/pneumatic/e1-bleed", 1);
setprop("/controls/pneumatic/e2-bleed", 1);
setprop("/controls/pneumatic/pack1", 1);

setprop("/controls/pneumatic/equipcooling", 1);
        me.reset(); 
}, 
	update : func {

# Setting Temperature Variables for each Hydraulic and Fuel Pumps

var outsidetemp = getprop("/environment/temperature-degc");

var temphyd2elec = getprop("/controls/pneumatic/temp/hyd-sys2-elec");
var temphyd3elec = getprop("/controls/pneumatic/temp/hyd-sys3-elec");

var temphyd0eng = getprop("/controls/pneumatic/temp/hyd-sys0-eng");
var temphyd1eng = getprop("/controls/pneumatic/temp/hyd-sys1-eng");

var tempfuelpumpleft = getprop("/controls/pneumatic/temp/fuel-pump-left");
var tempfuelpumpcenter = getprop("/controls/pneumatic/temp/fuel-pump-center");
var tempfuelpumpright = getprop("/controls/pneumatic/temp/fuel-pump-right");

var coolingeffect = 2;

# Heat up Hydraulic and Fuel systems when used

if ((getprop("/controls/hydraulic/serviceable/system0") == 1) and (getprop("/controls/hydraulic/system/engine-pump") == 1)) {
temphyd0eng = temphyd0eng + 1;
}

if ((getprop("/controls/hydraulic/serviceable/system1") == 1) and (getprop("/controls/hydraulic/system[1]/engine-pump") == 1)) {
temphyd1eng = temphyd1eng + 1;
}

if ((getprop("/controls/hydraulic/serviceable/system2") == 1) and (getprop("/controls/hydraulic/system[2]/electric-pump") == 1)) {
temphyd2elec = temphyd2elec + 1;
}

if ((getprop("/controls/hydraulic/serviceable/system3") == 1) and (getprop("/controls/hydraulic/system[3]/electric-pump") == 1)) {
temphyd3elec = temphyd3elec + 1;
}

if (getprop("consumables/fuel/tank[0]/selected") == 1) {
tempfuelpumpleft = tempfuelpumpleft + 0.5;
}
if (getprop("consumables/fuel/tank[2]/selected") == 1) {
tempfuelpumpcenter = tempfuelpumpcenter + 0.5;
}
if (getprop("consumables/fuel/tank[1]/selected") == 1) {
tempfuelpumpright = tempfuelpumpright + 0.5;
}

# Equipment Cooling

if (getprop("/controls/pneumatic/equipcooling") == 1) {

coolingeffect = coolingeffect + 3;

# Trim Air Cooling Effects


if (getprop("/controls/pneumatic/triml") == 1) {
coolingeffect = coolingeffect + 2;
}

if (getprop("/controls/pneumatic/trimr") == 1) {
coolingeffect = coolingeffect + 2;
}

# Pack 1 and 2 Cooling Effects

if (getprop("/controls/pneumatic/pack1") == 1) {

if ((getprop("/controls/pneumatic/e1-bleed") == 1) and (getprop("/engines/engine/n2") >= 30)) {
coolingeffect = coolingeffect + 3;
}
if ((getprop("/controls/pneumatic/e2-bleed") == 1) and (getprop("/engines/engine[1]/n2") >= 30)) {
coolingeffect = coolingeffect + 3;
}
if ((getprop("/controls/pneumatic/apu-bleed") == 1) and (getprop("engines/APU/running") == 1)) {
coolingeffect = coolingeffect + 2;
}

}

if (getprop("/controls/pneumatic/pack2") == 1) {

if ((getprop("/controls/pneumatic/e1-bleed") == 1) and (getprop("/engines/engine/n2") >= 30)) {
coolingeffect = coolingeffect + 3;
}
if ((getprop("/controls/pneumatic/e2-bleed") == 1) and (getprop("/engines/engine[1]/n2") >= 30)) {
coolingeffect = coolingeffect + 3;
}
if ((getprop("/controls/pneumatic/apu-bleed") == 1) and (getprop("engines/APU/running") == 1)) {
coolingeffect = coolingeffect + 2;
}

}

# Cool All Electric, Engine and Fuel Pumps according to Cooling Effect

if (temphyd2elec >= outsidetemp) {
temphyd2elec = temphyd2elec - (coolingeffect / 5);
}
if (temphyd3elec >= outsidetemp) {
temphyd3elec = temphyd3elec - (coolingeffect / 5);
}
if (temphyd0eng >= outsidetemp) {
temphyd0eng = temphyd0eng - (coolingeffect / 5);
}
if (temphyd1eng >= outsidetemp) {
temphyd1eng = temphyd1eng - (coolingeffect / 5);
}
if (tempfuelpumpleft >= outsidetemp) {
tempfuelpumpleft = tempfuelpumpleft - (coolingeffect / 5);
}
if (tempfuelpumpcenter >= outsidetemp) {
tempfuelpumpcenter = tempfuelpumpcenter - (coolingeffect / 5);
}
if (tempfuelpumpright >= outsidetemp) {
tempfuelpumpright = tempfuelpumpright - (coolingeffect / 5);
}

}

# Set Temperature properties after modifications

setprop("/controls/pneumatic/temp/hyd-sys2-elec", temphyd2elec);
setprop("/controls/pneumatic/temp/hyd-sys3-elec", temphyd3elec);

setprop("/controls/pneumatic/temp/hyd-sys0-eng", temphyd0eng);
setprop("/controls/pneumatic/temp/hyd-sys1-eng", temphyd1eng);

setprop("/controls/pneumatic/temp/fuel-pump-left", tempfuelpumpleft);
setprop("/controls/pneumatic/temp/fuel-pump-center", tempfuelpumpcenter);
setprop("/controls/pneumatic/temp/fuel-pump-right", tempfuelpumpright);

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
 pneumatic.init();
 print("Pneumatic System .... Initialized");
 });
