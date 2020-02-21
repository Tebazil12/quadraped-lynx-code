robot_serial = serialport("COM4",9600, "Timeout", 30);
pause(1.5); % VERY IMPORTANT PAUSE, does not work without it! Opening serial port takes time.

resp = writeread(robot_serial,"all_middle")
pause(1.5)

 while 1

    resp = writeread(robot_serial,"all_middle")
    pause(1.5);
    
    resp = writeread(robot_serial,"-20_BL_rotateHip")% in middle pose
    pause(3);

end
pause(1.5);
clearvars robot_serial