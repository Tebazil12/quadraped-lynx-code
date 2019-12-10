robot_serial = serialport("/dev/ttyUSB0",9600, "Timeout", 30);

pause(1.5); % VERY IMPORTANT PAUSE, does not work without it! Opening serial port takes time.

while 1
resp = writeread(robot_serial,"Pose 01")

resp = writeread(robot_serial,"Pose 02")

resp = writeread(robot_serial,"Pose 03")

resp = writeread(robot_serial,"Pose 04")

resp = writeread(robot_serial,"Pose 05")

resp = writeread(robot_serial,"Pose 06")
end

clearvars robot_serial