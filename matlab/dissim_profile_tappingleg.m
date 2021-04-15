% ex = Experiment; % Experiment instance for this experiment
% ex.init();

% load('H:\git\quadraped-lynx-code\ref_taps\ref_tap_edge.mat')
% ex.ref_tap = ref_tap;
% 
% %TODO make and load still_tap!
% load('H:\git\quadraped-lynx-code\ref_taps\still_tap.mat')
% ex.still_tap = still_tap*0;

% load('C:\Users\ea-stone\Videos\walking_data\tapping-edge-20\2020-02-16_1216_tappingonbeam20\timestep41_tapping_edge')

[dissims, ys_for_real] = ex.process_taps(ex.data{2});
xs_default = [-15:15]';

plot([1; 2; xs_default],dissims)
hold on

x_min  = ex.radius_diss_shift(dissims(3:end), xs_default)
hold off