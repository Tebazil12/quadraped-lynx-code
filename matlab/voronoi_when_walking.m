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
                'Tracking',false, ...
                'MinThreshold',par(1),...
                'MaxThreshold',par(2), ...
                'MinArea',par(3), ...
                'MaxArea',par(4),...
                'MinCircularity',par(5), ...
                'MinConvexity',par(6), ...
                'MinInertiaRatio',par(7));
            
voronoi = VoronoiTactile('resolution', 900);

folder_name= strcat("H:\git\tactile-core\matlab\demos\voronoi_data\", datestr(now,'yyyy-mm-dd_HHMM'),"_walking\");
mkdir(folder_name)

% start botboarduino conection
robot_serial = serialport("COM4",9600, "Timeout", 30);
pause(1.5); % VERY IMPORTANT PAUSE, does not work without it! Opening serial port takes time.

resp = writeread(robot_serial,"start_pose")
pause(1.5)

t=1;
while 1 %for t = 1:1000
    %%%%%%%%%%%%%%%%%%%
    resp = writeread(robot_serial,"BR_leg_forward")
    pause(1.5);
    
    pins = sensor.record;
    all_pins{t} = pins;
    file_path=  strcat(folder_name,"timestep", num2str(t),"_BR_leg_forward");
    save(file_path, 'all_pins')
    for i = 1:2; [~,imax] = max(rms(squeeze(pins - mean(pins))')); pins(:,imax,:) = []; end % HACK
    voronoi.preproc(pins);
    voronoi.plotVoronoi;
    voronoi.plotSurface;
    t=t+1;
    
    pause(0.5);

    %%%%%%%%%%%%%%%%%%%    
    resp = writeread(robot_serial,"FR_leg_forward")
    pause(1.5);

    pins = sensor.record;
    all_pins{t} = pins;
    file_path=  strcat(folder_name,"timestep", num2str(t),"FR_leg_forward");
    save(file_path, 'all_pins')
    for i = 1:2; [~,imax] = max(rms(squeeze(pins - mean(pins))')); pins(:,imax,:) = []; end % HACK
    voronoi.preproc(pins);
    voronoi.plotVoronoi;
    voronoi.plotSurface;
    t=t+1;
    
    pause(0.5);
    
    %%%%%%%%%%%%%%%%%%%    
    resp = writeread(robot_serial,"FRf_body_forward")

    pause(1.5);
    
    pins = sensor.record;
    all_pins{t} = pins;
    file_path=  strcat(folder_name,"timestep", num2str(t),"FRf_body_forward");
    save(file_path, 'all_pins')
    for i = 1:2; [~,imax] = max(rms(squeeze(pins - mean(pins))')); pins(:,imax,:) = []; end % HACK
    voronoi.preproc(pins);
    voronoi.plotVoronoi;
    voronoi.plotSurface;
    t=t+1;
    pause(0.5);
    
    %%%%%%%%%%%%%%%%%%%
    resp = writeread(robot_serial,"BL_leg_forward")
    pause(1.5);
    
    pins = sensor.record;
    all_pins{t} = pins;
    file_path=  strcat(folder_name,"timestep", num2str(t),"BL_leg_forward");
    save(file_path, 'all_pins')
    for i = 1:2; [~,imax] = max(rms(squeeze(pins - mean(pins))')); pins(:,imax,:) = []; end % HACK
    voronoi.preproc(pins);
    voronoi.plotVoronoi;
    voronoi.plotSurface;
    t=t+1;
    pause(0.5);

    %%%%%%%%%%%%%%%%%%%    
    resp = writeread(robot_serial,"FL_leg_forward")
    pause(1.5);
    
    pins = sensor.record;
    all_pins{t} = pins;
    file_path=  strcat(folder_name,"timestep", num2str(t),"FL_leg_forward");
    save(file_path, 'all_pins')
    for i = 1:2; [~,imax] = max(rms(squeeze(pins - mean(pins))')); pins(:,imax,:) = []; end % HACK
    voronoi.preproc(pins);
    voronoi.plotVoronoi;
    voronoi.plotSurface;
    t=t+1;
    pause(0.5);
    
    %%%%%%%%%%%%%%%%%%%    
    resp = writeread(robot_serial,"FLf_body_forward")
    pause(1.5);
     
    pins = sensor.record;
    all_pins{t} = pins;
    file_path=  strcat(folder_name,"timestep", num2str(t),"FLf_body_forward");
    save(file_path, 'all_pins')
    for i = 1:2; [~,imax] = max(rms(squeeze(pins - mean(pins))')); pins(:,imax,:) = []; end % HACK
    voronoi.preproc(pins);
    voronoi.plotVoronoi;
    voronoi.plotSurface;
    t=t+1;
    pause(0.5);
end
% for t = 1:1000; disp(['t=' num2str(t)])
%         pins = sensor.record;
%         all_pins{t} = pins;
%         file_path=  strcat(folder_name,"timestep", num2str(t));
%         save(file_path, 'all_pins')
%         for i = 1:2; [~,imax] = max(rms(squeeze(pins - mean(pins))')); pins(:,imax,:) = []; end % HACK
%         voronoi.preproc(pins);
%         voronoi.plotVoronoi;
%         voronoi.plotSurface;
% end

pause(1.5);
clearvars robot_serial

delete(sensor); 