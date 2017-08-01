function [midline_x, midline_y, fan_angle, ...\
          vleft, vright, v_all, mask_midline_draw, ...\ 
    actualmidlineImgMarked, actualmidlineImgMarked_withTitle, rev] ...\
    = getLeftAndRitghtVentricleParameters(levelsetImg_3D)

midline_x = 0;
midline_y = 0;
fan_angle = 0;

vleft = 0;    % 2d bw
vright = 0;   % 2d bw
v_all = 0;    % 2d bw
mask_midline_draw  = 0; % 3d 1,2 plan is masked

rev = 0;
levelsetImg_3D = imread('C:\_conP2\new8_WinGood_result\360 iterations.png');
actualmidlineImgMarked = 0;
actualmidlineImgMarked_withTitle = levelsetImg_3D;


levelsetImg_1 = levelsetImg_3D(:,:,1);
levelsetImg_2 = levelsetImg_3D(:,:,2);
levelsetImg_3 = levelsetImg_3D(:,:,3);

mask_lookingOriImg_contour = zeros(size(levelsetImg_1));
mask_lookingOriImg_contour(find(levelsetImg_1==255)) = 1;
ori_2d_contourIncludingwindow = uint8(mask_lookingOriImg_contour(49+5:816+5,217-10:984-10));

[ind_x, ind_y] = find(ori_2d_contourIncludingwindow==1);
ori_2d_contourIncludingwindow(1:50,:)= 0;
ori_2d_contourIncludingwindow(718:768,:)= 0;
ori_2d_contourIncludingwindow(:,1:50)= 0;
ori_2d_contourIncludingwindow(:,718:768)= 0;

% star_x = ind_x(1)+100;
% star_y = ind_y(1)+100;

Iori = imread('C:\_conP2\new8_WinGood_result\0 iteration.png');
newFromOri = uint8(Iori(49+5:816+5,217-10:984-10));
contoursAllPlusIori = 255*ori_2d_contourIncludingwindow+newFromOri;

for i=1:(length(ind_x)-30)
    if (ind_x(i+1) - ind_x(i)) ~= 1 
        continue;
    end
    tmp_y = unique(ind_y(i:i+30));
    if length(tmp_y) == 1    
        star_x = ind_x(i)+1;
        star_y = ind_y(i)+1;
        break;
    end
end

window_width = 118;
window_heigh = 98 ;

window_width = 205;
window_heigh = 289 ;

window_j_keep=1;
window_i_keep=1;

window_leftuppoint=[star_x,star_y];
mask_new = zeros(size(ori_2d_contourIncludingwindow));

mask_new(window_leftuppoint(1) + window_j_keep:window_leftuppoint(1) + window_j_keep + window_heigh, ...\
    window_leftuppoint(2) + window_i_keep:window_leftuppoint(2) + window_i_keep + window_width )=1;

mask_new(

ori_2d_contour = floor(uint8(mask_new).*uint8(ori_2d_contourIncludingwindow));
% figure, imshow(ori_2d_contour,[]);

lab_mask = ori_2d_contour;

[L, num]=bwlabel(lab_mask);

v1 = zeros(size(L));
v2 = zeros(size(L));
vleft = zeros(size(L));
vright = zeros(size(L));

vv = zeros([size(L),num]);

if num == 1 % only find one ventricle
    rev = 1;
    return;
elseif num == 0 % find nothing
    
    rev = 1;
    return;
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
    
    if num > 2
        v3 = vv(:,:,3);
        [x1,y1] =  mass_center(v1) ; % x1 means x direction, y1 means y direction,
        [x2,y2] =  mass_center(v2) ; % x2 means x direction, y2 means y direction,
        [x3,y3] =  mass_center(v3) ; % x3 means x direction, y3 means y direction,
        
        y_dif = 0;
        
        d1 = abs(y1-y2);
        d2 = abs(y1-y3);
        d3 = abs(y2-y3);
        

        if d1 < d2
            group = 1;
            v_keep1 = v1;
            v_keep2 = v2;
            if d1 > d3
                group = 3;
                v_keep1 = v2;
                v_keep2 = v3;
            end
        else % d1 > d2
            group = 2;
                v_keep1 = v1;
                v_keep2 = v3;
            if d2 > d3
                group = 3;
                v_keep1 = v2;
                v_keep2 = v3;
            end
        end
            
        
%         max_dif = 0;
% 
%         v_keep1 = 1;
%         v_keep2 = 2;
%         
%         d1 = abs(x1-384);
%         d2 = abs(x2-384);
%         d3 = abs(x3-384);
%         
%         if d1 < d2
%             v_keep1 = v1;
%             if d2<d3
%                  v_keep2 = v2;
%             else
%                  v_keep2 = v3;
%             end
%         else % d1 > d2
%             v_keep2 = v2;
%             if d1 < d3
%              v_keep1 = v1;              
%             else  
%              v_keep1 = v3;
%             end
%         end
        v1 = v_keep1;
        v2 = v_keep2;
    end
    
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
threhold_y = 60;
angle = 0;
mask_midline_draw = zeros([size(L),3]);

midline_x = floor((mass_left(1) + mass_right(1))/2);
midline_y = floor((mass_left(2) + mass_right(2))/2);

[vl_x, vl_y] = find(vleft ~= 0);
[vr_x, vr_y] = find(vright ~= 0);

m1 = max(vl_y);
m2 = min(vr_y);

isReasonalbeSeq = false;
if m1 < m2
    midline_x = floor((double(m1) + double(m2))/2);
    isReasonalbeSeq = true;
end

mask_midline_draw(draw_line_y_direction(1):draw_line_y_direction(2),midline_x, 1:2)=255;
mask_midline_draw(draw_line_y_direction(1),midline_x-5:midline_x+5, 1)=255;
mask_midline_draw(draw_line_y_direction(2),midline_x-5:midline_x+5, 1)=255;

isNeedAdjust = false;
if isReasonalbeSeq || abs(mass_left(2) - mass_right(2)) < threhold_y  
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
    %     mask_midline_draw(:,:,1) = mask_tmp2;
    %     mask_midline_draw(:,:,2) = mask_tmp2;
    mask_midline_draw = zeros([size(L),3]);
    mask_midline_draw(:,:,1) = mask_tmp2;
    mask_midline_draw(:,:,2) = mask_tmp2;
    %     mask_midline_draw(draw_line_y_direction(1):draw_line_y_direction(2),midline_x, 1:2)=255;
    %     mask_midline_draw(draw_line_y_direction(1),midline_x-5:midline_x+5, 1)=255;
    %     mask_midline_draw(draw_line_y_direction(2),midline_x-5:midline_x+5, 1)=255;
    
end

Img_midline = uint8(levelsetImg_3D(49:816,217:984,1:3));

Img_midline= uint8(double(Img_midline) + double(mask_midline_draw));
% if isNeedAdjust
%     Img_midline= uint8(double(Img_midline) + double(mask_midline_draw));
% else
%     Img_midline = mask_midline_draw;
% end

actualmidlineImgMarked = Img_midline;
actualmidlineImgMarked_withTitle(49:816,217:984,:) = actualmidlineImgMarked(:,:,:);

end