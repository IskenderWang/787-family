################################################################################
#
# Boeing Flightplan Management
#-------------------------------------------------------------------------------
#
# The crew can enter 2 flightplans, a primary one and an alternate one. The
# crew also has a choice for an alternate airport. The 2 flightplans are stored
# in separate trees in the property list, and the crew can choose which one to
# use. The one chosen will be put into the route manager. When the pilot chooses
# to divert, the active route is cleared, and the aircraft is put on a direct
# flight to the alternate airport.
#-------------------------------------------------------------------------------
#
# This file (flightplan.nas) is standalone and only contains the functions
# that need to be executed for the flightplan manager's functions. These need to
# be called from the aircraft's CDU (mCDU for Airbus, but this is meant for BOE)
#-------------------------------------------------------------------------------
#
# This file permits the usage of how many ever flightplans are requierd. Just 
# add the flightplan too be initialized if you want more than 2. 2 flightplans
# are there by default as Boeing's Flight Management Computer uses 2.
#-------------------------------------------------------------------------------
#
# Copyright (c) 2012 Narendran Muraleedharan
#
# Licensed under GNU General Public License v2.
# <http://www.gnu.org/licenses/>
#
################################################################################

var fmcFPtree = "/instrumentation/fmcFP/";
var route = "/autopilot/route-manager/";

# Flight Management Computer: Flightplan Management Class

var fmcFP = {

	# Initialize Flight Plan Management

	init: func() {
	
		setprop(fmcFPtree~ "flightplan[0]/num", 0);
		setprop(fmcFPtree~ "flightplan[1]/num", 0);
		setprop(fmcFPtree~ "flightplan[0]/status", "EMPTY");
		setprop(fmcFPtree~ "flightplan[1]/status", "EMPTY");
		setprop(fmcFPtree~ "alternate/icao", "");
		
		setprop(fmcFPtree~ "FPpage[0]/first", 0);
		setprop(fmcFPtree~ "FPpage[1]/first", 0);
		
		setprop(fmcFPtree~ "path", getprop("/sim/fg-home/"));
		
		sysinfo.log_msg("[FMC] Initialized Empty Flightplans", 0);
	
	},

	# Basic Route Manager Functions (CLEAR, INSERT, ADD, REMOVE)
	
	clear: func(plan) {
	
		var n = 0;
		
		if (plan == 0)
			sysinfo.log_msg("[FMC] Primary Flightplan Cleared", 0);
		else
			sysinfo.log_msg("[FMC] Secondary Flightplan Cleared", 0);
	
		while(getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ n ~ "]/id") != nil) {
		
			setprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ n ~ "]/id", "");
			setprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ n ~ "]/alt", 0);
			n += 1;
			
		}
		
		setprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/num", 0);
	
	},
	
	insert: func(plan, index, wp, alt) {

		var n = getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/num"); 
		
		setprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/num", getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/num") + 1);
		
		while(n >= index) {
		
			setprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ (n + 1) ~ "]/id", getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ n ~ "]/id"));
			setprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ (n + 1) ~ "]/alt", getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ n ~ "]/alt"));
			
			n = n - 1;
		
		}
		
		setprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ index ~ "]/id", wp);
		setprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ index ~ "]/alt", alt);
	
	},
	
	add: func(plan, wp, alt) {
	
		var index = getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/num");
	
		setprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/num", getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/num") + 1);
		
		setprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ index ~ "]/id", wp);
		setprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ index ~ "]/alt", alt);
	
	},
	
	remove: func(plan, index) {
	
		var n = index;
		
		var last = getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/num");
		
		setprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/num", getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/num") - 1);
		
		while(n < getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/num")) {
		
			setprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ n ~ "]/id", getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ (n + 1) ~ "]/id"));
			setprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ n ~ "]/alt", getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ (n + 1) ~ "]/alt"));
			
			n += 1;
		
		}
		
		setprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ last ~ "]/id", "");
		setprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ last ~ "]/alt", 0);
		
	},
	
	# Copy a flight plan to Route Manager or Update the Route
	
	copy: func(plan) {
	
		if (plan == 0)
			sysinfo.log_msg("[FMC] Primary Flightplan Copied to Route", 0);
		else
			sysinfo.log_msg("[FMC] Secondary Flightplan Copied to Route", 0);
	
		## Clear the Route Manager
		
		setprop(route~ "input", "@CLEAR");
		
		## Put in all the Waypoints
		
		var n = 0;
		
		while (n < getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/num")) {
		
			setprop(route~ "input", "@INSERT999:" ~ getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ n ~ "]/id") ~ "@" ~ getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ n ~ "]/alt"));
			
			n += 1;
		
		}
	
	},
	
	# Function to set altitude for a WP
	
	setalt: func(plan, index, alt) {
	
		setprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ index ~ "]/alt", alt);
	
	},
	
	# Clear the active route and divert to the given airport
	
	divert: func(icao) {
	
		sysinfo.log_msg("[FMC] Diverting to " ~ icao, 0);
	
		## Clear the Route Manager
		
		setprop(route~ "input", "@CLEAR");
		
		## Set Diversion Airport as the only WP on the Route Manager
		
		setprop(route~ "departure/airport", "");
		setprop(route~ "destination/airport", "");
		setprop(route~ "departure/runway", "");
		setprop(route~ "destination/runway", "");
		
		setprop(route~ "input", "@INSERT999:" ~ icao ~ "@0");
		
		setprop(route~ "active", 1);
	
	},
	
	# Import/Export Flightplan
	
	import: func(path, plan) {
	
		io.read_properties(path, "/instrumentation/fmcFP/flightplan[" ~ plan ~ "]/");
	
	},
	
	export: func(path, plan) {
	
		var path = getprop("/sim/gui/dialogs/file-select-1/path");
		io.write_properties(path, "/sim/gui/style[999]/");
	
	}

};

################################################################################

# Function to display the Flightplan page (part of the CDU)

var FPpage = func(cdu, plan) {

	## Field Types
	
	setprop("/controls/cdu[" ~ cdu ~ "]/l1-type", "click");
	setprop("/controls/cdu[" ~ cdu ~ "]/l2-type", "click");
	setprop("/controls/cdu[" ~ cdu ~ "]/l3-type", "click");
	setprop("/controls/cdu[" ~ cdu ~ "]/l4-type", "click");
	setprop("/controls/cdu[" ~ cdu ~ "]/l5-type", "click");
	setprop("/controls/cdu[" ~ cdu ~ "]/l6-type", "click");
	setprop("/controls/cdu[" ~ cdu ~ "]/l7-type", "click");

	setprop("/controls/cdu[" ~ cdu ~ "]/r1-type", "click");
	setprop("/controls/cdu[" ~ cdu ~ "]/r2-type", "click");
	setprop("/controls/cdu[" ~ cdu ~ "]/r3-type", "click");
	setprop("/controls/cdu[" ~ cdu ~ "]/r4-type", "click");
	setprop("/controls/cdu[" ~ cdu ~ "]/r5-type", "click");
	setprop("/controls/cdu[" ~ cdu ~ "]/r6-type", "click");
	setprop("/controls/cdu[" ~ cdu ~ "]/r7-type", "click");

	## Field Values

	setprop("/controls/cdu[" ~ cdu ~ "]/display/l1-label", "");
	setprop("/controls/cdu[" ~ cdu ~ "]/display/l2-label", "");
	setprop("/controls/cdu[" ~ cdu ~ "]/display/l3-label", "");
	setprop("/controls/cdu[" ~ cdu ~ "]/display/l4-label", "");
	setprop("/controls/cdu[" ~ cdu ~ "]/display/l5-label", "");
	setprop("/controls/cdu[" ~ cdu ~ "]/display/l6-label", "");
	setprop("/controls/cdu[" ~ cdu ~ "]/display/l7-label", "");
	setprop("/controls/cdu[" ~ cdu ~ "]/display/r1-label", "");
	setprop("/controls/cdu[" ~ cdu ~ "]/display/r2-label", "");
	setprop("/controls/cdu[" ~ cdu ~ "]/display/r3-label", "");
	setprop("/controls/cdu[" ~ cdu ~ "]/display/r4-label", "");
	setprop("/controls/cdu[" ~ cdu ~ "]/display/r5-label", "");
	setprop("/controls/cdu[" ~ cdu ~ "]/display/r6-label", "");
	setprop("/controls/cdu[" ~ cdu ~ "]/display/r7-label", "");

	setprop("/controls/cdu[" ~ cdu ~ "]/display/l5", "< REMOVE WP");
	setprop("/controls/cdu[" ~ cdu ~ "]/display/l6", "< CLEAR FP");
	setprop("/controls/cdu[" ~ cdu ~ "]/display/l7", "< INDEX");
	setprop("/controls/cdu[" ~ cdu ~ "]/display/r7", "FLIGHTPLANS >");
	
	if (getprop(fmcFPtree~ "FPpage[" ~ plan ~ "]/first") != 0)
		setprop("/controls/cdu[" ~ cdu ~ "]/display/r5", "SCROLL UP >");
	else
		setprop("/controls/cdu[" ~ cdu ~ "]/display/r5", "");
		
	if (getprop(fmcFPtree~ "FPpage[" ~ plan ~ "]/first") + 4 < getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/num"))
		setprop("/controls/cdu[" ~ cdu ~ "]/display/r6", "SCROLL DOWN >");
	else
		setprop("/controls/cdu[" ~ cdu ~ "]/display/r6", "");
		
	## Display WP IDs and ALTs
	
	if ((getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ getprop(fmcFPtree~ "FPpage[" ~ plan ~ "]/first") ~ "]/id") != nil) and (getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ (getprop(fmcFPtree~ "FPpage[" ~ plan ~ "]/first")) ~ "]/id") != "")) {
	
		setprop("/controls/cdu[" ~ cdu ~ "]/display/l1", getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ (getprop(fmcFPtree~ "FPpage[" ~ plan ~ "]/first")) ~ "]/id"));
		setprop("/controls/cdu[" ~ cdu ~ "]/display/r1", getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ (getprop(fmcFPtree~ "FPpage[" ~ plan ~ "]/first")) ~ "]/alt"));
	
	} else {
	
		setprop("/controls/cdu[" ~ cdu ~ "]/display/l1", "-");
		setprop("/controls/cdu[" ~ cdu ~ "]/display/r1", "-");
	
	}
	
	if ((getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ (getprop(fmcFPtree~ "FPpage[" ~ plan ~ "]/first") + 1) ~ "]/id") != nil) and (getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ (getprop(fmcFPtree~ "FPpage[" ~ plan ~ "]/first") + 1) ~ "]/id") != "")) {
	
		setprop("/controls/cdu[" ~ cdu ~ "]/display/l2", getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ (getprop(fmcFPtree~ "FPpage[" ~ plan ~ "]/first") + 1) ~ "]/id"));
		setprop("/controls/cdu[" ~ cdu ~ "]/display/r2", getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ (getprop(fmcFPtree~ "FPpage[" ~ plan ~ "]/first") + 1) ~ "]/alt"));
	
	} else {
	
		setprop("/controls/cdu[" ~ cdu ~ "]/display/l2", "-");
		setprop("/controls/cdu[" ~ cdu ~ "]/display/r2", "-");
	
	}
	
	if ((getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ (getprop(fmcFPtree~ "FPpage[" ~ plan ~ "]/first") + 2) ~ "]/id") != nil) and (getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ (getprop(fmcFPtree~ "FPpage[" ~ plan ~ "]/first") + 2) ~ "]/id") != "")) {
	
		setprop("/controls/cdu[" ~ cdu ~ "]/display/l3", getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ (getprop(fmcFPtree~ "FPpage[" ~ plan ~ "]/first") + 2) ~ "]/id"));
		setprop("/controls/cdu[" ~ cdu ~ "]/display/r3", getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ (getprop(fmcFPtree~ "FPpage[" ~ plan ~ "]/first") + 2) ~ "]/alt"));
	
	} else {
	
		setprop("/controls/cdu[" ~ cdu ~ "]/display/l3", "-");
		setprop("/controls/cdu[" ~ cdu ~ "]/display/r3", "-");
	
	}
	
	if ((getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ (getprop(fmcFPtree~ "FPpage[" ~ plan ~ "]/first") + 3) ~ "]/id") != nil) and (getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ (getprop(fmcFPtree~ "FPpage[" ~ plan ~ "]/first") + 3) ~ "]/id") != "")) {
	
		setprop("/controls/cdu[" ~ cdu ~ "]/display/l4", getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ (getprop(fmcFPtree~ "FPpage[" ~ plan ~ "]/first") + 3) ~ "]/id"));
		setprop("/controls/cdu[" ~ cdu ~ "]/display/r4", getprop(fmcFPtree~ "flightplan[" ~ plan ~ "]/wp[" ~ (getprop(fmcFPtree~ "FPpage[" ~ plan ~ "]/first") + 3) ~ "]/alt"));
	
	} else {
	
		setprop("/controls/cdu[" ~ cdu ~ "]/display/l4", "-");
		setprop("/controls/cdu[" ~ cdu ~ "]/display/r4", "-");
	
	}
		
}
