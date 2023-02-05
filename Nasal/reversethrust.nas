togglereverser = func {
    r1  = "/fdm/jsbsim/propulsion/engine";
    r2  = "/fdm/jsbsim/propulsion/engine[1]";
    r3  = "/controls/engines/engine";
    r4  = "/controls/engines/engine[1]";
    r5  = "/sim/input/selected";
    rv1 = "/engines/engine/reverser-pos-norm";
    rv2 = "/engines/engine[1]/reverser-pos-norm";

    var wow = getprop("/gear/gear[1]/wow") and getprop("/gear/gear[2]/wow");
    var throttle = getprop("/controls/engines/engine/throttle") + getprop("/controls/engines/engine[1]/throttle");

    if (!wow and throttle != 0)
        return;

    val = getprop(rv1);
    if (val == 0 or val == nil) {
        interpolate(rv1, 1.0, 1.4);
        interpolate(rv2, 1.0, 1.4);
        setprop(r1, "reverser-angle-rad", 2.6);
        setprop(r2, "reverser-angle-rad", 2.6);
        setprop(r3,"reverser", "true");
        setprop(r4,"reverser", "true");
        setprop(r5,"engine", "true");
        setprop(r5,"engine[1]", "true");
    } elsif (val == 1.0) {
        interpolate(rv1, 0.0, 1.4);
        interpolate(rv2, 0.0, 1.4);
        setprop(r1, "reverser-angle-rad", 0.0);
        setprop(r2, "reverser-angle-rad", 0.0);
        setprop(r3,"reverser",0);
        setprop(r4,"reverser",0);
        setprop(r5,"engine", "true");
        setprop(r5,"engine[1]", "true");
    }
}
