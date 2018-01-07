function [rota, rotate_angle] = rotate_method(imgs)
optRotate = 1;
optAngle = 2;

%Initialization

imgStruct = [];

num_realCenter = 0;
sum_realCenter = [0,0];
imgStruct = [];

%%
idx = [];
for i = 1:size(imgs, 3)
    img_bone = [];
    img = imgs(:,:,i);
    img(img==img(1)) = 0;
    img_Mattress = img;

    % create struct to store all the computed results and relevant
    % information
    imgStruct(i).isDicom = 0;
    imgStruct(i).img_bone = img_bone;
    imgStruct(i).boneThreshold = 250;
    imgStruct(i).fname = i;
    imgStruct(i).flag = 0; % flag is 1 only if there is error (per image)
    imgStruct(i).img_Mattress = img_Mattress; % original image or crack filled image

    % check if the skull has crack  
    %---- THIS IS MOVED INSIDE closeFracture2
    % if cracked, fill the gap 
%             crack = isCrashed(img_Mattress,250);  
%             if crack ~= 0
    %---- THIS IS MOVED INSIDE closeFracture2
    label_img = bwlabel(img, 4);
    ImFilled = imfill(label_img, 'holes');
    bw_edge = edge(ImFilled, 'Canny');
    
    imgStruct(i).bwSkullBone = bw_edge;

    if sum(img(:))>0
        % segment skull and get the center of the image
        [   imgStruct(i).center , ...\
            imgStruct(i).flag  ] = MassCenterOfSkull(imgStruct(i));  %replaced getSkullBoneAndCenter function
        
        num_realCenter = num_realCenter + 1;
        sum_realCenter = sum_realCenter + imgStruct(i).center;
    else
        idx = [idx, i];
    end

    %adding the center position to get the average later on

end

imgStruct(idx)=[];

%%
center_approx = [256,256];

if num_realCenter > 1 
    
    % approximate_ideal_midline_center
    
    if (num_realCenter ~= 0)
        center_approx = floor(sum_realCenter / num_realCenter); %only used in optRotate 1
    else
        rev = 1;
        return;
    end
else
    rev = 1;
    imgAll = [];
    fprintf('    No images to process    \n');
    return;
end
%%
%  rotate angle is zero in normal situation (default value)
count = 0;
imgAll = [];
%imgAll = imgStruct; %copying all for now

num_stru = length(imgStruct);
rotate_angle_set = zeros(1,num_stru);

for i_pos=1:num_stru
    
    if imgStruct(i_pos).flag == 1
        continue;
    end
  
    if optRotate == 1
%         [ imgStruct(i_pos).rotate_angle,imgStruct(i_pos).choosing,imgStruct(i_pos).outerBw, ...\
%             imgStruct(i_pos).innerBw, imgStruct(i_pos).rev ] = ...\
%             getRotatedAngleByApproCenter( imgStruct(i_pos).bwSkullBone, center_approx);
        [ imgStruct(i_pos).rotate_angle] = ...\
            getRotatedAngleByApproCenter( imgStruct(i_pos).bwSkullBone, center_approx);
    elseif optRotate == 2
            [ imgStruct(i_pos).rotate_angle ] = ...\
        find_rotation_angle_get_li8_ideal_onepersonjuly10_N( imgStruct(i_pos).img_Mattress, imgStruct(i_pos).bwSkullBone );
        imgStruct(i_pos).flag = 0;
    end
        
    if imgStruct(i_pos).flag ~= 0
        continue;
    end
    
    count = count + 1; 
 
    imgAll = [imgAll; imgStruct(i_pos)];
    rotate_angle_set(count) = imgAll(count).rotate_angle; 

end

%%

imgAll = imgAll(1:count);

if optAngle == 1
    rotate_angle = median(rotate_angle_set);
elseif optAngle == 2
    max_ang = max(rotate_angle_set);
    min_ang = min(rotate_angle_set);
    
    if count > 2
        rotate_angle_approximate = floor((sum(rotate_angle_set) - max_ang - min_ang)/(count - 2));
    elseif count > 0
        rotate_angle_approximate = floor(sum(rotate_angle_set)/count);
    else
        rotate_angle_approximate = 0;
    end
    rotate_angle = rotate_angle_approximate;
end



%imgAll(i_pos).rota_original_img_2D = imrotate(imgAll(i_pos).centered_img_Mattress,rotate_angle,'nearest','crop');
%%
rota = uint8(zeros(size(imgs)));
for i = 1:length(imgStruct)
    if length(imgStruct)==1
        rota(:,:) = imrotate(imgAll(i).img_Mattress,rotate_angle,'nearest','crop');
    else
    	rota(:,:,i) = imrotate(imgAll(i).img_Mattress,rotate_angle,'nearest','crop');
    end
end

end
