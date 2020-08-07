var doors =
 {
 new: func(name, transit_time)
  {
  doors[name] = aircraft.door.new("sim/model/door-positions/" ~ name, transit_time);
  },
 toggle: func(name)
  {
  doors[name].toggle();
  },
 open: func(name)
  {
  doors[name].open();
  },
 close: func(name)
  {
  doors[name].close();
  },
 setpos: func(name, value)
  {
  doors[name].setpos(value);
  }
 };
doors.new("l1", 5);
doors.new("l2", 5);
doors.new("r1", 5);
doors.new("r2", 5);
doors.new("cam_menu", 0.5);
doors.new("cater_pos", 30);
doors.new("cargo", 10);
