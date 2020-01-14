robot_serial = serialport("/dev/ttyUSB0",9600, "Timeout", 30);

pause(1.5); % VERY IMPORTANT PAUSE, does not work without it! Opening serial port takes time.

% while 1
resp = writeread(robot_serial,"BR_leg_forward")

resp = writeread(robot_serial,"FR_leg_forward")

resp = writeread(robot_serial,"FRf_body_forward")

resp = writeread(robot_serial,"BL_leg_forward")

resp = writeread(robot_serial,"FL_leg_forward")

resp = writeread(robot_serial,"FLf_body_forward")
% end

clearvars robot_serial