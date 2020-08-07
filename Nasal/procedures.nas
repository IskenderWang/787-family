################################################################################
#
# Terminal Procedures Class - Contains different CDU TP Management Pages
#-------------------------------------------------------------------------------
#
# init - Initializes Terminal Procedures
# selectSID - CDU page to Select Departure Procedure
# selectSTAR - CDU page to Select Arrival Procedure
# selectIAP - CDU page to Select Approach Procedure
# setDep - function to set the departure procedures to the Active route
# setArr - function to set the arrival procedures to the Active route
# setApp - function to set the approach procedures to the Active route
# checkPos - function to check if position is close as on navdata
# wpInfo - CDU page to show selected WP information from navdata
# clrpage - function to clear CDU page
# update - function to update CDU page
################################################################################

var DepICAO = "";
var ArrICAO = "";
var AppICAO = "";
var SIDList = [];
var SIDindex = 0;
var SIDmax = 0;
var STARList = [];
var STARindex = 0;
var STARmax = 0;
var IAPList = [];
var IAPindex = 0;
var IAPmax = 0;
var WPindex = 0;
var WPmax = 0;
var SIDfirst = 0;
var STARfirst = 0;
var IAPfirst = 0;
var SIDwpmax = 0;
var STARwpmax = 0;
var IAPwpmax = 0;
var TPlist = [];
var TPindex = 0;
var TPtype = "SID";

var fmcTP = {

	init: func {
	
		# I don't really understand vectors and hashes much, so I'm using the old fashioned trusty method.
	
		me.l1_type = "disp";
		me.l2_type = "disp";
		me.l3_type = "disp";
		me.l4_type = "disp";
		me.l5_type = "disp";
		me.l6_type = "disp";
		me.l7_type = "disp";
		me.r1_type = "disp";
		me.r2_type = "disp";
		me.r3_type = "disp";
		me.r4_type = "disp";
		me.r5_type = "disp";
		me.r6_type = "disp";
		me.r7_type = "disp";
		
		me.l1_label = "";
		me.l2_label = "";
		me.l3_label = "";
		me.l4_label = "";
		me.l5_label = "";
		me.l6_label = "";
		me.l7_label = "";
		me.r1_label = "";
		me.r2_label = "";
		me.r3_label = "";
		me.r4_label = "";
		me.r5_label = "";
		me.r6_label = "";
		me.r7_label = "";
		
		me.l1 = "";
		me.l2 = "";
		me.l3 = "";
		me.l4 = "";
		me.l5 = "";
		me.l6 = "";
		me.l7 = "";
		me.r1 = "";
		me.r2 = "";
		me.r3 = "";
		me.r4 = "";
		me.r5 = "";
		me.r6 = "";
		me.r7 = "";
		
	},
	
	selectSID: func(cdu) {
	
		me.clrpage();
		
		me.l7_type = "click";
		me.l7 = "< INDEX";
		me.r7_type = "click";
		me.r7 = "PROCEDURES >";
		
		if (SIDmax == 0) {
			
			setprop("/controls/cdu[" ~ cdu ~ "]/input", "Apt/Rwy not in FMC!");
			
		} else {
		
			me.l1_type = "click";
			me.l1_label = "Available SIDs (Cycle)";
			me.l1 = SIDList[SIDindex].wp_name;
			
			me.l6_type = "click";
			me.l6 = "< USE SID";
			
			SIDwpmax = size(SIDList[SIDindex].wpts);
			
			me.l2_label = "Number of Waypoints";
			me.l2 = SIDwpmax;
			
			if (SIDfirst < SIDwpmax) {
				me.r1 = SIDList[SIDindex].wpts[SIDfirst].wp_name;
				me.r1_type = "click";
			}
			
			if (SIDfirst + 1 < SIDwpmax) {
				me.r2 = SIDList[SIDindex].wpts[SIDfirst + 1].wp_name;
				me.r2_type = "click";
			}
			
			if (SIDfirst + 2 < SIDwpmax) {
				me.r3 = SIDList[SIDindex].wpts[SIDfirst + 2].wp_name;
				me.r3_type = "click";
			}
			
			if (SIDfirst + 3 < SIDwpmax) {
				me.r4 = SIDList[SIDindex].wpts[SIDfirst + 3].wp_name;
				me.r4_type = "click";
			}
			
			if (SIDfirst + 4 < SIDwpmax) {
				me.r5 = SIDList[SIDindex].wpts[SIDfirst + 4].wp_name;
				me.r5_type = "click";
			}
			
			if (SIDfirst + 5 < SIDwpmax) {
				me.r6 = SIDList[SIDindex].wpts[SIDfirst + 5].wp_name;
				me.r6_type = "click";
			}
			
			if (SIDfirst != 0) {
				me.l4_type = "click";
				me.l4 = "< SCROLL UP";
			}
			
			if (SIDfirst + 6 < SIDwpmax) {
				me.l5_type = "click";
				me.l5 = "< SCROLL DOWN";
			}
			
		}
		
		me.update(cdu);
		
	},
	
	selectSTAR: func(cdu) {
	
		me.clrpage();
		
		me.l7_type = "click";
		me.l7 = "< INDEX";
		me.r7_type = "click";
		me.r7 = "PROCEDURES >";
		
		if (STARmax == 0) {
			
			setprop("/controls/cdu[" ~ cdu ~ "]/input", "Apt/Rwy not in FMC!");
			
		} else {
		
			me.l1_type = "click";
			me.l1_label = "Available STARs (Cycle)";
			me.l1 = STARList[STARindex].wp_name;
			
			me.l6_type = "click";
			me.l6 = "< USE STAR";
			
			STARwpmax = size(STARList[STARindex].wpts);
			
			me.l2_label = "Number of Waypoints";
			me.l2 = STARwpmax;
			
			if (STARfirst < STARwpmax) {
				me.r1 = STARList[STARindex].wpts[STARfirst].wp_name;
				me.r1_type = "click";
			}
			
			if (STARfirst + 1 < STARwpmax) {
				me.r2 = STARList[STARindex].wpts[STARfirst + 1].wp_name;
				me.r2_type = "click";
			}
			
			if (STARfirst + 2 < STARwpmax) {
				me.r3 = STARList[STARindex].wpts[STARfirst + 2].wp_name;
				me.r3_type = "click";
			}
			
			if (STARfirst + 3 < STARwpmax) {
				me.r4 = STARList[STARindex].wpts[STARfirst + 3].wp_name;
				me.r4_type = "click";
			}
			
			if (STARfirst + 4 < STARwpmax) {
				me.r5 = STARList[STARindex].wpts[STARfirst + 4].wp_name;
				me.r5_type = "click";
			}
			
			if (STARfirst + 5 < STARwpmax) {
				me.r6 = STARList[STARindex].wpts[STARfirst + 5].wp_name;
				me.r6_type = "click";
			}
			
			if (STARfirst != 0) {
				me.l4_type = "click";
				me.l4 = "< SCROLL UP";
			}
			
			if (STARfirst + 6 < STARwpmax) {
				me.l5_type = "click";
				me.l5 = "< SCROLL DOWN";
			}
			
		}
		
		me.update(cdu);
		
	},
	
	selectIAP: func(cdu) {
	
		me.clrpage();
		
		me.l7_type = "click";
		me.l7 = "< INDEX";
		me.r7_type = "click";
		me.r7 = "PROCEDURES >";
		
		if (IAPmax == 0) {
			
			setprop("/controls/cdu[" ~ cdu ~ "]/input", "Apt/Rwy not in FMC!");
			
		} else {
		
			me.l1_type = "click";
			me.l1_label = "Available IAPs (Cycle)";
			me.l1 = IAPList[IAPindex].wp_name;
			
			me.l6_type = "click";
			me.l6 = "< USE IAP";
			
			IAPwpmax = size(IAPList[IAPindex].wpts);
			
			me.l2_label = "Number of Waypoints";
			me.l2 = IAPwpmax;
			
			if (IAPfirst < IAPwpmax) {
				me.r1 = IAPList[IAPindex].wpts[IAPfirst].wp_name;
				me.r1_type = "click";
			}
			
			if (IAPfirst + 1 < IAPwpmax) {
				me.r2 = IAPList[IAPindex].wpts[IAPfirst + 1].wp_name;
				me.r2_type = "click";
			}
			
			if (IAPfirst + 2 < IAPwpmax) {
				me.r3 = IAPList[IAPindex].wpts[IAPfirst + 2].wp_name;
				me.r3_type = "click";
			}
			
			if (IAPfirst + 3 < IAPwpmax) {
				me.r4 = IAPList[IAPindex].wpts[IAPfirst + 3].wp_name;
				me.r4_type = "click";
			}
			
			if (IAPfirst + 4 < IAPwpmax) {
				me.r5 = IAPList[IAPindex].wpts[IAPfirst + 4].wp_name;
				me.r5_type = "click";
			}
			
			if (IAPfirst + 5 < IAPwpmax) {
				me.r6 = IAPList[IAPindex].wpts[IAPfirst + 5].wp_name;
				me.r6_type = "click";
			}
			
			if (IAPfirst != 0) {
				me.l4_type = "click";
				me.l4 = "< SCROLL UP";
			}
			
			if (IAPfirst + 6 < IAPwpmax) {
				me.l5_type = "click";
				me.l5 = "< SCROLL DOWN";
			}
			
		}
		
		me.update(cdu);
		
	},
	
	setDep: func() {
	
		sysinfo.log_msg("[FMC] Adding SID " ~ SIDList[SIDindex].wp_name ~ "to Route", 0);
	
		var n = 0;
	
		while (n < SIDwpmax) {
		
			if (SIDList[SIDindex].wpts[n].wp_type == "FIX")
				var type = "fix";
			else
				var type = "vor"; # Just for now
		
			
			if ((SIDList[SIDindex].wpts[n].wp_lon != 0) and (SIDList[SIDindex].wpts[n].wp_lat != 0)) {
				
				if (me.checkpos(SIDList[SIDindex].wpts[n].wp_name, type, SIDList[SIDindex].wpts[n].wp_lat, SIDList[SIDindex].wpts[n].wp_lon)) 
					setprop("/autopilot/route-manager/input", "@INSERT" ~  n ~ ":" ~ SIDList[SIDindex].wpts[n].wp_name ~ "@" ~ SIDList[SIDindex].wpts[n].alt_cstr);
				else
					setprop("/autopilot/route-manager/input", "@INSERT" ~ n ~ ":" ~ SIDList[SIDindex].wpts[n].wp_lon ~ "," ~ SIDList[SIDindex].wpts[n].wp_lat ~ "@" ~ SIDList[SIDindex].wpts[n].alt_cstr);
					
			}
		
			n += 1;
		
		}
		
	},
	
	setArr: func() {
	
	sysinfo.log_msg("[FMC] Adding STAR " ~ SIDList[SIDindex].wp_name ~ "to Route", 0);
	
		var n = 0;
	
		while (n < STARwpmax) {
		
			if (STARList[STARindex].wpts[n].wp_type == "FIX")
				var type = "fix";
			else
				var type = "vor"; # Just for now
				
			if ((STARList[STARindex].wpts[n].wp_lon != 0) and (STARList[STARindex].wpts[n].wp_lat != 0)) {
		
			if (me.checkpos(STARList[STARindex].wpts[n].wp_name, type, STARList[STARindex].wpts[n].wp_lat, STARList[STARindex].wpts[n].wp_lon)) 
				setprop("/autopilot/route-manager/input", "@INSERT" ~ (getprop("/autopilot/route-manager/route/num") - 1) ~ ":" ~ STARList[STARindex].wpts[n].wp_name ~ "@" ~ STARList[STARindex].wpts[n].alt_cstr);
			else
				setprop("/autopilot/route-manager/input", "@INSERT" ~ (getprop("/autopilot/route-manager/route/num") - 1)  ~ ":" ~ STARList[STARindex].wpts[n].wp_lon ~ "," ~ STARList[STARindex].wpts[n].wp_lat ~ "@" ~ STARList[STARindex].wpts[n].alt_cstr);
		
			}
		
			n += 1;
		
		}
		
	},
	
	setApp: func() {
	
	sysinfo.log_msg("[FMC] Adding IAP " ~ SIDList[SIDindex].wp_name ~ "to Route", 0);
	
		var n = 0;
	
		while (n < IAPwpmax) {
		
			if (IAPList[IAPindex].wpts[n].wp_type == "FIX")
				var type = "fix";
			else
				var type = "vor"; # Just for now
				
			if ((IAPList[IAPindex].wpts[n].wp_lon != 0) and (IAPList[IAPindex].wpts[n].wp_lat != 0)) {
		
			if (me.checkpos(IAPList[IAPindex].wpts[n].wp_name, type, IAPList[IAPindex].wpts[n].wp_lat, IAPList[IAPindex].wpts[n].wp_lon)) 
				setprop("/autopilot/route-manager/input", "@INSERT" ~ (getprop("/autopilot/route-manager/route/num") - 1)  ~ ":" ~ IAPList[IAPindex].wpts[n].wp_name ~ "@" ~ IAPList[IAPindex].wpts[n].alt_cstr);
			else
				setprop("/autopilot/route-manager/input", "@INSERT" ~ (getprop("/autopilot/route-manager/route/num") - 1)  ~ ":" ~ IAPList[IAPindex].wpts[n].wp_lon ~ "," ~ IAPList[IAPindex].wpts[n].wp_lat ~ "@" ~ IAPList[IAPindex].wpts[n].alt_cstr);
			
			}
			
			n += 1;
		
		}
		
	},
	
	checkpos: func(wp, type, wp_lat, wp_lon) {
		
		# Uses GPS[4] to Check if WP Position is close
		
		setprop("/instrumentation/gps[4]/scratch/query", wp);
		setprop("/instrumentation/gps[4]/scratch/type", type);
		setprop("/instrumentation/gps[4]/command", "search");
		
		var gps_lat = getprop("/instrumentation/gps[4]/scratch/latitude-deg");
		var gps_lon = getprop("/instrumentation/gps[4]/scratch/longitude-deg");
		
		if ((math.abs(wp_lat - gps_lat) <= 0.15) and (math.abs(wp_lon - gps_lon) <= 0.15))
			return 1;
		else
			return 0;
	},
	
	wpInfo: func(cdu, wpindex, tpindex, tptype) {
	
	me.clrpage();
	
		me.l7_type = "click";
		me.l7 = "< INDEX";
		me.r7_type = "click";
		
		if (tptype == "SID") {
			me.r7 = "DEPARTURE >";
			TPlist = SIDList;
			TPindex = SIDindex;
		} elsif (tptype == "STAR") {
			me.r7 = "ARRIVAL >";
			TPlist = STARList;
			TPindex = STARindex;
		} else {
			me.r7 = "APPROACH >";
			TPlist = IAPList;
			TPindex = IAPindex;
		}
		
		TPtype = tptype;
			
		me.l1_label = "Waypoint ID";
		me.r1_label = "Terminal Procedure";
		me.l2_label = "Waypoint Type";
		me.r2_label = "Waypoint Fly Type";
		me.l3_label = "LNAV Action";
		me.r3_label = "VNAV Altitude";
		me.l4_label = "Leg Distance";
		me.r4_label = "Leg Bearing";
		me.l5_label = "Waypoint Latitude";
		me.r5_label = "Waypoint Longitude";
		
		me.l1 = TPlist[TPindex].wpts[wpindex].wp_name;
		me.r1 = TPlist[TPindex].wpts[wpindex].wp_parent_name;
		me.l2 = TPlist[TPindex].wpts[wpindex].wp_type;
		me.r2 = TPlist[TPindex].wpts[wpindex].fly_type;
		me.l3 = TPlist[TPindex].wpts[wpindex].action;
		me.r3 = TPlist[TPindex].wpts[wpindex].alt_cstr;
		me.l4 = TPlist[TPindex].wpts[wpindex].leg_distance;
		me.r4 = TPlist[TPindex].wpts[wpindex].leg_bearing;
		me.l5 = TPlist[TPindex].wpts[wpindex].wp_lat;
		me.r5 = TPlist[TPindex].wpts[wpindex].wp_lon;
		
		me.update(cdu);
		
	},
	
	clrpage: func() {
		
		me.l1_type = "disp";
		me.l2_type = "disp";
		me.l3_type = "disp";
		me.l4_type = "disp";
		me.l5_type = "disp";
		me.l6_type = "disp";
		me.l7_type = "disp";
		me.r1_type = "disp";
		me.r2_type = "disp";
		me.r3_type = "disp";
		me.r4_type = "disp";
		me.r5_type = "disp";
		me.r6_type = "disp";
		me.r7_type = "disp";
		
		me.l1_label = "";
		me.l2_label = "";
		me.l3_label = "";
		me.l4_label = "";
		me.l5_label = "";
		me.l6_label = "";
		me.l7_label = "";
		me.r1_label = "";
		me.r2_label = "";
		me.r3_label = "";
		me.r4_label = "";
		me.r5_label = "";
		me.r6_label = "";
		me.r7_label = "";
		
		me.l1 = "";
		me.l2 = "";
		me.l3 = "";
		me.l4 = "";
		me.l5 = "";
		me.l6 = "";
		me.l7 = "";
		me.r1 = "";
		me.r2 = "";
		me.r3 = "";
		me.r4 = "";
		me.r5 = "";
		me.r6 = "";
		me.r7 = "";
		
	},
	
	update: func(cdu) {
			
		setprop("/controls/cdu[" ~ cdu ~ "]/l1-type", me.l1_type);
		setprop("/controls/cdu[" ~ cdu ~ "]/display/l1-label", me.l1_label);
		setprop("/controls/cdu[" ~ cdu ~ "]/display/l1", me.l1);
		setprop("/controls/cdu[" ~ cdu ~ "]/l2-type", me.l2_type);
		setprop("/controls/cdu[" ~ cdu ~ "]/display/l2-label", me.l2_label);
		setprop("/controls/cdu[" ~ cdu ~ "]/display/l2", me.l2);
		setprop("/controls/cdu[" ~ cdu ~ "]/l3-type", me.l3_type);
		setprop("/controls/cdu[" ~ cdu ~ "]/display/l3-label", me.l3_label);
		setprop("/controls/cdu[" ~ cdu ~ "]/display/l3", me.l3);
		setprop("/controls/cdu[" ~ cdu ~ "]/l4-type", me.l4_type);
		setprop("/controls/cdu[" ~ cdu ~ "]/display/l4-label", me.l4_label);
		setprop("/controls/cdu[" ~ cdu ~ "]/display/l4", me.l4);
		setprop("/controls/cdu[" ~ cdu ~ "]/l5-type", me.l5_type);
		setprop("/controls/cdu[" ~ cdu ~ "]/display/l5-label", me.l5_label);
		setprop("/controls/cdu[" ~ cdu ~ "]/display/l5", me.l5);
		setprop("/controls/cdu[" ~ cdu ~ "]/l6-type", me.l6_type);
		setprop("/controls/cdu[" ~ cdu ~ "]/display/l6-label", me.l6_label);
		setprop("/controls/cdu[" ~ cdu ~ "]/display/l6", me.l6);
		setprop("/controls/cdu[" ~ cdu ~ "]/l7-type", me.l7_type);
		setprop("/controls/cdu[" ~ cdu ~ "]/display/l7-label", me.l7_label);
		setprop("/controls/cdu[" ~ cdu ~ "]/display/l7", me.l7);
		
		setprop("/controls/cdu[" ~ cdu ~ "]/r1-type", me.r1_type);
		setprop("/controls/cdu[" ~ cdu ~ "]/display/r1-label", me.r1_label);
		setprop("/controls/cdu[" ~ cdu ~ "]/display/r1", me.r1);
		setprop("/controls/cdu[" ~ cdu ~ "]/r2-type", me.r2_type);
		setprop("/controls/cdu[" ~ cdu ~ "]/display/r2-label", me.r2_label);
		setprop("/controls/cdu[" ~ cdu ~ "]/display/r2", me.r2);
		setprop("/controls/cdu[" ~ cdu ~ "]/r3-type", me.r3_type);
		setprop("/controls/cdu[" ~ cdu ~ "]/display/r3-label", me.r3_label);
		setprop("/controls/cdu[" ~ cdu ~ "]/display/r3", me.r3);
		setprop("/controls/cdu[" ~ cdu ~ "]/r4-type", me.r4_type);
		setprop("/controls/cdu[" ~ cdu ~ "]/display/r4-label", me.r4_label);
		setprop("/controls/cdu[" ~ cdu ~ "]/display/r4", me.r4);
		setprop("/controls/cdu[" ~ cdu ~ "]/r5-type", me.r5_type);
		setprop("/controls/cdu[" ~ cdu ~ "]/display/r5-label", me.r5_label);
		setprop("/controls/cdu[" ~ cdu ~ "]/display/r5", me.r5);
		setprop("/controls/cdu[" ~ cdu ~ "]/r6-type", me.r6_type);
		setprop("/controls/cdu[" ~ cdu ~ "]/display/r6-label", me.r6_label);
		setprop("/controls/cdu[" ~ cdu ~ "]/display/r6", me.r6);
		setprop("/controls/cdu[" ~ cdu ~ "]/r7-type", me.r7_type);
		setprop("/controls/cdu[" ~ cdu ~ "]/display/r7-label", me.r7_label);
		setprop("/controls/cdu[" ~ cdu ~ "]/display/r7", me.r7);
		
	}

};
