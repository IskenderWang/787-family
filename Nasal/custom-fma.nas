# IT-AUTOFLIGHT Custom FMA File
# Make sure you enable custom-fma in the config
# Copyright (c) 2021 Josh Davidson (Octal450)

var updateFma = {
	latText: "T/O",
	vertText: "T/O CLB",
	lat: func() { # Called when lateral mode changes
		me.latText = Text.lat.getValue();
	},
	vert: func() { # Called when vertical mode changes
		me.vertText = Text.vert.getValue();
	},
	arm: func() { # Called when armed mode changes
		#Output.lnavArm.getBoolValue();
		#Output.locArm.getBoolValue();
		#Output.apprArm.getBoolValue();
	},
};
