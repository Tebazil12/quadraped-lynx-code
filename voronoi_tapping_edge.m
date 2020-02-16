killPython; startPyroNameServer
clear all; close all; clc; %dbstop if error

par = [60 ...   % Min_Threshold
       300 ... % Max_Threshold
       100 ...  % Min_Area
       290 ... % Max_Area
       0.3 ...    % Min_Circularity
       0.61 ...   % Min_Convexity
       0.22];     % Min_Inertia_Ratio
   

sensor = TacTip('Exposure', -6,...
                'Brightness', 225,...
                'Contrast', 225,...
                'Saturation', 0, ...
                'Tracking',true, ...
                'MinThreshold',par(1),...
                'MaxThreshold',par(2), ...
                'MinArea',par(3), ...
                'MaxArea',par(4),...
                'MinCircularity',par(5), ...
                'MinConvexity',par(6), ...
                'MinInertiaRatio',par(7));
            
voronoi = VoronoiTactile('resolution', 900);

folder_name= strcat("H:\git\tactile-core\matlab\demos\voronoi_data\", datestr(now,'yyyy-mm-dd_HHMM'),"_tappingonbeam20\");
mkdir(folder_name)

robot_serial = serialport("COM4",9600, "Timeout", 30);
pause(1.5); % VERY IMPORTANT PAUSE, does not work without it! Opening serial port takes time.

resp = writeread(robot_serial,"start_pose")
pause(10)

t=1;
for angle_of_collection = -20:20
    if angle_of_collection < 0 
        command_to_send = "-";
    else
        command_to_send = "+";
    end
    
    if angle_of_collection <10 && angle_of_collection >-10
        command_to_send = strcat(command_to_send, "0");
    end
    
    command_to_send = strcat(command_to_send, int2str(abs(angle_of_collection)), "_FR_rotateHip")
    
    
    resp = writeread(robot_serial,command_to_send)%xx_BR_rotateHip
    pause(1.5);
    
    %%%% Record tap %%%%
    pins = sensor.record;
    all_pins{t} = pins;
    file_path=  strcat(folder_name,"timestep", num2str(t),"_tapping_edge");
    save(file_path, 'all_pins')
    for i = 1:2; [~,imax] = max(rms(squeeze(pins - mean(pins))')); pins(:,imax,:) = []; end % HACK
    voronoi.preproc(pins);
    voronoi.plotVoronoi;
    voronoi.plotSurface;
    t=t+1;
    
    pause(0.5);
    %%%%%%%%
    

end
pause(1.5);
clearvars robot_serial

save(fullfile(folder_name,'all_data'))