clear all
figure(1)
x = [751 710 708 640 634 664 637 639 569 575 561 497 497 483 419 423 409 345 349 336 271 275 261 197 201 186 124 124 111 47 50 66 48 50];
y = [23 40 45 39 62 27 64 44 23 30 41 32 32 44 36 35 47 38 36 47 38 35 48 38 37 51 42 42 58 55 51 40 78 49];

footx = [x(3) x(8:3:end-5) x(end)];
footy = [y(3) y(8:3:end-5) y(end)];

woodx = [0 0 914 915 0];
woody= [46 64 49 31 46];

edge1 = [915 31 0]
edge2= [0 46 0]

woodwidth = point_to_line([914 49 0],edge1,edge2)

distances= [];
for i = 1:10
    distances= [distances point_to_line([footx(i) footy(i) 0],edge1,edge2)];
end

distances

plot(x,-y,'-o')
hold on
scatter(footx,-footy,'filled')

hold on
plot(woodx,-woody)
plot(woodx(4:5),-woody(4:5))

daspect([1 1 1])
axis([0 915 -90 -10])

figure(2)
half_wood = woodwidth/2;
bar([1:10],-distances/half_wood+half_wood/half_wood)
hold on
plot([0 11],[-half_wood/half_wood -half_wood/half_wood],'r')
% plot([0 11],[-woodwidth -woodwidth])
plot([0 11],[half_wood/half_wood half_wood/half_wood],'r')
% plot([0 11],[woodwidth woodwidth])
axis([0 11 -1.1 1.1])

xlabel("Foothold Number")
ylabel("Distance from center of beam(as fraction of beam width)")
set(gca, 'YGrid','on', 'YMinorGrid','on')
hold off

function d = point_to_line(pt, v1, v2)
      a = v1 - v2;
      b = pt - v2;
      d = norm(cross(a,b)) / norm(a);
end