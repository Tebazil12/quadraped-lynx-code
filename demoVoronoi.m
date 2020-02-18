killPython; startPyroNameServer
clear all; close all; clc; %dbstop if error

% original tactip
% sensor = TacTip('Tracking',false,'Min_Area',90,'Max_Area',200,'Min_Threshold',5,'Max_Threshold',100);

% tacwhisker
% sensor = TacTip('Tracking',false,'Min_Area',500,'Max_Area',2000,'Min_Threshold',5,'Max_Threshold',200); 

% improved tactip
% par = [88.67 200.51 43.96 155.97 0.56 0.39 0.24]; % Min_Threshold Max_Threshold Min_Area Max_Area Min_Circularity Min_Convexity Min_Inertia_Ratio
% par = [68.88 231.91 24.66 119.00 0.44 0.58 0.29]; % Min_Threshold Max_Threshold Min_Area Max_Area Min_Circularity Min_Convexity Min_Inertia_Ratio
% par = [70.85...   % Min_Threshold
%        280.06 ... % Max_Threshold
%        59.74 ...  % Min_Area
%        190.78 ... % Max_Area
%        0.3 ...    % Min_Circularity
%        0.61 ...   % Min_Convexity
%        0.22];     % Min_Inertia_Ratio
par = [60 ...   % Min_Threshold
       300 ... % Max_Threshold
       100 ...  % Min_Area
       290 ... % Max_Area
       0.3 ...    % Min_Circularity
       0.61 ...   % Min_Convexity
       0.22];     % Min_Inertia_Ratio
   
% sensor = TacTip('Exposure', -6,...
%                 'Brightness', 150,...
%                 'Contrast', 10,...
%                 'Saturation', 0, ...
%                 'Tracking',false, ...
%                 'MinThreshold',par(1),...
%                 'MaxThreshold',par(2), ...
%                 'MinArea',par(3), ...
%                 'MaxArea',par(4),...
%                 'MinCircularity',par(5), ...
%                 'MinConvexity',par(6), ...
%                 'MinInertiaRatio',par(7));
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

folder_name= strcat("H:\git\tactile-core\matlab\demos\voronoi_data\", datestr(now,'yyyy-mm-dd_HHMM'),"\");
mkdir(folder_name)
for t = 1:1000; disp(['t=' num2str(t)])
        pins = sensor.record;
        all_pins{t} = pins;
        file_path=  strcat(folder_name,"timestep", num2str(t));
        save(file_path, 'all_pins')
        for i = 1:2; [~,imax] = max(rms(squeeze(pins - mean(pins))')); pins(:,imax,:) = []; end % HACK
        voronoi.preproc(pins);
        voronoi.plotVoronoi;
        voronoi.plotSurface;
end


delete(sensor); 