################################################################################
#
# COLLIN's WXR-2100 "ECHO" MODEL
# ------------------------------
#
# The Weather systems in FlightGear at the time of this wxradar development were
# either circles or rectangles thus making their actual wxradar display unreali-
# tic. The other "PIXELS" model is still available in the Boeing 787-8's 'Devel'
# directory to be used when FlightGear's weather system is further advanced.
#
################################################################################
#
# THUNDERSTORM PROPERTY TREE
# --------------------------
#
# > /instrumentation/wxradar/storm[n]/show
# > /instrumentation/wxradar/storm[n]/latitude-deg
# > /instrumentation/wxradar/storm[n]/longitude-deg
# > /instrumentation/wxradar/storm[n]/heading-deg
# > /instrumentation/wxradar/storm[n]/deflection-deg
# > /instrumentation/wxradar/storm[n]/distance
# > /instrumentation/wxradar/storm[n]/base-altitude-ft
# > /instrumentation/wxradar/storm[n]/top-altitude-ft
# > /instrumentation/wxradar/storm[n]/radius-nm
# > /instrumentation/wxradar/storm[n]/reflectivity-norm
# > /instrumentation/wxradar/storm[n]/turbulence-norm
# > /instrumentation/wxradar/storm[n]/type
# (single_cell, multi_cell or super_cell)
#
################################################################################

var RAD2DEG = 57.2957795; # Conversion Factor from Radians to Degrees

var wxtree = "/instrumentation/wxradar/";

var sqr = func(n) return n * n;

    var Deflection = func(bug, limit) {
      var heading = getprop("orientation/heading-magnetic-deg");
      var bugDeg = 0;

      while (bug < 0)
       {
       bug += 360;
       }
      while (bug > 360)
       {
       bug -= 360;
       }
      if (bug < limit)
       {
       bug += 360;
       }
      if (heading < limit)
       {
       heading += 360;
       }
      # bug is adjusted normally
      if (math.abs(heading - bug) < limit)
       {
       bugDeg = heading - bug;
       }
      elsif (heading - bug < 0)
       {
       # bug is on the far right
       if (math.abs(heading - bug + 360 >= 180))
        {
        bugDeg = -limit;
        }
       # bug is on the far left
       elsif (math.abs(heading - bug + 360 < 180))
        {
        bugDeg = limit;
        }
       }
      else
       {
       # bug is on the far right
       if (math.abs(heading - bug >= 180))
        {
        bugDeg = -limit;
        }
       # bug is on the far left
       elsif (math.abs(heading - bug < 180))
        {
        bugDeg = limit;
        }
       }

      return bugDeg;
    }

    var wxradar2 = {
       init : func {
            me.UPDATE_INTERVAL = 0.02;
            me.loopid = 0;
            me.reset();
    },
       update : func {

    var heading = getprop("orientation/heading-magnetic-deg");

	var altitude = getprop("/position/altitude-ft");

    var pos_x = 60 * getprop("/position/latitude-deg");
    var pos_y = 60 * getprop("/position/longitude-deg");

	var multi_scan = getprop(wxtree ~ "multi-scan");
	var tilt_deg = getprop(wxtree ~ "tilt");

	var range_nm = getprop(wxtree ~ "range");

	for (var n = 0; n < 8; n += 1)
	{

		var storm = wxtree ~ "storm[" ~ n ~ "]/";

		if (getprop(storm ~ "latitude-deg") != nil) 
		{

			var storm_x = 60 * getprop(storm ~ "longitude-deg");
			var storm_y = 60 * getprop(storm ~ "latitude-deg");

			var bearing_deg = RAD2DEG * math.tan2(storm_x - pos_x, storm_y - pos_y);

			var distance_nm = math.sqrt(sqr(storm_x - pos_x) + sqr(storm_y - pos_y));

			var storm_top = getprop(storm ~ "top-altitude-ft"); 

			var storm_bottom = getprop(storm ~ "base-altitude-ft");

			var storm_type = getprop(storm ~ "type");
		
			var storm_precip = getprop(storm ~ "precipitation-norm");

			## Calculate Width and Height



			if (multi_scan == 1) # Multi-scan
			{

				var range_alt = distance_nm * (math.sin(15) / math.cos(15));

				if ((storm_top >= -range_alt) and (storm_bottom <= range_alt)) var alt_visible = 1;
				else var alt_visible = 0;

			}
			else # Manual Tilt
			{

				if ((storm_top >= tilt_deg) and (storm_bottom <= tilt_deg)) var alt_visible = 1;
				else var alt_visible = 0;

			}

			if ((Deflection(bearing_deg, 60) != 60) and (Deflection(bearing_deg,60) != -60) and (distance_nm <= range_nm) and (alt_visible == 1))
			{

				setprop(storm ~ "show", 1);
				setprop(storm ~ "deflection-deg", Deflection(bearing_deg, 60));
				setprop(storm ~ "distance", distance_nm);

				var x_textranslate = 0;
				var y_textranslate = 0;

				if (storm_precip >= 0.66) x_textranlate = 2;
				elsif (storm_precip >= 0.33) x_textranslate = 1;

				if (storm_type == "super_cell") y_textranslate = 1;
				elsif (storm_type == "multi_cell") y_textranslate = 2;

				setprop(storm ~ "x_textranslate", x_textranslate);
				setprop(storm ~ "y_textranslate", y_textranslate);

			} else setprop(storm ~ "show", 0);

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
# wxradar2.init();
 });
