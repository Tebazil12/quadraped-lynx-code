robot_serial = serialport("COM4",9600, "Timeout", 30);
pause(1.5); % VERY IMPORTANT PAUSE, does not work without it! Opening serial port takes time.

resp = writeread(robot_serial,"start_pose")
pause(1.5)

while 1
    resp = writeread(robot_serial,"BR_leg_forward")
    pause(1.5);
    
    %%%% tap and adjust %%%%
    resp = writeread(robot_serial,"FR_leg_forward")%this is a tap
    pause(1.5);
    resp = writeread(robot_serial,"-05_FR_rotateHip")
    pause(3);
    
    resp = writeread(robot_serial,"FR_leg_side")
    pause(1.5);
    
    resp = writeread(robot_serial,"+05_BLm_rotateHip")% in middle pose
    pause(3);
    
    resp = writeread(robot_serial,"+05_BR_rotateHip")% in side pose
    pause(3);
    
    resp = writeread(robot_serial,"+05_FLm_rotateHip")% in middle pose
    pause(3);
    
    resp = writeread(robot_serial,"FR_leg_forward") % this has to be here as turning for tapping needs to happen in forward pose, so can't move from side to back in hip twist
    pause(1.5);
%     resp = writeread(robot_serial,"-05_FR_rotateHip")%in extended pose
%     pause(3);
    
%     resp = writeread(robot_serial,"-05_allf_rotateHip")% in middle pose
    pause(3);
    
    %%%%%%%%%%

    resp = writeread(robot_serial,"FRf_body_forward")

    pause(1.5);
    resp = writeread(robot_serial,"BL_leg_forward")
    pause(1.5);
    resp = writeread(robot_serial,"-05_BLs_rotateHip")
    pause(1.5);
    resp = writeread(robot_serial,"FL_leg_forward")
    pause(1.5);
    resp = writeread(robot_serial,"-05_FLe_rotateHip")
    pause(1.5);
    resp = writeread(robot_serial,"FLf_body_forward")

end
pause(1.5);
clearvars robot_serial