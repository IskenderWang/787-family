var fmcHelp_loop = {
   init : func {
        me.UPDATE_INTERVAL = 0.25;
        me.loopid = 0;
        
        setprop("/instrumentation/fmcHelp/selected", 0);
        setprop("/instrumentation/fmcHelp/show", 1);
        setprop("/instrumentation/fmcHelp/search/active", 0);
        setprop("/instrumentation/fmcHelp/search/input", "");
        setprop("/instrumentation/fmcHelp/first", 0);
        
        setprop("/instrumentation/fmcHelp[1]/selected", 0);
        setprop("/instrumentation/fmcHelp[1]/show", 1);
        setprop("/instrumentation/fmcHelp[1]/search/active", 0);
        setprop("/instrumentation/fmcHelp[1]/search/input", "");
        setprop("/instrumentation/fmcHelp[1]/first", 0);
        
 		setprop("/instrumentation/fmcHelp/last_input", ""); 
 		setprop("/instrumentation/fmcHelp[1]/last_input", "");   
 		
 		fmcHelp.parseWords();    
        
        me.reset();
    },
    update : func {

		for (var n = 0; n <= 1; n += 1) {
		
			var search = getprop("/instrumentation/fmcHelp[" ~ n ~ "]/search/active");	
			
			var cduinput = getprop("/controls/cdu[" ~ n ~ "]/input");
			
			var lastinput = getprop("/instrumentation/fmcHelp[" ~ n ~ "]/last_input");
						
					# Check for CDU Input if Search bar is inactive
						
			if ((search != 1) and (cduinput != nil) and (lastinput != cduinput)) {
			
				fmcHelp.search(n, cduinput);
			
			}
			
			if (cduinput != nil)
				setprop("/instrumentation/fmcHelp[" ~ n ~ "]/last_input", cduinput);
		
		}

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
 fmcHelp_loop.init();
 print("CDU Word Completion . Initialized");

 sysinfo.log_msg("[FMC] Automatic Word Completion Ready", 0);
 });
