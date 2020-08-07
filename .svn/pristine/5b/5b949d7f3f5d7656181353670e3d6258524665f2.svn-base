# NOTE : I probably left out a LOT of other warning/system based properties... If you have any, please add them in. :)

var sc_tree = "/system_memory";

var syscheck = {
	init : func { 
        me.UPDATE_INTERVAL = 1; 
        me.loopid = 0; 
        
        me.fuel_low = 0;
        me.fuel_crit = 0;
        
        me.hyd_pump0_ovht = 0;
        me.hyd_pump1_ovht = 0;
        me.hyd_pump2_ovht = 0;
        me.hyd_pump3_ovht = 0;
        
        me.fuel_pump0_ovht = 0;
        me.fuel_pump1_ovht = 0;
        me.fuel_pump2_ovht = 0;
        
        me.hyd_pump0_fault = 0;
        me.hyd_pump1_fault = 0;
        me.hyd_pump2_fault = 0;
        me.hyd_pump3_fault = 0;
        
        me.fuel_pump0_fault = 0;
        me.fuel_pump1_fault = 0;
        me.fuel_pump2_fault = 0;
        
        me.no_power = 0;
        me.low_power = 0;
		
		me.syscpy_props = [
			"/sim/failure-manager/engines/engine/serviceable",
			"/sim/failure-manager/engines/engine[1]/serviceable",
			"/controls/electric/external-power",
			"/systems/electrical/serviceable",
			"/controls/electric/ram-air-turbine",
			"/systems/electrical/outputs/efis",
			"/controls/fires/fire/on-fire",
			"/controls/fires/fire[1]/on-fire",
			"/controls/fbw/alpha-protect",
			"/controls/fbw/autostable",
			"/controls/fbw/active",
			"/controls/fuel/x-feed",
			"/controls/jettison/arm",
			"/controls/gear-failures/gear[0]/break",
			"/controls/gear-failures/gear[0]/burst",
			"/controls/gear-failures/gear[1]/break",
			"/controls/gear-failures/gear[1]/burst",
			"/controls/gear-failures/gear[2]/break",
			"/controls/gear-failures/gear[2]/burst",
			"/controls/hydraulic/serviceable/system0",
			"/controls/hydraulic/serviceable/system1",
			"/controls/hydraulic/serviceable/system2",
			"/controls/hydraulic/serviceable/system3",
			"/controls/pneumatic/temp/hyd-sys0-eng",
			"/controls/pneumatic/temp/hyd-sys1-eng",
			"/controls/pneumatic/temp/hyd-sys2-elec",
			"/controls/pneumatic/temp/hyd-sys3-elec",
			"/controls/mfd/extra",
			"/autopilot/panel/master",
			"/autopilot/panel/auto-throttle",
			"/controls/pneumatic/equipcooling",
			"/controls/pneumatic/pack1",	
			"/controls/pneumatic/pack2",
			"/controls/pneumatic/temp/fuel-pump-left",
			"/controls/pneumatic/temp/fuel-pump-center",
			"/controls/pneumatic/temp/fuel-pump-right",
			"/autopilot/vnav/vnav-mode",
			"/controls/hydraulic/system[0]/engine-pump",
			"/controls/hydraulic/system[1]/engine-pump",
			"/controls/hydraulic/system[2]/electric-pump",
			"/controls/hydraulic/system[3]/electric-pump",
			"/controls/ice/wing/anti-ice",
			"/controls/ice/eng1/anti-ice",
			"/controls/ice/eng2/anti-ice",
			"/consumables/fuel/total-fuel-kg"
		];
		
		# Make the first copy
		
		foreach(var prop; me.syscpy_props) {
		
			if (getprop(prop) != nil)
				setprop(sc_tree ~ prop, getprop(prop));
	
		}

        me.reset(); 
}, 
	update : func {

	foreach(var prop; me.syscpy_props) {
	
		# First check for a change
		
		if (getprop(prop) != getprop(sc_tree ~ prop))
			me.check_prop(prop);
		
		# Now, copy the new props into the memory
	
		if (getprop(prop) != nil)
			setprop(sc_tree ~ prop, getprop(prop));
	
	}

},
	check_prop : func(prop) {
	
		if (prop == "/controls/electric/external-power") {
			if (getprop(prop) != 0)
				sysinfo.log_msg("[ELEC] External Power Connected", 0);
			else
				sysinfo.log_msg("[ELEC] External Power Disconnected", 0); }
		
		elsif (prop == "/sim/failure-manager/engines/engine/serviceable") {
			if (getprop(prop) != 1)
				sysinfo.log_msg("[ELEC] Engine 1 Failed", 2); }
				
		elsif (prop == "/sim/failure-manager/engines/engine[1]/serviceable") {
			if (getprop(prop) != 1)
				sysinfo.log_msg("[ELEC] Engine 2 Failed", 2); }
		
		elsif (prop == "/systems/electrical/serviceable") {
			if (getprop(prop) != 0)
				sysinfo.log_msg("[ELEC] Electrical System Servicable", 0);
			else
				sysinfo.log_msg("[ELEC] Electrical System Failure", 2); }
				
		elsif (prop == "/controls/electric/ram-air-turbine") {
			if (getprop(prop) != 0)
				sysinfo.log_msg("[ELEC] Ram Air Turbine Activated", 1); }
				
		elsif (prop == "/systems/electrical/outputs/efis") {
			if ((getprop(prop) < 5) and (me.no_power != 1)) {
				sysinfo.log_msg("[ELEC] Critical Electrical Power Generation", 1);
				me.no_power = 1;
			} elsif ((getprop(prop) < 9) and (me.low_power != 1) and (me.no_power != 1)) {
				sysinfo.log_msg("[ELEC] Low Electrical Power Generation", 1);
				me.low_power = 1;
			} }
			
		elsif (prop == "/controls/fires/fire/on-fire") {
			if (getprop(prop) == 1)
				sysinfo.log_msg("[ENG] Engine 1 On Fire", 2);
			else
				sysinfo.log_msg("[ENG] Engine 1 Fire Extinguished", 0); }
				
		elsif (prop == "/controls/fires/fire[1]/on-fire") {
			if (getprop(prop) == 1)
				sysinfo.log_msg("[ENG] Engine 2 On Fire", 2);
			else
				sysinfo.log_msg("[ENG] Engine 2 Fire Extinguished", 0); }
				
		elsif (prop == "/controls/fbw/alpha-protect") {
			if (getprop(prop) == 1)
				sysinfo.log_msg("[FBW] Alpha-Protection : Preventing Stall", 0); }
				
		elsif (prop == "/controls/fbw/autostable") {
			if (getprop(prop) == 1)
				sysinfo.log_msg("[FBW] Auto-Stabilization : Stabilizing Aircraft", 0);
			else
				sysinfo.log_msg("[FBW] Auto-Stabilization : Disconnected", 0);	 }		
		
		elsif (prop == "/controls/fbw/active") {
			if (getprop(prop) == 1)
				sysinfo.log_msg("[FBW] Fly-By-Wire Engaged and Working", 0);
			else
				sysinfo.log_msg("[FBW] Fly-By-Wire Disconnected", 1); }
				
		elsif (prop == "/controls/fuel/x-feed") {
			if (getprop(prop) == 1)
				sysinfo.log_msg("[FUEL] Cross-feed Active", 1); }
				
		elsif (prop == "/controls/jettison/arm") {
			if (getprop(prop) == 1)
				sysinfo.log_msg("[FUEL] Fuel Jettison Armed", 1);
			else
				sysinfo.log_msg("[FUEL] Fuel Jettison Disengaged", 0); }
				
		elsif (prop == "/controls/gear-failures/gear[0]/break") {
			if (getprop(prop) == 1)
				sysinfo.log_msg("[GEAR] Nose Gear Un-usabled", 2); }
				
		elsif (prop == "/controls/gear-failures/gear[0]/burst") {
			if (getprop(prop) == 1)
				sysinfo.log_msg("[GEAR] Nose Gear Tires Burst", 2); }
				
		elsif (prop == "/controls/gear-failures/gear[1]/break") {
			if (getprop(prop) == 1)
				sysinfo.log_msg("[GEAR] Left Main Gear Un-usabled", 2); }
				
		elsif (prop == "/controls/gear-failures/gear[1]/burst") {
			if (getprop(prop) == 1)
				sysinfo.log_msg("[GEAR] Left Main Gear Tires Burst", 2); }
				
		elsif (prop == "/controls/gear-failures/gear[2]/break") {
			if (getprop(prop) == 1)
				sysinfo.log_msg("[GEAR] Right Main Gear Un-usabled", 2); }
				
		elsif (prop == "/controls/gear-failures/gear[2]/burst") {
			if (getprop(prop) == 1)
				sysinfo.log_msg("[GEAR] Right Main Gear Tires Burst", 2); }
				
		elsif (prop == "/controls/hydraulic/serviceable/system0") {
			if (getprop(prop) == 1)
				sysinfo.log_msg("[HYD] Left Hydraulic System Servicable", 0);
			else
				sysinfo.log_msg("[HYD] Left Hydraulic System Failed", 2); }
				
		elsif (prop == "/controls/hydraulic/serviceable/system1") {
			if (getprop(prop) == 1)
				sysinfo.log_msg("[HYD] Right Hydraulic System Servicable", 0);
			else
				sysinfo.log_msg("[HYD] Right Hydraulic System Failed", 2); }
				
		elsif ((prop == "/controls/hydraulic/serviceable/system2") or (prop == "/controls/hydraulic/serviceable/system3")) {
			if (getprop(prop) == 1)
				sysinfo.log_msg("[HYD] Central Hydraulic System Servicable", 0);
			else
				sysinfo.log_msg("[HYD] Central Hydraulic System Failed", 2); }
		
		elsif (prop == "/controls/pneumatic/temp/hyd-sys0-eng") {
			if ((getprop(prop) > 120) and (me.hyd_pump0_fault != 1)) {
				sysinfo.log_msg("[HYD] Hydraulic E1 Engine Pump Fault", 2);
				me.hyd_pump0_fault = 1;
			} elsif ((getprop(prop) > 70) and (me.hyd_pump0_ovht != 1)) {
				sysinfo.log_msg("[HYD] Hydraulic E1 Engine Pump Overheat", 1);
				me.hyd_pump0_ovht = 1;
			} }
			
		elsif (prop == "/controls/pneumatic/temp/hyd-sys1-eng") {
			if ((getprop(prop) > 120) and (me.hyd_pump1_fault != 1)) {
				sysinfo.log_msg("[HYD] Hydraulic E2 Engine Pump Fault", 2);
				me.hyd_pump1_fault = 1;
			} elsif ((getprop(prop) > 70) and (me.hyd_pump1_ovht != 1)) {
				sysinfo.log_msg("[HYD] Hydraulic E2 Engine Pump Overheat", 1);
				me.hyd_pump1_ovht = 1;
			} }
			
		elsif (prop == "/controls/pneumatic/temp/hyd-sys2-elec") {
			if ((getprop(prop) > 120) and (me.hyd_pump2_fault != 1)) {
				sysinfo.log_msg("[HYD] Hydraulic C1 Electric Pump Fault", 2);
				me.hyd_pump2_fault = 1;
			} elsif ((getprop(prop) > 70) and (me.hyd_pump2_ovht != 1)) {
				sysinfo.log_msg("[HYD] Hydraulic C1 Electric Pump Overheat", 1);
				me.hyd_pump2_ovht = 1;
			} }
			
		elsif (prop == "/controls/pneumatic/temp/hyd-sys3-elec") {
			if ((getprop(prop) > 120) and (me.hyd_pump3_fault != 1)) {
				sysinfo.log_msg("[HYD] Hydraulic C2 Electric Pump Fault", 2);
				me.hyd_pump3_fault = 1;
			} elsif ((getprop(prop) > 70) and (me.hyd_pump3_ovht != 1)) {
				sysinfo.log_msg("[HYD] Hydraulic C2 Electric Pump Overheat", 1);
				me.hyd_pump3_ovht = 1;
			} }
			
		elsif (prop == "/controls/mfd/extra") {
			if (getprop(prop) == 0)
				sysinfo.log_msg("[MFD] Radar Mode Engaged", 0);
			elsif (getprop(prop) == 1)
				sysinfo.log_msg("[MFD] Satellite Map Engaged", 0);
			elsif (getprop(prop) == 2)
				sysinfo.log_msg("[MFD] Terrain Map Engaged", 0);
			else
				sysinfo.log_msg("[MFD] WXRadar Mode Engaged", 0); }
				
		elsif (prop == "/autopilot/panel/master") {
			if (getprop(prop) == 1)
				sysinfo.log_msg("[AP] Master Autopilot Engaged", 0);
			else
				sysinfo.log_msg("[AP] Master Autopilot Disengaged", 1); }
				
		elsif (prop == "/autopilot/panel/auto-throttle") {
			if (getprop(prop) == 1)
				sysinfo.log_msg("[AP] Auto-throttle Armed", 0);
			else
				sysinfo.log_msg("[AP] Auto-throttle Disengaged", 1); }
				
		elsif (prop == "/controls/pneumatic/equipcooling") {
			if (getprop(prop) == 1)
				sysinfo.log_msg("[PNEU] Equipment Cooling Engaged", 0);
			else
				sysinfo.log_msg("[PNEU] Equipment Cooling Disengaged", 1); }
				
		elsif (prop == "/controls/pneumatic/pack1") {
			if (getprop(prop) == 1)
				sysinfo.log_msg("[PNEU] Air-Conditioning Pack 1 Engaged", 0);
			else
				sysinfo.log_msg("[PNEU] Air-Conditioning Pack 1 Disngaged", 0); }
		
		elsif (prop == "/controls/pneumatic/pack2") {
			if (getprop(prop) == 1)
				sysinfo.log_msg("[PNEU] Air-Conditioning Pack 2 Engaged", 0);
			else
				sysinfo.log_msg("[PNEU] Air-Conditioning Pack 2 Disngaged", 0); }
				
		elsif (prop == "/autopilot/vnav/vnav-mode") {
			if (getprop(prop) == "crz-altitude-hold")
				sysinfo.log_msg("[FMC] VNAV Cruise Mode Engaged", 0);
			else
				sysinfo.log_msg("[FMC] VNAV Cruise Mode Disengaged", 0); }
				
		elsif (prop == "/controls/hydraulic/system[0]/engine-pump") {
			if (getprop(prop) == 1)
				sysinfo.log_msg("[HYD] Hydraulic E1 Engine Pump Activated", 0);
			else
				sysinfo.log_msg("[HYD] Hydraulic E1 Engine Pump De-Activated", 1); }
		
		elsif (prop == "/controls/hydraulic/system[1]/engine-pump") {
			if (getprop(prop) == 1)
				sysinfo.log_msg("[HYD] Hydraulic E2 Engine Pump Activated", 0);
			else
				sysinfo.log_msg("[HYD] Hydraulic E2 Engine Pump De-Activated", 1); }
				
		elsif (prop == "/controls/hydraulic/system[2]/electric-pump") {
			if (getprop(prop) == 1)
				sysinfo.log_msg("[HYD] Hydraulic C1 Engine Pump Activated", 0);
			else
				sysinfo.log_msg("[HYD] Hydraulic C1 Engine Pump De-Activated", 1); }
				
		elsif (prop == "/controls/hydraulic/system[3]/electric-pump") {
			if (getprop(prop) == 1)
				sysinfo.log_msg("[HYD] Hydraulic C2 Engine Pump Activated", 0);
			else
				sysinfo.log_msg("[HYD] Hydraulic C2 Engine Pump De-Activated", 1); }
				
		elsif (prop == "/controls/ice/wing/anti-ice") {
			if (getprop(prop) == 1)
				sysinfo.log_msg("[HEAT] Wing Anti-Icing Engaged", 0);
			else
				sysinfo.log_msg("[HEAT] Wing Anti-Icing Dis-engaged", 1); }
				
		elsif (prop == "/controls/ice/eng1/anti-ice") {
			if (getprop(prop) == 1)
				sysinfo.log_msg("[HEAT] Engine 1 Anti-Icing Engaged", 0);
			else
				sysinfo.log_msg("[HEAT] Engine 1 Anti-Icing Dis-engaged", 1); }
				
		elsif (prop == "/controls/ice/eng2/anti-ice") {
			if (getprop(prop) == 1)
				sysinfo.log_msg("[HEAT] Engine 2 Anti-Icing Engaged", 0);
			else
				sysinfo.log_msg("[HEAT] Engine 2 Anti-Icing Dis-engaged", 1); }
				
		elsif (prop == "/controls/pneumatic/temp/fuel-pump-left") {
			if ((getprop(prop) > 200) and (me.fuel_pump0_fault != 1)) {
				sysinfo.log_msg("[FUEL] Left Fuel Pump Fault", 2);
				me.fuel_pump0_fault = 1;
			} elsif ((getprop(prop) > 120) and (me.fuel_pump0_ovht != 1)) {
				sysinfo.log_msg("[FUEL] Left Fuel Pump Overheat", 1);
				me.fuel_pump0_ovht = 1;
			} }
			
		elsif (prop == "/controls/pneumatic/temp/fuel-pump-center") {
			if ((getprop(prop) > 200) and (me.fuel_pump1_fault != 1)) {
				sysinfo.log_msg("[FUEL] Center Fuel Pump Fault", 2);
				me.fuel_pump1_fault = 1;
			} elsif ((getprop(prop) > 120) and (me.fuel_pump1_ovht != 1)) {
				sysinfo.log_msg("[FUEL] Center Fuel Pump Overheat", 1);
				me.fuel_pump1_ovht = 1;
			} }
			
		elsif (prop == "/controls/pneumatic/temp/fuel-pump-right") {
			if ((getprop(prop) > 200) and (me.fuel_pump2_fault != 1)) {
				sysinfo.log_msg("[FUEL] Right Fuel Pump Fault", 2);
				me.fuel_pump2_fault = 1;
			} elsif ((getprop(prop) > 120) and (me.fuel_pump2_ovht != 1)) {
				sysinfo.log_msg("[FUEL] Right Fuel Pump Overheat", 1);
				me.fuel_pump2_ovht = 1;
			} }
			
		elsif (prop == "/consumables/fuel/total-fuel-kg") {
			if ((getprop(prop) < 1000) and (me.fuel_crit != 1)) {
				sysinfo.log_msg("[FUEL] Critical Fuel Level", 2);
				me.fuel_crit = 1;
			} elsif ((getprop(prop) < 4000) and (me.fuel_low != 1)) {
				sysinfo.log_msg("[FUEL] Low Fuel Level", 1);
				me.fuel_low = 1;
			} }
			
		else
			sysinfo.log_msg("[SYS] Unknown Error: " ~ prop);
		
				
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
 syscheck.init();
 print("System Logger ....... Initialized");
 });
