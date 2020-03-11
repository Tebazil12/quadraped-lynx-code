clear all
figure(1)
clf


x = [751 710 708 640 634 664 637 639 569 575 561 497 497 483 419 423 409 345 349 336 271 275 261 197 201 186 124 124 111 47 50 66 48 50];
y = [23 40 45 39 62 27 64 44 23 30 41 32 32 44 36 35 47 38 36 47 38 35 48 38 37 51 42 42 58 55 51 40 78 49];

footx = [x(3) x(8:3:end-5) x(end)];
footy = [y(3) y(8:3:end-5) y(end)];

woodx = [0 0 914 915 0];
woody= [46 64 49 31 46];

edge1 = [915 31 0]
edge2= [0 46 0]

hold on
plot(woodx,-woody, 'LineWidth',1,'Color',[210/255 105/255 30/255])
% plot(woodx(4:5),-woody(4:5))

woodwidth_pixel = point_to_line([914 49 0],edge1,edge2)
woodwidth_mm = 28

distances_pxl= [];
for i = 1:10
    distances_pxl= [distances_pxl point_to_line([footx(i) footy(i) 0],edge1,edge2)];
end

distances_pxl

distances_mm = (distances_pxl./woodwidth_pixel) * woodwidth_mm



plot(x,-y,'-+','LineWidth',1, 'MarkerSize',10,'Color', [0 102/255 204/255])
hold on
scatter(footx,-footy,100,'filled','o','MarkerFaceColor',[102/255 204/255  0])
a = [1:10]'; b = num2str(a); c = cellstr(b);
text(footx-12, -footy-[20 -22 20 20 20 20 20 20 20 -20], c, 'Fontsize',12);

xlabel('Distance (pixels)')
ylabel('Distance (pixels)')

daspect([1 1 1])
axis([30 760 -90 -10])
grid on
grid minor
set(gca,'FontSize',9)


figure(2)
half_wood_pxl = woodwidth_pixel/2;
bar([1:10], -distances_mm +(0.5*woodwidth_mm))%28*(-distances_pxl/half_wood_pxl+half_wood_pxl/half_wood_pxl))
hold on
plot([0 11],[woodwidth_mm/2 woodwidth_mm/2],'Color', [210/255 105/255 30/255])
% plot([0 11],[-woodwidth -woodwidth])
plot([0 11],[-woodwidth_mm/2 -woodwidth_mm/2],'Color',[210/255 105/255 30/255])
% plot([0 11],[woodwidth woodwidth])
% plot([0 11],16*[-half_wood/half_wood -half_wood/half_wood],'--r')
% plot([0 11],16*[half_wood/half_wood half_wood/half_wood],'--r')

mean_dist_mm = mean(abs(-distances_mm+(0.5*woodwidth_mm)))
% plot([0 11], [mean_dist_mm mean_dist_mm],'--g')

max_dist_mm = max(abs(-distances_mm+(0.5*woodwidth_mm)))

axis([0 11 -15 15])
set(gca, 'XDir','reverse')
xlabel("Foothold Number")
ylabel({"Approx. Distance";" from center of beam (mm)"})
set(gca, 'YGrid','on', 'YMinorGrid','on')
hold off

% distance_mm = 28*(-distances_pxl/half_wood_pxl+half_wood_pxl/half_wood_pxl)
% mean_dist_mm = mean(abs(-distances_mm+(0.5*woodwidth_mm)))

function d = point_to_line(pt, v1, v2)
      a = v1 - v2;
      b = pt - v2;
      d = norm(cross(a,b)) / norm(a);
end