# Create initial announced variables at startup of the sim
V1 = "";
VR = "";
V2 = "";

# The actual function
var vspeeds = func {

       # Create/populate variables at each function cycle
       # Retrieve total aircraft weight.
	WT = getprop("/fdm/jsbsim/inertia/weight-lbs");
	

       
		V1 = (1.98 * 0.0001 * WT)+44.53;
		VR = (1.98 * 0.0001 * WT)+59.53;
		V2 = (1.98 * 0.0001 * WT)+74.53;
	

       

       # Export the calculated V-speeds to the property-tree, for further use
	setprop("/instrumentation/fmc/vspeeds/V1",V1);
	setprop("/instrumentation/fmc/vspeeds/VR",VR);
	setprop("/instrumentation/fmc/vspeeds/V2",V2);

       # Repeat the function each second
	settimer(vspeeds, 1);
}

# Only start the function when the FDM is initialized, to prevent the problem of not-yet-created properties.
_setlistener("/sim/signals/fdm-initialized", vspeeds);
