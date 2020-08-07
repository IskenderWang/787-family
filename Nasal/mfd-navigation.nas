    var nav = {
       init : func {
            me.UPDATE_INTERVAL = 0.01;
            me.loopid = 0;

       setprop("/controls/navigation/init", 1);
       me.loopnum = 1;

	me.range = 50;

            me.reset();
    },
       update : func {

	if ((getprop("/controls/mfd2/page") == "nav") and (getprop("/controls/mfd3/page") == "nav")) {
		setprop("/instrumentation/ndfull/active", 1);
	} else {
		setprop("/instrumentation/ndfull/active", 0);
	}

    var heading = getprop("orientation/heading-magnetic-deg");
    var nav1heading = getprop("/instrumentation/nav/heading-deg");
    var nav2heading = getprop("/instrumentation/nav[1]/heading-deg");

    var poslat = getprop("/position/latitude-deg");
    var poslon = getprop("/position/longitude-deg");

    # Current WP Deflection and Distance Calculation

    if (getprop("/autopilot/route-manager/route/num") != 0) {

    var currentwpbrg = getprop("/instrumentation/gps/wp/leg-mag-course-deg");

    var currentwpdefl = Deflection(currentwpbrg, 45);
    setprop("/controls/navigation/wp1-defl", currentwpdefl);

    var currentwpdistnm = getprop("/instrumentation/gps/wp/leg-distance-nm");
    setprop("/controls/navigation/wp1-dist", currentwpdistnm * 1852);

    if ((currentwpdistnm * 1852) < 55600) {

    if (getprop("/autopilot/route-manager/active") == 1) {
     setprop("/controls/navigation/show-active-wp", 1);
     setprop("/controls/navigation/show-inactive-wp", 0);
    } else {
     setprop("/controls/navigation/show-active-wp", 0);
     setprop("/controls/navigation/show-inactive-wp", 1);
    }

    setprop("/controls/navigation/show-wp-pointer", 0);

    } else {
     setprop("/controls/navigation/show-active-wp", 0);
     setprop("/controls/navigation/show-inactive-wp", 0);
     setprop("/controls/navigation/show-wp-pointer", 1);
    }

    } else {
     setprop("/controls/navigation/show-active-wp", 0);
     setprop("/controls/navigation/show-inactive-wp", 0);
    }

    # Set Heading Deflections

    setprop("/controls/navigation/nav1-defl", Deflection(nav1heading,45));
    setprop("/controls/navigation/nav2-defl", Deflection(nav2heading,45));

	if (getprop("/autopilot/settings/heading-bug-deg") != nil) {
    setprop("/controls/navigation/heading-bug", Deflection(getprop("/autopilot/settings/heading-bug-deg"), 45)); }

    # Calculate Descent glideslope

    var verticalspeedfps = getprop("/velocities/vertical-speed-fps");
    var groundspeedfps = getprop("/velocities/groundspeed-kt") * 1.68780986;

    var indaltitude = getprop("instrumentation/altimeter/indicated-altitude-ft");

    var slope = (57.2957795 * math.atan2(groundspeedfps, 0 - verticalspeedfps)) - 90;
    setprop("/controls/navigation/descent-slope", slope);

    var linelength = 0;

    var convfactor = 1500; # Testing this value

    var xavail = me.range; # The box shows elevations upto 50 nm

    # I'll have to do some weird calculations to keep the descent slope inside the vertical profile box

    # Climbing

    if (slope > 0)
    {

    var yavail = 40000 - indaltitude; # yavail is in feet

    } else { # Descending

    var yavail = indaltitude;

    }

    if (yavail < math.abs(convfactor * me.range * (math.sin(slope / 57.2957795) / math.cos(slope / 57.2957795)))) { # The end of the line does not go on till the end of teh space given.

    linelength = (yavail / convfactor) / math.sin(slope / 57.2957795);

    } else { # Here, it does

    linelength = me.range / math.cos(slope / 57.2957795);

    }

    setprop("/controls/navigation/descent-line-length", math.abs(linelength));

    # Calculate vertical Profile

    var currentwp = getprop("/autopilot/route-manager/current-wp");
    var numberofwps = getprop("/autopilot/route-manager/route/num");

var wp1 = 0;
var wp1alt = 0;
var wp1dist = 0;
var wp1angle = 0;
var wp1length = 0;
var wp2 = 0;
var wp2alt = 0;
var wp2dist = 0;
var wp2angle = 0;
var wp2length = 0;
var wp3 = 0;
var wp3alt = 0;
var wp3dist = 0;
var wp3angle = 0;
var wp3length = 0;
var wp4 = 0;
var wp4alt = 0;
var wp4dist = 0;
var wp4angle = 0;
var wp4length = 0;
var wp5 = 0;
var wp5alt = 0;
var wp5dist = 0;
var wp5angle = 0;
var wp5length = 0;
var wp1id = "";
var wp2id = "";
var wp3id = "";
var wp4id = "";
var wp5id = "";
var wp1brg = 0;
var wp2brg = 0;
var wp3brg = 0;
var wp4brg = 0;
var wp5brg = 0;

var wp1path = 0;
var wp2path = 0;
var wp3path = 0;
var wp4path = 0;
var wp5path = 0;


if (getprop("/autopilot/route-manager/active") == 1) {

if (numberofwps - currentwp > 0) {

wp1 = currentwp;

wp1alt = getprop("/autopilot/route-manager/route/wp[" ~ wp1 ~ "]/altitude-ft");
wp1dist = getprop("/instrumentation/gps/wp/leg-distance-nm");
wp1brg = Deflection(getprop("/instrumentation/gps/wp/leg-mag-course-deg"), 45);

wp1angle = 90 - (57.2957795 * math.atan2(wp1dist , (wp1alt - indaltitude) / convfactor));

wp1length = wp1dist / math.cos(wp1angle / 57.2957795);

wp1id = getprop("/autopilot/route-manager/route/wp[" ~ wp1 ~ "]/id");

}

if (numberofwps - currentwp > 1) {

wp2 = currentwp + 1;

wp2alt = getprop("/autopilot/route-manager/route/wp[" ~ wp2 ~ "]/altitude-ft");
wp2dist = wp1dist + getprop("/autopilot/route-manager/route/wp[" ~ wp1 ~ "]/leg-distance-nm");
wp2path = getprop("/autopilot/route-manager/route/wp[" ~ wp1 ~ "]/leg-distance-nm");
wp2brg = Deflection(getprop("/autopilot/route-manager/route/wp[" ~ wp1 ~ "]/leg-bearing-true-deg"), 45);

wp2angle = 90 - (57.2957795 * math.atan2(wp2dist - wp1dist, (wp2alt - wp1alt) / convfactor));

wp2length = (wp2dist - wp1dist) / math.cos(wp2angle / 57.2957795);

wp2id = getprop("/autopilot/route-manager/route/wp[" ~ wp2 ~ "]/id");

}

if (numberofwps - currentwp > 2) {

wp3 = currentwp + 2;

wp3alt = getprop("/autopilot/route-manager/route/wp[" ~ wp3 ~ "]/altitude-ft");
wp3dist = wp2dist + getprop("/autopilot/route-manager/route/wp[" ~ wp2 ~ "]/leg-distance-nm");
wp3path = getprop("/autopilot/route-manager/route/wp[" ~ wp2 ~ "]/leg-distance-nm");
wp3brg = Deflection(getprop("/autopilot/route-manager/route/wp[" ~ wp2 ~ "]/leg-bearing-true-deg"), 45);

wp3angle = 90 - (57.2957795 * math.atan2(wp3dist - wp2dist, (wp3alt - wp2alt) / convfactor));

wp3length = (wp3dist - wp2dist) / math.cos(wp3angle / 57.2957795);

wp3id = getprop("/autopilot/route-manager/route/wp[" ~ wp3 ~ "]/id");

}

if (numberofwps - currentwp > 3) {

wp4 = currentwp + 3;

wp4alt = getprop("/autopilot/route-manager/route/wp[" ~ wp4 ~ "]/altitude-ft");
wp4dist = wp3dist + getprop("/autopilot/route-manager/route/wp[" ~ wp3 ~ "]/leg-distance-nm");
wp4path = getprop("/autopilot/route-manager/route/wp[" ~ wp3 ~ "]/leg-distance-nm");
wp4brg = Deflection(getprop("/autopilot/route-manager/route/wp[" ~ wp3 ~ "]/leg-bearing-true-deg"), 45);

wp4angle = 90 - (57.2957795 * math.atan2(wp4dist - wp3dist, (wp4alt - wp3alt) / convfactor));

wp4length = (wp4dist - wp3dist) / math.cos(wp4angle / 57.2957795);

wp4id = getprop("/autopilot/route-manager/route/wp[" ~ wp4 ~ "]/id");

}

if (numberofwps - currentwp > 4) {

wp5 = currentwp + 4;

wp5alt = getprop("/autopilot/route-manager/route/wp[" ~ wp5 ~ "]/altitude-ft");
wp5dist = wp4dist + getprop("/autopilot/route-manager/route/wp[" ~ wp4 ~ "]/leg-distance-nm");
wp5path = getprop("/autopilot/route-manager/route/wp[" ~ wp4 ~ "]/leg-distance-nm");
wp5brg = Deflection(getprop("/autopilot/route-manager/route/wp[" ~ wp4 ~ "]/leg-bearing-true-deg"), 45);

wp5angle = 90 - (57.2957795 * math.atan2(wp5dist - wp4dist, (wp5alt - wp4alt) / convfactor));

wp5length = (wp5dist - wp4dist) / math.cos(wp5angle / 57.2957795);

wp5id = getprop("/autopilot/route-manager/route/wp[" ~ wp5 ~ "]/id");

}

if ((wp1dist <= 30) and (wp1dist != 0)) {
setprop("/controls/navigation/show-wp1", 1);
} else {
setprop("/controls/navigation/show-wp1", 0);
}

if ((wp2dist <= 30) and (wp2dist != 0)) {
setprop("/controls/navigation/show-wp2", 1);
} else {
setprop("/controls/navigation/show-wp2", 0);
}

if ((wp3dist <= 30) and (wp3dist != 0)) {
setprop("/controls/navigation/show-wp3", 1);
} else {
setprop("/controls/navigation/show-wp3", 0);
}

if ((wp4dist <= 30) and (wp4dist != 0)) {
setprop("/controls/navigation/show-wp4", 1);
} else {
setprop("/controls/navigation/show-wp4", 0);
}

if ((wp1dist <= 50) and (wp1dist != 0)) {
setprop("/controls/navigation/vnav/show-wp1", 1);
} else {
setprop("/controls/navigation/vnav/show-wp1", 0);
}

if ((wp2dist <= 50) and (wp2dist != 0)) {
setprop("/controls/navigation/vnav/show-wp2", 1);
} else {
setprop("/controls/navigation/vnav/show-wp2", 0);
}

if ((wp3dist <= 50) and (wp3dist != 0)) {
setprop("/controls/navigation/vnav/show-wp3", 1);
} else {
setprop("/controls/navigation/vnav/show-wp3", 0);
}

if ((wp4dist <= 50) and (wp4dist != 0)) {
setprop("/controls/navigation/vnav/show-wp4", 1);
} else {
setprop("/controls/navigation/vnav/show-wp4", 0);
}

if ((wp5dist <= 50) and (wp5dist != 0)) {
setprop("/controls/navigation/vnav/show-wp5", 1);
} else {
setprop("/controls/navigation/vnav/show-wp5", 0);
}

}

setprop("/controls/navigation/wp1path", wp1path);
setprop("/controls/navigation/wp2path", wp2path);
setprop("/controls/navigation/wp3path", wp3path);
setprop("/controls/navigation/wp4path", wp4path);
setprop("/controls/navigation/wp5path", wp5path);

setprop("/controls/navigation/wp1brg", wp1brg);
setprop("/controls/navigation/wp2brg", wp2brg);
setprop("/controls/navigation/wp3brg", wp3brg);
setprop("/controls/navigation/wp4brg", wp4brg);
setprop("/controls/navigation/wp5brg", wp5brg);

setprop("/controls/navigation/vnav/wp1alt", wp1alt);
setprop("/controls/navigation/vnav/wp2alt", wp2alt);
setprop("/controls/navigation/vnav/wp3alt", wp3alt);
setprop("/controls/navigation/vnav/wp4alt", wp4alt);
setprop("/controls/navigation/vnav/wp5alt", wp5alt);

setprop("/controls/navigation/vnav/wp1", wp1);
setprop("/controls/navigation/vnav/wp1dist", wp1dist);
setprop("/controls/navigation/vnav/wp1angle", wp1angle);
setprop("/controls/navigation/vnav/wp1length", wp1length);
setprop("/controls/navigation/vnav/wp1id", wp1id);

setprop("/controls/navigation/vnav/wp2", wp2);
setprop("/controls/navigation/vnav/wp2dist", wp2dist);
setprop("/controls/navigation/vnav/wp2angle", wp2angle);
setprop("/controls/navigation/vnav/wp2length", wp2length);
setprop("/controls/navigation/vnav/wp2id", wp2id);

setprop("/controls/navigation/vnav/wp3", wp3);
setprop("/controls/navigation/vnav/wp3dist", wp3dist);
setprop("/controls/navigation/vnav/wp3angle", wp3angle);
setprop("/controls/navigation/vnav/wp3length", wp3length);
setprop("/controls/navigation/vnav/wp3id", wp3id);

setprop("/controls/navigation/vnav/wp4", wp4);
setprop("/controls/navigation/vnav/wp4dist", wp4dist);
setprop("/controls/navigation/vnav/wp4angle", wp4angle);
setprop("/controls/navigation/vnav/wp4length", wp4length);
setprop("/controls/navigation/vnav/wp4id", wp4id);

setprop("/controls/navigation/vnav/wp5", wp5);
setprop("/controls/navigation/vnav/wp5dist", wp5dist);
setprop("/controls/navigation/vnav/wp5angle", wp5angle);
setprop("/controls/navigation/vnav/wp5length", wp5length);
setprop("/controls/navigation/vnav/wp5id", wp5id);

    # Calculate Latitude and Longitude for 50 points in front of you.

    var x = poslon * 60;
    var y = poslat * 60;

    var xoffset = me.loopnum/2 * math.sin(heading);
    var yoffset = me.loopnum/2 * math.cos(heading);

    # Calculate elevations for the next 50 nautical miles (only 1 sample  every frame)

    setprop("/controls/navigation/vert-profile/nm" ~ me.loopnum/2, get_elevation((y + yoffset) / 60, (x + xoffset) / 60));

    var altdiff = indaltitude - get_elevation((y + yoffset) / 60, (x + xoffset) / 60);

    if (altdiff < 1000) {
    var color = "red";
    } elsif (altdiff < 2000) {
    var color = "orange";
    } elsif (altdiff < 3000) {
    var color = "yellow";
    } else {
    var color = "white";
    }

    if (getprop("/autopilot/route-manager/airborne") == 0) {
    var color = "white";
    }

    setprop("/controls/navigation/vert-profile-color/nm" ~ me.loopnum/2, color);

    # Loop Number Add and Reset

    me.loopnum = me.loopnum + 1;

    if (me.loopnum > 100) {
     me.loopnum = 1;
    }

for(var n = 0; n < 99; n = n + 1) {

if (getprop("/drawing/line[" ~ n ~ "]/y2") != nil) {

setprop("/drawing/line[" ~ n ~ "]/angle", RAD2DEG * math.atan2(getprop("/drawing/line[" ~ n ~ "]/y2") - getprop("/drawing/line[" ~ n ~ "]/y1"),getprop("/drawing/line[" ~ n ~ "]/x2") - getprop("/drawing/line[" ~ n ~ "]/x1")));

setprop("/drawing/line[" ~ n ~ "]/length-m", math.sqrt(square(getprop("/drawing/line[" ~ n ~ "]/x2") - getprop("/drawing/line[" ~ n ~ "]/x1")) + square(getprop("/drawing/line[" ~ n ~ "]/y2") - getprop("/drawing/line[" ~ n ~ "]/y1"))));

} }

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

    var DegToRad = func(deg) {
    var rad = deg * 0.0174532925;
    return rad;
    }

    var RadToDeg = func(rad) {
    var deg = rad * 57.2957795;
    return deg;
    }

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

    # Function to get Elevation at latitude and longitude

    var get_elevation = func (lat, lon) {

    var info = geodinfo(lat, lon);
       if (info != nil) {var elevation = info[0] * 3.2808399;}
       else {var elevation = -1.0; }

    return elevation;
    }

var square = func(n) n * n;

var DEG2RAD = 0.0174532925;
var RAD2DEG = 57.2957795;
