
function [ bwSkullBone,rotate_angle,center,choosing, outerBw, innerBw, rev ] ...\  
    = ideal_midline_detection_old( imStru )
% get ideal midline
%   Detailed explanation goes here
       
% get skull bone
[ bwSkullBone,rev ]  = getSkullBone( imStru.img_Mattress,imStru.boneThreshold );
if rev ~= 0
    return;
end

%figure, imshow(bwSkullBone,[]);

% judge the skull is broken or not
rev = isCrackedOfSkull(bwSkullBone);
if rev ~= 0
    return;
end


% approximate midline detection according to symmetry and center
[  rotate_angle,center,choosing, outerBw, innerBw, rev ] = getApproximateMidline(bwSkullBone);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% let the image centered with the mass center and set the new size
new_width=floor(1.5*size(bwSkullBone,2));
new_height=floor(1.5*size(bwSkullBone,1));
centered_img_Mattress=centerimg_size(imStru.img_Mattress, center, new_width, new_height);
centered_bwSkullBone=centerimg_size(bwSkullBone, center,new_width, new_height);
centered_innerBw = centerimg_size(innerBw, center,new_width, new_height);

rota_original_img = imrotate(centered_img_Mattress,rotate_angle,'nearest','crop');
rota_original_img_new = zeros([size(rota_original_img),3]);
for i=1:3
    rota_original_img_new(:,:,i) = rota_original_img;
end
rota_original_img = rota_original_img_new;

rota_bwSkullBone = imrotate(centered_bwSkullBone,rotate_angle,'nearest','crop');
rota_seg = rota_bwSkullBone; % for reading previous code
rota_innerBw = centered_innerBw;

% new test method 
% [bumpPoint, upper_boximg, boxRect_upper, isFoundBump, rev] = ...\ 
%    getUpperPoint(rota_bwSkullBone);
% [lowerUppestPoint, img_lower,boxRect_lower, isFoundLowerUppest, rev] = ...\ 
%                            getLowerPoint(rota_bwSkullBone,rota_original_img);

% find the upper bump
C=rota_bwSkullBone;  %% the red plane has been modified, so use the blue plane

B=imStru.img_Mattress; %  only using size(B) for reading previous code

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% draw a box near the point where the midline intersect with the upper
%% part of the skull and lower part of the skull.
center_x=floor(size(C,2)/2);
center_y=floor(size(C,1)/2);
vec_midline=C(:,center_x);
I=find(vec_midline>0);
if(isempty(I))
   rev = 1;
   return;
end
%% upper part
I_upper=I(find(I<center_y));
%% in case there is an open hole in the upper part, i.e, fracture in the
%% bone on both side.
if(isempty(I_upper))
   rev = 1;
   return;
else
    I_upper_lowest=max(I_upper);
end
%% lower part
I_lower=I(find(I>center_y));
if(isempty(I_lower))
   rev = 1;
   return;
else
   I_lower_uppest=min(I_lower);
end
%% set the box around the lowest point of upper part and uppest point of
%% lower part, the size(B,.) is used to dealing with different size of img
Half_width=floor(80*size(B,2)/512);
Half_height=floor(60*size(B,1)/512);
Half_width_lower=floor(60*size(B,2)/512);
Half_height_lower=floor(80*size(B,2)/512);
x_left=center_x-Half_width;
x_right=center_x+Half_width;
x_left_lower=center_x-Half_width_lower;
x_right_lower=center_x+Half_width_lower;
%% upper part
y_upper_sm=I_upper_lowest-Half_height;
y_upper_lg=I_upper_lowest+Half_height;
%% lower part
y_lower_sm=I_lower_uppest-Half_height_lower;
y_lower_lg=I_lower_uppest+Half_height_lower;
boxRect_upper=[x_left, x_right, y_upper_sm, y_upper_lg];
boxRect_lower=[x_left_lower, x_right_lower, y_lower_sm,y_lower_lg];

%% find the lowest edge line in the box by checking every vertical line and
%% get the lowest point of bone intensity of  the line, the similar line is
%% gotten on the lower part.
line_lowest=zeros(1,x_right-x_left+1); %% for upper part of the skull
line_uppest=zeros(1,x_right_lower-x_left_lower+1); %% for lower part of the skull
j=1;
for i=[x_left: x_right]
    vec_line=C(:,i);
    I_bone=find(vec_line>0);
    
    %% for upper part
    I_bone_box1=I_bone(find(I_bone>=y_upper_sm));
    I_bone_box2=I_bone_box1(find(I_bone_box1<=y_upper_lg));
    I_box_lowest=max(I_bone_box2);
    
    if(isempty(I_box_lowest))
        line_lowest(j)=y_upper_sm;
    else
        line_lowest(j)=I_box_lowest;
    end
    
    j=j+1;
end

j=1;
for i=[x_left_lower: x_right_lower]
    vec_line=C(:,i);
    I_bone=find(vec_line>0);
    
    %% for lower part
    I_bone_box3=I_bone(find(I_bone<=y_lower_lg));
    I_bone_box4=I_bone_box3(find(I_bone_box3>=y_lower_sm));
    I_box_uppest=min(I_bone_box4);
    
    if(isempty(I_box_uppest))
        line_uppest(j)=y_lower_lg;
    else
        line_uppest(j)=I_box_uppest;
    end
    
    
    j=j+1;
end

%% get rid of the points where the value reaches the bottom of the box 
line_lowest2=line_lowest;
line_lowest2(find(line_lowest==y_upper_lg))=-1;

%% deal with o shape.
%% basically, change the way of get the lowest line, get the hightest line 
%% in the interior edge.
upper_boximg=rota_seg([y_upper_sm:y_upper_lg],[x_left:x_right]);

edge_map=get_interior_edge(upper_boximg);
%% get the highest line in the curve
line_highest=zeros(1,size(edge_map,2));
for i=1:size(edge_map,2)
    [Ind_i,Ind_j]=find(edge_map(:,i));
    if(isempty(Ind_i)) 
        line_highest(i)=-1;
    else
        line_highest(i)=min(Ind_i);
    end
end

%% get rid of the place where there is no edge by setting them to -1
line_highest(find(line_highest==0))=-1;

rtv= zeros(1,2);
%% get the bump as the lowest part in the local area
[x_coord_lowest_inline, rev] = get_local_min(line_highest); 

if(x_coord_lowest_inline == 1) % <=>if rev ~= 0 
    rtv(1)=1;
    %% use the intersection point of the approximate midline and the skull
    %% instead
    x_coord_lowest=center_x;
    y_coord_lowest=I_upper_lowest;
    fprintf('No bump is found, use approximate position instead\n');
else
    x_coord_lowest=x_coord_lowest_inline+(center_x-Half_width-1);
    y_coord_lowest=line_lowest(x_coord_lowest_inline);
end

%% crop the lower part of the image
cropRect_lower=[x_left_lower,y_lower_sm,x_right_lower-x_left_lower,y_lower_lg-y_lower_sm-1];
img_lower=imcrop(rota_original_img,cropRect_lower); % img_lower=imcrop(rota_original_img,cropRect_lower);

%% find the lower part of midline point by detecting the gray line in the
%% lowpart
%% all the processing are in the lower part box: 
%% boxRect_lower=[x_left, x_right, y_lower_sm,y_lower_lg];

%% get the midline lower point 
% use hough transform to detect line and then get the point so it is
% possible not to be accurate. 
% later need judge by retotated degree threshold
mask_line=line_uppest-y_lower_sm+1;
[rev,ml_pt]=get_lower_mlpoint(img_lower,mask_line); % ml_pt=get_lower_mlpoint(img_lower,mask_line);
if rev ~= 0
    return;
end

if ((ml_pt(1)==0)&&(ml_pt(2)==0)) 
    fprintf('Failed to detect lines in the lower part of the skull, use mass center instead \n');
    rtv(2)=1;
end
ml_pt_img=[x_left_lower+ml_pt(1)-1,y_lower_sm+ml_pt(2)-1];


%% mark the image with lines and boxes
rota_original_img=drawbox(rota_original_img, boxRect_upper);
rota_original_img=drawbox(rota_original_img, boxRect_lower);
% 
x_midline=floor(size(rota_original_img,2)/2);
rota_original_img(:,x_midline,1)=imStru.boneThreshold + 1;  %% red for symmetric approximate midline
% rota_img(:,x_coord_lowest,1)=255;   %% this line is shifted to bump point

%% for animation images
% imwrite(uint8(rota_img), strcat('..',del,folder,del,'s_img.png'));
% %% plot bump
% figure; imshow(uint8(rota_img)); hold on;
% plot(x_coord_lowest,y_coord_lowest, 'x','LineWidth',2,'Color','yellow');
% plot(ml_pt_img(1),ml_pt_img(2),'x','LineWidth',2,'Color','blue');
% plot([x_coord_lowest,ml_pt_img(1)],[y_coord_lowest,ml_pt_img(2)],'x','LineWidth',2,'Color','green');

% figure; imshow(uint8(rota_img)); hold on;

%% plot the line connecting mass center and bump point.
%% plot([center_x,x_coord_lowest],[center_y,y_coord_lowest],'-+g');

%% plot the line connecting ml_pt and [x_coord_lowest,y_coord_lowest] on
%% the image
% plot([ml_pt_img(1),x_coord_lowest],[ml_pt_img(2),y_coord_lowest],'-+y'); %% yellow for this line

%% connect the lower point with revised upper bump point and rotate the image to
%% make  this line vertical around the midpoint of this line.

if((rtv(2)==0)&&(rtv(1)==0))
    %% for return value calculation later
    xy2_bump=[x_coord_lowest, y_coord_lowest];
    xy2_linept=[ml_pt_img(1),ml_pt_img(2)];
        
    %% get the midpoint of the line
    m_x=floor((x_coord_lowest+ml_pt_img(1))/2);
    m_y=floor((y_coord_lowest+ml_pt_img(2))/2);

    % %% use the tranforme function in matlab directly
    % coord_lowest=[x_coord_lowest,y_coord_lowest];
    % half_len=norm(ml_pt_img-coord_lowest)/2;
    % base_points=[m_x,m_y;x_coord_lowest,y_coord_lowest]
    % input_points=[center_x, center_y; center_x,center_y-floor(half_len)];
    % transformtype='linear conformal';
    % tform=cp2tform(input_points,base_points,transformtype);
    % rota_img=imtransform(rota_img,tform);

    %% get the angle of the rotate and rotate
    a=x_coord_lowest-ml_pt_img(1);
    b=ml_pt_img(2)-y_coord_lowest;
    alpha=atan(a/b);
    
    % add by Qi Apr. 2012
    new_a = x_coord_lowest - ml_pt_img(1);
    new_b = y_coord_lowest - ml_pt_img(2);
    new_alpha = atan(b/a)*180/pi; % the degree
    
    degree_th = 6;
    if new_alpha < degree_th
        
    

    rota_original_img=centerimg(rota_original_img,[m_x,m_y],'crop');
    rota_original_img=imrotate(rota_original_img, alpha*180/pi, 'nearest', 'crop');
    rota_seg=centerimg(rota_seg,[m_x,m_y],'crop');
    rota_seg=imrotate(rota_seg, alpha*180/pi,'nearest','crop');
    %rota_seg_brain=centerimg(rota_seg_brain,[m_x,m_y],'crop');
    %rota_seg_brain=imrotate(rota_seg_brain, alpha*180/pi,'crop');
    %% rota_img=imrotate_withcenter(rota_img, alpha*180/pi,[m_x,m_y],'crop');
    %% rota_seg=imrotate_withcenter(rota_seg, alpha*180/pi,[m_x,m_y],'crop');
    %% rota_seg_brain=imrotate_withcenter(rota_seg_brain, alpha*180/pi, [m_x,m_y],'crop');

    %% mark the midline green
    rota_original_img(:,floor(size(rota_original_img,2)/2),2)=imStru.boneThreshold + 1;
    
    %% for animation images
%     imwrite(uint8(rota_img), strcat('..',del,folder,del,'midline_img.png'));
    else
        % rtv(1)=1;
    end
elseif((rtv(1)==1)&&(rtv(2)==0))
%     a=ml_pt_img(1)-center_x;
%     b=center_y-ml_pt_img(2);
%     alpha=atan(a/b);
%     rota_img=imrotate(rota_img, alpha*180/pi,'crop');
%     rota_seg=imrotate(rota_seg, alpha*180/pi,'crop');
%     %% mark the midline 
%     rota_img(:,floor(size(rota_img,2)/2),1)=255;
%     rota_img(:,floor(size(rota_img,2)/2),2)=180;
elseif((rtv(1)==0)&&(rtv(2)==1))
      %% for return value calculation later
      xy2_bump=[x_coord_lowest, y_coord_lowest];
      xy2_linept=[ml_pt_img(1),ml_pt_img(2)];
%     a=x_coord_lowest-center_x;
%     b=center_y-y_coord_lowest;
%     alpha=atan(a/b);
%     rota_img=imrotate(rota_img, alpha*180/pi,'crop');
%     rota_seg=imrotate(rota_seg, alpha*180/pi,'crop');
%     %% mark the midline yellow
%     rota_img(:,floor(size(rota_img,2)/2),1)=255;
%     rota_img(:,floor(size(rota_img,2)/2),2)=255;
else %% no points are detected
    %% for return value calculation later
    xy2_bump=[center_x, I_upper_lowest];
    xy2_linept=[center_x, I_lower_uppest];
    %% mark the midline red
    rota_original_img(:,floor(size(rota_original_img,2)/2),1)=imStru.boneThreshold + 1;
end

if((rtv(2)==1)&&(rtv(1)==0))
    %% use the bump point and small fan to detect the midline

    %% show the image first
    % figure; imshow(uint8(rota_img)); hold on; 

    %% get the bump point coordinate of the rotated image.
    bump_x=floor(size(rota_original_img,2)/2);
    half_length=abs(center_y-y_coord_lowest);

    bump_y=floor(floor(size(rota_original_img,1)/2)-half_length);

    %% center the image with bump point
    centered_seg_bump=centerimg(rota_seg, [bump_x,bump_y], 'crop');
    %centered_seg_brain_bump=centerimg(rota_seg_brain, [bump_x, bump_y], 'crop');

    %% rotation search to find a good rotation angle to minimize the
    %% dissymmetry of the image

    low_angle=-5;
    high_angle=5;
    delta_angle=0.5;
    %% the same result of using the interior side of skull or using the edge
    %% between brain tissue and the skull

        if(choosing==1)
            method='max';
        else
            method='min';
        end
    fan_angle=rota_symm_search(centered_seg_bump, low_angle, high_angle, delta_angle, method);
    %% fan_angle2=rota_symm_search(centered_seg_brain_bump, low_angle, high_angle, delta_angle, 'max');

    %% set another point for plot
    rot_ang=-fan_angle;
    full_length=2*half_length;
    x2=x_coord_lowest+full_length*sin(rot_ang/180*pi);
    y2=y_coord_lowest+full_length*cos(rot_ang/180*pi);

    %% for return value calculation later
    xy2_bump=[x_coord_lowest, y_coord_lowest];
    xy2_linept=[x2,y2];


    %% plot the line on the image

    % plot([x_coord_lowest;x2],[y_coord_lowest;y2],'m.-');

    %% rotate to the new angle
    m_x2=floor((x_coord_lowest+x2)/2);
    m_y2=floor((y_coord_lowest+y2)/2);

    rota_original_img=centerimg(rota_original_img,[m_x2,m_y2],'crop');
    rota_original_img=imrotate(rota_original_img, fan_angle,'nearest','crop');
    rota_seg=centerimg(rota_seg,[m_x2,m_y2],'crop');
    rota_seg=imrotate(rota_seg, fan_angle,'nearest','crop');

    %% mark it yellow
    rota_original_img(:,floor(size(rota_original_img,2)/2),1)=imStru.boneThreshold + 1;
    rota_original_img(:,floor(size(rota_original_img,2)/2),2)=imStru.boneThreshold + 1;

end


if((rtv(1)==1)&&(rtv(2)==0))
    %% use the bump point and small fan to detect the midline

    %% show the image first
    % figure; imshow(uint8(rota_img)); hold on; 

    %% get the line point coordinate of the rotated image.
    line_pt_x=ml_pt_img(1); 
    line_pt_y=ml_pt_img(2);
    half_length=abs(line_pt_y-center_y);

    % bump_x=floor(size(rota_img,2)/2);
    % half_length=abs(center_y-y_coord_lowest);
    % 
    % bump_y=floor(floor(size(rota_img,1)/2)-half_length);

    %% center the image with low line point
    centered_seg_bump=centerimg(rota_seg, [line_pt_x, line_pt_y], 'crop');
    %centered_seg_brain_bump=centerimg(rota_seg_brain, [bump_x, bump_y], 'crop');

    %% rotation search to find a good rotation angle to minimize the
    %% dissymmetry of the image

    low_angle=-5;
    high_angle=5;
    delta_angle=0.5;
    %% the same result of using the interior side of skull or using the edge
    %% between brain tissue and the skull
    fan_angle=rota_symm_search(centered_seg_bump, low_angle, high_angle, delta_angle, 'min');
    %% fan_angle2=rota_symm_search(centered_seg_brain_bump, low_angle, high_angle, delta_angle, 'max');

    %% set another point for plot
    rot_ang=fan_angle;
    full_length=2*half_length;
    x2=line_pt_x+full_length*sin(rot_ang/180*pi);
    y2=line_pt_y-full_length*cos(rot_ang/180*pi);

    %% for return value calculation later
    xy2_bump=[x2, y2];
    xy2_linept=[ml_pt_img(1),ml_pt_img(2)];


    %% plot the line on the image

    % plot([x_coord_lowest;x2],[y_coord_lowest;y2],'m.-');

    %% rotate to the new angle
    m_x2=floor((line_pt_x+x2)/2);
    m_y2=floor((line_pt_y+y2)/2);

    rota_original_img=centerimg(rota_original_img,[m_x2,m_y2],'crop');
    rota_original_img=imrotate(rota_original_img, fan_angle,'crop');
    rota_seg=centerimg(rota_seg,[m_x2,m_y2],'crop');
    rota_seg=imrotate(rota_seg, fan_angle,'crop');

    %% mark it yellow
    rota_original_img(:,floor(size(rota_original_img,2)/2),1)=imStru.boneThreshold + 1;
    rota_original_img(:,floor(size(rota_original_img,2)/2),2)=imStru.boneThreshold + 1;

end


%% recover the original coordinates of bump and gray line points  
%% and calculate the pt and theta
%% for p1(x1,y1), with the transformation of rotation around the center
%% p(x0,y0), and the rotation angle delta, denote p2(x2,y2) the rotated
%% point, they have the following relation:
%% Denote R=[cos(delta), sin(delta); -sin(delta), cos(delta)], then 
%% [x1,y1]=[x2-x0,y2-y0]*A+[x0,y0];
p=[floor(size(rota_seg,2)/2),floor(size(rota_seg,1)/2)];
delta=rotate_angle/180*pi;
A=[cos(delta),sin(delta);-sin(delta),cos(delta)];
xy1_bump=(xy2_bump-p)*A+p;
xy1_linept=(xy2_linept-p)*A+p;
%% shift back because when do centering, there is a shift to make
%% center to the center of a big Canvas
xy1_bump=xy1_bump+(center-p);
xy1_linept=xy1_linept+(center-p);
%% calculate the pt and cot(theta)
%     pt=(xy1_bump+xy1_linept)/2;
%     cot_theta=(xy1_linept(1)-xy1_bump(1))/(xy1_linept(2)-xy1_bump(2));
%     theta=acot(cot_theta);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% actural ideal midline detection based on approximate midline 
% get bump of upper
getUpperPoint()

% get bump of lower
getLowerPoint()

% get ideal midline according to different principle.
getIdealmidline()


end

