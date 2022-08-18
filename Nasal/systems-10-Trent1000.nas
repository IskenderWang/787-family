## PRINT STARTUP MESSAGES
#########################
screen.log.write("Welcome aboard the Boeing 787-10!", 1, 1, 1);
setprop("/instrumentation/sysinfo/max", 0);
setprop("/instrumentation/sysinfo/first", 0);
b787.sysinfo.log_msg("[SYS] Testing EICAS Warning Display", 2);
b787.sysinfo.log_msg("[SYS] Systems Check and Logger Initialized", 0);

## LIVERY SELECT
################
aircraft.livery.init("Aircraft/787-family/Models/Liveries-10/Trent1000");

## LIGHTS
#########

# create all lights
var beacon_switch = props.globals.getNode("controls/switches/beacon", 2);
var beacon = aircraft.light.new("sim/model/lights/beacon", [0.05, 2], "controls/lighting/beacon");

var strobe_switch = props.globals.getNode("controls/switches/strobe", 2);
var strobe = aircraft.light.new("sim/model/lights/strobe", [0.05, 1.3], "controls/lighting/strobe");

## SOUNDS
#########

# seatbelt/no smoking sign triggers
setlistener("controls/switches/seatbelt-sign", func
 {
 props.globals.getNode("sim/sound/seatbelt-sign").setBoolValue(1);

 settimer(func
  {
  props.globals.getNode("sim/sound/seatbelt-sign").setBoolValue(0);
  }, 2);
 });
setlistener("controls/switches/no-smoking-sign", func
 {
 props.globals.getNode("sim/sound/no-smoking-sign").setBoolValue(1);

 settimer(func
  {
  props.globals.getNode("sim/sound/no-smoking-sign").setBoolValue(0);
  }, 2);
 });

## ENGINES
##########

# explanation of engine properties
# controls/engines/engine[X]/throttle-lever	When the engine isn't running, this value is constantly set to 0; otherwise, we transfer the value of controls/engines/engine[X]/throttle to it
# controls/engines/engine[X]/starter		Triggering it fires up the engine
# engines/engine[X]/running			Set based on the engine state
# engines/engine[X]/rpm				Used in place of the n1 value for the animations and set dynamically based on the engine state
# engines/engine[X]/failed			When triggered the engine is "failed" and cannot be restarted
# engines/engine[X]/on-fire			Self-explanatory

# APU loop function

var apuLoop = func
 {

	if (getprop("engines/APU/rpm") >= 80) {
		setprop("engines/APU/servicable",1);
	} else {
		setprop("engines/APU/servicable",0);
	}

 var setting = getprop("controls/APU/off-start-run");

 if (setting != 0)
  {
  if (setting == 1)
   {
   var rpm = getprop("engines/APU/rpm");
   rpm += getprop("sim/time/delta-realtime-sec") * 7;
   if (rpm >= 100)
    {
    rpm = 100;
    }
   setprop("engines/APU/rpm", rpm);
   }
  elsif (setting == 2 and getprop("engines/APU/rpm") >= 80)
   {
   props.globals.getNode("engines/APU/running").setBoolValue(1);
   }
  }
 else
  {
  props.globals.getNode("engines/APU/running").setBoolValue(0);

  var rpm = getprop("engines/APU/rpm");
  rpm -= getprop("sim/time/delta-realtime-sec") * 5;
  if (rpm < 0)
   {
   rpm = 0;
   }
  setprop("engines/APU/rpm", rpm);
  }

 settimer(apuLoop, 0);
 };
# main loop function
var engineLoop = func(engine_no)
 {
 # control the throttles and main engine properties
 var engineCtlTree = "controls/engines/engine[" ~ engine_no ~ "]/";
 var engineOutTree = "engines/engine[" ~ engine_no ~ "]/";

 # the FDM switches the running property to true automatically if the cutoff is set to false, this is unwanted
 if (props.globals.getNode(engineOutTree ~ "running").getBoolValue() and !props.globals.getNode(engineOutTree ~ "started").getBoolValue())
  {
  props.globals.getNode(engineOutTree ~ "running").setBoolValue(0);
  }

 if (props.globals.getNode(engineOutTree ~ "on-fire").getBoolValue())
  {
  props.globals.getNode(engineOutTree ~ "failed").setBoolValue(1);
  }
 if (props.globals.getNode(engineCtlTree ~ "cutoff").getBoolValue() or props.globals.getNode(engineOutTree ~ "failed").getBoolValue() or props.globals.getNode(engineCtlTree ~ "out-of-fuel").getBoolValue())
  {
  if (getprop(engineOutTree ~ "rpm") > 0)
   {
   var rpm = getprop(engineOutTree ~ "rpm");
   rpm -= getprop("sim/time/delta-realtime-sec") * 2.5;
   setprop(engineOutTree ~ "rpm", rpm);
   }
  else
   {
   setprop(engineOutTree ~ "rpm", 0);
   }

  props.globals.getNode(engineOutTree ~ "running").setBoolValue(0);
  props.globals.getNode(engineOutTree ~ "started").setBoolValue(0);
  setprop(engineCtlTree ~ "throttle-lever", 0);
  }
 elsif (props.globals.getNode(engineCtlTree ~ "starter").getBoolValue() and props.globals.getNode("engines/APU/running").getBoolValue())
  {
  props.globals.getNode(engineCtlTree ~ "cutoff").setBoolValue(0);

  var rpm = getprop(engineOutTree ~ "rpm");
  rpm += getprop("sim/time/delta-realtime-sec") * 3;
  setprop(engineOutTree ~ "rpm", rpm);

  if (rpm >= getprop(engineOutTree ~ "n1"))
   {
#   props.globals.getNode(engineCtlTree ~ "starter").setBoolValue(0);
   props.globals.getNode(engineOutTree ~ "started").setBoolValue(1);
   props.globals.getNode(engineOutTree ~ "running").setBoolValue(1);
   }
  else
   {
   props.globals.getNode(engineOutTree ~ "running").setBoolValue(0);
   }
  }
 elsif (props.globals.getNode(engineOutTree ~ "running").getBoolValue())
  {
  if (getprop("autopilot/settings/speed") == "speed-to-ga")
   {
   setprop(engineCtlTree ~ "throttle-lever", 1);
   }
  else
   {
   setprop(engineCtlTree ~ "throttle-lever", getprop(engineCtlTree ~ "throttle"));
   }

  setprop(engineOutTree ~ "rpm", getprop(engineOutTree ~ "n1"));
  }

 settimer(func
  {
  engineLoop(engine_no);
  }, 0);
 };
# start the loop 2 seconds after the FDM initializes
setlistener("sim/signals/fdm-initialized", func
 {
 settimer(func
  {
  engineLoop(0);
  engineLoop(1);
  apuLoop();
  }, 2);
 });

# startup/shutdown functions
var startup = func
 {
 setprop("controls/engines/engine[0]/throttle", 0);
 setprop("controls/engines/engine[1]/throttle", 0);
 setprop("controls/APU/off-start-run", 2);
 setprop("engines/APU/rpm", 100);
 setprop("controls/electric/battery-switch", 1);
 setprop("controls/electric/APU-generator", 1);
 setprop("controls/electric/external-power", 1);
 setprop("controls/electric/engine[0]/generator", 1);
 setprop("controls/electric/engine[1]/generator", 1);
    setprop("controls/engines/engine[0]/cutoff", 1);
setprop("consumables/fuel/tank[0]/selected", 1);
setprop("consumables/fuel/tank[2]/selected", 1);
setprop("consumables/fuel/tank[1]/selected", 1);
 setprop("controls/engines/engine[0]/starter", 1);
screen.log.write("APU, APU Generator, Battery, External Power and Engine Starters have been turned on.", 1, 1, 1);

 var engine1listener = setlistener("engines/engine[0]/n2", func
  {
  if (getprop("engines/engine[0]/n2") >= 25.18)
   {
   settimer(func
    {
    setprop("controls/engines/engine[0]/cutoff", 0);
screen.log.write("Engine 1 is starting up...", 1, 1, 1);
    }, 1);
    removelistener(engine1listener);
   }
  }, 0, 0);

 var engine1listener2 = setlistener("engines/engine[0]/n2", func
  {
  if (getprop("engines/engine[0]/n2") >= 60)
   {
   settimer(func
    {
    setprop("controls/engines/engine[0]/starter", 0);
screen.log.write("Engine 1 has been started and is now running.", 1, 1, 1);
screen.log.write("Engine 1 Generator is now supplying power.", 1, 1, 1);
setprop("controls/engines/engine[1]/starter", 1);
    setprop("controls/engines/engine[1]/cutoff", 1);
    }, 1);
    removelistener(engine1listener2);
   }
  }, 0, 0);

 var engine2listener = setlistener("engines/engine[1]/n2", func
  {
  if (getprop("engines/engine[1]/n2") >= 25.18)
   {
   settimer(func
    {
    setprop("controls/engines/engine[1]/cutoff", 0);
screen.log.write("Engine 2 is starting up...", 1, 1, 1);
    }, 1);
    removelistener(engine2listener);
   }
  }, 0, 0);

 var engine2listener2 = setlistener("engines/engine[1]/n2", func
  {
  if (getprop("engines/engine[1]/n2") >= 60)
   {
   settimer(func
    {
    setprop("controls/engines/engine[1]/starter", 0);
screen.log.write("Engine 2 has been started and is now running.", 1, 1, 1);
screen.log.write("Engine 2 Generator is now supplying power.", 1, 1, 1);
    setprop("engines/APU/running", 0);
    setprop("controls/electric/APU-generator", 0);
    setprop("controls/electric/external-power", 0);
    setprop("controls/APU/off-start-run", 0);
    setprop("/services/chocks/nose", 0);
    setprop("/services/chocks/left", 0);
    setprop("/services/chocks/right", 0);
    setprop("/services/fuel-truck/enable", 0);
    setprop("/services/ext-pwr/enable", 0);
    setprop("/services/deicing_truck/enable", 0);
    setprop("/services/catering/enable", 0);
screen.log.write("APU, APU Generator and External Power have been turned off.", 1, 1, 1);
screen.log.write("The aircraft has been started up, you are ready to go :D", 1, 1, 1);
    }, 1);
    removelistener(engine2listener2);
   }
  }, 0, 0);
 };

var shutdown = func
 {
 setprop("controls/electric/engine[0]/generator", 0);
 setprop("controls/electric/engine[1]/generator", 0);
 setprop("controls/engines/engine[0]/cutoff", 1);
 setprop("controls/engines/engine[1]/cutoff", 1);
setprop("consumables/fuel/tank[0]/selected", 0);
setprop("consumables/fuel/tank[2]/selected", 0);
setprop("consumables/fuel/tank[1]/selected", 0);
setprop("/controls/wiper/degrees",0);
 setprop("controls/APU/off-start-run", 0);
screen.log.write("The Aircraft Engines have been shut down.", 1, 1, 1);
 };

# listener to activate these functions accordingly
setlistener("sim/model/start-idling", func(idle)
 {
 var run = idle.getBoolValue();
 if (run)
  {
  startup();
  }
 else
  {
  shutdown();
  }
 }, 0, 0);

## GEAR
#######

# prevent retraction of the landing gear when any of the wheels are compressed
setlistener("controls/gear/gear-down", func
 {
 var down = props.globals.getNode("controls/gear/gear-down").getBoolValue();
 if (!down and (getprop("gear/gear[0]/wow") or getprop("gear/gear[1]/wow") or getprop("gear/gear[2]/wow")))
  {
  props.globals.getNode("controls/gear/gear-down").setBoolValue(1);
  }
 });

# wingflexer bug workaround (written by Andreas Z)
var D_param_0 = getprop('/sim/systems/wingflexer/params/D');
var D_param_1 = 10 * D_param_0;

var disable_wingflexer = func{
    setprop('/sim/systems/wingflexer/params/D',D_param_1);
    var simtime = getprop('/sim/time/elapsed-sec');
    logprint(3,'disable_wingflexer: Set parameter D to '~D_param_1~' at '~simtime~' sec.');
}
var enable_wingflexer = func{
    setprop('/sim/systems/wingflexer/params/D',D_param_0);
    var simtime = getprop('/sim/time/elapsed-sec');
    logprint(3,'enable_wingflexer: Set parameter D to '~D_param_0~' at '~simtime~' sec.');
}
disable_wingflexer();
setlistener("/sim/signals/fdm-initialized",func{
  var todo_when_sim_is_ready = func{
      enable_wingflexer();
  }
  var sim_ready_tmr = maketimer( 14.0, todo_when_sim_is_ready);
  sim_ready_tmr.singleShot = 1;
  sim_ready_tmr.start();
},0,0);

## REPLAY
#######

# disable wingflexer autopilot configuration when in replay

setlistener("sim/replay/replay-state", func(replay_state_node)
 {
  var autopilots = props.globals.getNode("/sim/systems").getChildren("autopilot");
  var autopilot = nil;
  var found = 0;
  
  for (i = 0; i < size(autopilots); i += 1) {

    if (autopilots[i].getChild("name").getValue() == "wing flexer property rule") {
      autopilot = autopilots[i];
      found = 1;
      break;
    }
   }
   
   if (!found) {
     print("wingflexer autopilot not found!");
     return;
   }
   
 
   var wingflexer_enabled = autopilot.getChild('serviceable');
 
   var replay_state = replay_state_node.getIntValue();
 
   if (replay_state == 0 or replay_state == 3)
   { 
     wingflexer_enabled.setBoolValue(1);
   }
   else
   { 
     wingflexer_enabled.setBoolValue(0);
   }
 }, 0, 0);
