% Adapted from tactile-core code (N Lepora April 2018) by Elizabeth Stone

killPython; close all; clear all; clear classes; clear figures; clc; %#ok<CLCLS,CLALL> % dbstop if error

startPyroNameServer

ex = Experiment; % Experiment instance for this experiment
ex.init();

ONLINE = true;% on/offline

%% paths for saving data
if strfind(system_dependent('getos'), 'Linux') == 1
    dirPath = '/home/lizzie/git/tactile-core/matlab/experiments/TacTip-demos/exploration/data';

elseif strfind(system_dependent('getos'), 'Microsoft Windows') == 1
%     dirPath = 'C:\Users\lizzie\Documents\Repos\tactile-core\matlab\experiments\TacTip-demos\exploration\data';
    dirPath = 'C:\Users\ea-stone\Videos\data';

else
    ME = MException('MATLAB:UnknownOperatingSystem', ...
        'Unknown operating system: only windows and linux are supported');
    throw(ME) 
end

%% save basic metadata
fileName = mfilename; 

% create directory
dirTrain = [fileName datestr(now,'yyyy-mm-dd_HHMM')];
mkdir(fullfile(dirPath,dirTrain)); 

% create file of metadata 
info_file = fopen(fullfile(dirPath,dirTrain,'README'),'w');
fprintf(info_file, fullfile(dirPath,dirTrain));
fprintf(info_file, '\r\n');
[~,repo]=system('git config --get remote.origin.url');
fprintf(info_file,'\r\nCurrent git repo: %s' ,repo);
[~,current_head] = system('git rev-parse --short HEAD');
fprintf(info_file,'\r\nCurrent git HEAD: %s' ,current_head);
[~,branches] = system('git branch');
fprintf(info_file,'\r\nCurrent branch:\r\n %s', branches);
fprintf(info_file, '\r\nExperiment Description:\r\n');
fprintf(info_file, '-----------------------\r\n');
fprintf(info_file, 'Walking Robot code online: removed gp smoothing \r\n');
fclose(info_file);

%% turn things on

% startup robot
ex.robot_serial = serialport("COM4",9600, "Timeout", 30);
pause(1.5); % VERY IMPORTANT PAUSE, does not work without it! Opening serial port takes time.

resp = writeread(ex.robot_serial,"start_pose")
pause(1.5);

% startup sensor
sensorParams =[60 ...   % Min_Threshold
                300 ... % Max_Threshold
                100 ...  % Min_Area
                290 ... % Max_Area
                0.3 ...    % Min_Circularity
                0.61 ...   % Min_Convexity
                0.22];     % Min_Inertia_Ratio
ex.sensor = TacTip('Exposure', -6,...
            'Brightness', 225,...
            'Contrast', 225,...
            'Saturation', 0, ...
            'Tracking',true, ...
            'MinThreshold',sensorParams(1),...
            'MaxThreshold',sensorParams(2), ...
            'MinArea',sensorParams(3), ...
            'MaxArea',sensorParams(4),...
            'MinCircularity',sensorParams(5), ...
            'MinConvexity',sensorParams(6), ...
            'MinInertiaRatio',sensorParams(7));



%% load reference tap
load('H:\git\quadraped-lynx-code\ref_taps\ref_tap.mat')
ex.ref_tap = ref_tap;

%TODO make and load still_tap!
load('H:\git\quadraped-lynx-code\ref_taps\still_tap.mat')
% ex.still_tap = still_tap;
ex.still_tap = still_tap*0; %% for some reason dissim profile is upside down with non 0 still_tap

% NB, walking takes one still frame at bottom of tap - need to either
% switch to raw values, or take a neutral frame to do displacements of pins

% % Normalize data, so get distance moved not just relative position
% ex.ref_diffs_norm = ref_tap(: ,:  ,:) - ref_tap(1 ,:  ,:); %normalized, assumes starts on no contact/all start in same position
% 
% % find the frame in ref_diffs_norm with greatest diffs
% [~,an_index] = max(abs(ex.ref_diffs_norm));
% ex.ref_diffs_norm_max_ind = round(mean([an_index(:,:,1) an_index(:,:,2)]));

%% Bootstrap 
[model, current_step] = ex.bootstrap();

%% Main loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

MAX_STEPS = 10;
TOL = 2; % mm, tolerance of on edge/not on edge
MAX_DISP =10;%mm, largest step can take on a predicted distance

for current_step = current_step+1:MAX_STEPS
    disp(strcat("*********Main loop: ", mat2str(current_step)))
    ex.tap_number = 0; % reset on every radius. Tapping adds 1 at start so that rest of logic works with same value
    
    % Do tap
    resp = writeread(ex.robot_serial,"FR_leg_forward")%this is a tap
    pause(1.5); % give time to get there
    ex.tap_number = ex.tap_number +1;
    pins = ex.sensor.record;
    ex.data{current_step}{ex.tap_number} = pins;
    if size(pins,2) ~= 37
        error("New tap is not same size as ref_tap")
    end
    
    % Process pins
    new_tap = ex.process_single_tap(ex.data{current_step}{ex.tap_number});
    
    if ~isequal(size(new_tap), [1 size(ref_tap,2)*2])
        warning("New tap is not the same dimensions as reference tap")
    end
    
    %% predict distance to edge from this tap using gplvm
    new_x = model.predict_singletap(new_tap);
    disp_to_edge = -new_x;
    turn_hips_by = round(disp_to_edge);
    disp(strcat("Predicted disp. is: ", mat2str(new_x)))
    
    % Check model prediction is reasonable (don't move ridiculously large
    % distances)
    if abs(disp_to_edge) < MAX_DISP
        
        % move distance predicted 
        if disp_to_edge < 0 
            command_to_send = "-";
        else
            command_to_send = "+";
        end

        if disp_to_edge <10 && disp_to_edge >-10
            command_to_send = strcat(command_to_send, "0");
        end

        command_to_send = strcat(command_to_send, int2str(abs(disp_to_edge)), "_FR_rotateHip")

        % Do tap
        resp = writeread(ex.robot_serial,command_to_send)%this is a tap
        pause(3); % give time to get there
        ex.tap_number = ex.tap_number +1;
        pins = ex.sensor.record;
        ex.data{current_step}{ex.tap_number} = pins;
        if size(pins,2) ~= 37
            error("New tap is not same size as ref_tap")
        end
        
        new_tap2 = ex.process_single_tap(ex.data{current_step}{ex.tap_number});

        if ~isequal(size(new_tap2), [1 size(ref_tap,2)*2])
            warning("New tap2 is not the same dimensions as reference tap")
        end

        % predict distance to edge from this tap using gplvm
        new_x2 = model.predict_singletap(new_tap2);
        disp_to_edge = -new_x2; %NB this overwrites previous tap var
        disp(strcat("Predicted disp. is: ", mat2str(new_x2)))
    %else
        % just carry on, distance will be greater than tol :. triggering line
        % collection
    end
    
    if abs(disp_to_edge) > TOL % prediction was wrong, collect more data
        disp("Distance was greater than tol, collecting new line")
        n_useless_taps = ex.tap_number; %so can exlude points later on
        
        % tap along edge
        for disp_from_start = -10:2:10 
            
            % move distance predicted 
            if disp_from_start < 0 
                command_to_send = "-";
            else
                command_to_send = "+";
            end

            if disp_from_start <10 && disp_from_start >-10
                command_to_send = strcat(command_to_send, "0");
            end

            command_to_send = strcat(command_to_send, int2str(abs(disp_from_start)), "_FR_rotateHip")

            % Do tap
            resp = writeread(ex.robot_serial,command_to_send)%this is a tap
            pause(3); % give time to get there
            ex.tap_number = ex.tap_number +1;
            pins = ex.sensor.record;
            ex.data{current_step}{ex.tap_number} = pins;
        end
        
        % calc dissim, align to 0 (edge)
        [dissims, ys_for_real] = ex.process_taps(ex.data{current_step});
        xs_default = [-10:2:10]';
        x_min  = ex.radius_diss_shift(dissims(n_useless_taps+1:end), xs_default);

        xs_current_step = xs_default + x_min; % so all minima are aligned
        
        %error check, see if minima was actually in range (ie end points arent minima, but somewhere in middle)
        [~,min_i] = min(dissims(n_useless_taps+1:end));
        if  min_i== 1 || min_i == length(dissims(n_useless_taps+1:end))
            warning("Minimum diss was at far end, actual minima probably not found, model may be bad")
        end
        
        % predict mu, add to model
        model.add_a_radius(ys_for_real(n_useless_taps+1:end,:), xs_current_step)
        
        % rotate hips by x_min in next phases of walking
        turn_hips_by = round(-x_min);
        
        
    else %(distance to edge <= tol)
        disp("Distance was good, moving on") 
        
    end
    
    % save data to file each loop
    save(fullfile(dirPath,dirTrain,mat2str(current_step)), 'ex')
    
    if abs(turn_hips_by) < TOL % not worth time & energy twisting if less than 2
        start_hip_rotation_command = "+00";
        start_hip_antirotation_command= "+00";
    else
        if turn_hips_by < 0 
            start_hip_rotation_command = "-";
            start_hip_antirotation_command = "+";
        else
            start_hip_rotation_command = "+";
            start_hip_antirotation_command = "-";
        end

        if turn_hips_by <10 && turn_hips_by >-10
            start_hip_rotation_command = strcat(start_hip_rotation_command, "0");
            start_hip_antirotation_command = strcat(start_hip_antirotation_command, "0");
        end

        start_hip_rotation_command = strcat(start_hip_rotation_command, int2str(abs(turn_hips_by)))
        start_hip_antirotation_command = strcat(start_hip_antirotation_command, int2str(abs(turn_hips_by)));

    end
    % next walking steps ...
%     resp = writeread(ex.robot_serial,"FR_leg_side")
%     pause(1.5);
    
    command_to_send = strcat(start_hip_antirotation_command, "_BLm_rotateHip");
    resp = writeread(ex.robot_serial,command_to_send)
    pause(3);
    
    command_to_send = strcat(start_hip_antirotation_command, "_BR_rotateHip");
    resp = writeread(ex.robot_serial,command_to_send)
    pause(3);
    
    command_to_send = strcat(start_hip_antirotation_command, "_FLm_rotateHip");
    resp = writeread(ex.robot_serial,command_to_send)
    pause(3);
    
    resp = writeread(ex.robot_serial,"FR_leg_forward_tap") % this has to be here as turning for tapping needs to happen in forward pose, so can't move from side to back in hip twist
    pause(1.5);

    resp = writeread(ex.robot_serial,"FRf_body_forward")
    pause(1.5);
    
    resp = writeread(ex.robot_serial,"BL_leg_forward")
    pause(1.5);

    command_to_send = strcat(start_hip_rotation_command, "_BLs_rotateHip");
    resp = writeread(ex.robot_serial,command_to_send)
    pause(1.5);
    
    resp = writeread(ex.robot_serial,"FL_leg_forward")
    pause(1.5);
    
    command_to_send = strcat(start_hip_rotation_command, "_FLe_rotateHip");
    resp = writeread(ex.robot_serial,command_to_send)
    pause(1.5);
    
    resp = writeread(ex.robot_serial,"FLf_body_forward")
    pause(1.5);
    
    resp = writeread(ex.robot_serial,"BR_leg_forward")
    pause(1.5);
    
end %main loop

disp("Main done, saving and closing")

% save all data
save(fullfile(dirPath,dirTrain,'all_data'))

% close everything
clearvars ex.robot_serial

delete(ex.sensor); 

disp("All done.")