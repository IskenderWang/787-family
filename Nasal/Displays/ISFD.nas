# Boeing Integrated Standby Flight Sidplay

var display = nil;
var isfd = nil;

var Value = {
    Airspeed: {
        indicatedKts = 0;
        fail = 0;
    },
    Altitude: {
        indicatedFt = 0;
        fail = 0;
    }
    Attitude: {
        indicatedRollDeg = 0;
        indicatedPitchDeg = 0;
        fail = 0;
    },
    Heading: {
        indicatedHeadingDeg = 0;
        fail = 0;
    },
    Init: {
        run = 0;
        startTime = 0;
    }
};

var canvasBase = {
	init: func(canvasGroup, file) {
		var font_mapper = func(family, weight) {
			return "MCDULarge.ttf";
		};
		
		canvas.parsesvg(canvasGroup, file, {"font-mapper": font_mapper});
		
		var svgKeys = me.getKeys();
		foreach(var key; svgKeys) {
			me[key] = canvasGroup.getElementById(key);
		}
		
		Value.Ai.center = me["AI_center"].getCenter();
		me.aiHorizonTrans = me["AI_horizon"].createTransform();
		me.aiHorizonRot = me["AI_horizon"].createTransform();
		
		me.page = canvasGroup;
		
		return me;
	},
	getKeys: func() {
		return ["warn-out-of-order", "warn-wait-att", "warn-init", "warn-hdg", "warn-hdg-back", "warn-loc", "warn-loc-back", "warn-att", "warn-att-back", "warn-alt", "warn-alt-back", "warn-gs", "warn-gs-back", "warn-spd", "warn-spd-back", "press-set", "bcrs", "app", "nav-gs", "nav-loc", "nav-lines", "nav-back", "spd-1", "spd-10", "spd-100", "spd-tape", "alt-20", "alt-100", "alt-1000", "alt-10000", "alt-tape-tick", "alt-tape6", "alt-tape5", "alt-tape4", "alt-tape3", "alt-tape2", "alt-tape1", "compass-dial", "bank-arrow", "ladder", "sky", "ground"];
	},
	setup: func() {
		# Hide the pages by default
		isfd.page.hide();
	},
	update: func() {
		if (systems.DUController.updateIsfd) {
			isfd.update();
		}
	},
};

var canvasIsfd = {
	new: func(canvasGroup, file) {
		var m = {parents: [canvasIsfd, canvasBase]};
		m.init(canvasGroup, file);
		
		return m;
	},
	update: func() {
        if (Value.Airspeed.fail) {
            me["warn"]
        }
	},
};

var setup = func() {
	display = canvas.new({
		"name": "ISFD",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
	});
	
	display.addPlacement({"node": "isfd.screen"});
	
	var isfdGroup = display.createGroup();
	
	isfd = canvasIsfd.new(isfdGroup, "Aircraft/787-family/Nasal/Displays/res/ISFD.svg");
	
	canvasBase.setup();
	update.start();
	
	if (pts.Systems.Acconfig.Options.Du.isfdFps.getValue() != 20) {
		rateApply();
	}
}

var rateApply = func() {
	update.restart(1 / pts.Systems.Acconfig.Options.Du.isfdFps.getValue());
}

var update = maketimer(0.05, func() { # 20FPS
	canvasBase.update();
});

var showIsfd = func() {
	var dlg = canvas.Window.new([256, 220], "dialog", nil, 0).set("resize", 1);
	dlg.setCanvas(display);
	dlg.set("title", "Integrated Standy Flight Display");
}