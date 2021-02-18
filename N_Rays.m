%Housekeeping
close all

%Given some rays, minimize the perpendicular distances from a point to each
%ray to find the average closest ray.

%Some parameters.
%Number of rays.
n = 10;
%Maximum camera origin point values (ie, in xyz all camera origins will be
%within -source_scatter:source_scatter.
source_scatter = 5;
%Maximum camera scatter (area around the origin that cameras can point).
%Same design as source_scatter.
target_scatter = -1;

%Preallocate rays vector.  Clear due to this not overwriting an existing
%allocation.
clear rays;
rays(n,1) = struct('origin',[],'direction',[]);

%Define some rays to represent cameras.
for ii=1:n
    %Choose some random rays.  Allow origins as per source_scatter.  We
    %choose the a point bounded by target_scatter around the origin as the
    %camera direction, to bias the rays into a realistic situation (ie,
    %point somewhat in the direction of the target).
    temp.origin = -source_scatter+2*source_scatter*[rand; rand; rand];
    temp.direction = -target_scatter+2*target_scatter*[rand rand rand]-temp.origin';
    
    %Make direction a unit vector / normalize.
    temp.direction = temp.direction./norm(temp.direction);
    
    %Add the temp ray to the rays vector.
    rays(ii) = temp;
end

%Define S*p = C as per https://math.stackexchange.com/questions/61719/, such
%that p = S\C.  Preallocate S and C.
S = zeros(3,3);
C = zeros(3,1);
for ii=1:length(rays)
   S = S + rays(ii).direction'*rays(ii).direction-eye(3);
   C = C + (rays(ii).direction'*rays(ii).direction-eye(3))*rays(ii).origin;
end

%Intersect point from S*p=C, as per the above stackexchange link.
p = S\C;

%Plot the rays and the intersect point.
figure
hold on

%Plot each of the rays.
for ii=1:length(rays)
    x = [rays(ii).origin(1) rays(ii).origin(1)+1E4*rays(ii).direction(1)];
    y = [rays(ii).origin(2) rays(ii).origin(2)+1E4*rays(ii).direction(2)];
    z = [rays(ii).origin(3) rays(ii).origin(3)+1E4*rays(ii).direction(3)];
    plot3(x, y, z);
    
    %Mark the camera origins.
    plot3(rays(ii).origin(1), rays(ii).origin(2), rays(ii).origin(3), 'k*');
end

%Plot the proposed intersect point.
plot3(p(1), p(2), p(3), 'r.', 'MarkerSize',10);

%Set the axis lims.
xlim([-source_scatter source_scatter])
ylim([-source_scatter source_scatter])
zlim([-source_scatter source_scatter])

%Format the plot.
title(['Least squares intersect for n rays (n=' num2str(n) ')'])
xlabel('x')
ylabel('y')
zlabel('z')
grid on