robot_serial = serialport("/dev/ttyUSB0",9600);
% slCharacterEncoding('UTF-8')
% configureTerminator(robot_serial,"CR/LF")

pause(1);

thingy = 'hello'

pause(0.5); % VERY IMPORTANT PAUSE, does not work without it!


resp = writeread(robot_serial,thingy)

% pause(5);


% writeline(robot_serial,string(thingy));
% 
% % pause(0);
% 
readline(robot_serial)

% pause(5);

readline(robot_serial)
% pause(5);

% readline(robot_serial)
% readline(robot_serial)

% delete(robot_serial)
clearvars robot_serial