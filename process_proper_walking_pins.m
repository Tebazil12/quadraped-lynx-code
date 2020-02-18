load('C:\Users\ea-stone\Videos\data\runrobot_2d_walking_beam2020-02-18_1622\3')
clf
% there are 6 poses, so compare repeatability in each pose
all_x =[];
all_y =[];
for i = 1:size(ex.data,2)
%     figure(i)
    subplot(1,size(ex.data,2),i);
    for movement = 1:size(ex.data{1},2)
        
        scatter(ex.data{i}{movement}(:,:,1), ex.data{i}{movement}(:,:,2))
        hold on
    end
    hold off
    daspect([1 1 1])
    axis([100 600 0 500])
    
    all_x = [all_x; all_pins{movement}(:,:,1)];
    all_y = [all_y; all_pins{movement}(:,:,2)];
%     legend 
end
