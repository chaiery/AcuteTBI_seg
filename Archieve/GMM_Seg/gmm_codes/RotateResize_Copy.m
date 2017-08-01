function [imgAll, rotate_angle, rev] = RotateResize(ImgDir, SaveDir, optRotate, optAngle, optSave)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [imgAll, rotate_angle] = RotateResize(ImgDir, SaveDir, optRotate, optAngle, optSave)
%
% Rotate and Resize the head CT images to align the head at the center of
% the image with vertical alignment
%
%--------- Inputs ------------
% ImgDir : Directory where the CT files are located
% SaveDir : Directory to save the results
% optRotate : Can choose between two different options
%               1) Wenan's Original method
%               2) Negar's imrotate method
% optAngle : method to choose the best angle of rotation
%               1) Median
%               2) Wenan's method
% optSave : 1) Save the final image in the SaveDir
%           2) Do not save the final image       
%
%--------- Outputs ------------
% ImgAll : Struct containing manipulated results with following fields
%             'flag'
%             'rotate_angle'
%             'img_Mattress'
%             'boneThreshold'
%             'bwSkullBone'
%             'center'
%             'fname'
%             'centered_img_Mattress'
%             'rota_original_img_2D'
%             'rota_original_img'
%             'mask_roi'
%             'rotated_resize_img_final'
%
% roate_angle : final rotation angle for all images
% rev         : flag for patient specific error (not per image)
%
% Written by Eunji Kang 10/29/2015    University of Michigan
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3
    optRotate = 1; % default method willbe Wenan's
    optAngle = 1;
    optSave = 1;
elseif nargin < 4
    optAngle = 1;
    optSave = 1;
elseif nargin < 5
    optSave = 1;
end


% Directory to save all the results:
% create the save folder if doesn't exist 
% only if the save option is enabled
if optSave == 1
    if ~exist(SaveDir, 'dir')
        mkdir(SaveDir);
    end
end

% get image files
ImgFiles = dir(ImgDir);

% flag for any errors
rev = 0; %patient specific errors 

%Initialization
num_realCenter = 0;
sum_realCenter = [0,0];
imgStruct = [];

% Run through all image files
for i = 1:length(ImgFiles)
    fname = ImgFiles(i).name;
    if length(fname) > 3
        if strcmp(fname(end-2:end),'jpg') || strcmp(fname(end-2:end),'png')|| strcmp(fname(end-2:end),'dcm') || fname(end-3)~='.'
            
            % Read image into matrix
            if fname(end-3)~='.' && strcmp(fname(end-2:end),'jpg') 
                img = imread_edit([ImgDir,'\', fname]);
            else
                img = dicomread([ImgDir,'\', fname]);
            end
            if ndims(img) ~=2
                img = img(:,:,1);
            end
            
            img_Mattress = img;
            
            % create struct to store all the computed results and relevant
            % information
            imgStruct(i).boneThreshold = 250;
            imgStruct(i).fname = fname;
            imgStruct(i).flag = 0; % flag is 1 only if there is error (per image)
            
            % check if the skull has crack
            % if cracked, fill the gap 
%             crack = isCrashed(img_Mattress,250);
            crack = 0;
            if crack ~= 0
                img_Mattress = closeFracture(img_Mattress);
            end
            imgStruct(i).img_Mattress = img_Mattress; % original image or crack filled image
            

            % segment skull and get the center of the image
            [   imgStruct(i).bwSkullBone , ...\
                imgStruct(i).center , ...\
                imgStruct(i).flag  ] = getSkullBoneAndCenter(imgStruct(i));

            %adding the center position to get the average later on
            num_realCenter = num_realCenter + 1;
            sum_realCenter = sum_realCenter + imgStruct(i).center;
        else
            imgStruct(i).flag = 1; 
        
        end
    else
        imgStruct(i).flag = 1;
    end
    imgStruct(i).rotate_angle = 0; % create placeholder for later
end

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

%  rotate angle is zero in normal situation (default value)
count = 0;
imgAll = imgStruct; %copying all for now

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
 
    imgAll(count) = imgStruct(i_pos);
    rotate_angle_set(count) = imgAll(count).rotate_angle; 

end
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

center = center_approx;

% set the new size and then centerlize the rescaled bone and CT image.
new_width=floor(1.5*size(imgAll(1).bwSkullBone,2));
new_height=floor(1.5*size(imgAll(1).bwSkullBone,1));

if count < 1
    rev = 1;
    imgAll = [];
    fprintf('    No images to process    \n');
    return;
end

for i_pos=1:count
    % center the image with the same center (center_approxate).
    imgAll(i_pos).centered_img_Mattress=centerimg_size(imgAll(i_pos).img_Mattress, center, new_width, new_height);
%     imgAll(i_pos).centered_bwSkullBone=centerimg_size(imgAll(i_pos).bwSkullBone, center,new_width, new_height);
%     imgAll(i_pos).centered_innerBw = centerimg_size(imgAll(i_pos).innerBw, center,new_width, new_height);
    
    % rotate centered_img_Mattress
    imgAll(i_pos).rota_original_img_2D = imrotate(imgAll(i_pos).centered_img_Mattress,rotate_angle,'nearest','crop');
    imgAll(i_pos).rota_original_img = zeros([size(imgAll(i_pos).rota_original_img_2D),3]);
    
    for i=1:3
        imgAll(i_pos).rota_original_img(:,:,i) = imgAll(i_pos).rota_original_img_2D;
    end
    
    % rotate centered_bwSkullBone
%     imgAll(i_pos).rota_bwSkullBone = imrotate(imgAll(i_pos).centered_bwSkullBone,rotate_angle,'nearest','crop');
%     imgAll(i_pos).rota_seg = imgAll(i_pos).rota_bwSkullBone; % for reading previous code
%     imgAll(i_pos).rota_innerBw = imgAll(i_pos).centered_innerBw;
    
    % get 2D version of rota_original_img
    rota_original_img_2D = imgAll(i_pos).rota_original_img_2D;
    % if     stru_good(i_pos).ismasked then deal with else does not save or operate it.
    SaveFileName = [SaveDir, '\' imgAll(i_pos).fname(1:end-3), '.png'];
    [imgAll(i_pos).mask_roi, imgAll(i_pos).flag] = getinnerbrainwhite(rota_original_img_2D, imgAll(i_pos).boneThreshold);
    imgAll(i_pos).rotated_resize_img_final = uint8(rota_original_img_2D.*imgAll(i_pos).mask_roi);
    
    if optSave == 1
        imwrite(imgAll(i_pos).rotated_resize_img_final, SaveFileName);
    end
    
end

