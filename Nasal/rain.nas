# Rain splashes

# The function that calculates the rain splashes.
var rain_splash = func {
   var airspeed = getprop("/velocities/airspeed-kt");
   var airspeed_max = 120;

   if (airspeed > airspeed_max)
      airspeed = airspeed_max;

   airspeed = math.sqrt(airspeed/airspeed_max);
   var splash_x = -0.1 - 2.0 * airspeed;
   var splash_z = 1.0 - 1.35 * airspeed;

   setprop("/environment/aircraft-effects/splash-vector-x", -splash_x);
   setprop("/environment/aircraft-effects/splash-vector-y", 0.0);
   setprop("/environment/aircraft-effects/splash-vector-z", -splash_z);
};

# The timer for recalculating the vectors
rainTimer = maketimer(2, rain_splash);
rainTimer.simulatedTime = 1;

# Start and stop based on wether it's raining
var rain_listener = setlistener("/environment/rain-norm", func(){
   if (getprop("/environment/rain-norm") != 0)
      rainTimer.start();
   else
      rainTimer.stop();
}, 1, 0);
