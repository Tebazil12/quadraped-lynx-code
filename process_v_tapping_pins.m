load('C:\Users\ea-stone\Videos\walking_data\tapping-edge-20\2020-02-16_1216_tappingonbeam20\timestep41_tapping_edge')
clf
% there are 6 poses, so compare repeatability in each pose

%2 and 26 will be still and ref taps respectively

% for i = 1:6
% %     figure(i)
%     subplot(2,3,i);
all_x = [];
all_y =[];
    for movement = 1:41
        if movement>41
            break;
        end
        if sum(movement == [26 27])
            figure(1)
            hold on
            plot(all_pins{movement}(:,:,1), all_pins{movement}(:,:,2))
            scatter(all_pins{movement}(:,:,1), all_pins{movement}(:,:,2))
        end
        if sum(movement == [1 2 3])
            figure(3)
            scatter(all_pins{movement}(:,:,1), all_pins{movement}(:,:,2))
        end
        all_x = [all_x; all_pins{movement}(:,:,1)];
        all_y = [all_y; all_pins{movement}(:,:,2)];
        hold on
    end
%     plot(all_x,all_y);
    
    for pin_num = 1:37
        figure(2)
        plot(all_x(:,pin_num),all_y(:,pin_num),"+-");
        hold on
    end
    hold off
    daspect([1 1 1])
    axis([100 600 0 500])
    legend 
    
    figure(1)
    hold off
    daspect([1 1 1])
    axis([100 600 0 500])
    legend 
    
    figure(3)
    hold off
    daspect([1 1 1])
    axis([100 600 0 500])
    legend 
% end
