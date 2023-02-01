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

        var rear_on_ground = getprop("gear/gear[1]/wow") or getprop("gear/gear[2]/wow");
        var rear_spin = getprop("gear/gear[1]/rollspeed-ms");
        if (rear_spin < getprop("gear/gear[2]/rollspeed-ms"))
            rear_spin = getprop("gear/gear[2]/rollspeed-ms");

        # The pressure will be interpolated to go from 0 to 1 in 1 second (or, for eg, 0 to 0.2 in 0.2 seconds)
        var brake_pressure = (absetting - 1) / 5.0;

        # Handle disarming events
        #########################

        # Initiating a go-around after touchdown disarms the system.
        if (
            absetting > 1
            and current_throttle > me.old_throttle
            and rear_spin > 5
            # The wheels will only be spinning if the aircraft has touched down.
        ) {
            interpolate("controls/gear/brake-left", 0, brake_pressure / 2);
            interpolate("controls/gear/brake-right", 0, brake_pressure / 2);
            setprop("controls/autobrake/setting", 1);
            #screen.log.write("Disarming Autobrakes after go-around"); # For testing
        }

        # Pressing the pedal brakes when the system is armed disarms the system.
        if (
            absetting > 1
            and getprop("controls/gear/brake-left") > (absetting - 1) / 5
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
            rear_on_ground
            and getprop("controls/gear/brake-left") > 0
            and me.old_spdbrk > 0
            and current_spdbrk == 0
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
        if (absetting == 0 or absetting == 1)
            return;

        # The wheels must be spinning to appy brakes
        if (rear_spin < 5)
            return;

        # RTO setting
        if (absetting == -1) {
            # Set to OFF after takeoff
            if (!rear_on_ground) {
                #screen.log.write("Setting Autobrakes to OFF after takeoff"); # For testing
                setprop("controls/autobrake/setting", 0);
            }

            # 43.5 rollspeed means 85 kt ground speed
            if (
                rear_spin > 43.5
                and current_throttle == 0
            ) {
                #screen.log.write("Applying autobrakes after RTO"); # For testing
                interpolate("controls/gear/brake-left", 1, 0.8);
                interpolate("controls/gear/brake-right", 1, 0.8);
            }

            return;
        }

        # Throttle has to be set to idle to apply brake pressure.
        if (current_throttle != 0)
            return;

        # AUTOBRAKE MAX setting
        if (absetting == 6) {
            # We should be detecting a pitch angle lower than 1°, but this can be unreliable in
            # sloped runways, so instead we detect that the nose wheel is touching the ground.
            if (!getprop("gear/gear[0]/wow")) {
                #screen.log.write("Setting Autobrakes to 0.8 MAX"); # For testing
                interpolate("controls/gear/brake-left", 0.8, 0.8);
                interpolate("controls/gear/brake-right", 0.8, 0.8);
                return;
            }

            # Set the brakes to MAX after nose wheel touches the ground.
            #screen.log.write("Setting Autobrakes to 1.0 MAX"); # For testing
            interpolate("controls/gear/brake-left", 1, 0.2);
            interpolate("controls/gear/brake-right", 1, 0.2);

            return;
        }

        # All remaining autobrake settings
        #screen.log.write("Setting autobrakes to " ~ brake_pressure ~ "."); # For testing
        interpolate("controls/gear/brake-left", brake_pressure, brake_pressure);
        interpolate("controls/gear/brake-right", brake_pressure, brake_pressure);

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
# 3. `gear/gear[2]` is the right gear (last to takeoff, first to land)
# 4. RTO position is -1
# 5. OFF position is 0, DISARM position is 1
# 6. 2 to 6 are autobrake 1 to MAX
