load('H:\git\tactile-core\matlab\demos\voronoi_data\2020-02-12_1407_walking\timestep23FL_leg_forward')
clf
% there are 6 poses, so compare repeatability in each pose

for i = 1:6
%     figure(i)
    subplot(2,3,i);
    for movement = [i i+6 i+12 i+18]
        if movement>23
            break;
        end
        scatter(all_pins{movement}(:,:,1), all_pins{movement}(:,:,2))
        hold on
    end
    hold off
    daspect([1 1 1])
    axis([100 600 0 500])
    legend 
end
