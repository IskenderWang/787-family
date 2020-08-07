# Parser for $FG_ROOT/Aircraft/787-8/EFB-DB/ChartsList
#
# Properties Stored in the following way:
# > /instrumentation/efb/chartsDB/<icao>/<type (str/sid/iap)>[index]
# 
# For Example, if the the 'ChartsList' file, a line says:
# > WSSS.STR:BOBAG1A, BOBAG1B, LAVAX1A, LAVAX1B;
#
# The Parser will convert it to:
# > /instrumentation/efb/chartsDB/WSSS/STR-0 = BOBAG1A
# > /instrumentation/efb/chartsDB/WSSS/STR-1 = BOBAG1B
# > /instrumentation/efb/chartsDB/WSSS/STR-2 = LAVAX1A
# > /instrumentation/efb/chartsDB/WSSS/STR-3 = LAVAX1B
# 
# This will let the chart IDs be togglable on the CDU

var root = getprop("/sim/aircraft-dir");

io.read_properties(root ~ "/EFB-DB/ChartsList.xml", "/instrumentation/efb");

sysinfo.log_msg("[EFB] Database Check ..... OK", 0);

# var row = split(";", io.readfile(root ~ "/EFB-DB/ChartsList"));

# for (var n = 1; n< (size(row) - 1); n += 1) {

#	var icao = substr(row[n], 1, 4);

#	var chrttype = substr(row[n],6,3);

#	if (substr(row[n],6,3) == "STR") chrttype = "STAR"; # If it's STR, convert to STAR

#	var id = split(", ", substr(row[n],10));

#	for (var m = 0; m < size(id); m += 1) {

#		if ((icao != nil) and (chrttype != nil) and (id[m] != nil))
#		setprop("/instrumentation/efb/chartsDB/" ~ icao ~ "/" ~ chrttype ~ "-" ~ m, id[m]);

#	}
#		if ((icao != nil) and (chrttype != nil) and (id[m] != nil))
#		setprop("/instrumentation/efb/chartsDB/" ~ icao ~ "/" ~ chrttype ~ "s", m);

# }
