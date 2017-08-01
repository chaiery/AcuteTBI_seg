
function [ bwSkullBone,rotate_angle,center,choosing, outerBw, innerBw, ...\
    rota_original_img, rota_original_img_2D ...\
    xy2_bump, xy2_linept, xy1_bump, xy1_linept, rev ] = ideal_midline_detection( imStru )

bwSkullBone = 0;
rotate_angle= 0;
center= [0,0];
choosing= 0;
outerBw= 0;
innerBw= 0;
rota_original_img= 0;
rota_original_img_2D = 0;
xy2_bump= [0,0];
xy2_linept= 0;
xy1_bump= [0,0];
xy1_linept= 0;
rev= 0;

% get ideal midline
%   Detailed explanation goes here

%% get skull bone
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

%% approximate midline detection according to symmetry and center
[  rotate_angle,center,choosing, outerBw, innerBw, rev ] = ...\
    getApproximateIdealMidline(bwSkullBone);
if rev ~= 0
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% set the new size and then centerlize the rescaled bone and CT image.
new_width=floor(1.5*size(bwSkullBone,2));
new_height=floor(1.5*size(bwSkullBone,1));
centered_img_Mattress=centerimg_size(imStru.img_Mattress, center, new_width, new_height);
centered_bwSkullBone=centerimg_size(bwSkullBone, center,new_width, new_height);
centered_innerBw = centerimg_size(innerBw, center,new_width, new_height);

% rotate centered_img_Mattress
rota_original_img_2D = imrotate(centered_img_Mattress,rotate_angle,'nearest','crop');
rota_original_img = zeros([size(rota_original_img_2D),3]);
for i=1:3
    rota_original_img(:,:,i) = rota_original_img_2D;
end

% rotate centered_bwSkullBone
rota_bwSkullBone = imrotate(centered_bwSkullBone,rotate_angle,'nearest','crop');
rota_seg = rota_bwSkullBone; % for reading previous code
rota_innerBw = centered_innerBw;

%% get extreme value points
% get bump which is the lowest point on upper by getUpperPoint()
[bumpPoint, I_upper_lowest, boneInupper_boximg, boxRect_upper, isFoundBump, rev] = ...\
    getUpperPoint(rota_bwSkullBone);
if rev ~= 0
    return;
end

% get bump which is the lowest point on upper by getUpperPoint()
[linePoint, I_lower_uppest, boneInlower_boximg,boxRect_lower, isFoundLowerUppest, rev] = ...\
    getLowerPoint(rota_bwSkullBone,rota_original_img);
if rev ~= 0
    return;
end

%% mark the image with lines and boxes
rota_original_img=drawbox(rota_original_img, boxRect_upper,imStru.boneThreshold + 1);
rota_original_img=drawbox(rota_original_img, boxRect_lower,imStru.boneThreshold + 1);

% mark the midline
x_midline=floor(size(rota_original_img,2)/2);

% red for symmetric approximate midline
% rota_original_img(:,x_midline,1)=imStru.boneThreshold + 1;

%% the tactic of dealing with these two extreme value point.
[ xy2_bump, xy2_linept, rota_original_img, rota_bwSkullBone, adjust_Ang_center, rev] = ...\
    getValidatedExtremePointByTactic( ...\
    bumpPoint, isFoundBump,  I_upper_lowest,  ...\
    linePoint, isFoundLowerUppest, I_lower_uppest, ...\
    choosing, rota_bwSkullBone, rota_original_img, imStru.boneThreshold);
if rev ~= 0
    return;
end

% get 2D version of rota_original_img
rota_original_img_2D = rota_original_img(:,:,3);

%% recover to original coordination of bump and gray point
rota_center_p = [floor(size(rota_bwSkullBone,2)/2),floor(size(rota_bwSkullBone,1)/2)];
[ xy1_bump,xy1_linept, rev ] = ...\
    getOriPosition( xy2_bump,xy2_linept, rota_center_p, center, rotate_angle);
if rev ~= 0
    return;
end


end

