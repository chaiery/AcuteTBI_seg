%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Wenan Chen
%% September, 2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% This function drow a box on the rgb image rota_img by setting the r
%% component to 255. 
function rota_img=drawbox(rota_img, boxRect, boxcolor)

%% input: boxRect is a four element vector: 
%% [x_left, x_right, y_upper, y_lower]

if isempty(boxcolor)
    boxcolor = 255;
end

x_left=boxRect(1);
x_right=boxRect(2);
y_upper=boxRect(3);
y_lower=boxRect(4);
rota_img([y_upper:y_lower],x_left,1)=boxcolor;
rota_img([y_upper:y_lower],x_right,1)=boxcolor;
rota_img(y_upper,[x_left:x_right],1)=boxcolor;
rota_img(y_lower,[x_left:x_right],1)=boxcolor;

%% figure; imshow(uint8(rota_img));


