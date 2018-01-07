I = imread('sample_findLine.png');
I = imread('Patient 8720580_10112006-044537_15.png');
I = imread('Patient 8704366_09162006-193944_13.png');

I = imread('Patient 8720935_09302006-192856_14.png');

midline_x = 0;
midline_y = y;
fan_angle = 0;
rev = 0;

I1 = I(:,:,1);
I2 = I(:,:,2);
I3 = I(:,:,3);

mask = zeros(size(I1));

mask(find(I1==255)) = 1;

% [ind_x, ind_y] = find(I1==255);

window_width = 118;
window_heigh = 98 ;
window_j_keep=0;
window_i_keep=0;

ori = uint8(mask(64:831,216:983));

[ind_x, ind_y] = find(ori==1);

star_x = ind_x(1)+1;
star_y = ind_y(1)+1;

window_leftuppoint=[star_x,star_y];
mask_new = zeros(size(ori));
% mask_new(260:380,320:450)=1;
mask_new(window_leftuppoint(1) + window_j_keep:window_leftuppoint(1) + window_j_keep + window_heigh, ...\
    window_leftuppoint(2) + window_i_keep:window_leftuppoint(2) + window_i_keep + window_width )=1;

ori_window_masked = floor(uint8(mask_new).*uint8(ori));
% figure, imshow(ori_window_masked,[]);

lab_mask = ori_window_masked;

[L, num]=bwlabel(lab_mask);

v1 = zeros(size(L));
v2 = zeros(size(L));
vleft = zeros(size(L));
vright = zeros(size(L));

vv = zeros([size(L),num]);

if num == 1 % only find one ventricle
    %     rev = 1;
    %     return;
elseif num == 0 % find nothing
    
    %     rev = 1;
    %     return;
else
    % sort the two biggest one
    %% use threshold to remove smaller parts.
    s = regionprops(L, 'Area');
    s_area = zeros(num,1);
    for i=1:num
        s_area(i)=s(i).Area;
    end
    [area_sort, ind]=sort(s_area, 'descend');
    % note: area_sort = s_area(ind) (28,25,5,3)'
    % note:  s_area(i)=s(i).Area; i=1:num  every area made by some points.
    % note: reg_img(i) is the ith region of num
    
    %     vv = zeros([size(L),num]);
    
    for i=1:num % for every region
        v_mask = zeros(size(L));
        v_mask(find(L==ind(i)))=1; %% bone labeled as 1
        vv(:,:,i) = v_mask;
        %         figure, imshow(uint8(v_mask),[]);
    end
    
    v1 = vv(:,:,1);
    v2 = vv(:,:,2);
end

% note: the coordination is on the real pic oriation(direction), not related the image mattrix.
[x1,y1] =  mass_center(v1) ; % x1 means x direction, y1 means y direction,
[x2,y2] =  mass_center(v2) ; % x2 means x direction, y2 means y direction,

x1 = floor(x1);
x2 = floor(x2);
y1 = floor(y1);
y2 = floor(y2);

isv1left = true;
if x1 < x2
    isv1left = true;
    
    vleft = v1;
    vright = v2;
    
    mass_left = [x1,y1];
    mass_right = [x2,y2];
else
    isv1left = false;
    
    vleft = v2;
    vright = v1;
    mass_right = [x1,y1];
    mass_left = [x2,y2];
end

v_all = vleft + vright;
[inx, iny] = find(v_all==1);
draw_line_y_direction = [min(inx), max(inx)];

% the y direction threshold to control rotate or not;
threhold_y = 3;
angle = 0;
mask_midline_draw = zeros([size(L),3]);

midline_x = floor((mass_left(1) + mass_right(1))/2);
midline_y = floor((mass_left(2) + mass_right(2))/2);

mask_midline_draw(draw_line_y_direction(1):draw_line_y_direction(2),midline_x, 1:2)=255;
mask_midline_draw(draw_line_y_direction(1),midline_x-5:midline_x+5, 1)=255;
mask_midline_draw(draw_line_y_direction(2),midline_x-5:midline_x+5, 1)=255;

isNeedAdjust = false;
if abs(mass_left(2) - mass_right(2)) < threhold_y
    % not rotate
    isNeedAdjust = false;
else
    isNeedAdjust = true;
    
    % need to adjust
    midline_x = floor((mass_left(1) + mass_right(1))/2);
    midline_y = floor((mass_left(2) + mass_right(2))/2);
    
    % get the angle of the rotate and rotate
    a = mass_right(1) - mass_left(1);
    b = mass_right(2) - mass_left(2);
    alpha=atan(-b/a);
    fan_angle = alpha*180/pi;
    
    
%         m_x = floor(size(mask_midline_draw,2)/2);
%         m_y = floor(size(mask_midline_draw,1)/2);
% 
%     mask_midline_draw = centerimg(mask_midline_draw,[m_x,m_y],'crop');
% %     mask_midline_draw = imrotate(mask_midline_draw, fan_angle, 'nearest', 'crop');
    
    mask_midline_draw = imrotate(mask_midline_draw, fan_angle, 'nearest', 'crop');
    
    mask_tmp = zeros(size(L));
    mask_tmp(find(mask_midline_draw(:,:,1)==255)) = 1;
    [x_tmp_mass,y_tmp_mass] =  mass_center(mask_tmp) ; % x_tmp_mass means x direction, y_tmp_mass means y direction,
    
    dif = floor(x_tmp_mass - midline_x);
    
    step_star = abs(dif)+1;
    step_end = size(L)-2*abs(dif)-1;
    
    if step_star > step_end
        rev = 1;
        return;
    end
    
    mask_tmp2 = zeros(size(L));
    
    mask_tmp2(:,step_star:step_end) = mask_tmp(:,step_star+dif:step_end+dif); 
    mask_tmp2(find(mask_tmp2~=0))=255;
%    mask_midline_draw(:,:,1) = mask_tmp2;
%     mask_midline_draw(:,:,2) = mask_tmp2;
     mask_midline_draw(:,:,3) = mask_tmp2;
    
%     mask_midline_draw(draw_line_y_direction(1):draw_line_y_direction(2),midline_x, 1:2)=255;
%     mask_midline_draw(draw_line_y_direction(1),midline_x-5:midline_x+5, 1)=255;
%     mask_midline_draw(draw_line_y_direction(2),midline_x-5:midline_x+5, 1)=255;
    
end

Img_midline = uint8(I(64:831,216:983,1:3));


if isNeedAdjust    
    Img_midline= uint8(double(Img_midline) + double(mask_midline_draw));   
else    
    Img_midline = mask_midline_draw;
end

fan_angle
Img_midline

% figure, imshow(Img_midline, []);

% [vl, num_vl]=bwlabel(vleft);
% s = regionprops(vl, 'Area');

% figure, imshow(vleft, []);
% figure, imshow(vright, []);
% close all;

%
% [ind_x, ind_y]  = find(v_mask1 == 1);
%
% mask_new(ind_x(1):ind_x(1) +window_heigh, ...\
%     ind_y(1):ind_y + window_width )=1;
%
%








