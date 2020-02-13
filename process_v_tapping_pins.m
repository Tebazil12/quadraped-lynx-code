load('H:\git\tactile-core\matlab\demos\voronoi_data\2020-02-13_1816_tapping\timestep21_tapping_edge')
clf
% there are 6 poses, so compare repeatability in each pose

% for i = 1:6
% %     figure(i)
%     subplot(2,3,i);
    for movement = 1:21
        if movement>21
            break;
        end
        scatter(all_pins{movement}(:,:,1), all_pins{movement}(:,:,2))
        hold on
    end
    hold off
    daspect([1 1 1])
    axis([100 600 0 500])
    legend 
% end
