robot_serial = serialport("COM4",9600, "Timeout", 30);
pause(1.5); % VERY IMPORTANT PAUSE, does not work without it! Opening serial port takes time.

resp = writeread(robot_serial,"start_pose")
pause(1.5)

while 1
    resp = writeread(robot_serial,"FR_leg_forward_tap")
    pause(3);

    resp = writeread(robot_serial,"-40_FR_rotateHip")%xx_BR_rotateHip

    pause(3);
    
    resp = writeread(robot_serial,"+00_FR_rotateHip")%xx_BR_rotateHip

    pause(3);

end
pause(1.5);
clearvars robot_serial