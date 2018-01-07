%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Wenan Chen
%% Sep 24rd, 2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% This function calculate the mass center of the object in the seg_img. 
%% The formulae are the follows:
%%
%% x=\sum{i=1}{n}x_i*l_y*1 / number of pixels
%% y=\sum{i=1}{n}y_i*l_x*1 / number of pixels
%%
%% x_i are the horizontal coordinates of each pixel, l_y is the number of
%% pixels along the vertical line of x=x_i. The meaning is similar for the
%% second formula

function [x,y]=mass_center(seg_img)

%% inputs: seg_img is the intensity image with 1 for foreground and
%% 0 for background 

%% outputs: [x,y] is the position of the mass center. 

[m,n]=size(seg_img);

x_accu=0;
y_accu=0;
N_pixels=length(find(seg_img==1));

%% calculate x direction
for x_i=1:n
    yline=seg_img(:,x_i);
    l_y=length(find(yline==1));
    x_accu=x_accu+x_i*l_y;
end
x=x_accu/N_pixels;

%% calculate y direction
for y_i=1:m
    xline=seg_img(y_i,:);
    l_x=length(find(xline==1));
    y_accu=y_accu+y_i*l_x;
end
y=y_accu/N_pixels;


