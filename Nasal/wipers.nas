var wipers = {
    init : func {
        me.UPDATE_INTERVAL = 0.001;
        me.loopid = 0;

        me.direction = 0;
        me.delay = 0;

        me.reset();
    },
    update : func {
        # Update Wiper Position Function

        if (getprop("/sim/frame-rate") != nil)
            var fpsfix = 25 / getprop("/sim/frame-rate");
        else
            fpsfix = 1;

        var wiperpos = getprop("/controls/wipers/degrees");
        var speed = getprop("/controls/wipers/speed");
        var delay = getprop("/controls/wipers/delay");

        if (speed > 0)
            setprop("/environment/aircraft-effects/use-wipers", 1.0);
        else
            setprop("/environment/aircraft-effects/use-wipers", 0.0);

        # INT speed
        if (speed == 1) {
            if (me.delay == 1) {
                if (me.direction == 0)
                    setprop("/controls/wipers/delay", delay + 2);

                if (me.direction == 1)
                    setprop("/controls/wipers/delay", delay - 2);

                if (delay <= 0) {
                    me.direction = 0;
                    me.delay = 0;
                }

                if (delay >= 40)
                    me.direction = 1;
            } else {
                if (me.direction == 0)
                    setprop("/controls/wipers/degrees", wiperpos + 2);

                if (me.direction == 1)
                    setprop("/controls/wipers/degrees", wiperpos - 2);

                if (wiperpos <= 0) {
                    me.direction = 0;
                    me.delay = 1;
                }

                if (wiperpos >= 40)
                    me.direction = 1;
            }
        }

        # LOW speed
        if (speed == 2) {
            if (me.direction == 0)
                setprop("/controls/wipers/degrees", wiperpos + 2);

            if (me.direction == 1)
                setprop("/controls/wipers/degrees", wiperpos - 2);

            if (wiperpos >= 40)
                me.direction = 1;
            elsif (wiperpos <= 0)
                me.direction = 0;
        }

        # HIGH speed
        if (speed == 3) {
            if (me.direction == 0)
                setprop("/controls/wipers/degrees", wiperpos + 4);

            if (me.direction == 1)
                setprop("/controls/wipers/degrees", wiperpos - 4);

            if (wiperpos >= 40)
                me.direction = 1;
            elsif (wiperpos <= 0)
                me.direction = 0;
        }

        # Handle OFF setting when wipers are not stowed vertically
        if ((speed == 0) and (getprop("/controls/wipers/degrees") >= 2)) {
            setprop("/controls/wipers/degrees", getprop("/controls/wipers/degrees") - 2);
            me.delay = 0;
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
    wipers.init();
    print("Windshield Wipers ... Initialized");
});
