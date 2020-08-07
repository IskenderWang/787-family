var sysinfo = {
	
	log_msg : func(system_msg, type) {
	
		# Message Logging System
		
		## Move all messages down and get the system_msg on the top
		
		for (var n = (getprop("/instrumentation/sysinfo/max") - 1); n >= 0; n = n - 1) {
		
			setprop("/instrumentation/sysinfo/msg[" ~ (n + 1) ~ "]/message", getprop("/instrumentation/sysinfo/msg[" ~ n ~ "]/message"));
			
			setprop("/instrumentation/sysinfo/msg[" ~ (n + 1) ~ "]/type", getprop("/instrumentation/sysinfo/msg[" ~ n ~ "]/type"));
			
			setprop("/instrumentation/sysinfo/msg[" ~ (n + 1) ~ "]/attend", getprop("/instrumentation/sysinfo/msg[" ~ n ~ "]/attend"));
		
		}
		
		## Increment MAX Value
		
		setprop("/instrumentation/sysinfo/max", getprop("/instrumentation/sysinfo/max") + 1);
		
		## Set new message to top level
		
		setprop("/instrumentation/sysinfo/msg/message", getprop("/sim/time/gmt-string") ~ " UTC : " ~ system_msg);
		setprop("/instrumentation/sysinfo/message", system_msg);
		setprop("/instrumentation/sysinfo/msg/type", type);
		
		if ((type == 1) or (type == 2)) {
			setprop("/instrumentation/sysinfo/warning", system_msg);
			setprop("/instrumentation/sysinfo/msg/attend", 1);
		} else {
			setprop("/instrumentation/sysinfo/msg/attend", 0);
		}
			
#		if (type == 0)
#			print("System Message : " ~ system_msg);
#		elsif (type == 2)
#			print("System Warning : " ~ system_msg);
#		else
#			print("System Caution : " ~ system_msg);
			
		# Update Display
		
		me.update_display();
	
	},
	
	update_display : func() {
	
		var first = getprop("/instrumentation/sysinfo/first");
	
		for (var n = first; n < (first + 20); n += 1) {
		
			if (getprop("/instrumentation/sysinfo/msg[" ~ n ~ "]/message") != nil) {
			
				setprop("/instrumentation/sysinfo/disp[" ~ (n - first) ~ "]/message", getprop("/instrumentation/sysinfo/msg[" ~ n ~ "]/message"));
				
				setprop("/instrumentation/sysinfo/disp[" ~ (n - first) ~ "]/type", getprop("/instrumentation/sysinfo/msg[" ~ n ~ "]/type"));
				
				setprop("/instrumentation/sysinfo/disp[" ~ (n - first) ~ "]/attend", getprop("/instrumentation/sysinfo/msg[" ~ n ~ "]/attend"));
			
			}
		
		}
		
		# Check for unattended stuff below
			
			var unattended = 0;
			
			for (var n = (first + 19); n < 999; n += 1) {
			
				if (getprop("/instrumentation/sysinfo/msg[" ~ n ~ "]/message") != nil) {
				
					if (getprop("/instrumentation/sysinfo/msg[" ~ n ~ "]/attend") == 1)
						unattended = 1;
				
				}
			
			}
		
		setprop("/instrumentation/sysinfo/unattended", unattended);
	
	},
	
	attend : func(disp) {
	
		var first = getprop("/instrumentation/sysinfo/first");
		
		setprop("/instrumentation/sysinfo/msg[" ~ (first + disp) ~ "]/attend", 0);
		
		me.update_display();
	
	},
	
	print_log : func() {
	
		me.log_msg("[SYS] System Log Printed", 0);
		
		print("");
	
		print("======================= Boeing 787-8 System Log =======================");
		
		print("");
		
		print("ACTIVE WARNING : " ~ getprop("/instrumentation/sysinfo/warning"));
		print("ACTIVE MESSAGE : " ~ getprop("/instrumentation/sysinfo/message"));
		
		print("");
		
		print("System Log History:");
		
		print("");
		
		for (var n = 0; n < getprop("/instrumentation/sysinfo/max"); n += 1) {
		
			var type = getprop("/instrumentation/sysinfo/msg[" ~ n ~ "]/type");
			
			var msg = getprop("/instrumentation/sysinfo/msg[" ~ n ~ "]/message");
			
			if (type == 0)
				print("MSG : " ~ msg);
			elsif (type == 2)
				print("WRN : " ~ msg);
			else
				print("CAU : " ~ msg);
		
		}
		
		print("");
		
		print("=======================================================================");
	}
};
