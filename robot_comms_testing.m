robot_serial = serialport("/dev/ttyUSB0",9600);

pause(1);

write(robot_serial,"hello","string");

% pause(0);

readline(robot_serial)

% delete(robot_serial)
clearvars robot_serial