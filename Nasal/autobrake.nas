var autobrake = {
    init : func {
        me.UPDATE_INTERVAL = 0.5;
        me.loopid = 0;
        me.old_throttle = getprop("controls/engine[0]/throttle");
        me.current_spdbrk = getprop("controls/flight/speedbrake-lever");
        setprop("controls/autobrake/setting", 0);

        me.reset();
    },
    update : func {
        var current_throttle = getprop("controls/engines/engine[0]/throttle");
        var current_spdbrk = getprop("controls/flight/speedbrake-lever");
        var absetting = getprop("controls/autobrake/setting");

        # Handle disarming events
        #########################

        # Initiating a go-around after touchdown disarms the system.
        if (
            (absetting > 1)
            and (current_throttle > me.old_throttle)
            and (getprop("gear/gear[1]/rollspeed-ms") > 5)
            # The wheels will only be spinning if the aircraft has touched down.
        ) {
            setprop("controls/gear/brake-left", 0);
            setprop("controls/gear/brake-right", 0);
            setprop("controls/autobrake/setting", 1);
            #screen.log.write("Disarming Autobrakes after go-around"); # For testing
        }

        # Pressing the pedal brakes when the system is armed disarms the system.
        if (
            (absetting > 1)
            and (getprop("controls/gear/brake-left") > (absetting - 1) / 5)
        ) {
            setprop("controls/autobrake/setting", 1);

            #screen.log.write("Disarming Autobrakes after pedal input"); # For testing
            # The fact that `/controls/autobrake/setting` is tied to both the pedal brakes and
            # autobrakes limits our ability to detect pedal braking to just detecting more pedal
            # braking than the autobrake setting.
        }

        # Moving the speedbrake lever to down (0) after brakes have deployed on the ground disarms
        # the system.
        if (
            (getprop("gear/gear[1]/compression-ft") != 0)
            and (getprop("controls/gear/brake-left") > 0)
            and (me.old_spdbrk > 0)
            and (current_spdbrk == 0)
        ) {
            setprop("controls/autobrake/setting", 1);
            #screen.log.write("Disarming Autobrakes after speedbrakes down"); # For testing
        }

        # TODO: Add normal intiskid system fault and loss of inertial data from the IRUs as
        # disarming events.

        me.old_throttle = current_throttle;
        me.old_spdbrk = current_spdbrk;

        # Handle application of brake pressure
        ######################################

        # OFF & DISARM settings
        if ((absetting == 0) or (absetting == 1))
            return;

        # The wheels must be spinning to appy brakes
        if (getprop("gear/gear[1]/rollspeed-ms") < 5)
            return;

        # RTO setting
        if (absetting == -1) {
            # Set to OFF after takeoff
            if (getprop("gear/gear[1]/compression-ft") == 0) {
                #screen.log.write("Setting Autobrakes to OFF after takeoff"); # For testing
                setprop("controls/autobrake/setting", 0);
            }

            # 43.5 rollspeed means 85 kt ground speed
            if (
                (getprop("gear/gear[1]/rollspeed-ms") > 43.5)
                and (current_throttle == 0)
            ) {
                #screen.log.write("Applying autobrakes after RTO"); # For testing
                setprop("controls/gear/brake-left", 1);
                setprop("controls/gear/brake-right", 1);
            }

            return;
        }

        # Throttle has to be set to idle to apply brake pressure.
        if ((current_throttle != 0))
            return;

        # AUTOBRAKE MAX setting
        if (absetting == 6) {
            # We should be detecting a pitch angle lower than 1°, but this can be unreliable in
            # sloped runways, so instead we detect that the nose wheel is touching the ground.
            if (getprop("gear/gear[0]/compression-ft") == 0) {
                #screen.log.write("Setting Autobrakes to 0.8 MAX"); # For testing
                setprop("controls/gear/brake-left", 0.8);
                setprop("controls/gear/brake-right", 0.8);
                return;
            }

            # Set the brakes to MAX after nose wheel touches the ground.
            #screen.log.write("Setting Autobrakes to 1.0 MAX"); # For testing
            setprop("controls/gear/brake-left", 1);
            setprop("controls/gear/brake-right", 1);

            return;
        }

        # All remaining autobrake settings
        #screen.log.write("Setting autobrakes to " ~ (absetting - 1) / 5.0 ~ "."); # For testing
        setprop("controls/gear/brake-left", (absetting - 1) / 5.0);
        setprop("controls/gear/brake-right", (absetting - 1) / 5.0);

        # The brakes will stay applied until coming to a complete stop or until it's disarmed.
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
    autobrake.init();
    print("Autobrake System .... Initialized");
    sysinfo.log_msg("[ABS] Autobrake System Initialized", 0);
});

# Notes:
# 1. `gear/gear[0]` is the nose gear (first to takeoff, last to land)
# 2. `gear/gear[1]` is the left gear (last to takeoff, first to land)
# 3. RTO position is -1
# 4. OFF position is 0, DISARM position is 1
# 5. 2 to 6 are autobrake 1 to MAX
