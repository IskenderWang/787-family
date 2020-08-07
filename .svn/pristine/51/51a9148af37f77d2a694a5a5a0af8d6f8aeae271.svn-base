var RAD2DEG = 57.2957795;
var DEG2RAD = 0.016774532925;
var wmap = "/instrumentation/world-map/";

    var satellite_map = {
       init : func {
            me.UPDATE_INTERVAL = 60;
            me.loopid = 0;

			setprop(wmap ~ "wmap[1]/latitude-deg", getprop("/position/latitude-deg"));
			setprop(wmap ~ "wmap[1]/longitude-deg", getprop("/position/longitude-deg"));
			setprop(wmap ~ "wmap[2]/latitude-deg", getprop("/position/latitude-deg"));
			setprop(wmap ~ "wmap[2]/longitude-deg", getprop("/position/longitude-deg"));
			setprop(wmap ~ "wmap[3]/latitude-deg", getprop("/position/latitude-deg"));
			setprop(wmap ~ "wmap[3]/longitude-deg", getprop("/position/longitude-deg"));
			setprop(wmap ~ "wmap[4]/latitude-deg", getprop("/position/latitude-deg"));
			setprop(wmap ~ "wmap[4]/longitude-deg", getprop("/position/longitude-deg"));
			setprop(wmap ~ "wmap[5]/latitude-deg", getprop("/position/latitude-deg"));
			setprop(wmap ~ "wmap[5]/longitude-deg", getprop("/position/longitude-deg"));
			setprop(wmap ~ "wmap[6]/latitude-deg", getprop("/position/latitude-deg"));
			setprop(wmap ~ "wmap[6]/longitude-deg", getprop("/position/longitude-deg"));
			setprop(wmap ~ "wmap[7]/latitude-deg", getprop("/position/latitude-deg"));
			setprop(wmap ~ "wmap[7]/longitude-deg", getprop("/position/longitude-deg"));
			setprop(wmap ~ "wmap[8]/latitude-deg", getprop("/position/latitude-deg"));
			setprop(wmap ~ "wmap[8]/longitude-deg", getprop("/position/longitude-deg"));
			setprop(wmap ~ "wmap[9]/latitude-deg", getprop("/position/latitude-deg"));
			setprop(wmap ~ "wmap[9]/longitude-deg", getprop("/position/longitude-deg"));

            me.reset();
    },
       update : func {

# Move the Red marker positions down step by step

setprop(wmap ~ "wmap[9]/latitude-deg", getprop(wmap ~ "wmap[8]/latitude-deg"));
setprop(wmap ~ "wmap[9]/longitude-deg", getprop(wmap ~ "wmap[8]/longitude-deg"));

setprop(wmap ~ "wmap[8]/latitude-deg", getprop(wmap ~ "wmap[7]/latitude-deg"));
setprop(wmap ~ "wmap[8]/longitude-deg", getprop(wmap ~ "wmap[7]/longitude-deg"));

setprop(wmap ~ "wmap[7]/latitude-deg", getprop(wmap ~ "wmap[6]/latitude-deg"));
setprop(wmap ~ "wmap[7]/longitude-deg", getprop(wmap ~ "wmap[6]/longitude-deg"));

setprop(wmap ~ "wmap[6]/latitude-deg", getprop(wmap ~ "wmap[5]/latitude-deg"));
setprop(wmap ~ "wmap[6]/longitude-deg", getprop(wmap ~ "wmap[5]/longitude-deg"));

setprop(wmap ~ "wmap[5]/latitude-deg", getprop(wmap ~ "wmap[4]/latitude-deg"));
setprop(wmap ~ "wmap[5]/longitude-deg", getprop(wmap ~ "wmap[4]/longitude-deg"));

setprop(wmap ~ "wmap[4]/latitude-deg", getprop(wmap ~ "wmap[3]/latitude-deg"));
setprop(wmap ~ "wmap[4]/longitude-deg", getprop(wmap ~ "wmap[3]/longitude-deg"));

setprop(wmap ~ "wmap[3]/latitude-deg", getprop(wmap ~ "wmap[2]/latitude-deg"));
setprop(wmap ~ "wmap[3]/longitude-deg", getprop(wmap ~ "wmap[2]/longitude-deg"));

setprop(wmap ~ "wmap[2]/latitude-deg", getprop(wmap ~ "wmap[1]/latitude-deg"));
setprop(wmap ~ "wmap[2]/longitude-deg", getprop(wmap ~ "wmap[1]/longitude-deg"));

# Get latitude and longitude and set it to wmap_1

setprop(wmap ~ "wmap[1]/latitude-deg", getprop("/position/latitude-deg"));
setprop(wmap ~ "wmap[1]/longitude-deg", getprop("/position/longitude-deg"));

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
 satellite_map.init();
 print("Satellite Imaging ... Initialized");
 });
