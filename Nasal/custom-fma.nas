# IT-AUTOFLIGHT V4.0.9 Custom FMA File
# Make sure you enable custom-fma in the config
# Copyright (c) 2024 Josh Davidson (Octal450)
var Fma = {
	ap: props.globals.initNode("/instrumentation/pfd/fma/ap-mode", "", "STRING"),
	thr: props.globals.initNode("/instrumentation/pfd/fma/thr-mode", "", "STRING"),
	pitch: props.globals.initNode("/instrumentation/pfd/fma/pitch-mode", "", "STRING"),
	pitchArm: props.globals.initNode("/instrumentation/pfd/fma/pitch-mode-armed", "", "STRING"),
	roll: props.globals.initNode("/instrumentation/pfd/fma/roll-mode", "", "STRING"),
	rollArm: props.globals.initNode("/instrumentation/pfd/fma/roll-mode-armed", "", "STRING"),
};

var UpdateFma = {
    latMode: {"" : "", "T/O" : "TO/GA", "RLOU" : "ROLLOUT", "HDG" : "HDG SEL", "ALGN" : "LOC", "ROLL" : "", "LNAV" : "LNAV", "LOC" : "LOC"}, # HDG HOLD, TRK SEL, TRK HLD, B/CRS FAC not supported
    thrMode: {"" : "", "RETARD" : "", "THR LIM" : "THR REF", "IDLE" : "IDLE", "MACH" : "SPD", "SPEED" : "SPD"}, # THR, HOLD not supported
    vertMode: {"" : "", "T/O CLB" : "TO/GA", "ROLLOUT" : "", "ALT HLD" : "ALT HLD", "FPA" : "", "V/S" : "V/S", "ALT CAP" : "ALT/ACQ", "FLARE" : "FLARE", "SPD CLB" : "MCP SPD", "SPD DES" : "MCP SPD", "G/S" : "G/S", "G/A CLB" : "TO/GA"}, # G/P and VNAV SPD/PTH/ALT not supported
	thr: func() { # Called when speed/thrust modes change
		Fma.thr.setValue(me.thrMode[Text.thr.getValue()]);
	},
	arm: func() { # Called when armed modes change
		# Pitch Modes
		if (Output.lnavArm.getBoolValue()) {
			Fma.pitchArm.setValue("LNAV");
		} elsif (Output.gsArm.getBoolValue()) {
			if (Text.vert.getValue() == "V/S") {
				Fma.pitchArm.setValue("G/S V/S");
			} else {
				Fma.pitchArm.setValue("G/S");
			}
		} elsif (Text.vert.getValue() == "V/S") {
			Fma.pitchArm.setValue("V/S");
		} elsif (Text.vert.getValue() == "FLARE") {
			Fma.pitchArm.setValue("FLARE");
		} else {
			Fma.pitchArm.setValue("");
		}

		# Roll Modes
		if (Output.lnavArm.getBoolValue()) {
			Fma.rollArm.setValue("LNAV");
		} elsif (Output.locArm.getBoolValue()) {
			if (Output.lnavArm.getBoolValue()) {
				Fma.rollArm.setValue("LNAV VOR/LOC");
			} else {
				Fma.rollArm.setValue("VOR/LOC");
			}
		} else {
			Fma.rollArm.setValue("");
		}
	},
	lat: func() { # Called when lateral mode changes
        Fma.roll.setValue(me.latMode[Text.lat.getValue()]);
	},
	vert: func() { # Called when vertical mode changes
        Fma.pitch.setValue(me.vertMode[Text.vert.getValue()]);
	},
};