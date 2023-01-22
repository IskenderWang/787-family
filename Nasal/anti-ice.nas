var icing = {
    init : func {
        me.UPDATE_INTERVAL = 5;
        me.loopid = 0;
        me.icewarnw = 0;
        me.icewarne1 = 0;
        me.icewarne2 = 0;
        setprop("/controls/ice/wing/temp", getprop("/environment/temperature-degc") );
        setprop("/controls/ice/eng1/temp", getprop("/environment/temperature-degc") );
        setprop("/controls/ice/eng2/temp", getprop("/environment/temperature-degc") );

        if (getprop("/environment/temperature-degc") <= 0) {
            setprop("/controls/ice/wing/anti-ice-setting", 2);
            setprop("/controls/ice/eng1/anti-ice-setting", 2);
            setprop("/controls/ice/eng2/anti-ice-setting", 2);
        } else {
            setprop("/controls/ice/wing/anti-ice-setting", 1);
            setprop("/controls/ice/eng1/anti-ice-setting", 1);
            setprop("/controls/ice/eng2/anti-ice-setting", 1);
        }

        me.reset();
    },
    update : func {
        var outsidetemp = getprop("/environment/temperature-degc");
        var wingtemp = getprop("/controls/ice/wing/temp");
        var eng1temp = getprop("/controls/ice/eng1/temp");
        var eng2temp = getprop("/controls/ice/eng2/temp");

        # Calculate TAT Value (TAT = static temp (1 +((1.4 - 1) / 2) Mach^2) )

        setprop("/controls/ice/tat", outsidetemp * (1 + (0.2 * getprop("/velocities/mach") * getprop("/velocities/mach"))) );

        # Automatic Anti-Ice Control System

        var wingicesetting = getprop("/controls/ice/wing/anti-ice-setting");
        var eng1icesetting = getprop("/controls/ice/eng1/anti-ice-setting");
        var eng2icesetting = getprop("/controls/ice/eng2/anti-ice-setting");

        # Initialize Auto Anti-Ice Control System

        var AutoAntiIce = func(part) {
            var Temp = getprop("/controls/ice/" ~ part ~ "/temp");

            if (Temp <= -10)
                setprop("/controls/" ~ part ~ "/anti-ice", 1);
            else
                setprop("/controls/" ~ part ~ "/anti-ice", 0);
        };

        if (wingicesetting == 0)
            setprop("/controls/ice/wing/anti-ice", 0);
        elsif (wingicesetting == 1)
            AutoAntiIce("wing");
        else
            setprop("/controls/ice/wing/anti-ice", 1);

        if (eng1icesetting == 0)
            setprop("/controls/ice/eng1/anti-ice", 0);
        elsif (eng1icesetting == 1)
            AutoAntiIce("eng1");
        else
            setprop("/controls/ice/eng1/anti-ice", 1);

        if (eng2icesetting == 0)
            setprop("/controls/ice/eng2/anti-ice", 0);
        elsif (eng2icesetting == 1)
            AutoAntiIce("eng2");
        else
            setprop("/controls/ice/eng2/anti-ice", 1);

        # Wing Ice
        if ((getprop("/controls/ice/wing/anti-ice") == 0) or (outsidetemp > 15)) {
            if (outsidetemp > wingtemp) {
                wingtemp = wingtemp + 1;

                if ((wingtemp <= 0) and (me.icewarnw == 0)) {
                    screen.log.write("Wing Ice Alert!", 1, 0, 0);
                    sysinfo.log_msg("[HEAT] Ice Detected on Wings", 1);
                    me.icewarnw = 1;
                }
            }

            if (outsidetemp < wingtemp)
                wingtemp = wingtemp - 0.25;
        } elsif (wingtemp < 15) {
            wingtemp = wingtemp + 1;
        }

        # Engine 1 Ice
        if ((getprop("/controls/ice/eng1/anti-ice") == 0) or (outsidetemp > 15)) {
            if (outsidetemp > eng1temp) {
                eng1temp = eng1temp + 1;

                if ((eng1temp <= 0) and (me.icewarne1 == 0)) {
                    screen.log.write("Engine 1 Ice Alert!", 1, 0, 0);
                    sysinfo.log_msg("[HEAT] Ice Detected on Engine 1", 1);
                    me. icewarne1 = 1;
                }
            }

            if (outsidetemp < eng1temp)
                eng1temp = eng1temp - 0.25;
        } elsif (eng1temp < 15) {
            eng1temp = eng1temp + 1;
        }

        # Engine 2 Ice

        if ((getprop("/controls/ice/eng2/anti-ice") == 0) or (outsidetemp > 15)) {
            if (outsidetemp > eng2temp) {
                eng2temp = eng2temp + 1;

                if ((eng2temp <= 0) and (me.icewarne2 == 0)) {
                    screen.log.write("Engine 2 Ice Alert!", 1, 0, 0);
                    sysinfo.log_msg("[HEAT] Ice Detected on Engine 2", 1);
                    me. icewarne2 = 1;
                }
            }

            if (outsidetemp < eng2temp)
                eng2temp = eng2temp - 0.25;
        } elsif (eng2temp < 15) {
            eng2temp = eng2temp + 1;
        }

        # Exporting nasal variables back to the property tree

        setprop("/controls/ice/wing/temp", wingtemp);
        setprop("/controls/ice/eng1/temp", eng1temp);
        setprop("/controls/ice/eng2/temp", eng2temp);

        # Set Engine Failures in case of Heavy Ice

        if (eng1temp <= -30)
            setprop("/controls/engines/engine/cut-off", 1);

        if (eng2temp <= -30)
            setprop("/controls/engines/engine[1]/cut-off", 1);

        # Set Wing Lift and Drag Coefficients according to temperature

        if (wingtemp>=0) {
            setprop("/controls/ice/wing/lift-coefficient", 1);
            setprop("/controls/ice/wing/drag-coefficient", 1);
        } else {
            setprop("/controls/ice/wing/lift-coefficient", 1 + ( wingtemp / 80 ) );
            setprop("/controls/ice/wing/drag-coefficient", 1 - ( wingtemp / 80 ) );
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

setlistener("sim/signals/fdm-initialized", func {
    icing.init();
    print("Anti-Icing .......... Initialized");
    sysinfo.log_msg("[HEAT] System Check ...... OK", 0);
});
