var nav_tree = "/NavData/navaids/";

var nav_disp = "/NavData/disp/";

var round = func(number, dec_places) {

#	var factor = math.pow(10, dec_places);
	
#	var rounded = int(number * factor) / factor;
	
	return number;

}

var navaids = {

	load : func {
	
		var root = getprop("/sim/aircraft-dir");
		
		sysinfo.log_msg("[FMC] Loading FMC NavData/navaids", 0);
		
		io.read_properties(root ~ "/FMC-DB/NavData/navaids.xml", "/NavData/");
		
		sysinfo.log_msg("[FMC] Navigational Data Loaded", 0);
		
		setprop("/NavData/results[0]/first", 0);
		setprop("/NavData/results[1]/first", 0);
	
	},
	
	search_by_name : func (cdu, name) {
	
		var nav_result = "/NavData/results[" ~ cdu ~ "]/";
		
		var result = 0;
		
		for (var n = 0; getprop(nav_result~ "result[" ~ n ~ "]/id") != nil; n += 1) {
		
			setprop(nav_result~ "result[" ~ result ~ "]/id", " ");
				
			setprop(nav_result~ "result[" ~ result ~ "]/name", " ");
				
			setprop(nav_result~ "result[" ~ result ~ "]/lat", " ");
				
			setprop(nav_result~ "result[" ~ result ~ "]/lon", " ");
					
		}
	
		for (var n = 0; getprop(nav_tree ~ "navaid[" ~ n ~ "]/id") != nil; n += 1) {
		
			if (substr(getprop(nav_tree ~ "navaid[" ~ n ~ "]/id"), 0, size(name)) == name) {
			
				setprop(nav_result~ "result[" ~ result ~ "]/id", getprop(nav_tree ~ "navaid[" ~ n ~ "]/id"));
				
				setprop(nav_result~ "result[" ~ result ~ "]/name", getprop(nav_tree ~ "navaid[" ~ n ~ "]/name"));
				
				setprop(nav_result~ "result[" ~ result ~ "]/lat", round(getprop(nav_tree ~ "navaid[" ~ n ~ "]/latitude-deg"), 2));
				
				setprop(nav_result~ "result[" ~ result ~ "]/lon", round(getprop(nav_tree ~ "navaid[" ~ n ~ "]/longitude-deg"), 2));
				
				result += 1;
			
			}
		
		}
		
		me.update_display(cdu);
		
		setprop("/NavData/results["~ cdu ~"]/first", 0);
	
	},
	
	search_by_dist : func (cdu, pos_lat, pos_lon, range) {
	
		var nav_result = "/NavData/results[" ~ cdu ~ "]/";
		
		var result = 0;
		
		for (var n = 0; getprop(nav_result~ "result[" ~ n ~ "]/id") != nil; n += 1) {
		
			setprop(nav_result~ "result[" ~ result ~ "]/id", " ");
				
			setprop(nav_result~ "result[" ~ result ~ "]/name", " ");
				
			setprop(nav_result~ "result[" ~ result ~ "]/lat", " ");
				
			setprop(nav_result~ "result[" ~ result ~ "]/lon", " ");
					
		}
		
		for (var n = 0; getprop(nav_tree ~ "navaid[" ~ n ~ "]/id") != nil; n += 1) {
		
		var latitude_deg = getprop(nav_tree ~ "navaid[" ~ n ~ "]/latitude-deg");
		
		var longitude_deg = getprop(nav_tree ~ "navaid[" ~ n ~ "]/longitude-deg");
		
		var distance_deg = math.sqrt(((latitude_deg - pos_lat) * (latitude_deg - pos_lat)) + ((longitude_deg - pos_lon) * (longitude_deg - pos_lon)));
		
			if ((distance_deg * 60) <= range) {
			
				setprop(nav_result~ "result[" ~ result ~ "]/id", getprop(nav_tree ~ "navaid[" ~ n ~ "]/id"));
				
				setprop(nav_result~ "result[" ~ result ~ "]/name", getprop(nav_tree ~ "navaid[" ~ n ~ "]/name"));
				
				setprop(nav_result~ "result[" ~ result ~ "]/lat", round(latitude_deg, 2));
				
				setprop(nav_result~ "result[" ~ result ~ "]/lon", round(longitude_deg, 2));
				
				result += 1;
			
			}
		
		}
		
		me.update_display(cdu);
		
		setprop("/NavData/results["~ cdu ~"]/first", 0);
	
	},
	
	update_display : func (cdu) {
	
		var nav_result = "/NavData/results[" ~ cdu ~ "]/";
	
		var first = getprop(nav_result ~ "/first");
		
		for (var n = 0; n < 5; n += 1) {
		
			var result_id = getprop(nav_result ~ "result[" ~ (n + first) ~ "]/id");
			var result_name = getprop(nav_result ~ "result[" ~ (n + first) ~ "]/name");
			var result_lat = getprop(nav_result ~ "result[" ~ (n + first) ~ "]/lat");
			var result_lon = getprop(nav_result ~ "result[" ~ (n + first) ~ "]/lon");
			
			if (result_id != nil) {
				setprop(nav_disp ~ "cdu[" ~ cdu ~ "]/disp[" ~ n ~ "]/id", result_id);
				setprop(nav_disp ~ "cdu[" ~ cdu ~ "]/disp[" ~ n ~ "]/name", result_name);
				setprop(nav_disp ~ "cdu[" ~ cdu ~ "]/disp[" ~ n ~ "]/lat", result_lat);
				setprop(nav_disp ~ "cdu[" ~ cdu ~ "]/disp[" ~ n ~ "]/lon", result_lon);
			} else {
				setprop(nav_disp ~ "cdu[" ~ cdu ~ "]/disp[" ~ n ~ "]/id", " ");
				setprop(nav_disp ~ "cdu[" ~ cdu ~ "]/disp[" ~ n ~ "]/name", " ");
				setprop(nav_disp ~ "cdu[" ~ cdu ~ "]/disp[" ~ n ~ "]/lat", " ");
				setprop(nav_disp ~ "cdu[" ~ cdu ~ "]/disp[" ~ n ~ "]/lon", " ");
			}
		
		}
		
	}
	
};
