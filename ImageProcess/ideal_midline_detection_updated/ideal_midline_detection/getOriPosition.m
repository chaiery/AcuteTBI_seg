function [ xy1_bump,xy1_linept, rev ] = ...\ 
    getOriPosition( xy2_bump,xy2_linept, rota_center_p, center, rotate_angle)
%% recover the original coordinates of bump and gray line points  
% and calculate the pt and theta
% for p1(x1,y1), with the transformation of rotation around the center
% p(x0,y0), and the rotation angle delta, denote p2(x2,y2) the rotated
% point, they have the following relation:
% Denote R=[cos(delta), sin(delta); -sin(delta), cos(delta)], then 
% [x1,y1]=[x2-x0,y2-y0]*A+[x0,y0];

rev = 0;

%rota_center_p = [floor(size(rota_bwSkullBone,2)/2),floor(size(rota_bwSkullBone,1)/2)];
delta=rotate_angle/180*pi;
A=[cos(delta),sin(delta);-sin(delta),cos(delta)];
xy1_bump=(xy2_bump-rota_center_p)*A+rota_center_p;
xy1_linept=(xy2_linept-rota_center_p)*A+rota_center_p;

%% shift back because when do centering, there is a shift to make
%% center to the center of a big Canvas
xy1_bump = xy1_bump+(center-rota_center_p);
xy1_linept = xy1_linept+(center-rota_center_p);

%% calculate the pt and cot(theta)
%     pt=(xy1_bump+xy1_linept)/2;
%     cot_theta=(xy1_linept(1)-xy1_bump(1))/(xy1_linept(2)-xy1_bump(2));
%     theta=acot(cot_theta);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

