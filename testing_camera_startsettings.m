killPython; close all; clear all; clear classes; clear figures; clc; %#ok<CLCLS,CLALL> % dbstop if error

startPyroNameServer


sensorParams =[60 ...   % Min_Threshold
                300 ... % Max_Threshold
                100 ...  % Min_Area
                320 ... % Max_Area
                0.3 ...    % Min_Circularity
                0.61 ...   % Min_Convexity
                0.22];     % Min_Inertia_Ratio
sensor = TacTip('Exposure', -6,...
            'Brightness', 255,...
            'Contrast', 255,...
            'Saturation', 0, ...
            'Tracking',true, ...
            'MinThreshold',sensorParams(1),...
            'MaxThreshold',sensorParams(2), ...
            'MinArea',sensorParams(3), ...
            'MaxArea',sensorParams(4),...
            'MinCircularity',sensorParams(5), ...
            'MinConvexity',sensorParams(6), ...
            'MinInertiaRatio',sensorParams(7),...
            'maxTrackingMove', 100);
        
pins = sensor.record        