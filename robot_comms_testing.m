robot_serial = serialport("COM4",9600, "Timeout", 30);
pause(1.5); % VERY IMPORTANT PAUSE, does not work without it! Opening serial port takes time.

resp = writeread(robot_serial,"start_pose")
pause(1.5)

while 1
    resp = writeread(robot_serial,"BR_leg_forward")
    pause(1.5);

    resp = writeread(robot_serial,"FR_leg_forward")
    pause(1.5);

    resp = writeread(robot_serial,"FRf_body_forward")

    pause(1.5);
    resp = writeread(robot_serial,"BL_leg_forward")
    pause(1.5);
    resp = writeread(robot_serial,"FL_leg_forward")
    pause(1.5);
    resp = writeread(robot_serial,"FLf_body_forward")
end
pause(1.5);
clearvars robot_serial