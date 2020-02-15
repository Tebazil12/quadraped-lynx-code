% Adapted from tactile-core code (N Lepora April 2018) by Elizabeth Stone

killPython; close all; clear all; clear classes; clear figures; clc; %#ok<CLCLS,CLALL> % dbstop if error
    
ex = Experiment; % Experiment instance for this experiment
ex.init();

ONLINE = true;% on/offline

VIDEO_ON = true;% video output
if VIDEO_ON; videos = [ "Data" ]; end %#ok<NBRAK> % "Voronoi" "Offline"

% paths for saving data
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

%% init experiment parameters

% set robot parameters
Expt.actionTraj = [0 0 5 0 0 0; 0 0 0 0 0 0]; % tap move trajectory wrt tool/sensor frame
Expt.robotSpeed = [25 15 15 10];%2*[50 30 15 10];
Expt.workFrame = [326-5 -272 68-15-2 180 0 180];%[475 180 69 180 0 180]; % board 2 ABB1 % specify work frame wrt base frame (x,y,z,r,p,y) %find using abb jogger
% the workframe should be at the object edge with the greatest x component
% as ref tap is taken here

% tactip calibration
Expt.sensorParams = [119.18 232.37 54.66 129.47 0.46 0.47 0.28]; % min_threshold max_threshold min_area max_area min_circularity min_convexity min_inertia_ratio

if VIDEO_ON;Expt.videos = videos; Expt.resolution = 400;end

%% startup everything
fileName = mfilename; 

% create directory
if ONLINE
    dirTrain = [fileName datestr(now,'yyyy-mm-dd_HHMM')];
    mkdir(fullfile(dirPath,dirTrain)); 
end

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
fprintf(info_file, 'Robot code online: step5, collect data at-10:10,banana\r\n');
fclose(info_file);


% startup robot
if ONLINE; robotArm = ABBRobotArm; end
robotArm.setSpeed(Expt.robotSpeed)

% startup sensor
if ONLINE && isfield(Expt,'sensorParams') 
    par = Expt.sensorParams;
    sensor = TacTip('min_threshold',par(1),...
                    'max_threshold',par(2),...
                    'min_area',par(3),...
                    'max_area',par(4),...
                    'min_circularity',par(5),...
                    'min_convexity',par(6),...
                    'min_inertia_ratio',par(7));
end

ex.robot = TactileActionRobot(robotArm, sensor, Expt.workFrame, Expt.actionTraj);

% detect and choose pins
rad = 300; mdist = 0;
if ONLINE; Expt.pinPositions = ex.robot.initPinPositions(rad,mdist); end

[Expt.nPins, Expt.nDims] = size(Expt.pinPositions);

% startup camera
ex.camera = Camera(Expt);
ex.camera.initialize(dirPath, dirTrain, [], [])

% startup video
video = Video(Expt);

% startup model
tactile = TactileData(Expt);

%% collect reference tap
COLLECT_NEW_REFTAP = true;

% Define/load reference tap
if COLLECT_NEW_REFTAP
    %location of edge
    ex.robot.move([0 0 0 0 0 0])
    tacData = ex.robot.recordAction; 
    ref_tap = tacData;
    
    % save point in file for future use
    save(fullfile(dirPath,dirTrain,"ref_tap"), 'ref_tap')
else
    load('/home/lizzie/git/masters-tactile/blah.mat') %TODO file structure, where file should go & windows v linux
%     ref_tap = ref_tap;
end

% Normalize data, so get distance moved not just relative position
ex.ref_diffs_norm = ref_tap(: ,:  ,:) - ref_tap(1 ,:  ,:); %normalized, assumes starts on no contact/all start in same position

% find the frame in ref_diffs_norm with greatest diffs
[~,an_index] = max(abs(ex.ref_diffs_norm));
ex.ref_diffs_norm_max_ind = round(mean([an_index(:,:,1) an_index(:,:,2)]));

%% Bootstrap 
[model, current_step] = ex.bootstrap();

%% Main loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

MAX_STEPS = 90;
STEP_LENGTH = 5;%mm, 
TOL = 2; % mm, tolerance of on edge/not on edge
MAX_DISP =15;%mm, largest step can take on a predicted distance

for current_step = current_step+1:MAX_STEPS % (&& not returned to begining location - checked at end of while loop)
    disp(strcat("*********Main loop: ", mat2str(current_step)))
    ex.tap_number = 0; % reset on every radius. Tapping adds 1 at start so that rest of logic works with same value
    
    % Extrapolate previous two dissim points, move along this by step size
    % and rotate tactip
    if size(ex.dissim_locations,1) == 0
        error("ex.dissim_locations is empty, bootstrap failed?")
    elseif size(ex.dissim_locations,1) == 1
        if current_step ~= 2
            error("ex.dissim_locations is only 1 long but current step is not 2")
        end
        new_theta = ex.current_rotation;
%         new_theta_tan = ex.current_rotation;
    else
        step = ex.dissim_locations(end,:) - ex.dissim_locations(end-1,:);
        new_theta = -atan2d(step(1),step(2)); %(Y,X), x =1,y=2
    end
    new_test_point = ex.dissim_locations(end,:) + STEP_LENGTH*[sind(-new_theta)...
                                                               cosd(-new_theta)];
    actual_step_length= pdist2(ex.dissim_locations(end,:),new_test_point);
    if round(actual_step_length,3) ~= STEP_LENGTH
        actual_step_length %#ok<NOPTS>
        warning("Distance is not step length") 
    end
                                                           
    if new_theta < -180
        new_theta = new_theta +360;
    end
    ex.move_and_tap([new_test_point new_theta],current_step); %hereafter, ex.current_rotation == current_theta
    new_tap = ex.process_single_tap(ex.data{current_step}{ex.tap_number});
    
    if ~isequal(size(new_tap), [1 size(ref_tap,2)*2])
        warning("New tap is not the same dimensions as reference tap")
    end
    
    %% predict distance to edge from this tap using gplvm
    new_x = model.predict_singletap(new_tap);
    disp_to_edge = -new_x;
    disp(strcat("Predicted disp. is: ", mat2str(new_x)))
    
    % Check model prediction is reasonable (don't move ridiculously large
    % distances)
    if abs(disp_to_edge) < MAX_DISP
        % move distance predicted 
        new_test_point2 = new_test_point + disp_to_edge*[cosd(ex.current_rotation)...
                                                         sind(ex.current_rotation)];
        ex.move_and_tap([new_test_point2 ex.current_rotation],current_step);
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
        for disp_from_start = -10:10 
            temp_point = new_test_point + disp_from_start*[cosd(ex.current_rotation)...
                                                           sind(ex.current_rotation)];
            ex.move_and_tap([temp_point ex.current_rotation],current_step);
        end
        
        % calc dissim, align to 0 (edge)
        [dissims, ys_for_real] = ex.process_taps(ex.data{current_step});
        xs_default = [-10:10]';
        x_min  = ex.radius_diss_shift(dissims(n_useless_taps+1:end), xs_default);

        xs_current_step = xs_default + x_min; % so all minima are aligned
        
        %error check, see if minima was actually in range (ie end points arent minima, but somewhere in middle)
        [~,min_i] = min(dissims(n_useless_taps+1:end));
        if  min_i== 1 || min_i == length(dissims(n_useless_taps+1:end))
            warning("Minimum diss was at far end, actual minima probably not found, model may be bad")
        end
        
        new_dissim_loc = new_test_point - x_min*[cosd(ex.current_rotation)...
                                                 sind(ex.current_rotation)];
                                             
        % location closest to 0 dissim is point for next extrapolation
        ex.dissim_locations = [ex.dissim_locations; new_dissim_loc]; 
        
        % predict mu, add to model (TODO, do we repredict mu's for all
        % previous lines or just add new line?)
        model.add_a_radius(ys_for_real(n_useless_taps+1:end,:), xs_current_step)
        
        %TODO do hyper pars need re-optimizing? i.e. after first
        %line/couple of lines?
        
    else %(distance to edge <= tol)
        disp("Distance was good, moving on")
        % save this location for next extrapolation
        ex.dissim_locations = [ex.dissim_locations; new_test_point2]; 
    end
    
    % comment out this graph to make things run a little faster
    figure(1)
    plot(ex.dissim_locations(:,1),ex.dissim_locations(:,2),'+')
    
    figure(2)
    clf
    hold on
    for a= 1:size(ex.actual_locations,2)
        for b = 1:size(ex.actual_locations{a},2)
            if mod(a,3) == 0 
                plot(ex.actual_locations{a}{b}(1),ex.actual_locations{a}{b}(2),'b+')
            elseif mod(a,3) == 1 
                plot(ex.actual_locations{a}{b}(1),ex.actual_locations{a}{b}(2),'r+')
            elseif mod(a,3) == 2 
                plot(ex.actual_locations{a}{b}(1),ex.actual_locations{a}{b}(2),'g+')
            end
    %         pause(1)
        end
    end
    r = 53;
    % --- https://uk.mathworks.com/matlabcentral/answers/3058-plotting-circles 
    ang=0:0.01:2*pi; 
    x=-53+r*cos(ang);
    y=r*sin(ang);
    plot(x,y);
    %---%
    plot(ex.dissim_locations(:,1),ex.dissim_locations(:,2),'o')
    plot(ex.dissim_locations(:,1),ex.dissim_locations(:,2))
    axis equal
    hold off
    
    % save data to file each loop
    save(fullfile(dirPath,dirTrain,mat2str(current_step)), 'ex') %TODO is this too much info in one file? loading might overwrite lots of vars...
    
    % back at start location?, break if so (only check after 2nd point)
    if pdist2(ex.dissim_locations(1,:), ex.dissim_locations(end,:)) < STEP_LENGTH && current_step > 2
        disp("Distance to start point is less than step length, breaking loop")
        break
    end
end %main loop

disp("Main done, saving and closing")
% save all data
save(fullfile(dirPath,dirTrain,'all_data'))

%TODO? display gplvm model graph

% commonShutdown (from tactile core utils) - adapted to use ex. instance
ex.robot.move(zeros(1, 6));
ex.robot.setWorkFrame([400, 0, 300, 180, 0, 180]);
ex.robot.move(zeros(1, 6));
delete(sensor); 
delete(robotArm);
delete(ex.robot);
disp("All done.")