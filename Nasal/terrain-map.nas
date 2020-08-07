################################################################################
#
# Boeing 787-8 Dreamliner Terrain Map (also used in other aircraft)
#
# The idea about getting a terrain map without compromising much frame-rate is
# to sweep the changes across the screen instead of getting the whole screen at
# once. Another idea here is to interpolate between 2 points and 'assume' what
# would be there. That way, say in a line of 32, instead of getting all 32
# points, we could get just 16 and interpolate the rest to this and it would be
# almost just as good.
#
# Licensed along with the 787-8 under GNU GPL v2
#
################################################################################

var row = 0;
var RAD2DEG = 57.2957795;
var DEG2RAD = 0.016774532925;
var terrain = "/instrumentation/terrain-map/pixels/";
var terrain_full = "/instrumentation/terrain-map[1]/pixels/";

# Function to get Elevation at latitude and longitude



var get_elevation = func (lat, lon) {

	var info = geodinfo(lat, lon);
	if (info != nil) {var elevation = info[0] * 3.2808399;}
	else {var elevation = -1.0; }

	return elevation;
}


var terrain_map = {

	init : func {
		me.UPDATE_INTERVAL = 0.025;
		me.loopid = 0;

		me.reset();
	},

	update : func {

		if (getprop("/controls/mfd/extra") == 2) {

			var pos_lon = getprop("/position/longitude-deg");
			var pos_lat = getprop("/position/latitude-deg");
			var heading = getprop("orientation/heading-magnetic-deg");

			setprop("/controls/mfd/terrain-map/range", getprop("/instrumentation/ndfull/range"));

			var range = getprop("/controls/mfd/terrain-map/range");
	
			# for (var row = 0; row < 32; row += 2)
			# {

				# First get all the points (16x16)

				for (var col = 1; col <= 32; col += 2)
				{

					var proj_lon = pos_lon + (-1 * (col-16) * math.sin(DEG2RAD * (heading - 90)) / 60);
					var proj_lat = pos_lat + (-1 * (col-16) * math.cos(DEG2RAD * (heading - 90)) / 60);

					var point_lon = proj_lon + ((row / 60) * math.sin(DEG2RAD * heading));
					var point_lat = proj_lat + ((row / 60) * math.cos(DEG2RAD * heading));

					setprop(terrain ~ "row[" ~ row ~ "]/col[" ~ col ~ "]/elevation-ft", get_elevation(point_lat, point_lon));

				}

				# Interpolate the rest of the points in each column

				for (var col = 2; col <= 31; col += 2)
				{

					var elev_prev = getprop(terrain ~ "row[" ~ row ~ "]/col[" ~ (col - 1) ~ "]/elevation-ft");
					var elev_next = getprop(terrain ~ "row[" ~ row ~ "]/col[" ~ (col + 1) ~ "]/elevation-ft");
					var elevation = (elev_prev + elev_next) / 2;

					setprop(terrain ~ "row[" ~ row ~ "]/col[" ~ col ~ "]/elevation-ft", elevation);

				}

			# }


			### Same calculations but for the fullscreen ND, that means RANGE matters

			# First get all the points (16x16)

			for (var col = 1; col <= 32; col += 2)
			{
	
				var proj_lon = pos_lon + ((-1 * (col-16) * (range/30) * math.sin(DEG2RAD * (heading - 90))) / 60);
				var proj_lat = pos_lat + ((-1 * (col-16) * (range/30) * math.cos(DEG2RAD * (heading - 90))) / 60);

				var point_lon = proj_lon + ((row * (range/30) / 60) * math.sin(DEG2RAD * heading));
				var point_lat = proj_lat + ((row * (range/30) / 60) * math.cos(DEG2RAD * heading));

				setprop(terrain_full ~ "row[" ~ row ~ "]/col[" ~ col ~ "]/elevation-ft", get_elevation(point_lat, point_lon));

			}

			# Interpolate the rest of the points in each column

			for (var col = 2; col <= 31; col += 2)
			{

				var elev_prev = getprop(terrain_full ~ "row[" ~ row ~ "]/col[" ~ (col - 1) ~ "]/elevation-ft");
				var elev_next = getprop(terrain_full ~ "row[" ~ row ~ "]/col[" ~ (col + 1) ~ "]/elevation-ft");
				var elevation = (elev_prev + elev_next) / 2;

				setprop(terrain_full ~ "row[" ~ row ~ "]/col[" ~ col ~ "]/elevation-ft", elevation);

			}

			row += 1;

			if (row == 32) row = 0;

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
	terrain_map.init();
	print("Terrain Map ......... Initialized");
});



