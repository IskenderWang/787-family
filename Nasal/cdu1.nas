var cdu = {
	init : func { 
        me.UPDATE_INTERVAL = 0.1; 
        me.loopid = 0; 

# Initialize display and other CDU properties

## Initialize Flight Plan Management System

fmcFP.init();
print("Flightplan Manager .. Initialized");

fmcTP.init();
print("Procedures Manager .. Initialized");

## VNAV Config Properties

setprop("/controls/cdu/vnav/crz-altitude-ft", 10000);
setprop("/controls/cdu/vnav/start-crz", "");
setprop("/controls/cdu/vnav/end-crz", "");

## Navaid Search Properties

setprop("/instrumentation/navSearch/name", " ");
setprop("/instrumentation/navSearch/d_aircraft", 20);
setprop("/instrumentation/navSearch/icao", getprop("/autopilot/route-manager/departure/airport"));
setprop("/instrumentation/navSearch/d_airport", 20);

## TP Properties

setprop("/instrumentation/b787-fmc/TPicao", "");
setprop("/instrumentation/b787-fmc/TPname", "");
setprop("/instrumentation/b787-fmc/TPtype", "SID");
setprop("/instrumentation/b787-fmc/TPrwy", "");

## HOLD Config Properties

setprop("/controls/cdu/hold/found", 0);

var htree = "/autopilot/hold/";

setprop(htree ~"hold-time", 60);
setprop(htree ~"hold-direction", "Right");
setprop(htree ~"hold-radial", 0);
setprop(htree ~"altitude", 5000);
setprop(htree ~"active", 0);
setprop(htree ~"entry", 0); #0 = direct, 1 = parallel, 2 = teardrop
setprop(htree ~"phase", 0); #0 = define entry, 1 = inbound leg, 2 = outbound turn, 3 = outbound leg, 4 = inbound turn, 5 = fly entry
setprop(htree ~"entry-phase", 0); #0 = parallel - fly to fix, 1 =  fly parallel, 2 = turn inbound, 3 intercept inbound leg
setprop(htree ~"fix", "");
setprop(htree ~"nav-type", "vor");

## Root Properties

setprop("/controls/cdu/flightnum", "");

setprop("/controls/cdu/keypress", "");

setprop("/controls/cdu/display/page", "IDENT");

setprop("/controls/cdu/input", "");

## Chart Properties

if (getprop("/instrumentation/gps/scratch/ident") != nil) setprop("/instrumentation/efb/chart/icao", getprop("/instrumentation/gps/scratch/ident"));
else setprop("/instrumentation/efb/chart/icao", "");

setprop("/instrumentation/efb/chart/type", "SID");

setprop("/instrumentation/efb/chart/newairport", 1);
me.nochart = 1;

## Flight Log Properties

setprop("/controls/cdu/log/flighttime", "00:00");
setprop("/controls/cdu/log/fuel", "0");
setprop("/autopilot/route-manager/departure/airport", getprop("/sim/airport/closest-airport-id"));

setprop("/controls/cdu/log/start-time-utc/day", getprop("/sim/time/utc/day"));
setprop("/controls/cdu/log/start-time-utc/hour", getprop("/sim/time/utc/hour"));
setprop("/controls/cdu/log/start-time-utc/minute", getprop("/sim/time/utc/minute"));

setprop("/controls/cdu/log/start-fuel-kg", getprop("/consumables/fuel/total-fuel-kg"));

## Extra Props for The Route Manager

setprop("/controls/cdu/route-manager/page", 1);
setprop("/controls/cdu/route-manager/max-pages", 1);

## Display Props

setprop("/controls/cdu/display/l1-label", "");
setprop("/controls/cdu/display/l2-label", "");
setprop("/controls/cdu/display/l3-label", "");
setprop("/controls/cdu/display/l4-label", "");
setprop("/controls/cdu/display/l5-label", "");
setprop("/controls/cdu/display/l6-label", "");
setprop("/controls/cdu/display/l7-label", "");

setprop("/controls/cdu/display/r1-label", "");
setprop("/controls/cdu/display/r2-label", "");
setprop("/controls/cdu/display/r3-label", "");
setprop("/controls/cdu/display/r4-label", "");
setprop("/controls/cdu/display/r5-label", "");
setprop("/controls/cdu/display/r6-label", "");
setprop("/controls/cdu/display/r7-label", "");

setprop("/controls/cdu/display/l1", "");
setprop("/controls/cdu/display/l2", "");
setprop("/controls/cdu/display/l3", "");
setprop("/controls/cdu/display/l4", "");
setprop("/controls/cdu/display/l5", "");
setprop("/controls/cdu/display/l6", "");
setprop("/controls/cdu/display/l7", "");

setprop("/controls/cdu/display/r1", "");
setprop("/controls/cdu/display/r2", "");
setprop("/controls/cdu/display/r3", "");
setprop("/controls/cdu/display/r4", "");
setprop("/controls/cdu/display/r5", "");
setprop("/controls/cdu/display/r6", "");
setprop("/controls/cdu/display/r7", "");

        me.reset(); 
}, 
	update : func {
	
# Check if Flightplans are empty or ready

if (getprop("/instrumentation/fmcFP/flightplan[0]/num") == 0)
	setprop("/instrumentation/fmcFP/flightplan[0]/status", "EMPTY");
else
	setprop("/instrumentation/fmcFP/flightplan[0]/status", "READY");
	
if (getprop("/instrumentation/fmcFP/flightplan[1]/num") == 0)
	setprop("/instrumentation/fmcFP/flightplan[1]/status", "EMPTY");
else
	setprop("/instrumentation/fmcFP/flightplan[1]/status", "READY");

# Set Display Properties into Variables

var page = getprop("/controls/cdu/display/page");

var l1label = getprop("/controls/cdu/display/l1-label");
var l2label = getprop("/controls/cdu/display/l2-label");
var l3label = getprop("/controls/cdu/display/l3-label");
var l4label = getprop("/controls/cdu/display/l4-label");
var l5label = getprop("/controls/cdu/display/l5-label");
var l6label = getprop("/controls/cdu/display/l6-label");
var l7label = getprop("/controls/cdu/display/l7-label");

var r1label = getprop("/controls/cdu/display/r1-label");
var r2label = getprop("/controls/cdu/display/r2-label");
var r3label = getprop("/controls/cdu/display/r3-label");
var r4label = getprop("/controls/cdu/display/r4-label");
var r5label = getprop("/controls/cdu/display/r5-label");
var r6label = getprop("/controls/cdu/display/r6-label");
var r7label = getprop("/controls/cdu/display/r7-label");

var l1value = getprop("/controls/cdu/display/l1");
var l2value = getprop("/controls/cdu/display/l2");
var l3value = getprop("/controls/cdu/display/l3");
var l4value = getprop("/controls/cdu/display/l4");
var l5value = getprop("/controls/cdu/display/l5");
var l6value = getprop("/controls/cdu/display/l6");
var l7value = getprop("/controls/cdu/display/l7");

var r1value = getprop("/controls/cdu/display/r1");
var r2value = getprop("/controls/cdu/display/r2");
var r3value = getprop("/controls/cdu/display/r3");
var r4value = getprop("/controls/cdu/display/r4");
var r5value = getprop("/controls/cdu/display/r5");
var r6value = getprop("/controls/cdu/display/r6");
var r7value = getprop("/controls/cdu/display/r7");

var keypress = getprop("/controls/cdu/keypress");

var cduinput = getprop("/controls/cdu/input");

# Check for new words for the FMC to learn :)

if ((cduinput != nil) and (me.keypress_check(keypress) == 1) and (cduinput != ""))
	fmcHelp.learn(cduinput);

# Pages and their Displays :)

### IDENT PAGE

if (page == "IDENT") {

#### Field types

setprop("/controls/cdu/l1-type", "disp");
setprop("/controls/cdu/l2-type", "disp");
setprop("/controls/cdu/l3-type", "disp");
setprop("/controls/cdu/l4-type", "disp");
setprop("/controls/cdu/l5-type", "disp");
setprop("/controls/cdu/l6-type", "disp");
setprop("/controls/cdu/l7-type", "click");

setprop("/controls/cdu/r1-type", "disp");
setprop("/controls/cdu/r2-type", "disp");
setprop("/controls/cdu/r3-type", "disp");
setprop("/controls/cdu/r4-type", "disp");
setprop("/controls/cdu/r5-type", "disp");
setprop("/controls/cdu/r6-type", "disp");
setprop("/controls/cdu/r7-type", "disp");

#### Field Values

setprop("/controls/cdu/display/l1-label", "Model");

setprop("/controls/cdu/display/r1-label", "Engines");
setprop("/controls/cdu/display/r2-label", "Callsign");

setprop("/controls/cdu/display/l2-label", "");
setprop("/controls/cdu/display/l3-label", "");
setprop("/controls/cdu/display/l4-label", "");
setprop("/controls/cdu/display/l5-label", "");
setprop("/controls/cdu/display/l6-label", "");
setprop("/controls/cdu/display/l7-label", "");
setprop("/controls/cdu/display/r3-label", "");
setprop("/controls/cdu/display/r4-label", "");
setprop("/controls/cdu/display/r5-label", "");
setprop("/controls/cdu/display/r6-label", "");
setprop("/controls/cdu/display/r7-label", "");

setprop("/controls/cdu/display/l1", "Boeing 787-8");
setprop("/controls/cdu/display/l2", "");
setprop("/controls/cdu/display/l3", "");
setprop("/controls/cdu/display/l4", "");
setprop("/controls/cdu/display/l5", "");
setprop("/controls/cdu/display/l6", "");
setprop("/controls/cdu/display/l7", "INDEX");

setprop("/controls/cdu/display/r1", "RR Trent_1000");
setprop("/controls/cdu/display/r2", getprop("/sim/multiplay/callsign"));
setprop("/controls/cdu/display/r3", "");
setprop("/controls/cdu/display/r4", "");
setprop("/controls/cdu/display/r5", "");
setprop("/controls/cdu/display/r6", "");
setprop("/controls/cdu/display/r7", "");

#### Menu Presses

if (keypress == "l7") {
page = "INDEX";
keypress = "";
}

} elsif (page == "INDEX") {

#### Field types

setprop("/controls/cdu/l1-type", "disp");
setprop("/controls/cdu/l2-type", "disp");
setprop("/controls/cdu/l3-type", "click");
setprop("/controls/cdu/l4-type", "click");
setprop("/controls/cdu/l5-type", "click");
setprop("/controls/cdu/l6-type", "click");
setprop("/controls/cdu/l7-type", "click");

setprop("/controls/cdu/r1-type", "disp");
setprop("/controls/cdu/r2-type", "disp");
setprop("/controls/cdu/r3-type", "click");
setprop("/controls/cdu/r4-type", "click");
setprop("/controls/cdu/r5-type", "click");
setprop("/controls/cdu/r6-type", "click");
setprop("/controls/cdu/r7-type", "click");

#### Field Values

setprop("/controls/cdu/display/l1-label", "");
setprop("/controls/cdu/display/l2-label", "");
setprop("/controls/cdu/display/l3-label", "");
setprop("/controls/cdu/display/l4-label", "");
setprop("/controls/cdu/display/l5-label", "");
setprop("/controls/cdu/display/l6-label", "");
setprop("/controls/cdu/display/l7-label", "");
setprop("/controls/cdu/display/r1-label", "");
setprop("/controls/cdu/display/r2-label", "");
setprop("/controls/cdu/display/r3-label", "");
setprop("/controls/cdu/display/r4-label", "");
setprop("/controls/cdu/display/r5-label", "");
setprop("/controls/cdu/display/r6-label", "");
setprop("/controls/cdu/display/r7-label", "");

setprop("/controls/cdu/display/l1", "");
setprop("/controls/cdu/display/r1", "");

setprop("/controls/cdu/display/l2", "");
setprop("/controls/cdu/display/r2", "");

setprop("/controls/cdu/display/l3", "NAVAIDS");
setprop("/controls/cdu/display/r3", "HOLD CONFIG");

setprop("/controls/cdu/display/l4", "VNAV CONFIG");
setprop("/controls/cdu/display/r4", "EFB INPUT");

setprop("/controls/cdu/display/l5", "FBW CONFIG");
setprop("/controls/cdu/display/r5", "RADIOS");

setprop("/controls/cdu/display/l6", "DEP / ARR");
setprop("/controls/cdu/display/r6", "FLIGHTPLAN");

setprop("/controls/cdu/display/l7", "T/O PERF");
setprop("/controls/cdu/display/r7", "APP PERF");

#### Menu Presses

if (keypress == "l3") {
page = "NAVAIDS";
keypress = "";
}

if (keypress == "r3") {
page = "HOLD CONFIG";
keypress = "";
}

if (keypress == "l4") {
page = "VNAV CONFIG";
keypress = "";
}

if (keypress == "r4") {
page = "EFB INPUT";
keypress = "";
}

if (keypress == "l5") {
page = "FBW CONFIG";
keypress = "";
}

if (keypress == "r5") {
page = "RADIO";
keypress = "";
}

if (keypress == "l6") {
page = "DEP/ARR";
keypress = "";
}

if (keypress == "r6") {
page = "FLIGHTPLANS";
keypress = "";
}

if (keypress == "l7") {
page = "TAKE-OFF PERFORMANCE";
keypress = "";
}

if (keypress == "r7") {
page = "APPROACH PERFORMANCE";
keypress = "";
}

} elsif (page == "RADIO") {

#### Field types

setprop("/controls/cdu/l1-type", "click");
setprop("/controls/cdu/l2-type", "click");
setprop("/controls/cdu/l3-type", "click");
setprop("/controls/cdu/l4-type", "click");
setprop("/controls/cdu/l5-type", "click");
setprop("/controls/cdu/l6-type", "click");
setprop("/controls/cdu/l7-type", "click");

setprop("/controls/cdu/r1-type", "click");
setprop("/controls/cdu/r2-type", "click");
setprop("/controls/cdu/r3-type", "click");
setprop("/controls/cdu/r4-type", "click");
setprop("/controls/cdu/r5-type", "click");
setprop("/controls/cdu/r6-type", "click");
setprop("/controls/cdu/r7-type", "disp");

## Field Values

setprop("/controls/cdu/display/l1-label", "COM1");
setprop("/controls/cdu/display/l2-label", "COM2");
setprop("/controls/cdu/display/l3-label", "NAV1");
setprop("/controls/cdu/display/l4-label", "NAV2");
setprop("/controls/cdu/display/l5-label", "ADF1");
setprop("/controls/cdu/display/l6-label", "ADF2");
setprop("/controls/cdu/display/r7-label", "");
setprop("/controls/cdu/display/r1-label", "STBY COM1");
setprop("/controls/cdu/display/r2-label", "STBY COM2");
setprop("/controls/cdu/display/r3-label", "STBY NAV1");
setprop("/controls/cdu/display/r4-label", "STBY NAV2");
setprop("/controls/cdu/display/r5-label", "STBY ADF1");
setprop("/controls/cdu/display/r6-label", "STBY ADF2");
setprop("/controls/cdu/display/r7-label", "");

setprop("/controls/cdu/display/l1", getprop("/instrumentation/comm[0]/frequencies/selected-mhz"));
setprop("/controls/cdu/display/r1", getprop("/instrumentation/comm[0]/frequencies/standby-mhz"));

setprop("/controls/cdu/display/l2", getprop("/instrumentation/comm[1]/frequencies/selected-mhz"));
setprop("/controls/cdu/display/r2", getprop("/instrumentation/comm[1]/frequencies/standby-mhz"));

setprop("/controls/cdu/display/l3", getprop("/instrumentation/nav[0]/frequencies/selected-mhz"));
setprop("/controls/cdu/display/r3", getprop("/instrumentation/nav[0]/frequencies/standby-mhz"));

setprop("/controls/cdu/display/l4", getprop("/instrumentation/nav[1]/frequencies/selected-mhz"));
setprop("/controls/cdu/display/r4", getprop("/instrumentation/nav[1]/frequencies/standby-mhz"));

setprop("/controls/cdu/display/l5", getprop("/instrumentation/adf/frequencies/selected-khz"));
setprop("/controls/cdu/display/r5", getprop("/instrumentation/adf/frequencies/standby-khz"));

setprop("/controls/cdu/display/l6", getprop("/instrumentation/adf[1]/frequencies/selected-khz"));
setprop("/controls/cdu/display/r6", getprop("/instrumentation/adf[1]/frequencies/standby-khz"));

setprop("/controls/cdu/display/l7", "< INDEX");
setprop("/controls/cdu/display/r7", "");

## Menu Presses

if (keypress == "l7") {
page = "INDEX";
keypress = "";
}

### Set Standby Frequencies

if ((keypress == "r1") and (cduinput != "")) {
setprop("/instrumentation/comm[0]/frequencies/standby-mhz", cduinput);
setprop("/controls/cdu/input", "");
keypress = "";
cduinput = "";
}

if ((keypress == "r2") and (cduinput != "")) {
setprop("/instrumentation/comm[1]/frequencies/standby-mhz", cduinput);
setprop("/controls/cdu/input", "");
keypress = "";
cduinput = "";
}

if ((keypress == "r3") and (cduinput != "")) {
setprop("/instrumentation/nav[0]/frequencies/standby-mhz", cduinput);
setprop("/controls/cdu/input", "");
keypress = "";
cduinput = "";
}

if ((keypress == "r4") and (cduinput != "")) {
setprop("/instrumentation/nav[1]/frequencies/standby-mhz", cduinput);
setprop("/controls/cdu/input", "");
keypress = "";
cduinput = "";
}

if ((keypress == "r5") and (cduinput != "")) {
setprop("/instrumentation/adf/frequencies/standby-mhz", cduinput);
setprop("/controls/cdu/input", "");
keypress = "";
cduinput = "";
}

if ((keypress == "r6") and (cduinput != "")) {
setprop("/instrumentation/adf[1]/frequencies/standby-mhz", cduinput);
setprop("/controls/cdu/input", "");
keypress = "";
cduinput = "";
}

### Swap Active and Standby Frequencies

if (keypress == "l1") {
var stby = getprop("/instrumentation/comm[0]/frequencies/standby-mhz");
setprop("/instrumentation/comm[0]/frequencies/standby-mhz", getprop("/instrumentation/comm[0]/frequencies/selected-mhz"));
setprop("/instrumentation/comm[0]/frequencies/selected-mhz", stby);

var freq = (int(stby * 100))/100 ;
sysinfo.log_msg("[CDU] COM1 Frequency set to " ~ freq, 0);

keypress = "";
cduinput = "";
}

if (keypress == "l2") {
var stby = getprop("/instrumentation/comm[1]/frequencies/standby-mhz");
setprop("/instrumentation/comm[1]/frequencies/standby-mhz", getprop("/instrumentation/comm[1]/frequencies/selected-mhz"));
setprop("/instrumentation/comm[1]/frequencies/selected-mhz", stby);

var freq = (int(stby * 100))/100 ;
sysinfo.log_msg("[CDU] COM2 Frequency set to " ~ freq, 0);

keypress = "";
cduinput = "";
}

if (keypress == "l3") {
var stby = getprop("/instrumentation/nav[0]/frequencies/standby-mhz");
setprop("/instrumentation/nav[0]/frequencies/standby-mhz", getprop("/instrumentation/nav[0]/frequencies/selected-mhz"));
setprop("/instrumentation/nav[0]/frequencies/selected-mhz", stby);

var freq = (int(stby * 100))/100 ;
sysinfo.log_msg("[CDU] NAV1 Frequency set to " ~ freq, 0);

keypress = "";
cduinput = "";
}

if (keypress == "l4") {
var stby = getprop("/instrumentation/nav[1]/frequencies/standby-mhz");
setprop("/instrumentation/nav[1]/frequencies/standby-mhz", getprop("/instrumentation/nav[1]/frequencies/selected-mhz"));
setprop("/instrumentation/nav[1]/frequencies/selected-mhz", stby);

var freq = (int(stby * 100))/100 ;
sysinfo.log_msg("[CDU] NAV2 Frequency set to " ~ freq, 0);

keypress = "";
cduinput = "";
}

} elsif (page == "DEP/ARR") {

#### Field types

setprop("/controls/cdu/l1-type", "click");
setprop("/controls/cdu/l2-type", "click");
setprop("/controls/cdu/l3-type", "disp");
setprop("/controls/cdu/l4-type", "click");
setprop("/controls/cdu/l5-type", "disp");
if (getprop("/controls/cdu/flightnum") != nil)
	setprop("/controls/cdu/l6-type", "click");
else 
	setprop("/controls/cdu/l6-type", "disp");
setprop("/controls/cdu/l7-type", "click");

setprop("/controls/cdu/r1-type", "click");
setprop("/controls/cdu/r2-type", "click");
setprop("/controls/cdu/r3-type", "disp");
setprop("/controls/cdu/r4-type", "disp");
setprop("/controls/cdu/r5-type", "click");
setprop("/controls/cdu/r6-type", "click");
setprop("/controls/cdu/r7-type", "click");

#### Field Values

setprop("/controls/cdu/display/l1-label", "Departure");
setprop("/controls/cdu/display/l2-label", "Runway");
setprop("/controls/cdu/display/l3-label", "");
setprop("/controls/cdu/display/r4-label", "");
setprop("/controls/cdu/display/l5-label", "");
setprop("/controls/cdu/display/l6-label", "");
setprop("/controls/cdu/display/r7-label", "");
setprop("/controls/cdu/display/r1-label", "Destination");
setprop("/controls/cdu/display/r2-label", "Runway");
setprop("/controls/cdu/display/r3-label", "");
setprop("/controls/cdu/display/l4-label", "Flight No.");
setprop("/controls/cdu/display/r5-label", "");
setprop("/controls/cdu/display/r6-label", "");
setprop("/controls/cdu/display/r7-label", "");

if (getprop("/autopilot/route-manager/departure/airport") != nil)
	setprop("/controls/cdu/display/l1", getprop("/autopilot/route-manager/departure/airport"));
else
	setprop("/controls/cdu/display/l1", "");
if (getprop("/autopilot/route-manager/destination/airport") != nil)
	setprop("/controls/cdu/display/r1", getprop("/autopilot/route-manager/destination/airport"));
else
	setprop("/controls/cdu/display/r1", "");

if (getprop("/autopilot/route-manager/departure/runway") != nil)
	setprop("/controls/cdu/display/l2", getprop("/autopilot/route-manager/departure/runway"));
else
	setprop("/controls/cdu/display/l2", "");
if (getprop("/autopilot/route-manager/destination/runway") != nil)
	setprop("/controls/cdu/display/r2", getprop("/autopilot/route-manager/destination/runway"));
else 
	setprop("/controls/cdu/display/r2", "");
setprop("/controls/cdu/display/l3", "");
setprop("/controls/cdu/display/r3", "");

setprop("/controls/cdu/display/l4", getprop("/controls/cdu/flightnum"));
setprop("/controls/cdu/display/r4", "");

setprop("/controls/cdu/display/l5", "");
setprop("/controls/cdu/display/r5", "PROCEDURES >");

if (getprop("/controls/cdu/flightnum") != "")
	setprop("/controls/cdu/display/l6", "< FLIGHT INFO");
else
	setprop("/controls/cdu/display/l6", "");
setprop("/controls/cdu/display/r6", "FLIGHT LOG >");

setprop("/controls/cdu/display/l7", "< INDEX");
setprop("/controls/cdu/display/r7", "FLIGHTPLAN >");

### Menu Presses

if (keypress == "l7") {
page = "INDEX";
keypress = "";
} elsif (keypress == "l6") {
page = "FLIGHT INFO";
keypress = "";
} elsif (keypress == "r6") {
page = " LOG ";
keypress = "";
} elsif (keypress == "r5") {
page = "PROCEDURES";
keypress = "";
} elsif (keypress == "r7") {
page = "FLIGHTPLANS";
keypress = "";
}

### Set Input Values into Fields L1, L2, R1, R2 and L4

if (keypress == "l1") {
setprop("/autopilot/route-manager/departure/airport", cduinput);
setprop("/controls/cdu/input", "");
keypress = "";
cduinput = "";
}

if (keypress == "l2") {
setprop("/autopilot/route-manager/departure/runway", cduinput);
setprop("/controls/cdu/input", "");
keypress = "";
cduinput = "";
}

if (keypress == "r1") {
setprop("/autopilot/route-manager/destination/airport", cduinput);
setprop("/controls/cdu/input", "");
keypress = "";
cduinput = "";
}

if (keypress == "r2") {
setprop("/autopilot/route-manager/destination/runway", cduinput);
setprop("/controls/cdu/input", "");
keypress = "";
cduinput = "";
}

if (keypress == "l4") {
setprop("/controls/cdu/flightnum", cduinput);
setprop("/controls/cdu/input", "");
keypress = "";
cduinput = "";
}

} elsif (page == "ROUTE") {

### The Routes Pages, the best part about this CDU :D

#### Field types

setprop("/controls/cdu/l4-type", "click");
setprop("/controls/cdu/l5-type", "click");
setprop("/controls/cdu/l6-type", "click");
setprop("/controls/cdu/l7-type", "click");

setprop("/controls/cdu/r5-type", "click");
setprop("/controls/cdu/r6-type", "click");
setprop("/controls/cdu/r7-type", "click");

var l1type = "disp";
var r1type = "disp";

var l2type = "disp";
var r2type = "disp";

var l3type = "disp";
var r3type = "disp";

var l4type = "disp";
var r4type = "disp";

#### Field Values

setprop("/controls/cdu/display/l1-label", "");
setprop("/controls/cdu/display/r1-label", "");
setprop("/controls/cdu/display/l2-label", "");
setprop("/controls/cdu/display/r2-label", "");
setprop("/controls/cdu/display/l3-label", "");
setprop("/controls/cdu/display/r3-label", "");
setprop("/controls/cdu/display/l4-label", "");
setprop("/controls/cdu/display/r4-label", "");
setprop("/controls/cdu/display/l5-label", "");
setprop("/controls/cdu/display/r5-label", "");
setprop("/controls/cdu/display/l6-label", "");
setprop("/controls/cdu/display/r6-label", "");
setprop("/controls/cdu/display/l7-label", "");
setprop("/controls/cdu/display/r7-label", "");

setprop("/controls/cdu/display/l6", "< CLEAR");
setprop("/controls/cdu/display/r6", "REMOVE >");

setprop("/controls/cdu/display/l7", "< INDEX");

if (getprop("/autopilot/route-manager/active") == 0) {
setprop("/controls/cdu/display/r7", "ACTIVATE >");
} else {
setprop("/controls/cdu/display/r7", "JUMP TO >");
}

#### Menu Presses

if (keypress == "l7") {
page = "INDEX";
keypress = "";
}

#### ROUTE DISPLAY (in pages)

##### Display nothing if there're no waypoints

if (getprop("/autopilot/route-manager/route/num") == 0) {
setprop("/controls/cdu/display/l1", "-");
setprop("/controls/cdu/display/r1", "-");
setprop("/controls/cdu/display/l2", "-");
setprop("/controls/cdu/display/r2", "-");
setprop("/controls/cdu/display/l3", "-");
setprop("/controls/cdu/display/r3", "-");
setprop("/controls/cdu/display/l4", "-");
setprop("/controls/cdu/display/r4", "-");
setprop("/controls/cdu/display/l5", "-");
setprop("/controls/cdu/display/r5", "-");
} else {

var currentwp = getprop("/autopilot/route-manager/current-wp");
 
##### Display for 1 or more waypoints

for (var i = 0; i < 100; i = i + 1) {
if (getprop("/autopilot/route-manager/route/num") / 4 > i) {
setprop("/controls/cdu/route-manager/max-pages", i + 1);
}
}

###### Display and "function-ize" BACK and NEXT (for more than 1 page)

if (getprop("/controls/cdu/route-manager/max-pages") != getprop("/controls/cdu/route-manager/page")) {
setprop("/controls/cdu/display/r5", "NEXT >");
if (keypress == "r5") {
setprop("/controls/cdu/route-manager/page", getprop("/controls/cdu/route-manager/page") + 1);
keypress = "";
}
} else {
setprop("/controls/cdu/display/r5", "-");
}
if (getprop("/controls/cdu/route-manager/page") != 1) {
setprop("/controls/cdu/display/l5", "< BACK");
if (keypress == "l5") {
setprop("/controls/cdu/route-manager/page", getprop("/controls/cdu/route-manager/page") - 1);
keypress = "";
}
} else {
setprop("/controls/cdu/display/l5", "-");
}

###### Displays the last page of waypoints (also first page if there's only 1 page)

if (getprop("/controls/cdu/route-manager/max-pages") == getprop("/controls/cdu/route-manager/page")) {

var l1 = "-";
var r1 = "-";
var l2 = "-";
var r2 = "-";
var l3 = "-";
var r3 = "-";
var l4 = "-";
var r4 = "-";

var lastpagewps = getprop("/autopilot/route-manager/route/num") - ((getprop("/controls/cdu/route-manager/max-pages") - 1) * 4);

if (lastpagewps >= 1) {
l1_wp = ((getprop("/controls/cdu/route-manager/max-pages") - 1) * 4);
if (currentwp == l1_wp) {
l1 = "> " ~ getprop("/autopilot/route-manager/route/wp[" ~ l1_wp ~"]/id");
} else {
l1 = getprop("/autopilot/route-manager/route/wp[" ~ l1_wp ~"]/id");
}
r1 = getprop("/autopilot/route-manager/route/wp[" ~ l1_wp ~"]/altitude-ft");
var l1type = "click";
var r1type = "click";
}

if (lastpagewps >= 2) {
l2_wp = ((getprop("/controls/cdu/route-manager/max-pages") - 1) * 4) + 1;
if (currentwp == l2_wp) {
l2 = "> " ~ getprop("/autopilot/route-manager/route/wp[" ~ l2_wp ~"]/id");
} else {
l2 = getprop("/autopilot/route-manager/route/wp[" ~ l2_wp ~"]/id");
}
r2 = getprop("/autopilot/route-manager/route/wp[" ~ l2_wp ~"]/altitude-ft");
var l2type = "click";
var r2type = "click";
}

if (lastpagewps >= 3) {
l3_wp = ((getprop("/controls/cdu/route-manager/max-pages") - 1) * 4) + 2;
if (currentwp == l3_wp) {
l3 = "> " ~ getprop("/autopilot/route-manager/route/wp[" ~ l3_wp ~"]/id");
} else {
l3 = getprop("/autopilot/route-manager/route/wp[" ~ l3_wp ~"]/id");
}
r3 = getprop("/autopilot/route-manager/route/wp[" ~ l3_wp ~"]/altitude-ft");
var l3type = "click";
var r3type = "click";
}

if (lastpagewps == 4) {
l4_wp = ((getprop("/controls/cdu/route-manager/max-pages") - 1) * 4) + 3;
if (currentwp == l4_wp) {
l4 = "> " ~ getprop("/autopilot/route-manager/route/wp[" ~ l4_wp ~"]/id");
} else {
l4 = getprop("/autopilot/route-manager/route/wp[" ~ l4_wp ~"]/id");
}
r4 = getprop("/autopilot/route-manager/route/wp[" ~ l4_wp ~"]/altitude-ft");
var l4type = "click";
var r4type = "click";
}

} else {

###### The middle (not last) and first (if more than 1 page) pages

var l1type = "click";
var r1type = "click";

var l2type = "click";
var r2type = "click";

var l3type = "click";
var r3type = "click";

var l4type = "click";
var r4type = "click";

l1_wp = ((getprop("/controls/cdu/route-manager/page") - 1) * 4);
l2_wp = ((getprop("/controls/cdu/route-manager/page") - 1) * 4) + 1;
l3_wp = ((getprop("/controls/cdu/route-manager/page") - 1) * 4) + 2;
l4_wp = ((getprop("/controls/cdu/route-manager/page") - 1) * 4) + 3;	

if (currentwp == l1_wp) {
l1 = "> " ~ getprop("/autopilot/route-manager/route/wp[" ~ l1_wp ~"]/id");
} else {
l1 = getprop("/autopilot/route-manager/route/wp[" ~ l1_wp ~"]/id");
}
r1 = getprop("/autopilot/route-manager/route/wp[" ~ l1_wp ~"]/altitude-ft");
if (currentwp == l2_wp) {
l1 = "> " ~ getprop("/autopilot/route-manager/route/wp[" ~ l2_wp ~"]/id");
} else {
l2 = getprop("/autopilot/route-manager/route/wp[" ~ l2_wp ~"]/id");
}
r2 = getprop("/autopilot/route-manager/route/wp[" ~ l2_wp ~"]/altitude-ft");
if (currentwp == l3_wp) {
l1 = "> " ~ getprop("/autopilot/route-manager/route/wp[" ~ l3_wp ~"]/id");
} else {
l3 = getprop("/autopilot/route-manager/route/wp[" ~ l3_wp ~"]/id");
}
r3 = getprop("/autopilot/route-manager/route/wp[" ~ l3_wp ~"]/altitude-ft");
if (currentwp == l4_wp) {
l1 = "> " ~ getprop("/autopilot/route-manager/route/wp[" ~ l4_wp ~"]/id");
} else {
l4 = getprop("/autopilot/route-manager/route/wp[" ~ l4_wp ~"]/id");
}
r4 = getprop("/autopilot/route-manager/route/wp[" ~ l4_wp ~"]/altitude-ft");

}

setprop("/controls/cdu/l1-type", l1type);
setprop("/controls/cdu/r1-type", r1type);

setprop("/controls/cdu/l2-type", l2type);
setprop("/controls/cdu/r2-type", r2type);

setprop("/controls/cdu/l3-type", l3type);
setprop("/controls/cdu/r3-type", r3type);

setprop("/controls/cdu/l4-type", l4type);
setprop("/controls/cdu/r4-type", r4type);

setprop("/controls/cdu/display/l1", l1);
setprop("/controls/cdu/display/r1", r1);
setprop("/controls/cdu/display/l2", l2);
setprop("/controls/cdu/display/r2", r2);
setprop("/controls/cdu/display/l3", l3);
setprop("/controls/cdu/display/r3", r3);
setprop("/controls/cdu/display/l4", l4);
setprop("/controls/cdu/display/r4", r4);

} # Ends brace for there being 1 or more waypoints

#### Route Manager Functions (REPLACE, INSERT, ADD, JUMP TO, ACTIVATE, CLEAR, REMOVE)

##### ACTIVATE / JUMP TO (PART 1) FUNCTION

if ((getprop("/autopilot/route-manager/active") == 1) and (keypress == "r7")) {
# setprop("/controls/cdu/input", "JUMP TO");
cduinput = "JUMP TO";
keypress = "";
}
if ((getprop("/autopilot/route-manager/active") != 1) and (keypress == "r7")) {
setprop("/autopilot/route-manager/active", 1);
sysinfo.log_msg("[AP] Selected Route Activated", 0);
keypress = "";
cduinput = "";
}

##### JUMP TO (PART 2) FUNCTION
if ((keypress == "l1") and (cduinput == "JUMP TO")) {
setprop("/autopilot/route-manager/input", "@JUMP" ~ l1_wp);
keypress = "";
cduinput = "";
} elsif ((keypress == "l2") and (cduinput == "JUMP TO")) {
setprop("/autopilot/route-manager/input", "@JUMP" ~ l2_wp);
keypress = "";
cduinput = "";
} elsif ((keypress == "l3") and (cduinput == "JUMP TO")) {
setprop("/autopilot/route-manager/input", "@JUMP" ~ l3_wp);
keypress = "";
cduinput = "";
} elsif ((keypress == "l4") and (cduinput == "JUMP TO")) {
setprop("/autopilot/route-manager/input", "@JUMP" ~ l4_wp);
keypress = "";
cduinput = "";
}

##### CLEAR FUNCTION

if (keypress == "l6") {
setprop("/autopilot/route-manager/input", "@CLEAR");
setprop("/controls/cdu/route-manager/page", 1);
setprop("/autopilot/route-manager/current-wp", 0);
sysinfo.log_msg("[AP] Active Route Cleared", 0);
keypress = "";
cduinput = "";
}

##### REMOVE FUNCTION (PART 1)

if (keypress == "r6") {
# setprop("/controls/cdu/input", "REMOVE");
cduinput = "REMOVE";
keypress = "";
}

##### REMOVE FUNCTION (PART 2)

if ((keypress == "l1") and (cduinput == "REMOVE")) {
setprop("/autopilot/route-manager/input", "@DELETE" ~ l1_wp);
keypress = "";
cduinput = "";
} elsif ((keypress == "l2") and (cduinput == "REMOVE")) {
setprop("/autopilot/route-manager/input", "@DELETE" ~ l2_wp);
keypress = "";
cduinput = "";
} elsif ((keypress == "l3") and (cduinput == "REMOVE")) {
setprop("/autopilot/route-manager/input", "@DELETE" ~ l3_wp);
keypress = "";
cduinput = "";
} elsif ((keypress == "l4") and (cduinput == "REMOVE")) {
setprop("/autopilot/route-manager/input", "@DELETE" ~ l4_wp);
keypress = "";
cduinput = "";
}


##### ADD FUNCTION (EXEC)

if ((keypress == "exec") and (cduinput != "")) {
setprop("/autopilot/route-manager/input", "@INSERT999:" ~ cduinput);
keypress = "";
cduinput = "";

} 

##### REPLACE FUNCTION (for ALT only, ofcourse)

if ((keypress == "r1") and (cduinput != "")) {
setprop("/autopilot/route-manager/route/wp[" ~ l1_wp ~ "]/altitude-ft", cduinput);
keypress = "";
cduinput = "";
} elsif ((keypress == "r2") and (cduinput != "")) {
setprop("/autopilot/route-manager/route/wp[" ~ l2_wp ~ "]/altitude-ft", cduinput);
keypress = "";
cduinput = "";
} elsif ((keypress == "r3") and (cduinput != "")) {
setprop("/autopilot/route-manager/route/wp[" ~ l3_wp ~ "]/altitude-ft", cduinput);
keypress = "";
cduinput = "";
} elsif ((keypress == "r4") and (cduinput != "")) {
setprop("/autopilot/route-manager/route/wp[" ~ l4_wp ~ "]/altitude-ft", cduinput);
keypress = "";
cduinput = "";
}


##### INSERT FUNCTION
if ((keypress == "l1") and (cduinput != "")) {
setprop("/autopilot/route-manager/input", "@INSERT" ~ l1_wp ~ ":" ~ cduinput);
keypress = "";
cduinput = "";
} elsif ((keypress == "l2") and (cduinput != "")) {
setprop("/autopilot/route-manager/input", "@INSERT" ~ l2_wp ~ ":" ~ cduinput);
keypress = "";
cduinput = "";
} elsif ((keypress == "l3") and (cduinput != "")) {
setprop("/autopilot/route-manager/input", "@INSERT" ~ l3_wp ~ ":" ~ cduinput);
keypress = "";
cduinput = "";
} elsif ((keypress == "l4") and (cduinput != "")) {
setprop("/autopilot/route-manager/input", "@INSERT" ~ l4_wp ~ ":" ~ cduinput);
keypress = "";
cduinput = "";
}

setprop("/controls/cdu/input", cduinput);

} elsif (page == "TAKE-OFF PERFORMANCE") {

#### Field types

setprop("/controls/cdu/l1-type", "disp");
setprop("/controls/cdu/l2-type", "disp");
setprop("/controls/cdu/l3-type", "disp");
setprop("/controls/cdu/l4-type", "disp");
setprop("/controls/cdu/l5-type", "disp");
setprop("/controls/cdu/l6-type", "disp");
setprop("/controls/cdu/l7-type", "click");

setprop("/controls/cdu/r1-type", "disp");
setprop("/controls/cdu/r2-type", "disp");
setprop("/controls/cdu/r3-type", "disp");
setprop("/controls/cdu/r4-type", "disp");
setprop("/controls/cdu/r5-type", "disp");
setprop("/controls/cdu/r6-type", "disp");
setprop("/controls/cdu/r7-type", "click");

#### Field Values

setprop("/controls/cdu/display/l1-label", "T/O Flaps");
setprop("/controls/cdu/display/l2-label", "Climb Rate");
setprop("/controls/cdu/display/l3-label", "Lift Pitch");
setprop("/controls/cdu/display/l4-label", "FLAPS 5 Degrees");
setprop("/controls/cdu/display/l5-label", "FLAPS 1 Degree");
setprop("/controls/cdu/display/l6-label", "FLAPS UP");
setprop("/controls/cdu/display/r7-label", "");
setprop("/controls/cdu/display/r1-label", "V1");
setprop("/controls/cdu/display/r2-label", "VR");
setprop("/controls/cdu/display/r3-label", "V2");
setprop("/controls/cdu/display/r4-label", "");
setprop("/controls/cdu/display/r5-label", "");
setprop("/controls/cdu/display/r6-label", "");
setprop("/controls/cdu/display/r7-label", "");

setprop("/controls/cdu/display/l1", "10 Degrees");
setprop("/controls/cdu/display/r1", sprintf("%3.0f", getprop("/instrumentation/fmc/vspeeds/V1")));

setprop("/controls/cdu/display/l2", "Min. 1800 FPM");
setprop("/controls/cdu/display/r2", sprintf("%3.0f", getprop("/instrumentation/fmc/vspeeds/VR")));

setprop("/controls/cdu/display/l3", "12 Degrees");
setprop("/controls/cdu/display/r3", sprintf("%3.0f", getprop("/instrumentation/fmc/vspeeds/V2")));

fmc.calc_speeds();

setprop("/controls/cdu/display/l4", sprintf("%3.0f",getprop("/instrumentation/b787-fmc/speeds/flaps10")));
setprop("/controls/cdu/display/r4", "");

setprop("/controls/cdu/display/l5", sprintf("%3.0f",getprop("/instrumentation/b787-fmc/speeds/flaps5")));
setprop("/controls/cdu/display/r5", "");

setprop("/controls/cdu/display/l6", sprintf("%3.0f",getprop("/instrumentation/b787-fmc/speeds/flaps1")));
setprop("/controls/cdu/display/r6", "");

setprop("/controls/cdu/display/l7", "< INDEX");
setprop("/controls/cdu/display/r7", "APP PERF >");

### Menu Presses

if (keypress == "l7") {
page = "INDEX";
keypress = "";
} elsif (keypress == "r7") {
page = "APPROACH PERFORMANCE";
keypress = "";
}

} elsif (page == "APPROACH PERFORMANCE") {

#### Field types

setprop("/controls/cdu/l1-type", "disp");
setprop("/controls/cdu/l2-type", "disp");
setprop("/controls/cdu/l3-type", "disp");
setprop("/controls/cdu/l4-type", "disp");
setprop("/controls/cdu/l5-type", "disp");
setprop("/controls/cdu/l6-type", "disp");
setprop("/controls/cdu/l7-type", "click");

setprop("/controls/cdu/r1-type", "disp");
setprop("/controls/cdu/r2-type", "disp");
setprop("/controls/cdu/r3-type", "disp");
setprop("/controls/cdu/r4-type", "disp");
setprop("/controls/cdu/r5-type", "disp");
setprop("/controls/cdu/r6-type", "disp");
setprop("/controls/cdu/r7-type", "disp");

#### Field Values

setprop("/controls/cdu/display/l1-label", "FLAPS 1 Degree");
setprop("/controls/cdu/display/l2-label", "FLAPS 5 Degrees");
setprop("/controls/cdu/display/l3-label", "FLAPS 10 Degrees");
setprop("/controls/cdu/display/l4-label", "FLAPS 15 Degrees");
setprop("/controls/cdu/display/l5-label", "FLAPS 25 Degrees");
setprop("/controls/cdu/display/l6-label", "FLAPS 35 Degrees");
setprop("/controls/cdu/display/r7-label", "");
setprop("/controls/cdu/display/r1-label", "Max. Descent Rate");
setprop("/controls/cdu/display/r2-label", "");
setprop("/controls/cdu/display/r3-label", "Approach Speed");
setprop("/controls/cdu/display/r4-label", "Touchdown Speed");
setprop("/controls/cdu/display/r5-label", "");
setprop("/controls/cdu/display/r6-label", "");
setprop("/controls/cdu/display/r7-label", "");

fmc.calc_speeds();

setprop("/controls/cdu/display/l1", sprintf("%3.0f", getprop("/instrumentation/b787-fmc/speeds/flaps1")));
setprop("/controls/cdu/display/r1", "-2500 FPM");

setprop("/controls/cdu/display/l2", sprintf("%3.0f", getprop("/instrumentation/b787-fmc/speeds/flaps5")));
setprop("/controls/cdu/display/r2", "");

setprop("/controls/cdu/display/l3", sprintf("%3.0f", getprop("/instrumentation/b787-fmc/speeds/flaps10")));
setprop("/controls/cdu/display/r3", sprintf("%3.0f", getprop("/instrumentation/b787-fmc/speeds/ap")));

setprop("/controls/cdu/display/l4", sprintf("%3.0f", getprop("/instrumentation/b787-fmc/speeds/flaps15")));
setprop("/controls/cdu/display/r4", sprintf("%3.0f", getprop("/instrumentation/b787-fmc/speeds/td")));

setprop("/controls/cdu/display/l5", sprintf("%3.0f", getprop("/instrumentation/b787-fmc/speeds/flaps25")));
setprop("/controls/cdu/display/r5", "");

setprop("/controls/cdu/display/l6", sprintf("%3.0f", getprop("/instrumentation/b787-fmc/speeds/flaps35")));
setprop("/controls/cdu/display/r6", "");

setprop("/controls/cdu/display/l7", "< INDEX");
setprop("/controls/cdu/display/r7", "");

### Menu Presses

if (keypress == "l7") {
page = "INDEX";
keypress = "";
}

} elsif (page == " LOG ") {

#### Calculate Flight Time and Fuel Consumed

var fuelused = getprop("/consumables/fuel/total-fuel-kg") - getprop("/controls/cdu/log/start-fuel-kg");

setprop("/controls/cdu/log/fuel", 0 - fuelused);

#### Day Time Flight (started and ended on the same UTC day)

if (getprop("/controls/cdu/log/start-time-utc/day") == getprop("/sim/time/utc/day")) {

var hours = getprop("/sim/time/utc/hour") - getprop("/controls/cdu/log/start-time-utc/hour");

if (getprop("/sim/time/utc/minute") >= getprop("/controls/cdu/log/start-time-utc/minute")) {

var minutes = getprop("/sim/time/utc/minute") - getprop("/controls/cdu/log/start-time-utc/minute");

} else {

var minutes = (60 - getprop("/controls/cdu/log/start-time-utc/minute")) + getprop("/sim/time/utc/minute");

hours = hours - 1;

}

} 

#### Overnight Flight (flight ends the next day)

else {

var hours = (24 - getprop("/controls/cdu/log/start-time-utc/hour")) + getprop("/sim/time/utc/hour");

if (getprop("/sim/time/utc/minute") >= getprop("/controls/cdu/log/start-time-utc/minute")) {

var minutes = getprop("/sim/time/utc/minute") - getprop("/controls/cdu/log/start-time-utc/minute");

} else {

var minutes = (60 - getprop("/controls/cdu/log/start-time-utc/minute")) + getprop("/sim/time/utc/minute");

hours = hours - 1;

}

}

var flighttime = hours~":"~minutes;

setprop("/controls/cdu/log/flighttime", flighttime);

#### Field types

setprop("/controls/cdu/l1-type", "disp");
setprop("/controls/cdu/l2-type", "disp");
setprop("/controls/cdu/l3-type", "disp");
setprop("/controls/cdu/l4-type", "disp");
setprop("/controls/cdu/l5-type", "disp");
setprop("/controls/cdu/l6-type", "click");
setprop("/controls/cdu/l7-type", "click");

setprop("/controls/cdu/r1-type", "disp");
setprop("/controls/cdu/r2-type", "disp");
setprop("/controls/cdu/r3-type", "disp");
setprop("/controls/cdu/r4-type", "disp");
setprop("/controls/cdu/r5-type", "disp");
setprop("/controls/cdu/r6-type", "click");
setprop("/controls/cdu/r7-type", "click");

#### Field Values

setprop("/controls/cdu/display/l1-label", "Callsign");
setprop("/controls/cdu/display/l2-label", "");
setprop("/controls/cdu/display/l3-label", "Departure");
setprop("/controls/cdu/display/l4-label", "Flight Time");
setprop("/controls/cdu/display/l5-label", "");
setprop("/controls/cdu/display/l6-label", "");
setprop("/controls/cdu/display/l7-label", "");
setprop("/controls/cdu/display/r1-label", "Flight Number");
setprop("/controls/cdu/display/r2-label", "");
setprop("/controls/cdu/display/r3-label", "Destination");
setprop("/controls/cdu/display/r4-label", "Fuel Consumed");
setprop("/controls/cdu/display/r5-label", "");
setprop("/controls/cdu/display/r6-label", "");
setprop("/controls/cdu/display/r7-label", "");

setprop("/controls/cdu/display/l1", getprop("/sim/multiplay/callsign"));
setprop("/controls/cdu/display/r1", getprop("/controls/cdu/flightnum"));

setprop("/controls/cdu/display/l2", "");
setprop("/controls/cdu/display/r2", "");

setprop("/controls/cdu/display/l3", getprop("/autopilot/route-manager/departure/airport"));
setprop("/controls/cdu/display/r3", getprop("/autopilot/route-manager/destination/airport"));

setprop("/controls/cdu/display/l4", getprop("/controls/cdu/log/flighttime"));
setprop("/controls/cdu/display/r4", getprop("/controls/cdu/log/fuel"));

setprop("/controls/cdu/display/l5", "");
setprop("/controls/cdu/display/r5", "");

setprop("/controls/cdu/display/l6", "< DEP / ARR");
setprop("/controls/cdu/display/r6", "FLIGHTPLAN >");

setprop("/controls/cdu/display/l7", "< INDEX");
setprop("/controls/cdu/display/r7", "RESET >");

#### Menu Presses

if (keypress == "l7") {
page = "INDEX";
keypress = "";
} elsif (keypress == "l6") {
page = "DEP/ARR";
keypress = "";
} elsif (keypress == "r6") {
page = "FLIGHTPLANS";
keypress = "";
}

#### Flight Logging System (we just need to calculate flight time and fuel used actually)

if (keypress == "r7") {

setprop("/controls/cdu/log/start-time-utc/day", getprop("/sim/time/utc/day"));
setprop("/controls/cdu/log/start-time-utc/hour", getprop("/sim/time/utc/hour"));
setprop("/controls/cdu/log/start-time-utc/minute", getprop("/sim/time/utc/minute"));

setprop("/controls/cdu/log/start-fuel-kg", getprop("/consumables/fuel/total-fuel-kg"));

keypress = "";
}

} elsif (page == "FBW CONFIG") {

#### Field types

setprop("/controls/cdu/l1-type", "disp");
setprop("/controls/cdu/l2-type", "disp");
setprop("/controls/cdu/l3-type", "disp");
setprop("/controls/cdu/l4-type", "disp");
setprop("/controls/cdu/l5-type", "disp");
setprop("/controls/cdu/l6-type", "disp");
setprop("/controls/cdu/l7-type", "click");

setprop("/controls/cdu/r1-type", "click");
setprop("/controls/cdu/r2-type", "click");
setprop("/controls/cdu/r3-type", "click");
setprop("/controls/cdu/r4-type", "click");
setprop("/controls/cdu/r5-type", "disp");
setprop("/controls/cdu/r6-type", "disp");
setprop("/controls/cdu/r7-type", "disp");

#### Field Values

setprop("/controls/cdu/display/l1-label", "");
setprop("/controls/cdu/display/l2-label", "");
setprop("/controls/cdu/display/l3-label", "");
setprop("/controls/cdu/display/l4-label", "");
setprop("/controls/cdu/display/l5-label", "");
setprop("/controls/cdu/display/l6-label", "");
setprop("/controls/cdu/display/l7-label", "");
setprop("/controls/cdu/display/r1-label", "");
setprop("/controls/cdu/display/r2-label", "");
setprop("/controls/cdu/display/r3-label", "");
setprop("/controls/cdu/display/r4-label", "");
setprop("/controls/cdu/display/r5-label", "");
setprop("/controls/cdu/display/r6-label", "");
setprop("/controls/cdu/display/r7-label", "");

setprop("/controls/cdu/display/l1", "Fly By Wire Status :");

if (getprop("/controls/fbw/active") == 1) {
setprop("/controls/cdu/display/r1", "ACTIVE");
} else {
setprop("/controls/cdu/display/r1", "DISABLED");
}

setprop("/controls/cdu/display/l2", "Rudder Control :");
if (getprop("/controls/fbw/rudder") == 1) {
setprop("/controls/cdu/display/r2", "PERMITTED");
} else {
setprop("/controls/cdu/display/r2", "NOT PERMITTED");
}

setprop("/controls/cdu/display/l3", "Yaw Damper :");
if (getprop("/controls/fbw/yaw-damper") == 1) {
setprop("/controls/cdu/display/r3", "ACTIVE");
} else {
setprop("/controls/cdu/display/r3", "DISABLED");
}

setprop("/controls/cdu/display/l4", "Bank Limit :");
setprop("/controls/cdu/display/r4", sprintf("%2.0f", getprop("/controls/fbw/bank-limit")));

setprop("/controls/cdu/display/l5", "");
setprop("/controls/cdu/display/r5", "");

setprop("/controls/cdu/display/l6", "");
setprop("/controls/cdu/display/r6", "");

setprop("/controls/cdu/display/l7", "< INDEX");
setprop("/controls/cdu/display/r7", "");

### Menu Presses

if (keypress == "l7") {
page = "INDEX";
keypress = "";
}

if (keypress == "r1") {
if (getprop("/controls/fbw/active") == 1) {
setprop("/controls/fbw/active", 0);
} else {
setprop("/controls/fbw/active", 1);
}
keypress = "";
}

if (keypress == "r2") {
if (getprop("/controls/fbw/rudder") == 1) {
setprop("/controls/fbw/rudder", 0);
} else {
setprop("/controls/fbw/rudder", 1);
}
keypress = "";
}

if (keypress == "r3") {
if (getprop("/controls/fbw/yaw-damper") == 1) {
setprop("/controls/fbw/yaw-damper", 0);
} else {
setprop("/controls/fbw/yaw-damper", 1);
}
keypress = "";
}

if (keypress == "r4") {
var banklimit = getprop("/controls/fbw/bank-limit");

if (banklimit == 10) {
newlimit = 15;
} elsif (banklimit == 15) {
newlimit = 20;
} elsif (banklimit == 20) {
newlimit = 25;
} elsif (banklimit == 25) {
newlimit = 30;
} elsif (banklimit == 30) {
newlimit = 35;
} elsif (banklimit == 35) {
newlimit = 40;
} elsif (banklimit == 40) {
newlimit = 45;
} else {
newlimit = 15;
}

setprop("/controls/fbw/bank-limit", newlimit);
keypress = "";
}


} elsif (page == "EFB INPUT") {

#### Field types

setprop("/controls/cdu/l1-type", "disp");
setprop("/controls/cdu/l5-type", "disp");
setprop("/controls/cdu/l6-type", "disp");
setprop("/controls/cdu/l7-type", "click");

setprop("/controls/cdu/r1-type", "disp");
setprop("/controls/cdu/r2-type", "disp");
setprop("/controls/cdu/r3-type", "disp");
setprop("/controls/cdu/r4-type", "disp");
setprop("/controls/cdu/r5-type", "disp");
setprop("/controls/cdu/r6-type", "disp");

#### Chart Selection at Airport Selection

if ((getprop("/instrumentation/efb/chart/newairport") == 1) or (getprop("/instrumentation/efb/chart/newtype") == 1)) {
if (getprop("/instrumentation/efb/chart/icao") == nil) me.nochart = 1;
else {
if (getprop("/instrumentation/efb/chartsDB/" ~ getprop("/instrumentation/efb/chart/icao") ~ "/" ~ getprop("/instrumentation/efb/chart/type") ~ "-0") == nil ) me.nochart = 1;
else { setprop("/instrumentation/efb/chart/selected", getprop("/instrumentation/efb/chartsDB/" ~ getprop("/instrumentation/efb/chart/icao") ~ "/" ~ getprop("/instrumentation/efb/chart/type") ~ "-0"));
me.nochart = 0; }
}
}

#### Field Values

if (getprop("/instrumentation/efb/page") == "Airport Charts") {
setprop("/controls/cdu/l2-type", "click");
setprop("/controls/cdu/l3-type", "click");
setprop("/controls/cdu/l4-type", "click");
setprop("/controls/cdu/r7-type", "click");
setprop("/controls/cdu/display/l2-label", "Airport ICAO (Enter)");
setprop("/controls/cdu/display/l3-label", "Chart Type (Select)");
setprop("/controls/cdu/display/l4-label", "Chart ID (Select)");
setprop("/controls/cdu/display/l2", getprop("/instrumentation/efb/chart/icao"));
setprop("/controls/cdu/display/l3", getprop("/instrumentation/efb/chart/type"));
if (me.nochart == 1) setprop("/controls/cdu/display/l4", "No Available Charts");
else setprop("/controls/cdu/display/l4", getprop("/instrumentation/efb/chart/selected"));
setprop("/controls/cdu/display/r7", "DISPLAY >");
} else {
setprop("/controls/cdu/l2-type", "disp");
setprop("/controls/cdu/l3-type", "disp");
setprop("/controls/cdu/l4-type", "disp");
setprop("/controls/cdu/r7-type", "disp");
setprop("/controls/cdu/display/l2-label", "");
setprop("/controls/cdu/display/l3-label", "");
setprop("/controls/cdu/display/l4-label", "");
setprop("/controls/cdu/display/l2", "");
setprop("/controls/cdu/display/l3", "");
setprop("/controls/cdu/display/l4", "");
setprop("/controls/cdu/display/r7", "");
}

setprop("/controls/cdu/display/l1-label", "");
setprop("/controls/cdu/display/l5-label", "");
setprop("/controls/cdu/display/l6-label", "");
setprop("/controls/cdu/display/l7-label", "");
setprop("/controls/cdu/display/r1-label", "");
setprop("/controls/cdu/display/r2-label", "");
setprop("/controls/cdu/display/r3-label", "");
setprop("/controls/cdu/display/r4-label", "");
setprop("/controls/cdu/display/r5-label", "");
setprop("/controls/cdu/display/r6-label", "");
setprop("/controls/cdu/display/r7-label", "");

setprop("/controls/cdu/display/l1", "");
setprop("/controls/cdu/display/r1", "");

setprop("/controls/cdu/display/r2", "");
setprop("/controls/cdu/display/r3", "");
setprop("/controls/cdu/display/r4", "");

setprop("/controls/cdu/display/l5", "");
setprop("/controls/cdu/display/r5", "");

setprop("/controls/cdu/display/l6", "");
setprop("/controls/cdu/display/r6", "");

setprop("/controls/cdu/display/l7", "< INDEX");
### Menu Presses

if (keypress == "l7") {
page = "INDEX";
keypress = "";
}

setprop("/instrumentation/efb/chart/newairport", 0);
if ((keypress == "l2") and (cduinput != "")) {
setprop("/instrumentation/efb/chart/icao", cduinput);
keypress = "";
setprop("/controls/cdu/input", "");
cduinput = "";
setprop("/instrumentation/efb/chart/newairport", 1);
}

setprop("/instrumentation/efb/chart/newtype", 0);
if (keypress == "l3") {
if (getprop("/instrumentation/efb/chart/type") == "SID") setprop("/instrumentation/efb/chart/type", "STAR");
elsif (getprop("/instrumentation/efb/chart/type") == "STAR") setprop("/instrumentation/efb/chart/type", "IAP");
else setprop("/instrumentation/efb/chart/type", "SID");
keypress = "";
setprop("/instrumentation/efb/chart/newtype", 1);
}

if ((keypress == "l4") and (me.nochart == 0)) {

var lastn = getprop("/instrumentation/efb/chartsDB/" ~ getprop("/instrumentation/efb/chart/icao") ~ "/" ~ getprop("/instrumentation/efb/chart/type") ~ "s") - 1;

var selected = getprop("/instrumentation/efb/chart/selected");

var propbase = "/instrumentation/efb/chartsDB/" ~ getprop("/instrumentation/efb/chart/icao") ~ "/" ~ getprop("/instrumentation/efb/chart/type") ~ "-";

if (selected == getprop(propbase ~ (lastn))) setprop("/instrumentation/efb/chart/selected", getprop(propbase ~ "0"));
else {
for (var index = 0; index < lastn; index += 1) {

if (selected == getprop(propbase ~ index)) {
setprop("/instrumentation/efb/chart/selected", getprop(propbase ~ (index + 1)));
index = lastn;
}
}
}

keypress = "";
}

if (keypress == "r7") {
if (getprop("/instrumentation/efb/page") == "Airport Charts") efb.searchcharts(getprop("/instrumentation/efb/chart/icao") ~ "/" ~ getprop("/instrumentation/efb/chart/type") ~ "/" ~ getprop("/instrumentation/efb/chart/selected")); 
keypress = "";
}


if ((keypress == "exec") and (cduinput != "")) {

setprop("/instrumentation/efb/input", cduinput);

### Airport Information and Diagram

if ((getprop("/instrumentation/efb/page") == "Airport Diagram") or (getprop("/instrumentation/efb/page") == "Airport Information")) {
setprop("/environment/metar[6]/station-id", cduinput);
setprop("/environment/metar[6]/time-to-live", 1);
efb.searchairport(cduinput);
}

if (getprop("/instrumentation/efb/page") == "Runway Information") setprop("/instrumentation/efb/selected-rwy/id", cduinput);

keypress = "";
setprop("/controls/cdu/input", "");
}

} elsif (page == "VNAV CONFIG") {

#### Field types

setprop("/controls/cdu/l1-type", "disp");
setprop("/controls/cdu/l2-type", "click");
setprop("/controls/cdu/l3-type", "click");
setprop("/controls/cdu/l4-type", "click");
setprop("/controls/cdu/l5-type", "disp");
setprop("/controls/cdu/l6-type", "disp");
setprop("/controls/cdu/l7-type", "click");

setprop("/controls/cdu/r1-type", "disp");
setprop("/controls/cdu/r2-type", "disp");
setprop("/controls/cdu/r3-type", "disp");
setprop("/controls/cdu/r4-type", "disp");
setprop("/controls/cdu/r5-type", "disp");
setprop("/controls/cdu/r6-type", "disp");
setprop("/controls/cdu/r7-type", "disp");

#### Field Values

setprop("/controls/cdu/display/l1-label", "");
setprop("/controls/cdu/display/l2-label", "Cruise Altitude");
setprop("/controls/cdu/display/l3-label", "Start Cruise at");
setprop("/controls/cdu/display/l4-label", "End Cruise at");
setprop("/controls/cdu/display/l5-label", "");
setprop("/controls/cdu/display/l6-label", "");
setprop("/controls/cdu/display/l7-label", "");
setprop("/controls/cdu/display/r1-label", "");
setprop("/controls/cdu/display/r2-label", "");
setprop("/controls/cdu/display/r3-label", "");
setprop("/controls/cdu/display/r4-label", "");
setprop("/controls/cdu/display/r5-label", "");
setprop("/controls/cdu/display/r6-label", "");
setprop("/controls/cdu/display/r7-label", "");

setprop("/controls/cdu/display/l1", "");
setprop("/controls/cdu/display/r1", "");

setprop("/controls/cdu/display/l2", getprop("/controls/cdu/vnav/crz-altitude-ft"));
setprop("/controls/cdu/display/r2", "");

setprop("/controls/cdu/display/l3", getprop("/controls/cdu/vnav/start-crz"));
setprop("/controls/cdu/display/r3", "");

setprop("/controls/cdu/display/l4", getprop("/controls/cdu/vnav/end-crz"));
setprop("/controls/cdu/display/r4", "");

setprop("/controls/cdu/display/l5", "");
setprop("/controls/cdu/display/r5", "");

setprop("/controls/cdu/display/l6", "");
setprop("/controls/cdu/display/r6", "");

setprop("/controls/cdu/display/l7", "< INDEX");
setprop("/controls/cdu/display/r7", "");

# MENU PRESSES

if (keypress == "l7") {
page = "INDEX";
keypress = "";
}

if ((keypress == "l2") and (cduinput != "")) {
setprop("/controls/cdu/vnav/crz-altitude-ft", cduinput);
cduinput = "";
setprop("/controls/cdu/input", "");
keypress = "";
}

if ((keypress == "l3") and (cduinput != "")) {
setprop("/controls/cdu/vnav/start-crz", cduinput);
cduinput = "";
setprop("/controls/cdu/input", "");
keypress = "";
}

if ((keypress == "l4") and (cduinput != "")) {
setprop("/controls/cdu/vnav/end-crz", cduinput);
cduinput = "";
setprop("/controls/cdu/input", "");
keypress = "";
}

} elsif (page == "HOLD CONFIG") {

#### Field types

setprop("/controls/cdu/l1-type", "disp");
setprop("/controls/cdu/l2-type", "click");
setprop("/controls/cdu/l3-type", "click");
setprop("/controls/cdu/l4-type", "click");
setprop("/controls/cdu/l5-type", "click");
setprop("/controls/cdu/l6-type", "click");
setprop("/controls/cdu/l7-type", "click");

setprop("/controls/cdu/r1-type", "disp");
setprop("/controls/cdu/r2-type", "click");
setprop("/controls/cdu/r3-type", "disp");
setprop("/controls/cdu/r4-type", "disp");
setprop("/controls/cdu/r5-type", "disp");
setprop("/controls/cdu/r6-type", "click");
setprop("/controls/cdu/r7-type", "click");

#### Field Values

setprop("/controls/cdu/display/l1-label", "");
setprop("/controls/cdu/display/l2-label", "Holding Navaid");
setprop("/controls/cdu/display/l3-label", "Holding Navaid Type");
setprop("/controls/cdu/display/l4-label", "Holding Radial");
setprop("/controls/cdu/display/l5-label", "Holding Altitude");
setprop("/controls/cdu/display/l6-label", "Holding Time (sec)");
setprop("/controls/cdu/display/l7-label", "");
setprop("/controls/cdu/display/r1-label", "");
setprop("/controls/cdu/display/r2-label", "Turn Direction");
setprop("/controls/cdu/display/r3-label", "");
setprop("/controls/cdu/display/r4-label", "");
setprop("/controls/cdu/display/r5-label", "");
setprop("/controls/cdu/display/r6-label", "");
setprop("/controls/cdu/display/r7-label", "");

setprop("/controls/cdu/display/l1", "");
setprop("/controls/cdu/display/r1", "");

setprop("/controls/cdu/display/l2", getprop("/autopilot/hold/fix"));
setprop("/controls/cdu/display/r2", getprop("/autopilot/hold/hold-direction"));

setprop("/controls/cdu/display/l3", getprop("/autopilot/hold/nav-type"));
setprop("/controls/cdu/display/r3", "");

setprop("/controls/cdu/display/l4", getprop("/autopilot/hold/hold-radial"));
setprop("/controls/cdu/display/r4", "");

setprop("/controls/cdu/display/l5", getprop("/autopilot/hold/altitude"));
setprop("/controls/cdu/display/r5", "");

setprop("/controls/cdu/display/l6", getprop("/autopilot/hold/hold-time"));
setprop("/controls/cdu/display/r6", "");

setprop("/controls/cdu/display/l7", "< INDEX");

if (getprop("/controls/cdu/hold/found") == 1) {
setprop("/controls/cdu/display/r6", "");
if (getprop("/autopilot/hold/active") == 0) setprop("/controls/cdu/display/r7", "ENTER HOLD >");
else setprop("/controls/cdu/display/r7", "EXIT HOLD >");
} else {
setprop("/controls/cdu/display/r6", "SEARCH NAVAID >");
setprop("/controls/cdu/display/r7", "");
}

# MENU PRESSES

if (keypress == "l7") {
page = "INDEX";
keypress = "";
}

if ((keypress == "l2") and (cduinput != "")) {
setprop("/autopilot/hold/fix", cduinput);
cduinput = "";
setprop("/controls/cdu/input", "");
keypress = "";
}

if ((keypress == "l6") and (cduinput != "")) {
setprop("/autopilot/hold/hold-time", cduinput);
cduinput = "";
setprop("/controls/cdu/input", "");
keypress = "";
}

if (keypress == "r2") {

if (getprop("/autopilot/hold/hold-direction") == "Left") setprop("/autopilot/hold/hold-direction", "Right");
else setprop("/autopilot/hold/hold-direction", "Left");

keypress = "";
}

if (keypress == "l3") {

var nav_type = getprop("/autopilot/hold/nav-type");

if (nav_type == "vor") setprop("/autopilot/hold/nav-type", "ndb");
elsif (nav_type == "ndb") setprop("/autopilot/hold/nav-type", "fix");
else setprop("/autopilot/hold/nav-type", "vor");

keypress = "";
}

if (keypress == "r6") {

setprop("/instrumentation/gps[2]/scratch/query", getprop("/autopilot/hold/fix"));
setprop("/instrumentation/gps[2]/scratch/type", getprop("/autopilot/hold/nav-type"));

setprop("/instrumentation/gps[2]/command", "search");

setprop("/controls/cdu/hold/found", 1);

keypress = "";
}

if (keypress == "r7") {

if (getprop("/autopilot/hold/active") == 0) { 
setprop("/autopilot/hold/active", 1);
sysinfo.log_msg("[CDU] Entered Automatic Holding Pattern", 0);
} else {
setprop("/autopilot/hold/active", 0);
setprop("/controls/cdu/hold/found", 0);
}

keypress = "";

}

if ((keypress == "l4") and (cduinput != "")) {
setprop("/autopilot/hold/hold-radial", cduinput);
cduinput = "";
setprop("/controls/cdu/input", "");
keypress = "";
}

if ((keypress == "l5") and (cduinput != "")) {
setprop("/autopilot/hold/altitude", cduinput);
cduinput = "";
setprop("/controls/cdu/input", "");
keypress = "";
}

} elsif (page == "FLIGHT INFO") {

#### Field types

setprop("/controls/cdu/l1-type", "disp");
setprop("/controls/cdu/l2-type", "disp");
setprop("/controls/cdu/l3-type", "disp");
setprop("/controls/cdu/l4-type", "disp");
setprop("/controls/cdu/l5-type", "disp");
setprop("/controls/cdu/l6-type", "disp");
setprop("/controls/cdu/l7-type", "click");

setprop("/controls/cdu/r1-type", "disp");
setprop("/controls/cdu/r2-type", "disp");
setprop("/controls/cdu/r3-type", "disp");
setprop("/controls/cdu/r4-type", "disp");
setprop("/controls/cdu/r5-type", "disp");
setprop("/controls/cdu/r6-type", "disp");
setprop("/controls/cdu/r7-type", "click");

#### Field Values

setprop("/controls/cdu/display/l1-label", "Flight Number");
setprop("/controls/cdu/display/l2-label", "Departure ICAO");
setprop("/controls/cdu/display/l3-label", "Destination ICAO");
setprop("/controls/cdu/display/l4-label", "Aircraft Registration");
setprop("/controls/cdu/display/l5-label", "Total Flight Time");
setprop("/controls/cdu/display/l6-label", "Preset Flight Plan");
setprop("/controls/cdu/display/r7-label", "");
setprop("/controls/cdu/display/r1-label", "");
setprop("/controls/cdu/display/r2-label", "");
setprop("/controls/cdu/display/r3-label", "");
setprop("/controls/cdu/display/r4-label", "");
setprop("/controls/cdu/display/r5-label", "");
setprop("/controls/cdu/display/r6-label", "");
setprop("/controls/cdu/display/r7-label", "");

setprop("/controls/cdu/display/l7", "< INDEX");

setprop("/controls/cdu/display/r1", "");
setprop("/controls/cdu/display/r2", "");
setprop("/controls/cdu/display/r3", "");
setprop("/controls/cdu/display/r4", "");
setprop("/controls/cdu/display/r5", "");
setprop("/controls/cdu/display/r6", "");
setprop("/controls/cdu/display/r7", "SET ROUTE >");


# Run the Flight Search Function
# Todo: don't run each frame!
fmc.search_flight(getprop("/controls/cdu/flightnum"));

# MENU PRESSES

if (keypress == "l7") {
page = "INDEX";
keypress = "";
} elsif (keypress == "r7") {
fmc.confirm_flight(getprop("/controls/cdu/flightnum"));
keypress = "";
}

} elsif (page == "PROCEDURES") {

if ((getprop("/autopilot/route-manager/departure/airport") == nil) or (getprop("/autopilot/route-manager/departure/runway") == nil) or (getprop("/autopilot/route-manager/destination/airport") == nil) or (getprop("/autopilot/route-manager/destination/runway") == nil)) {
page = "DEP/ARR";
}

setprop("/controls/cdu/l1-type", "disp");
setprop("/controls/cdu/l2-type", "disp");
setprop("/controls/cdu/l3-type", "disp");
setprop("/controls/cdu/l4-type", "disp");
setprop("/controls/cdu/l5-type", "disp");
setprop("/controls/cdu/l6-type", "click");
setprop("/controls/cdu/l7-type", "click");

setprop("/controls/cdu/r1-type", "disp");
setprop("/controls/cdu/r2-type", "disp");
setprop("/controls/cdu/r3-type", "click");
setprop("/controls/cdu/r4-type", "click");
setprop("/controls/cdu/r5-type", "click");
setprop("/controls/cdu/r6-type", "disp");
setprop("/controls/cdu/r7-type", "click");

setprop("/controls/cdu/display/l1-label", "");
setprop("/controls/cdu/display/l2-label", "");
setprop("/controls/cdu/display/l3-label", "");
setprop("/controls/cdu/display/l4-label", "");
setprop("/controls/cdu/display/l5-label", "");
setprop("/controls/cdu/display/l6-label", "");
setprop("/controls/cdu/display/l7-label", "");
setprop("/controls/cdu/display/r1-label", "");
setprop("/controls/cdu/display/r2-label", "");
setprop("/controls/cdu/display/r3-label", "");
setprop("/controls/cdu/display/r4-label", "");
setprop("/controls/cdu/display/r5-label", "");
setprop("/controls/cdu/display/r6-label", "");
setprop("/controls/cdu/display/r7-label", "");

setprop("/controls/cdu/display/l1", "");
setprop("/controls/cdu/display/r1", "");
setprop("/controls/cdu/display/l2", "");
setprop("/controls/cdu/display/r2", "");
setprop("/controls/cdu/display/l3", "");
setprop("/controls/cdu/display/r3", "DEPARTURE >");
setprop("/controls/cdu/display/l4", "");
setprop("/controls/cdu/display/r4", "ARRIVAL >");
setprop("/controls/cdu/display/l5", "");
setprop("/controls/cdu/display/r5", "APPROACH >");
setprop("/controls/cdu/display/l6", "< DEP / ARR");
setprop("/controls/cdu/display/r6", "");
setprop("/controls/cdu/display/l7", "< INDEX");
setprop("/controls/cdu/display/r7", "FLIGHTPLAN >");

## MENU Presses

if (keypress == "r3") {
page = "DEPARTURE (SID)";

		DepICAO = fmsDB.new(getprop("/autopilot/route-manager/departure/airport"));
		SIDList = DepICAO.getSIDList(getprop("/autopilot/route-manager/departure/runway"));
		SIDmax = size(SIDList);

keypress = "";
} elsif (keypress == "r4") {
page = "ARRIVAL (STAR)";

		ArrICAO = fmsDB.new(getprop("/autopilot/route-manager/destination/airport"));
		STARList = ArrICAO.getSTARList(getprop("/autopilot/route-manager/destination/runway"));
		STARmax = size(STARList);

keypress = "";
} elsif (keypress == "r5") {
page = "APPROACH (IAP)";

		AppICAO = fmsDB.new(getprop("/autopilot/route-manager/destination/airport"));
		IAPList = AppICAO.getApproachList(getprop("/autopilot/route-manager/destination/runway"));
		IAPmax = size(IAPList);

keypress = "";
} elsif (keypress == "l6") {
page = "DEP/ARR";
keypress = "";
} elsif (keypress == "l7") {
page = "INDEX";
keypress = "";
} elsif (keypress == "r7") {
page = "FLIGHTPLANS";
keypress = "";
}
} elsif (page == "DEPARTURE (SID)") {

fmcTP.selectSID(0);

# Menu Presses

if (keypress == "l7") {
page = "INDEX";
keypress = "";
} elsif (keypress == "r7") {
page = "PROCEDURES";
keypress = "";
} elsif (keypress == "l4") {
SIDfirst = SIDfirst - 1;
keypress = "";
} elsif (keypress == "l5") {
SIDfirst += 1;
keypress = "";
} elsif (keypress == "l6") {
fmcTP.setDep();
keypress = "";
} elsif (keypress == "l1") {
if (SIDindex + 1 < SIDmax)
	SIDindex += 1;
else
	SIDindex = 0;
keypress = "";
}

# Waypoint Information

if (keypress == "r1") {
fmcTP.wpInfo(0, SIDfirst, SIDindex, "SID");
page = "Waypoint Information";
} elsif (keypress == "r2") {
fmcTP.wpInfo(0, SIDfirst + 1, SIDindex, "SID");
page = "Waypoint Information";
} elsif (keypress == "r3") {
fmcTP.wpInfo(0, SIDfirst + 2, SIDindex, "SID");
page = "Waypoint Information";
} elsif (keypress == "r4") {
fmcTP.wpInfo(0, SIDfirst + 3, SIDindex, "SID");
page = "Waypoint Information";
} elsif (keypress == "r5") {
fmcTP.wpInfo(0, SIDfirst + 4, SIDindex, "SID");
page = "Waypoint Information";
} elsif (keypress == "r6") {
fmcTP.wpInfo(0, SIDfirst + 5, SIDindex, "SID");
page = "Waypoint Information";
}

} elsif (page == "ARRIVAL (STAR)") {

fmcTP.selectSTAR(0);

# Menu Presses

if (keypress == "l7") {
page = "INDEX";
keypress = "";
} elsif (keypress == "r7") {
page = "PROCEDURES";
keypress = "";
} elsif (keypress == "l4") {
STARfirst = STARfirst - 1;
keypress = "";
} elsif (keypress == "l5") {
STARfirst += 1;
keypress = "";
} elsif (keypress == "l6") {
fmcTP.setArr();
keypress = "";
} elsif (keypress == "l1") {
if (STARindex + 1 < STARmax)
	STARindex += 1;
else
	STARindex = 0;
keypress = "";
}

# Waypoint Information

if (keypress == "r1") {
fmcTP.wpInfo(0, STARfirst, STARindex, "STAR");
page = "Waypoint Information";
} elsif (keypress == "r2") {
fmcTP.wpInfo(0, STARfirst + 1, STARindex, "STAR");
page = "Waypoint Information";
} elsif (keypress == "r3") {
fmcTP.wpInfo(0, STARfirst + 2, STARindex, "STAR");
page = "Waypoint Information";
} elsif (keypress == "r4") {
fmcTP.wpInfo(0, STARfirst + 3, STARindex, "STAR");
page = "Waypoint Information";
} elsif (keypress == "r5") {
fmcTP.wpInfo(0, STARfirst + 4, STARindex, "STAR");
page = "Waypoint Information";
} elsif (keypress == "r6") {
fmcTP.wpInfo(0, STARfirst + 5, STARindex, "STAR");
page = "Waypoint Information";
}

} elsif (page == "APPROACH (IAP)") {

fmcTP.selectIAP(0);

# Menu Presses

if (keypress == "l7") {
page = "INDEX";
keypress = "";
} elsif (keypress == "r7") {
page = "PROCEDURES";
keypress = "";
} elsif (keypress == "l4") {
IAPfirst = IAPfirst - 1;
keypress = "";
} elsif (keypress == "l5") {
IAPfirst += 1;
keypress = "";
} elsif (keypress == "l6") {
fmcTP.setApp();
keypress = "";
} elsif (keypress == "l1") {
if (IAPindex + 1 < IAPmax)
	IAPindex += 1;
else
	IAPindex = 0;
keypress = "";
}

# Waypoint Information

if (keypress == "r1") {
fmcTP.wpInfo(0, IAPfirst, IAPindex, "IAP");
page = "Waypoint Information";
} elsif (keypress == "r2") {
fmcTP.wpInfo(0, IAPfirst + 1, IAPindex, "IAP");
page = "Waypoint Information";
} elsif (keypress == "r3") {
fmcTP.wpInfo(0, IAPfirst + 2, IAPindex, "IAP");
page = "Waypoint Information";
} elsif (keypress == "r4") {
fmcTP.wpInfo(0, IAPfirst + 3, IAPindex, "IAP");
page = "Waypoint Information";
} elsif (keypress == "r5") {
fmcTP.wpInfo(0, IAPfirst + 4, IAPindex, "IAP");
page = "Waypoint Information";
} elsif (keypress == "r6") {
fmcTP.wpInfo(0, IAPfirst + 5, IAPindex, "IAP");
page = "Waypoint Information";
}

} elsif (page == "Waypoint Information") {

## Page is displayed from the entry functions, this is only required for MENU presses

if (keypress == "l7") {
page = "INDEX";
keypress = "";
} elsif (keypress = "r7") {

	if (TPtype == "SID")
		page = "DEPARTURE (SID)";
	elsif (TPtype == "STAR")
		page = "ARRIVAL (STAR)";
	else
		page = "APPROACH (IAP)";

keypress = "";
}

} elsif (page == "FLIGHTPLANS") {

#### Field types

setprop("/controls/cdu/l1-type", "disp");
setprop("/controls/cdu/l2-type", "disp");
setprop("/controls/cdu/l3-type", "click");
setprop("/controls/cdu/l4-type", "click");
setprop("/controls/cdu/l5-type", "click");
setprop("/controls/cdu/l6-type", "click");
setprop("/controls/cdu/l7-type", "click");

setprop("/controls/cdu/r1-type", "disp");
setprop("/controls/cdu/r2-type", "disp");
setprop("/controls/cdu/r3-type", "click");
setprop("/controls/cdu/r4-type", "click");
setprop("/controls/cdu/r5-type", "click");
setprop("/controls/cdu/r6-type", "click");
setprop("/controls/cdu/r7-type", "click");

#### Field Values

setprop("/controls/cdu/display/l1-label", "");
setprop("/controls/cdu/display/l2-label", "Flightplan Status");
setprop("/controls/cdu/display/l3-label", "");
setprop("/controls/cdu/display/l4-label", "");
setprop("/controls/cdu/display/l5-label", "Alternate Airport");
setprop("/controls/cdu/display/l6-label", "");
setprop("/controls/cdu/display/l7-label", "");
setprop("/controls/cdu/display/r1-label", "");
setprop("/controls/cdu/display/r2-label", "Flightplan Status");
setprop("/controls/cdu/display/r3-label", "");
setprop("/controls/cdu/display/r4-label", "");
setprop("/controls/cdu/display/r5-label", "");
setprop("/controls/cdu/display/r6-label", "");
setprop("/controls/cdu/display/r7-label", "");

setprop("/controls/cdu/display/l1", "PRIMARY FP");
setprop("/controls/cdu/display/l2", getprop("/instrumentation/fmcFP/flightplan[0]/status"));
setprop("/controls/cdu/display/l3", "< VIEW / EDIT");

if (getprop("/instrumentation/fmcFP/flightplan[0]/num") > 0)
	setprop("/controls/cdu/display/l4", "< COPY TO RTE");
else
	setprop("/controls/cdu/display/l4", "");
	
setprop("/controls/cdu/display/l5", getprop("/instrumentation/fmcFP/alternate/icao"));
setprop("/controls/cdu/display/l6", "< DEP / ARR");
setprop("/controls/cdu/display/l7", "< INDEX");

setprop("/controls/cdu/display/r1", "SECONDARY FP");
setprop("/controls/cdu/display/r2",  getprop("/instrumentation/fmcFP/flightplan[1]/status"));
setprop("/controls/cdu/display/r3", "VIEW / EDIT >");

if (getprop("/instrumentation/fmcFP/flightplan[1]/num") > 0)
	setprop("/controls/cdu/display/r4", "COPY TO RTE >");
else
	setprop("/controls/cdu/display/r4", "");

setprop("/controls/cdu/display/r5", "DIVERT >");
setprop("/controls/cdu/display/r6", "ACTIVE RTE >");
setprop("/controls/cdu/display/r7", "PROCEDURES >");

## MENU PRESSES

if (keypress == "l7") {
page = "INDEX";
keypress = "";
} elsif (keypress == "r7") {
page = "PROCEDURES";
keypress = "";
} elsif (keypress == "l6") {
page = "DEP/ARR";
keypress = "";
} elsif (keypress == "r6") {
page = "ROUTE";
keypress = "";
} elsif ((keypress == "l5") and (cduinput != "")) {
setprop("/instrumentation/fmcFP/alternate/icao", cduinput);
keypress = "";
cduinput = "";
setprop("/controls/cdu/input", "");
} elsif (keypress == "r5") {
fmcFP.divert(getprop("/instrumentation/fmcFP/alternate/icao"));
keypress = "";
} elsif (keypress == "l4") {
fmcFP.copy(0);
keypress = "";
} elsif (keypress == "r4") {
fmcFP.copy(1);
keypress = "";
} elsif (keypress == "l3") {
page = "PRIMARY FLIGHTPLAN";
keypress = "";
} elsif (keypress == "r3") {
page = "SECONDARY FLIGHTPLAN";
keypress = "";
}

}

if (page == "PRIMARY FLIGHTPLAN") {
FPpage(0,0);

	## Menu Presses
	
	if (keypress == "l7") {
		page = "INDEX";
		keypress = "";
	} elsif (keypress == "r7") {
		page = "FLIGHTPLANS";
		keypress = "";
	} elsif (keypress == "r5") {
		setprop(fmcFPtree~ "FPpage[" ~ 0 ~ "]/first", getprop(fmcFPtree~ "FPpage[" ~ 0 ~ "]/first") - 1);
		keypress = "";
	} elsif (keypress == "r6") {
		setprop(fmcFPtree~ "FPpage[" ~ 0 ~ "]/first", getprop(fmcFPtree~ "FPpage[" ~ 0 ~ "]/first") + 1);
		keypress = "";
	} elsif (keypress == "l5") {
		setprop("/controls/cdu/input", "REMOVE WP");
		keypress = "";
	} elsif (keypress == "l6") {
		fmcFP.clear(0);
		keypress = "";
	} elsif (keypress == "exec") {
		fmcFP.add(0, getprop("/controls/cdu/input"), 0);
		keypress = "";
		cduinput = "";
		setprop("/controls/cdu/input", "");
	} elsif (keypress == "r1") {
		fmcFP.setalt(0, (getprop(fmcFPtree~ "FPpage[" ~ 0 ~ "]/first")),getprop("/controls/cdu/input"));
		keypress = "";
		cduinput = "";
		setprop("/controls/cdu/input", "");		
	} elsif (keypress == "r2") {
		fmcFP.setalt(0, (getprop(fmcFPtree~ "FPpage[" ~ 0 ~ "]/first") + 1),getprop("/controls/cdu/input"));
		keypress = "";
		cduinput = "";
		setprop("/controls/cdu/input", "");
	} elsif (keypress == "r3") {
		fmcFP.setalt(0, (getprop(fmcFPtree~ "FPpage[" ~ 0 ~ "]/first") + 2),getprop("/controls/cdu/input"));
		keypress = "";
		cduinput = "";
		setprop("/controls/cdu/input", "");
	} elsif (keypress == "r4") {
		fmcFP.setalt(0, (getprop(fmcFPtree~ "FPpage[" ~ 0 ~ "]/first") + 3),getprop("/controls/cdu/input"));
		keypress = "";
		cduinput = "";
		setprop("/controls/cdu/input", "");
	}
	
	if ((getprop("/controls/cdu/input") == "REMOVE WP") and (keypress == "l1")) {
		fmcFP.remove(0, getprop(fmcFPtree~ "FPpage[" ~ 0 ~ "]/first"));
		keypress = "";
		cduinput = "";
		setprop("/controls/cdu/input", "");
	} elsif ((getprop("/controls/cdu/input") == "REMOVE WP") and (keypress == "l2")) {
		fmcFP.remove(0, getprop(fmcFPtree~ "FPpage[" ~ 0 ~ "]/first") + 1);
		keypress = "";
		cduinput = "";
		setprop("/controls/cdu/input", "");
	} elsif ((getprop("/controls/cdu/input") == "REMOVE WP") and (keypress == "l3")) {
		fmcFP.remove(0, getprop(fmcFPtree~ "FPpage[" ~ 0 ~ "]/first") + 2);
		keypress = "";
		cduinput = "";
		setprop("/controls/cdu/input", "");
	} elsif ((getprop("/controls/cdu/input") == "REMOVE WP") and (keypress == "l4")) {
		fmcFP.remove(0, getprop(fmcFPtree~ "FPpage[" ~ 0 ~ "]/first") + 3);
		keypress = "";
		cduinput = "";
		setprop("/controls/cdu/input", "");
	}

}

if (page == "SECONDARY FLIGHTPLAN") {
FPpage(0,1);

	## Menu Presses
	
	if (keypress == "l7") {
		page = "INDEX";
		keypress = "";
	} elsif (keypress == "r7") {
		page = "FLIGHTPLANS";
		keypress = "";
	} elsif (keypress == "r5") {
		setprop(fmcFPtree~ "FPpage[" ~ 1 ~ "]/first", getprop(fmcFPtree~ "FPpage[" ~ 1 ~ "]/first") - 1);
		keypress = "";
	} elsif (keypress == "r6") {
		setprop(fmcFPtree~ "FPpage[" ~ 1 ~ "]/first", getprop(fmcFPtree~ "FPpage[" ~ 1 ~ "]/first") + 1);
		keypress = "";
	} elsif (keypress == "l5") {
		setprop("/controls/cdu/input", "REMOVE WP");
		keypress = "";
	} elsif (keypress == "l6") {
		fmcFP.clear(1);
		keypress = "";
	} elsif (keypress == "exec") {
		fmcFP.add(1, getprop("/controls/cdu/input"), 0);
		keypress = "";
		cduinput = "";
		setprop("/controls/cdu/input", "");
	} elsif (keypress == "r1") {
		fmcFP.setalt(1, (getprop(fmcFPtree~ "FPpage[" ~ 1 ~ "]/first")),getprop("/controls/cdu/input"));
		keypress = "";
		cduinput = "";
		setprop("/controls/cdu/input", "");
	} elsif (keypress == "r2") {
		fmcFP.setalt(1, (getprop(fmcFPtree~ "FPpage[" ~ 1 ~ "]/first") + 1),getprop("/controls/cdu/input"));
		keypress = "";
		cduinput = "";
		setprop("/controls/cdu/input", "");
	} elsif (keypress == "r3") {
		fmcFP.setalt(1, (getprop(fmcFPtree~ "FPpage[" ~ 1 ~ "]/first") + 2),getprop("/controls/cdu/input"));
		keypress = "";
		cduinput = "";
		setprop("/controls/cdu/input", "");
	} elsif (keypress == "r4") {
		fmcFP.setalt(1, (getprop(fmcFPtree~ "FPpage[" ~ 1 ~ "]/first") + 3),getprop("/controls/cdu/input"));
		keypress = "";
		cduinput = "";
		setprop("/controls/cdu/input", "");
	}
	
	if ((getprop("/controls/cdu/input") == "REMOVE WP") and (keypress == "l1")) {
		fmcFP.remove(1, getprop(fmcFPtree~ "FPpage[" ~ 1 ~ "]/first"));
		keypress = "";
		cduinput = "";
		setprop("/controls/cdu/input", "");
	} elsif ((getprop("/controls/cdu/input") == "REMOVE WP") and (keypress == "l2")) {
		fmcFP.remove(1, getprop(fmcFPtree~ "FPpage[" ~ 1 ~ "]/first") + 1);
		keypress = "";
		cduinput = "";
		setprop("/controls/cdu/input", "");
	} elsif ((getprop("/controls/cdu/input") == "REMOVE WP") and (keypress == "l3")) {
		fmcFP.remove(1, getprop(fmcFPtree~ "FPpage[" ~ 1 ~ "]/first") + 2);
		keypress = "";
		cduinput = "";
		setprop("/controls/cdu/input", "");
	} elsif ((getprop("/controls/cdu/input") == "REMOVE WP") and (keypress == "l4")) {
		fmcFP.remove(1, getprop(fmcFPtree~ "FPpage[" ~ 1 ~ "]/first") + 3);
		keypress = "";
		cduinput = "";
		setprop("/controls/cdu/input", "");
	}

} elsif (page == "NAVAIDS") {

#### Field types

setprop("/controls/cdu/l1-type", "click");
setprop("/controls/cdu/l2-type", "click");
setprop("/controls/cdu/l3-type", "disp");
setprop("/controls/cdu/l4-type", "click");
setprop("/controls/cdu/l5-type", "click");
setprop("/controls/cdu/l6-type", "disp");
setprop("/controls/cdu/l7-type", "click");

setprop("/controls/cdu/r1-type", "click");
setprop("/controls/cdu/r2-type", "click");
setprop("/controls/cdu/r3-type", "disp");
setprop("/controls/cdu/r4-type", "disp");
setprop("/controls/cdu/r5-type", "click");
setprop("/controls/cdu/r6-type", "disp");
setprop("/controls/cdu/r7-type", "disp");

#### Field Values

setprop("/controls/cdu/display/l1-label", "Part or Full ID");
setprop("/controls/cdu/display/l2-label", "Distance from Aircraft");
setprop("/controls/cdu/display/l3-label", "");
setprop("/controls/cdu/display/l4-label", "Airport ICAO");
setprop("/controls/cdu/display/l5-label", "Distance from Airport");
setprop("/controls/cdu/display/l6-label", "");
setprop("/controls/cdu/display/l7-label", "");
setprop("/controls/cdu/display/r1-label", "Search by ID");
setprop("/controls/cdu/display/r2-label", "Search by Distance from Aircraft");
setprop("/controls/cdu/display/r3-label", "");
setprop("/controls/cdu/display/r4-label", "");
setprop("/controls/cdu/display/r5-label", "Search by Distance from Airport");
setprop("/controls/cdu/display/r6-label", "");
setprop("/controls/cdu/display/r7-label", "");

setprop("/controls/cdu/display/l1", getprop("/instrumentation/navSearch/name"));
setprop("/controls/cdu/display/l2", getprop("/instrumentation/navSearch/d_aircraft"));
setprop("/controls/cdu/display/l3", "");
setprop("/controls/cdu/display/l4", getprop("/instrumentation/navSearch/icao"));
setprop("/controls/cdu/display/l5", getprop("/instrumentation/navSearch/d_airport"));
setprop("/controls/cdu/display/l6", "");
setprop("/controls/cdu/display/l7", "< INDEX");

setprop("/controls/cdu/display/r1", "SEARCH >");
setprop("/controls/cdu/display/r2", "SEARCH >");
setprop("/controls/cdu/display/r3", "");
setprop("/controls/cdu/display/r4", "");
setprop("/controls/cdu/display/r5", "SEARCH >");
setprop("/controls/cdu/display/r6", "");
setprop("/controls/cdu/display/r7", "");

## MENU PRESSES

if (keypress == "l7") {
page = "INDEX";
keypress = "";
} elsif ((keypress == "l1") and (cduinput != nil)) {
setprop("/instrumentation/navSearch/name", cduinput);
setprop("/controls/cdu/input", "");
cduinput = "";
keypress = "";
} elsif ((keypress == "l2") and (cduinput != nil)) {
setprop("/instrumentation/navSearch/d_aircraft", cduinput);
setprop("/controls/cdu/input", "");
cduinput = "";
keypress = "";
} elsif ((keypress == "l4") and (cduinput != nil)) {
setprop("/instrumentation/navSearch/icao", cduinput);
setprop("/controls/cdu/input", "");
cduinput = "";
keypress = "";
} elsif ((keypress == "l5") and (cduinput != nil)) {
setprop("/instrumentation/navSearch/d_airport", cduinput);
setprop("/controls/cdu/input", "");
cduinput = "";
keypress = "";
}

## Search functions

elsif (keypress == "r1") {

navaids.search_by_name(0,getprop("/instrumentation/navSearch/name"));

page = "SEARCH RESULTS";

keypress = "";
} elsif (keypress == "r2") {

navaids.search_by_dist(0,getprop("/position/latitude-deg"), getprop("/position/longitude-deg"), getprop("/instrumentation/navSearch/d_aircraft"));

page = "SEARCH RESULTS";

keypress = "";
} elsif (keypress == "r5") {

setprop("/instrumentation/gps[4]/scratch/query", getprop("/instrumentation/navSearch/icao"));
setprop("/instrumentation/gps[4]/scratch/type", "airport");
setprop("/instrumentation/gps[4]/command", "search");

var gps_lat = getprop("/instrumentation/gps[4]/scratch/latitude-deg");
var gps_lon = getprop("/instrumentation/gps[4]/scratch/longitude-deg");

navaids.search_by_dist(0, gps_lat, gps_lon, getprop("/instrumentation/navSearch/d_airport"));

page = "SEARCH RESULTS";

keypress = "";
}

} elsif (page == "SEARCH RESULTS") {

var nav_disp = "/NavData/disp/cdu/";

var nav_result = "/NavData/results/";
	
var first = getprop(nav_result ~ "/first");

#### Field types

setprop("/controls/cdu/l1-type", "disp");
setprop("/controls/cdu/l2-type", "disp");
setprop("/controls/cdu/l3-type", "disp");
setprop("/controls/cdu/l4-type", "disp");
setprop("/controls/cdu/l5-type", "disp");
setprop("/controls/cdu/l6-type", "click");
setprop("/controls/cdu/l7-type", "click");

setprop("/controls/cdu/r1-type", "disp");
setprop("/controls/cdu/r2-type", "disp");
setprop("/controls/cdu/r3-type", "disp");
setprop("/controls/cdu/r4-type", "disp");
setprop("/controls/cdu/r5-type", "disp");
setprop("/controls/cdu/r6-type", "click");
setprop("/controls/cdu/r7-type", "click");

#### Field Values

setprop("/controls/cdu/display/l1-label", getprop(nav_disp ~ "disp/name"));
setprop("/controls/cdu/display/l2-label", getprop(nav_disp ~ "disp[1]/name"));
setprop("/controls/cdu/display/l3-label", getprop(nav_disp ~ "disp[2]/name"));
setprop("/controls/cdu/display/l4-label", getprop(nav_disp ~ "disp[3]/name"));
setprop("/controls/cdu/display/l5-label", getprop(nav_disp ~ "disp[4]/name"));
setprop("/controls/cdu/display/l6-label", "");
setprop("/controls/cdu/display/l7-label", "");
setprop("/controls/cdu/display/r1-label", "");
setprop("/controls/cdu/display/r2-label", "");
setprop("/controls/cdu/display/r3-label", "");
setprop("/controls/cdu/display/r4-label", "");
setprop("/controls/cdu/display/r5-label", "");
setprop("/controls/cdu/display/r6-label", "");
setprop("/controls/cdu/display/r7-label", "");

if ((getprop(nav_disp ~ "disp/id") != nil) and (getprop(nav_disp ~ "disp/id") != " "))
	setprop("/controls/cdu/display/l1", getprop(nav_disp ~ "disp/id") ~ " | Lat: " ~ getprop(nav_disp ~ "disp/lat") ~ ", Lon: " ~ getprop(nav_disp ~ "disp/lon"));
else
	setprop("/controls/cdu/display/l1", "No Search Results...");
	
if ((getprop(nav_disp ~ "disp[1]/id") != nil) and (getprop(nav_disp ~ "disp[1]/id") != " "))
setprop("/controls/cdu/display/l2", getprop(nav_disp ~ "disp[1]/id") ~ " | Lat: " ~ getprop(nav_disp ~ "disp[1]/lat") ~ ", Lon: " ~ getprop(nav_disp ~ "disp[1]/lon"));

if ((getprop(nav_disp ~ "disp[2]/id") != nil) and (getprop(nav_disp ~ "disp[2]/id") != " "))
setprop("/controls/cdu/display/l3", getprop(nav_disp ~ "disp[2]/id") ~ " | Lat: " ~ getprop(nav_disp ~ "disp[2]/lat") ~ ", Lon: " ~ getprop(nav_disp ~ "disp[2]/lon"));

if ((getprop(nav_disp ~ "disp[3]/id") != nil) and (getprop(nav_disp ~ "disp[3]/id") != " "))
setprop("/controls/cdu/display/l4", getprop(nav_disp ~ "disp[3]/id") ~ " | Lat: " ~ getprop(nav_disp ~ "disp[3]/lat") ~ ", Lon: " ~ getprop(nav_disp ~ "disp[3]/lon"));

if ((getprop(nav_disp ~ "disp[4]/id") != nil) and (getprop(nav_disp ~ "disp[4]/id") != " "))
setprop("/controls/cdu/display/l5", getprop(nav_disp ~ "disp[4]/id") ~ " | Lat: " ~ getprop(nav_disp ~ "disp[4]/lat") ~ ", Lon: " ~ getprop(nav_disp ~ "disp[4]/lon"));

setprop("/controls/cdu/display/l6", "< NAVAIDS");
setprop("/controls/cdu/display/l7", "< INDEX");

setprop("/controls/cdu/display/r1", "");
setprop("/controls/cdu/display/r2", "");
setprop("/controls/cdu/display/r3", "");
setprop("/controls/cdu/display/r4", "");
setprop("/controls/cdu/display/r5", "");
if (first != 0)
	setprop("/controls/cdu/display/r6", "SCROLL UP >");
else
	setprop("/controls/cdu/display/r6", "");

var next = getprop(nav_result ~ "result[" ~ (first + 5) ~ "]/id");

if ((next != nil) and (next != ""))
	setprop("/controls/cdu/display/r7", "SCROLL DOWN >");
else
	setprop("/controls/cdu/display/r7", "");

if (keypress == "l7") {
page = "INDEX";
keypress = "";
} elsif (keypress == "l6") {
page = "NAVAIDS";
keypress = "";
} elsif (keypress == "r6") {

if (first != 0)
	setprop(nav_result ~ "/first", first - 1);
	
navaids.update_display(0);

keypress = "";
} elsif (keypress == "r7") {

if ((next != nil) and (next != ""))
	setprop(nav_result ~ "/first", first + 1);
	
navaids.update_display(0);

keypress = "";
}

}

## Typing Characters and Functions

if (keypress != "") {

var charlength = size(getprop("/controls/cdu/input"));
var fmc_charlength = size(getprop("/instrumentation/fmcHelp[1]/search/input"));


### DEL Function
if (keypress == "del") {

if (getprop("/instrumentation/fmcHelp/search/active") != 1)

	setprop("/controls/cdu/input",substr(getprop("/controls/cdu/input"),0,charlength - 1));

else

	setprop("/instrumentation/fmcHelp/search/input",substr(getprop("/instrumentation/fmcHelp/search/input"),0,fmc_charlength - 1));

}

### CLR Function
elsif (keypress == "clr") {

if (getprop("/instrumentation/fmcHelp/search/active") != 1)

	setprop("/controls/cdu/input", "");

else

	setprop("/instrumentation/fmcHelp/search/input", "");

}

### The actual Typing Function

else {

if (getprop("/instrumentation/fmcHelp/search/active") != 1)

	setprop("/controls/cdu/input", cduinput ~ keypress);

else

	setprop("/instrumentation/fmcHelp/search/input", getprop("/instrumentation/fmcHelp/search/input") ~ keypress);

}
}

# Update Display Properties

setprop("/controls/cdu/display/page", page);

setprop("/controls/cdu/keypress", "");

},
	keypress_check : func(keypress) {
	
		var check = 0;
	
		var input_key = ["l1", "l2", "l3", "l4", "l5", "l6", "l7", "r1", "r2", "r3", "r4", "r5", "r6", "r7", "exec"];
		
		foreach(var key; input_key) {
		
			if (keypress == key)
				check = 1;
		
		}
		
		return check;
	
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
 cdu.init();
 print("FMS Computer 1 ...... Initialized");
 
 sysinfo.log_msg("[CDU] Control Display Units Initialized", 0);
 sysinfo.log_msg("[FMC] Flight Management Computer Ready", 0);
 
 navaids.load();
 
 });
