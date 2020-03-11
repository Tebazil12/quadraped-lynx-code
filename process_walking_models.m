clear all
load('C:\Users\ea-stone\Documents\ActivePresenter\Untitled18\runrobot_2d_walking_beam2020-02-20_1746\all_data')


% ydata{1}{1} = [model.y_gplvm_input_train(1:31,1:37);  model.y_gplvm_input_train(1:31,38:74)]; %model.y_gplvm_input_train(1:31)

model.y_gplvm_input_train;
model.x_gplvm_input_train;


figure(3)

clf
hold on

dissims=[];
for tap = 1:93
    differences = [ex.ref_tap(:,:,1) ex.ref_tap(:,:,2)] - model.y_gplvm_input_train(tap,:); 

    diss = norm([differences']);
    dissims =[dissims diss]; 
    
    if tap <=31
        color = 'r';
    elseif tap <= 62
        color = 'b';
    else
        color = 'g';
    end
    
    scatter3(model.x_gplvm_input_train(tap,1), model.x_gplvm_input_train(tap,2), diss,color,'+')
end
dissims

a = [1:3]'; b = num2str(a); c = cellstr(b);
text([0 10 0], [model.x_gplvm_input_train(1,2) model.x_gplvm_input_train(32,2) model.x_gplvm_input_train(63,2)], [250 250 250] , c, 'Fontsize',15);

grid on 
% xlabel("Estimated location (°)")
% ylabel("\phi")
% zlabel("Dissimilarity")

xlabel("Estimated angle / °")
ylabel("Predicted \phi")
zlabel("Dissimilarity")
title("GPLVM Model")

view([-1,-1.5,1.2])

% [dissims, ys_for_real] = ex.process_taps(ydata{1});


% plot(model.x_gplvm_input_train(:,1), dissims)