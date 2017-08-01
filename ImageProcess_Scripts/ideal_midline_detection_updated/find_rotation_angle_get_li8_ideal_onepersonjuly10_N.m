%%%%%
%   Negar 
%   August 2015
%%%%%

function [ rotate_angle]=find_rotation_angle_get_li8_ideal_onepersonjuly10_N(A,seg_img)
%% Put it into the grayscale matrix 
 rotate_angle = 0;
 ceter=zeros(1,2);
 B=A(:,:,1);
 d = ct_brain_mask(A(:,:,1));
%% segmentation of the brain tissue, suppose the skull is connected
% seg_img=ct_seg(B);

% [x,y]=mass_center(seg_img);
% 
% x_c=floor(x);
% y_c=floor(y);
%% detect cracks in the brain bone

innerSkull_angle = regionprops(d,'orientation');
outerSkull_angle = regionprops(seg_img,'orientation');
in= innerSkull_angle.Orientation;
out= outerSkull_angle.Orientation;
if(crackdeg(seg_img))
    %N: return;
    in=out;
end
in1=in;
if (in < 0)
   in1= 180 + in ;
end
out1=out;
if (out < 0)
    out1 = 180 +out;
end
k= mean([in1;out1]);
rotate_angle = 90-k;
% rota_img = imrotate(A,rotate_angle);
    
