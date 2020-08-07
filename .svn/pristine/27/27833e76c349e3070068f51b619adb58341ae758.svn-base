var l1 = "";
var l2 = "";
var l3 = "";
var l4 = "";
var l5 = "";
var l6 = "";
var l7 = "";
var l8 = "";
var l9 = "";
var l10 = "";
var l11 = "";
var l12 = "";
var l13 = "";
var r1 = "";
var r3 = "";
var r5 = "";
var r7 = "";
var r9 = "";
var r11 = "";
var r13 = "";
var helper = "";
var keypress = "";
var lastlog = "";
var hist1 = "";
var hist2 = "";
var hist3 = "";
var hist4 = "";
var hist5 = "";
var hist6 = "";

var fuelrequired = 0;
var fuelrecommended = 0;


var efb = {
	init : func { 
        me.UPDATE_INTERVAL = 0.05; 
        me.loopid = 0; 
# Initialize

setprop("/instrumentation/efb/page", "MENU");

setprop("/instrumentation/efb/chart/rotation", 0);
setprop("/instrumentation/efb/diagram/rotation", 0);

setprop("/instrumentation/efb/manual-page", 0);

setprop("/instrumentation/efb/vnav_autogen/first", 0);
setprop("/instrumentation/efb/vnav_autogen/gen", 0);

setprop("/instrumentation/efb/catchme/score", 0);

        me.reset(); 
}, 
	searchairport : func(query) {

	setprop("/instrumentation/gps/scratch/query", query);
	setprop("/instrumentation/gps/scratch/type", "airport");

	setprop("/instrumentation/gps/command", "search");

setprop("/instrumentation/efb/selected-rwy/id", "");

},
	searchcharts : func(chart) {

	setprop("/sim/model/efb/chart", "Charts/" ~ chart ~ ".jpg");

},
	update : func {

var keypress = getprop("/instrumentation/efb/keypress");

if (getprop("/instrumentation/efb/page") == "MENU") {
	
	page.clearpage();
	page.index();

if (keypress == "r1") { setprop("/instrumentation/efb/page", "Are you Bored?");
keypress = "";
}
if (keypress == "l4") { setprop("/instrumentation/efb/page", "Airport Information");
keypress = "";
}
if (keypress == "l5") { setprop("/instrumentation/efb/page", "Airport Charts");
keypress = "";
}
if (keypress == "l6") { setprop("/instrumentation/efb/page", "Flight Manual Index");
keypress = "";
}
if (keypress == "l7") { setprop("/instrumentation/efb/page", "FGFSCopilot Logger");
keypress = "";
}
if (keypress == "r4") { setprop("/instrumentation/efb/page", "Airport Diagram");
keypress = "";
}
if (keypress == "r5") { setprop("/instrumentation/efb/page", "GPS Settings");
keypress = "";
}
if (keypress == "r6") { setprop("/instrumentation/efb/page", "Flight Fuel Planner");
keypress = "";
}
if (keypress == "r7") { setprop("/instrumentation/efb/page", "VNAV Altitudes Generator");
keypress = "";
}

} elsif (getprop("/instrumentation/efb/page") == "Airport Diagram") {
	
	page.clearpage();
setprop("/sim/model/efb/diagram", getprop("/instrumentation/gps/scratch/ident") ~ ".jpg");

	r13 = "ROTATE >";

if (keypress == "r7") toggle("/instrumentation/efb/diagram/rotation");

} elsif (getprop("/instrumentation/efb/page") == "Airport Charts") {
	
	page.clearpage();

	helper = "Select Chart in CDU";

	r13 = "ROTATE >";

if (keypress == "r7") toggle("/instrumentation/efb/chart/rotation");

} elsif (getprop("/instrumentation/efb/page") == "Airport Information") {
	
	page.clearpage();
	page.airportinfo();

if (keypress == "r6") { setprop("/instrumentation/efb/page", "Runway Information");
keypress = "";
}

} elsif (getprop("/instrumentation/efb/page") == "Runway Information") {
	
	page.clearpage();
	page.runwayinfo();

if (keypress == "r6") { 
setprop("/instrumentation/nav[0]/frequencies/selected-mhz", getprop("/instrumentation/efb/selected-rwy/ils-mhz"));
keypress = "";
}

} elsif (getprop("/instrumentation/efb/page") == "Auto-PIREP System") {
	
	page.clearpage();
	
	helper = "Only Applicable to Virtual Star Alliance";	

} elsif (getprop("/instrumentation/efb/page") == "FGFSCopilot Logger") {
	
	page.clearpage();
	page.fgfscopilot();

} elsif (getprop("/instrumentation/efb/page") == "Flight Fuel Planner") {
	
	page.clearpage();
	page.fuelplanner();

} elsif (getprop("/instrumentation/efb/page") == "GPS Settings") {
	
	page.clearpage();
	page.gps();

} elsif (getprop("/instrumentation/efb/page") == "Flight Manual Index") {
	
	page.clearpage();
	page.flightmanual();

if (keypress == "l1") { setprop("/instrumentation/efb/page", "Aircraft Checklists (1)");
keypress = "";
}
if (keypress == "l2") { setprop("/instrumentation/efb/page", "Aircraft Checklists (3)");
keypress = "";
}
if (keypress == "l3") { setprop("/instrumentation/efb/page", "Aircraft Checklists (5)");
keypress = "";
}
if (keypress == "l4") { setprop("/instrumentation/efb/page", "Aircraft Checklists (7)");
keypress = "";
}
if (keypress == "l5") { setprop("/instrumentation/efb/page", "Aircraft Checklists (9)");
keypress = "";
}
if (keypress == "l6") { setprop("/instrumentation/efb/page", "Aircraft Checklists (10)");
keypress = "";
}
if (keypress == "r1") { setprop("/instrumentation/efb/page", "Aircraft Checklists (2)");
keypress = "";
}
if (keypress == "r2") { setprop("/instrumentation/efb/page", "Aircraft Checklists (4)");
keypress = "";
}
if (keypress == "r3") { setprop("/instrumentation/efb/page", "Aircraft Checklists (6)");
keypress = "";
}
if (keypress == "r4") { setprop("/instrumentation/efb/page", "Aircraft Checklists (8)");
keypress = "";
}
if (keypress == "r5") { setprop("/instrumentation/efb/page", "Aircraft Checklists (9)");
keypress = "";
}
if (keypress == "r6") { setprop("/instrumentation/efb/page", "Aircraft Checklists (10)");
keypress = "";
}
if (keypress == "r7") { setprop("/instrumentation/efb/page", "Operating Manual");
keypress = "";
}

} elsif (getprop("/instrumentation/efb/page") == "Operating Manual") {
	
	page.clearpage();
	page.operatingmanual();

if (keypress == "r1") { setprop("/instrumentation/efb/manual-page", getprop("/instrumentation/efb/manual-page") - 0.12);
keypress = "";
}
if (keypress == "r2") { setprop("/instrumentation/efb/manual-page", getprop("/instrumentation/efb/manual-page") - 0.02);
keypress = "";
}

if (keypress == "r6") { setprop("/instrumentation/efb/manual-page", getprop("/instrumentation/efb/manual-page") + 0.02);
keypress = "";
}

if (keypress == "r7") { setprop("/instrumentation/efb/manual-page", getprop("/instrumentation/efb/manual-page") + 0.12);
keypress = "";
}

} elsif (getprop("/instrumentation/efb/page") == "Aircraft Checklists (1)") {
	
	page.clearpage();

setprop("/instrumentation/efb/checklists/x",0);
setprop("/instrumentation/efb/checklists/y",0);

r13 = "NEXT CHECKLIST >";

if (keypress == "r7") { setprop("/instrumentation/efb/page", "Aircraft Checklists (2)");
keypress = "";
}

} elsif (getprop("/instrumentation/efb/page") == "Aircraft Checklists (2)") {
	
	page.clearpage();

setprop("/instrumentation/efb/checklists/x",1);
setprop("/instrumentation/efb/checklists/y",0);

r13 = "NEXT CHECKLIST >";

if (keypress == "r7") { setprop("/instrumentation/efb/page", "Aircraft Checklists (3)");
keypress = "";
}

} elsif (getprop("/instrumentation/efb/page") == "Aircraft Checklists (3)") {
	
	page.clearpage();

setprop("/instrumentation/efb/checklists/x",2);
setprop("/instrumentation/efb/checklists/y",0);

r13 = "NEXT CHECKLIST >";

if (keypress == "r7") { setprop("/instrumentation/efb/page", "Aircraft Checklists (4)");
keypress = "";
}

} elsif (getprop("/instrumentation/efb/page") == "Aircraft Checklists (4)") {
	
	page.clearpage();

setprop("/instrumentation/efb/checklists/x",3);
setprop("/instrumentation/efb/checklists/y",0);

r13 = "NEXT CHECKLIST >";

if (keypress == "r7") { setprop("/instrumentation/efb/page", "Aircraft Checklists (5)");
keypress = "";
}

} elsif (getprop("/instrumentation/efb/page") == "Aircraft Checklists (5)") {
	
	page.clearpage();

setprop("/instrumentation/efb/checklists/x",0);
setprop("/instrumentation/efb/checklists/y",1);

r13 = "NEXT CHECKLIST >";

if (keypress == "r7") { setprop("/instrumentation/efb/page", "Aircraft Checklists (6)");
keypress = "";
}

} elsif (getprop("/instrumentation/efb/page") == "Aircraft Checklists (6)") {
	
	page.clearpage();

setprop("/instrumentation/efb/checklists/x",1);
setprop("/instrumentation/efb/checklists/y",1);

r13 = "NEXT CHECKLIST >";

if (keypress == "r7") { setprop("/instrumentation/efb/page", "Aircraft Checklists (7)");
keypress = "";
}

} elsif (getprop("/instrumentation/efb/page") == "Aircraft Checklists (7)") {
	
	page.clearpage();

setprop("/instrumentation/efb/checklists/x",2);
setprop("/instrumentation/efb/checklists/y",1);

r13 = "NEXT CHECKLIST >";

if (keypress == "r7") { setprop("/instrumentation/efb/page", "Aircraft Checklists (8)");
keypress = "";
}

} elsif (getprop("/instrumentation/efb/page") == "Aircraft Checklists (8)") {
	
	page.clearpage();

setprop("/instrumentation/efb/checklists/x",3);
setprop("/instrumentation/efb/checklists/y",1);

r13 = "NEXT CHECKLIST >";

if (keypress == "r7") { setprop("/instrumentation/efb/page", "Aircraft Checklists (9)");
keypress = "";
}

} elsif (getprop("/instrumentation/efb/page") == "Aircraft Checklists (9)") {
	
	page.clearpage();

setprop("/instrumentation/efb/checklists/x",0);
setprop("/instrumentation/efb/checklists/y",2);

r13 = "NEXT CHECKLIST >";

if (keypress == "r7") { setprop("/instrumentation/efb/page", "Aircraft Checklists (10)");
keypress = "";
}

} elsif (getprop("/instrumentation/efb/page") == "Aircraft Checklists (10)") {
	
	page.clearpage();

setprop("/instrumentation/efb/checklists/x",1);
setprop("/instrumentation/efb/checklists/y",2);

r13 = "BACK TO START >";

if (keypress == "r7") { setprop("/instrumentation/efb/page", "Aircraft Checklists (1)");
keypress = "";
}

} elsif (getprop("/instrumentation/efb/page") == "VNAV Altitudes Generator") {
	
	page.clearpage();

	page.vnav_alts();

# Menu Presses

	if (keypress == "r1") {
		b787.fmc.autogen_alts();
		setprop("/instrumentation/efb/vnav_autogen/gen", 1);
		}

	if (keypress == "r2")
		if (getprop("/instrumentation/efb/vnav_autogen/gen") == 1)
			b787.fmc.copy_altitudes();		
		
	if ((getprop("/instrumentation/efb/vnav_autogen/first") > 0) and (keypress == "r6"))
		setprop("/instrumentation/efb/vnav_autogen/first", getprop("/instrumentation/efb/vnav_autogen/first") - 1);
		
	if ((getprop("/instrumentation/efb/vnav_autogen/first") + 10 < getprop("autopilot/route-manager/route/num")) and (keypress == "r7"))
		setprop("/instrumentation/efb/vnav_autogen/first", getprop("/instrumentation/efb/vnav_autogen/first") + 1);

	page.update();

} elsif (getprop("/instrumentation/efb/page") == "Are you Bored?") {

	setprop("/instrumentation/efb/catchme/score", 0);
	
	page.clearpage();

	page.boredom();

# Menu Presses

	if (keypress == "l4") {
			setprop("/instrumentation/efb/catchme/score", 0);
			setprop("/instrumentation/efb/page", "Catch me if you can");
		}

	page.update();

} elsif (getprop("/instrumentation/efb/page") == "Catch me if you can") {

	page.clearpage();
	
	page.catchme();
	
	page.update();

} elsif (getprop("/instrumentation/efb/page") == "GAME OVER") {

	page.clearpage();
	
	page.catchme_gameover();
	
	# Menu Presses
	
	if (keypress == "r7") {
	
		setprop("/instrumentation/efb/catchme/score", 0);
		setprop("/instrumentation/efb/catchme/x", 0);
		setprop("/instrumentation/efb/catchme/y", 0);
		setprop("/instrumentation/efb/catchme/color", "white");
		
		setprop("/instrumentation/efb/page", "Catch me if you can");
	
	}
	
	page.update();

}



if (substr(getprop("/instrumentation/efb/page"),0,19) == "Aircraft Checklists") {
setprop("/instrumentation/efb/checklists/show",1);
} else {
setprop("/instrumentation/efb/checklists/show",0);
}


	# L7 is always MENU except in MENU page
if (getprop("/instrumentation/efb/page") != "MENU") {
l13 = "< MENU";
if (keypress == "l7") { setprop("/instrumentation/efb/page", "MENU");
keypress = "";
} }
	page.update();

if ((getprop("/instrumentation/efb/page") == "Airport Charts") or (getprop("/instrumentation/efb/page") == "Airport Diagram") or (getprop("/instrumentation/efb/page") == "Operating Manual")) setprop("/instrumentation/efb/text-color", 0);
else setprop("/instrumentation/efb/text-color", 1);

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

var page = {
	update : func {

		setprop("/instrumentation/efb/display/line1-l", l1);
		setprop("/instrumentation/efb/display/line2-l", l2);
		setprop("/instrumentation/efb/display/line3-l", l3);
		setprop("/instrumentation/efb/display/line4-l", l4);
		setprop("/instrumentation/efb/display/line5-l", l5);
		setprop("/instrumentation/efb/display/line6-l", l6);
		setprop("/instrumentation/efb/display/line7-l", l7);
		setprop("/instrumentation/efb/display/line8-l", l8);
		setprop("/instrumentation/efb/display/line9-l", l9);
		setprop("/instrumentation/efb/display/line10-l", l10);
		setprop("/instrumentation/efb/display/line11-l", l11);
		setprop("/instrumentation/efb/display/line12-l", l12);
		setprop("/instrumentation/efb/display/line13-l", l13);

		setprop("/instrumentation/efb/display/line1-r", r1);
		setprop("/instrumentation/efb/display/line3-r", r3);
		setprop("/instrumentation/efb/display/line5-r", r5);
		setprop("/instrumentation/efb/display/line7-r", r7);
		setprop("/instrumentation/efb/display/line9-r", r9);
		setprop("/instrumentation/efb/display/line11-r", r11);
		setprop("/instrumentation/efb/display/line13-r", r13);

		setprop("/instrumentation/efb/display/input-helper", helper);
		setprop("/instrumentation/efb/keypress", keypress);

},
	clearpage : func {

		l1 = "";
		l2 = "";
		l3 = "";
		l4 = "";
		l5 = "";
		l6 = "";
		l7 = "";
		l8 = "";
		l9 = "";
		l10 = "";
		l11 = "";
		l12 = "";
		l13 = "";

		r1 = "";
		r3 = "";
		r5 = "";
		r7 = "";
		r9 = "";
		r11 = "";
		r13 = "";

		helper = "";

},

	boredom : func {
	
		l1 = "You should NOT be here if you're flying!";
		l3 = "But then, we know that if you're cruising on long,";
		l4 = "flights it gets quite boring... So well, select a";
		l5 = "game and have fun!";
		
		l7 = "< Catch me if you can";
		
		helper = "More Games Coming Soon...";
	
},

	catchme : func {
	
		r13 = "SCORE : " ~ getprop("/instrumentation/efb/catchme/score");
		
		helper = "Click on the ball to catch it!"
	
},

	catchme_gameover : func {
	
		helper = "SCORE : " ~ getprop("/instrumentation/efb/catchme/score");
		
		r13 = "PLAY AGAIN >";
	
},

	vnav_alts : func {
	
		r1 = "AUTOGEN >";
		
		r3 = "COPY TO RTE >";
			
		if (getprop("/instrumentation/efb/vnav_autogen/first") != 0)
			r11 = "SCROLL UP >";
			
		if (getprop("/instrumentation/efb/vnav_autogen/first") + 10 < getprop("autopilot/route-manager/route/num"))
			r13 = "SCROLL DOWN >";
			
		if (getprop("/instrumentation/efb/vnav_autogen/gen") == 1) {	
		
		var first = getprop("/instrumentation/efb/vnav_autogen/first");	
			
		if (getprop("/autopilot/route-manager/route/wp[" ~ (first) ~ "]/id") != nil) {
		
			var wp_id = getprop("/autopilot/route-manager/route/wp[" ~ (first) ~ "]/id");
			var wp_alt = getprop("/instrumentation/b787-fmc/vnav-calcs/wp[" ~ (first) ~ "]/altitude");
			
			l1 = wp_id ~ " at " ~ int(wp_alt) ~ " ft";
		
		}
		
		if (getprop("/autopilot/route-manager/route/wp[" ~ (first + 1) ~ "]/id") != nil) {
		
			var wp_id = getprop("/autopilot/route-manager/route/wp[" ~ (first + 1) ~ "]/id");
			var wp_alt = getprop("/instrumentation/b787-fmc/vnav-calcs/wp[" ~ (first + 1) ~ "]/altitude");
			
			l2 = wp_id ~ " at " ~ int(wp_alt) ~ " ft";
		
		}
		
		if (getprop("/autopilot/route-manager/route/wp[" ~ (first + 2) ~ "]/id") != nil) {
		
			var wp_id = getprop("/autopilot/route-manager/route/wp[" ~ (first + 2) ~ "]/id");
			var wp_alt = getprop("/instrumentation/b787-fmc/vnav-calcs/wp[" ~ (first + 2) ~ "]/altitude");
			
			l3 = wp_id ~ " at " ~ int(wp_alt) ~ " ft";
		
		}
		
		if (getprop("/autopilot/route-manager/route/wp[" ~ (first + 3) ~ "]/id") != nil) {
		
			var wp_id = getprop("/autopilot/route-manager/route/wp[" ~ (first + 3) ~ "]/id");
			var wp_alt = getprop("/instrumentation/b787-fmc/vnav-calcs/wp[" ~ (first + 3) ~ "]/altitude");
			
			l4 = wp_id ~ " at " ~ int(wp_alt) ~ " ft";
		
		}
		
		if (getprop("/autopilot/route-manager/route/wp[" ~ (first + 4) ~ "]/id") != nil) {
		
			var wp_id = getprop("/autopilot/route-manager/route/wp[" ~ (first + 4) ~ "]/id");
			var wp_alt = getprop("/instrumentation/b787-fmc/vnav-calcs/wp[" ~ (first + 4) ~ "]/altitude");
			
			l5 = wp_id ~ " at " ~ int(wp_alt) ~ " ft";
		
		}
		
		if (getprop("/autopilot/route-manager/route/wp[" ~ (first + 5) ~ "]/id") != nil) {
		
			var wp_id = getprop("/autopilot/route-manager/route/wp[" ~ (first + 5) ~ "]/id");
			var wp_alt = getprop("/instrumentation/b787-fmc/vnav-calcs/wp[" ~ (first + 5) ~ "]/altitude");
			
			l6 = wp_id ~ " at " ~ int(wp_alt) ~ " ft";
		
		}
		
		if (getprop("/autopilot/route-manager/route/wp[" ~ (first + 6) ~ "]/id") != nil) {
		
			var wp_id = getprop("/autopilot/route-manager/route/wp[" ~ (first + 6) ~ "]/id");
			var wp_alt = getprop("/instrumentation/b787-fmc/vnav-calcs/wp[" ~ (first + 6) ~ "]/altitude");
			
			l7 = wp_id ~ " at " ~ int(wp_alt) ~ " ft";
		
		}
		
		if (getprop("/autopilot/route-manager/route/wp[" ~ (first + 7) ~ "]/id") != nil) {
		
			var wp_id = getprop("/autopilot/route-manager/route/wp[" ~ (first + 7) ~ "]/id");
			var wp_alt = getprop("/instrumentation/b787-fmc/vnav-calcs/wp[" ~ (first + 7) ~ "]/altitude");
			
			l8 = wp_id ~ " at " ~ int(wp_alt) ~ " ft";
		
		}
		
		if (getprop("/autopilot/route-manager/route/wp[" ~ (first + 8) ~ "]/id") != nil) {
		
			var wp_id = getprop("/autopilot/route-manager/route/wp[" ~ (first + 8) ~ "]/id");
			var wp_alt = getprop("/instrumentation/b787-fmc/vnav-calcs/wp[" ~ (first + 8) ~ "]/altitude");
			
			l9 = wp_id ~ " at " ~ int(wp_alt) ~ " ft";
		
		}
		
		if (getprop("/autopilot/route-manager/route/wp[" ~ (first + 9) ~ "]/id") != nil) {
		
			var wp_id = getprop("/autopilot/route-manager/route/wp[" ~ (first + 9) ~ "]/id");
			var wp_alt = getprop("/instrumentation/b787-fmc/vnav-calcs/wp[" ~ (first + 9) ~ "]/altitude");
			
			l10 = wp_id ~ " at " ~ int(wp_alt) ~ " ft";
		
		}
		
		if (getprop("/autopilot/route-manager/route/wp[" ~ (first + 10) ~ "]/id") != nil) {
		
			var wp_id = getprop("/autopilot/route-manager/route/wp[" ~ (first + 10) ~ "]/id");
			var wp_alt = getprop("/instrumentation/b787-fmc/vnav-calcs/wp[" ~ (first + 10) ~ "]/altitude");
			
			l11 = wp_id ~ " at " ~ int(wp_alt) ~ " ft";
		
		}
		
		}
		
		helper = "Create Route and then use Autogen";		
	
},
	index : func {

l7 = "< Airport Information";
r7 = "Airport Diagram >";
l9 = "< Airport Charts";
r9 = "GPS Settings >";
l11 = "< Flight Manual Index";
r11 = "Flight Fuel Planner >";
l13 = "< FGFSCopilot Connect";
r13 = "VNAV Altitudes Gen >";

},
	airportinfo : func {

l1 = "Airport : " ~ getprop("/instrumentation/gps/scratch/ident") ~ " (" ~ getprop("/instrumentation/gps/scratch/name") ~ ")";

setprop("/environment/metar[6]/station-id", getprop("/instrumentation/gps/scratch/ident"));

l8 = "Elevation : " ~ getprop("/instrumentation/gps/scratch/altitude-ft") ~ " ft";

l9 = "Weather : " ~ substr(getprop("/environment/metar[6]/data"),17,30);

if (size(getprop("/environment/metar[6]/data")) > 30) l10 = substr(getprop("/environment/metar[6]/data"), 47, 40);

l11 = "Runways : ";

l12 = "         ";

for (var n = 0; n < 12; n += 1) {

	if (getprop("/instrumentation/gps/scratch/runways[" ~ n ~ "]/id") != nil) {

		if (n <= 5)	l11 = l11 ~ getprop("/instrumentation/gps/scratch/runways[" ~ n ~ "]/id") ~ " ";
		else l12 = l12 ~ getprop("/instrumentation/gps/scratch/runways[" ~ n ~ "]/id") ~ " ";
	}

}

r11 = "INFO > ";

helper = "Enter ICAO in CDU to Search";

}, 
	runwayinfo : func {

l1 = "Runways : ";

l2 = "         ";

if (getprop("/instrumentation/efb/selected-rwy/id") == nil) {

setprop("/instrumentation/efb/selected-rwy/id", getprop("/instrumentation/gps/scratch/runways/id"));

}

for (var n = 0; n < 12; n += 1) {

	if (getprop("/instrumentation/gps/scratch/runways[" ~ n ~ "]/id") != nil) {

		if (n <= 7)	l1 = l1 ~ getprop("/instrumentation/gps/scratch/runways[" ~ n ~ "]/id") ~ " ";
		else l2 = l2 ~ getprop("/instrumentation/gps/scratch/runways[" ~ n ~ "]/id") ~ " ";

		if (getprop("/instrumentation/gps/scratch/runways[" ~ n ~ "]/id") == getprop("/instrumentation/efb/selected-rwy/id")) {
	
			setprop("/instrumentation/efb/selected-rwy/length-ft", getprop("/instrumentation/gps/scratch/runways[" ~ n ~ "]/length-ft"));
			setprop("/instrumentation/efb/selected-rwy/width-ft", getprop("/instrumentation/gps/scratch/runways[" ~ n ~ "]/width-ft"));
			setprop("/instrumentation/efb/selected-rwy/heading-deg", getprop("/instrumentation/gps/scratch/runways[" ~ n ~ "]/heading-deg"));
			if (getprop("/instrumentation/gps/scratch/runways[" ~ n ~ "]/ils-frequency-mhz") != nil ) {
			setprop("/instrumentation/efb/selected-rwy/ils-mhz", getprop("/instrumentation/gps/scratch/runways[" ~ n ~ "]/ils-frequency-mhz"));
			} else setprop("/instrumentation/efb/selected-rwy/ils-mhz", "NOT AVAILABLE");

		}

	}

}

helper = "Enter Runway ID in CDU to Search";

l4 = "Selected Runway : " ~ getprop("/instrumentation/efb/selected-rwy/id");

if (getprop("/instrumentation/efb/selected-rwy/heading-deg") != nil) l6 = "Runway Heading  : " ~ getprop("/instrumentation/efb/selected-rwy/heading-deg") ~ " Degrees";
if (getprop("/instrumentation/efb/selected-rwy/length-ft") != nil) l8 = "Runway Length   : " ~ getprop("/instrumentation/efb/selected-rwy/length-ft") ~ " ft";
if (getprop("/instrumentation/efb/selected-rwy/width-ft") != nil) l9 = "Runway Width    : " ~ getprop("/instrumentation/efb/selected-rwy/width-ft") ~ " ft";

if (getprop("/instrumentation/efb/selected-rwy/ils-mhz") != nil) {
l11 = "ILS Frequency   : " ~ getprop("/instrumentation/efb/selected-rwy/ils-mhz");
r11 = "SET NAV1 >";
} else l11 = "ILS Frequency   : NOT ILS Equipped";

},
	fgfscopilot : func {

	if (getprop("/connection/fgfscopilot/connected")) 
	{
		l1 = "FGFSCopilot Connected!";
		l2 = "Connected to : Telnet Port " ~ getprop("/connection/fgfscopilot/telnet");

		l4 = "LAST MESSAGE : " ~ getprop("/connection/fgfscopilot/log");

		l5 = "LOG HISTORY :";

		if (lastlog != getprop("/connection/fgfscopilot/log")) {

			hist6 = hist5;
			hist5 = hist4;
			hist4 = hist3;			
			hist3 = hist2;
			hist2 = hist1;
			hist1 = lastlog;

		}

		lastlog = getprop("/connection/fgfscopilot/log");

		l6 = "  " ~ hist1;
		l7 = "  " ~ hist2;
		l8 = "  " ~ hist3;
		l9 = "  " ~ hist4;
		l10 = "  " ~ hist5;
		l11 = "  " ~ hist6;

	}
	else l1 = "FGFSCopilot NOT Connected!";

}, 
	flightmanual : func {

l1 = "< Preflight Checklist";
r1 = "Startup Checklist >";
l3 = "< Taxi Checklist";
r3 = "Take Off Checklist >";
l5 = "< Climbout Checklist";
r5 = "Cruise Checklist >";
l7 = "< Descent Checklist";
r7 = "Approach Checklist >";
l9 = "< Landing Checklist";
r9 = "Taxi-to-Ramp Checklist >";
l11 = "< Shutdown Checklist";
r11 = "Secure Aircraft Checklist >";
r13 = "Operating Manual >";

},
	operatingmanual : func {

r1 = "PAGE UP >";
r3 = "SCROLL UP >";
r11 = "SCROLL DOWN >";
r13 = "PAGE DOWN >";

},
	gps : func {

l9 = "Desired Magnetic Course : " ~ getprop("/instrumentation/gps/wp/leg-mag-course-deg");
l10 = "Desired True Heading" ~ getprop("/instrumentation/gps/wp/leg-true-course-deg");
l11 = "Distance to Waypoint : " ~ getprop("/instrumentation/gps/wp/leg-distance-nm");

},
	fuelplanner : func {

setprop("/autopilot/route-manager/airborne", 1);
setprop("/autopilot/route-manager/active", 1);

if ((getprop("/autopilot/route-manager/wp-last/dist") != 0) and (getprop("/autopilot/route-manager/wp-last/dist") != nil) and (getprop("/autopilot/route-manager/route/num") >= 2)) {

l2 = "Total Route Distance : " ~ getprop("/autopilot/route-manager/wp-last/dist") ~ " nm";

fuelrequired = (13.475 * getprop("/autopilot/route-manager/wp-last/dist") + 6450);
fuelrecommended = (14.35 * getprop("/autopilot/route-manager/wp-last/dist") + 8000);

if (fuelrequired >= 125000) 
{
l6 = "Fuel Required : ROUTE TOO LONG!";

l8 = "Fuel Recommended : ROUTE TOO LONG!";
} else {

if (fuelrequired >= 101604) fuelrequired = 101604.00;

if (fuelrecommended >= 101604) fuelrecommended = 101604.00;

l6 = "Fuel Required : " ~ fuelrequired ~ " kg";

l8 = "Fuel Recommended : " ~ fuelrecommended ~ " kg";
}

l10 = "Calculations are made assuming cruise at 0.85";
l11 = "mach around FL360 (36000 ft)";

} else {

helper = "Enter Route in CDU";

}

}

};

var toggle = func(property) {

if (getprop(property) == 1) setprop(property, 0);
else setprop(property, 1);

}

setlistener("sim/signals/fdm-initialized", func
 {
 efb.init();
 print("EFB Computer ........ Initialized");
 });
