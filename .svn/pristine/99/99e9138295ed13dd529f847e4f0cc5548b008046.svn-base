  var catchme = {
   init : func {
      me.UPDATE_INTERVAL = 0.2;
      me.loopid = 0;
      me.time = 0;
      me.score = 0;
      me.reset();
      
      setprop("/instrumentation/efb/catchme/x", 0);
      setprop("/instrumentation/efb/catchme/y", 0);
      
	},
	update : func {

			if (getprop("/instrumentation/efb/page") == "Catch me if you can") {
			
				# Generate Random Numbers for Type and Direction
				
				var mystery = rand();
				var vertical = rand();
				var horizontal = rand();
				
				# Check for Type and set color
				
				if (mystery <= 0.75)
					setprop("/instrumentation/efb/catchme/color", "white");
				elsif (mystery <= 0.9)
					setprop("/instrumentation/efb/catchme/color", "red");
				else
					setprop("/instrumentation/efb/catchme/color", "green");
					
				# Vertical Movement
				
				if (vertical <= 0.4) # GO UP!
					setprop("/instrumentation/efb/catchme/y", getprop("/instrumentation/efb/catchme/y") + 1);
				elsif (vertical <= 0.8) # GO DOWN!
					setprop("/instrumentation/efb/catchme/y", getprop("/instrumentation/efb/catchme/y") - 1);
				
				if (horizontal <= 0.4) # GO LEFT!
					setprop("/instrumentation/efb/catchme/x", getprop("/instrumentation/efb/catchme/x") - 1);
				elsif (horizontal <= 0.8) # GO RIGHT!
					setprop("/instrumentation/efb/catchme/x", getprop("/instrumentation/efb/catchme/x") + 1);
					
				# Bump the Ball back if it exceeds boundary limits
				
				if (getprop("/instrumentation/efb/catchme/y") > 5)
					setprop("/instrumentation/efb/catchme/y", 5);
				
				if (getprop("/instrumentation/efb/catchme/y") < -5)
					setprop("/instrumentation/efb/catchme/y", -5);
					
				if (getprop("/instrumentation/efb/catchme/x") > 5)
					setprop("/instrumentation/efb/catchme/x", 5);
					
				if (getprop("/instrumentation/efb/catchme/x") < -5)
					setprop("/instrumentation/efb/catchme/x", -5);
					
				# Set timer to zero if you scored a point
				
				if (getprop("/instrumentation/efb/catchme/score") != me.score) {# Just scored a point!
					me.set_0();
					
					setprop("/instrumentation/efb/catchme/scored", 1);
					
				} else {
					setprop("/instrumentation/efb/catchme/scored", 0)
				}
				
				# Check Timer
				
				me.timer();
				
				# Store Score for checking
				
				me.score = getprop("/instrumentation/efb/catchme/score");			
			
			} else
					me.set_0();

	},
	reset_score : func {
		setprop("/instrumentation/efb/catchme/score", 0);
	},
	timer : func {
			me.time += 1;
			
			setprop("/instrumentation/efb/catchme/timer-norm", me.time / 60);
			
			if (me.time >= 60) {
				setprop("/instrumentation/efb/page", "GAME OVER");			
				setprop("/instrumentation/efb/catchme/x", 0);
				setprop("/instrumentation/efb/catchme/y", 0);
			}
	},
	set_0 : func {
			me.time = 0;
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
 catchme.init();
 });
