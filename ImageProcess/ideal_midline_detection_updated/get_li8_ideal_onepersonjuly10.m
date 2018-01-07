function rev = get_li8_ideal_onepersonjuly10(stru, adjust)

if  ~adjust 
    get_li8_ideal_onepersonjuly10(stru);
end

rev = 0;
%
% stru(person_postion).imFilePathAndName =  imFilePathAndName;
% stru(person_postion).imgnameWithoutExtendName =  imgnameWithoutExtendName;
% stru(person_postion).imgname =  imgname;
% stru(person_postion).imageDirSaveRoot =  imageDirSaveRoot;
% stru(person_postion).isDecFormat =  isDecFormat;
% stru(person_postion).imFilePathAndName =  imFilePathAndName;

num_stru = length(stru);
if num_stru == 0
    rev = 1;
    return;
end

% do some initialization

% fn_png = [imgnameWithoutExtendName, '.png'];
% fn_ideal = [dir_ideal, fn_png];
% fn_ideal_color = [dir_ideal_color, fn_png];

% fn_actualGMM =  [dir_actualGMM, fn_png];

% fn_HemoGMM =  [dir_HemoGMM, fn_png];
% fn_actualKMean = [dir_actualKMean, fn_png];
% fn_HemoKMean = [dir_HemoKMean, fn_png];

saveDir = stru(1).imageDirSaveRoot;

dir_ideal  = [ saveDir, 'dir_ideal/'];
if ~exist(dir_ideal,'dir')
    mkdir(dir_ideal);
end

dir_ideal_color  = [ saveDir, 'dir_ideal_color/'];
if ~exist(dir_ideal_color,'dir')
    mkdir(dir_ideal_color);
end

dir_ideal_color_sampleRedLine  = [ saveDir, 'dir_ideal_color_sampleRedLine/'];
if ~exist(dir_ideal_color_sampleRedLine,'dir')
    mkdir(dir_ideal_color_sampleRedLine);
end

% 
% dir_actualGMM  = [ saveDir, 'dir_actualGMM/'];
% if ~exist(dir_actualGMM,'dir')
%     mkdir(dir_actualGMM);
% end
% 
% dir_HemoGMM  = [ saveDir, 'dir_HemoGMM/'];
% if ~exist(dir_HemoGMM,'dir')
%     mkdir(dir_HemoGMM);
% end
% 
% dir_actualKMean  = [ saveDir, 'dir_actualKMean/'];
% if ~exist(dir_actualKMean,'dir')
%     mkdir(dir_actualKMean);
% end
% 
% dir_HemoKMean  = [ saveDir, 'dir_HemoKMean/'];
% if ~exist(dir_HemoKMean,'dir')
%     mkdir(dir_HemoKMean);
% end

%% ideal midline detection
fprintf('\n   1.  start ideal midline detection\n' );
fprintf('\n     (1) approximate ideal midline detection \n' );
% (1) approximate ideal midline detection
num_realCenter = 0;
sum_realCenter = [0,0];
for i_pos=1:num_stru
    [ stru(i_pos).imStru, stru(i_pos).rev ] = init(stru(i_pos).imFilePathAndName,stru(i_pos).isDecFormat);
    if stru(i_pos).rev ~= 0
        continue;
    end
    [ stru(i_pos).bwSkullBone ,stru(i_pos).center , stru(i_pos).rev] = getSkullBoneAndCenter(stru(i_pos).imStru);
    if stru(i_pos).rev ~= 0
        continue;
    end
    num_realCenter = num_realCenter + 1;
    sum_realCenter = sum_realCenter + stru(i_pos).center;
end


imStru.boneThreshold = stru(1).imStru.boneThreshold;
boneThreshold = imStru.boneThreshold;

% approximate_ideal_midline_center
center_approxate = [256,256];
if (num_realCenter ~= 0)
    center_approxate = floor(sum_realCenter / num_realCenter);
else
    rev = 1;
    return;
end

%  rotate angle is zero in normal situation (default value)
rotate_angle_set = zeros(1,num_stru);
num_rotate_angle_approximate = 0;
i_pos_good = 0;
stru_good=[];
for i_pos=1:num_stru
    [ stru(i_pos).rotate_angle,stru(i_pos).choosing, stru(i_pos).outerBw, ...\
        stru(i_pos).innerBw, stru(i_pos).rev ] = ...\
        getRotatedAngleByApproCenter( stru(i_pos).bwSkullBone, center_approxate);
%     % N: to find the best initial rotation angle based on orientation, we
%     % arenot using the initial angle based on symmetry which is aquired
%     % above.
%     [ stru(i_pos).rotate_angle ] = ...\
%         find_rotation_angle_get_li8_ideal_onepersonjuly10_N( stru(i_pos).imStru.img_Mattress);
    if stru(i_pos).rev ~= 0
        continue;
    end
    num_rotate_angle_approximate = num_rotate_angle_approximate + 1;
    
    i_pos_good = i_pos_good + 1;
    rotate_angle_set(i_pos_good) = stru(i_pos).rotate_angle; 
    stru_good(i_pos_good).imFilePathAndName = stru(i_pos).imFilePathAndName;
    stru_good(i_pos_good).isDecFormat = stru(i_pos).isDecFormat;
    stru_good(i_pos_good).imageDirSaveRoot = stru(i_pos).imageDirSaveRoot;
    stru_good(i_pos_good).imStru = stru(i_pos).imStru;
    stru_good(i_pos_good).bwSkullBone = stru(i_pos).bwSkullBone;
    stru_good(i_pos_good).center = stru(i_pos).center;
    stru_good(i_pos_good).rotate_angle = stru(i_pos).rotate_angle;
    stru_good(i_pos_good).choosing = stru(i_pos).choosing;
    stru_good(i_pos_good).outerBw = stru(i_pos).outerBw;
    stru_good(i_pos_good).innerBw = stru(i_pos).innerBw;
    stru_good(i_pos_good).imgnameWithoutExtendName = stru(i_pos).imgnameWithoutExtendName;
    
end

max_ang = max(rotate_angle_set);
min_ang = min(rotate_angle_set);

if num_rotate_angle_approximate > 2
    rotate_angle_approximate = floor((sum(rotate_angle_set) - max_ang - min_ang)/(num_rotate_angle_approximate - 2));
elseif num_rotate_angle_approximate > 0
    rotate_angle_approximate = floor(sum(rotate_angle_set)/num_rotate_angle_approximate);
else
    rotate_angle_approximate = 0;
end

center = center_approxate;
rotate_angle = rotate_angle_approximate;

% set the new size and then centerlize the rescaled bone and CT image.
new_width=floor(1.5*size(stru(1).bwSkullBone,2));
new_height=floor(1.5*size(stru(1).bwSkullBone,1));

fprintf('    (1) result of approximate ideal midline detection:\n        rotate_angle = %d; center = [ %d, %d ] \n',rotate_angle, center(1), center(2) );

for i_pos=1:i_pos_good
    % center the image with the same center (center_approxate).
    stru_good(i_pos).centered_img_Mattress=centerimg_size(stru_good(i_pos).imStru.img_Mattress, center, new_width, new_height);
    stru_good(i_pos).centered_bwSkullBone=centerimg_size(stru_good(i_pos).bwSkullBone, center,new_width, new_height);
    stru_good(i_pos).centered_innerBw = centerimg_size(stru_good(i_pos).innerBw, center,new_width, new_height);
    
    % rotate centered_img_Mattress
    stru_good(i_pos).rota_original_img_2D = imrotate(stru_good(i_pos).centered_img_Mattress,rotate_angle,'nearest','crop');
    stru_good(i_pos).rota_original_img = zeros([size(stru_good(i_pos).rota_original_img_2D),3]);
    
    for i=1:3
        stru_good(i_pos).rota_original_img(:,:,i) = stru_good(i_pos).rota_original_img_2D;
    end
    
    % rotate centered_bwSkullBone
    stru_good(i_pos).rota_bwSkullBone = imrotate(stru_good(i_pos).centered_bwSkullBone,rotate_angle,'nearest','crop');
    stru_good(i_pos).rota_seg = stru_good(i_pos).rota_bwSkullBone; % for reading previous code
    stru_good(i_pos).rota_innerBw = stru_good(i_pos).centered_innerBw;
    
end

%(2) accurate ideal midline detection (according to the anatomic character)
fprintf('\n    (2) actual ideal midline detection \n' );
weight_set = zeros(1,num_stru);
adjust_Ang_set = zeros(1,num_stru);
adjust_Center_set = zeros(1,num_stru);
num_accurate = 0;
sum_accurateCenter = [0,0];
for i_pos=1:i_pos_good    
    % initialize the variation to simplify the calculation and reuse code
    rota_bwSkullBone = stru_good(i_pos).rota_bwSkullBone;
    rota_original_img = stru_good(i_pos).rota_original_img;
%     imStru.boneThreshold = stru_good(i_pos).imStru.boneThreshold;
    
    choosing = stru_good(i_pos).choosing;
    
    % get extreme value points
    % get bump which is the lowest point on upper by getUpperPoint()
    [bumpPoint, I_upper_lowest, boneInupper_boximg, boxRect_upper, isFoundBump, rev] = ...\
        getUpperPoint(rota_bwSkullBone);
    if rev ~= 0
        continue;
    end
    
    % get bump which is the lowest point on upper by getUpperPoint()
    [linePoint, I_lower_uppest, boneInlower_boximg,boxRect_lower, isFoundLowerUppest, rev] = ...\
        getLowerPoint(rota_bwSkullBone,rota_original_img);
    if rev ~= 0
        continue;
    end
    
    % mark the image with lines and boxes
    rota_original_img=drawbox(rota_original_img, boxRect_upper,imStru.boneThreshold + 1);
    rota_original_img=drawbox(rota_original_img, boxRect_lower,imStru.boneThreshold + 1);
    
    % mark the midline
    x_midline=floor(size(rota_original_img,2)/2);
    
    % red for symmetric approximate midline
    % rota_original_img(:,x_midline,1)=imStru.boneThreshold + 1;
    
    % the tactic of dealing with these two extreme value point.
    [ xy2_bump, xy2_linept, rota_original_img, rota_bwSkullBone, adjust_Ang_center, weight, rev] = ...\
        getValidatedExtremePointAndWeightByTactic( ...\
        bumpPoint, isFoundBump,  I_upper_lowest,  ...\
        linePoint, isFoundLowerUppest, I_lower_uppest, ...\
        choosing, rota_bwSkullBone, rota_original_img, imStru.boneThreshold);
    if rev ~= 0
        continue;
    end
    
    num_accurate = num_accurate + 1;
    adjust_Ang_set(i_pos) = adjust_Ang_center(1);
    sum_accurateCenter = sum_accurateCenter + weight.*[adjust_Ang_center(2),adjust_Ang_center(3)];
    weight_set(i_pos) = weight;

end

[max_ang, index_max] = max(adjust_Ang_set);
[min_ang, index_min] = min(adjust_Ang_set);

if num_accurate > 2
    rotate_angle_actural_idealmidline = floor((sum(adjust_Ang_set) - max_ang - min_ang)/(num_accurate - 2));
elseif num_accurate > 0
    rotate_angle_actural_idealmidline = floor(sum(adjust_Ang_set)/num_accurate );
else
    rotate_angle_actural_idealmidline = 0;
end

ave_accurateCenter = floor(sum_accurateCenter/sum(weight_set));
% the center and angle of actual ideal midline detection.
m_x = ave_accurateCenter(1);
m_y = ave_accurateCenter(2);
fan_angle = rotate_angle_actural_idealmidline;

fprintf('    (2) result of actual ideal midline detection:\n        rotate_angle = %d; center = [ %d, %d ] \n',fan_angle, m_x, m_y );

% rotate all ct slice to the fan_angle at center [m_x,m_y]
% note: this is the 2nd rotatioin(one is for approximate, here is for actual) 
% so if want to change back to coordination, it need to do twice.
for i_pos=1:i_pos_good % num_stru    
      
   % fan_angle = adjust_Ang_center(1);
   
   % <--> use the above definition of m_x and m_y seems more resonable. 11/24/2013
%     m_x = adjust_Ang_center(2);
%     m_y = adjust_Ang_center(3);
    % </-->
    
    rota_bwSkullBone = stru_good(i_pos).rota_bwSkullBone;
    rota_original_img = stru_good(i_pos).rota_original_img;
    
    rota_original_img=centerimg(rota_original_img,[m_x,m_y],'crop');
    rota_original_img=imrotate(rota_original_img, fan_angle,'nearest','crop');
    rota_bwSkullBone=centerimg(rota_bwSkullBone,[m_x,m_y],'crop');
    rota_bwSkullBone=imrotate(rota_bwSkullBone, fan_angle,'nearest','crop');
    
%   mark the midline green
    rota_original_img_green = rota_original_img;
    rota_original_img_green(:,floor(size(rota_original_img,2)/2),2)= imStru.boneThreshold + 1;
    
    % get 2D version of rota_original_img
    rota_original_img_2D = rota_original_img(:,:,3);
    
    % save to image structure 
    stru_good(i_pos).rota_bwSkullBone = rota_bwSkullBone;
    stru_good(i_pos).rota_original_img = rota_original_img;
    stru_good(i_pos).rota_original_img_2D = rota_original_img_2D;
    stru_good(i_pos).rota_original_img_green = rota_original_img_green;
    
    fn_png = [stru_good(i_pos).imgnameWithoutExtendName, '.png'];
    fn_ideal = [dir_ideal, fn_png];
    fn_ideal_color = [dir_ideal_color, fn_png];
    fn_ideal_color_sampleRedLine = [dir_ideal_color_sampleRedLine, fn_png];

    [mask_roi, rev] = getinnerbrainwhite(rota_original_img_2D, imStru.boneThreshold);
    if(rev ~= 0)
        stru_good(i_pos).ismasked = false;
        stru_good(i_pos).rota_original_img_2D_masked = rota_original_img_2D;
        stru_good(i_pos).rota_original_img_masked = stru_good(i_pos).rota_original_img;
%         continue; % broken skull.
    else
        stru_good(i_pos).ismasked = true;
        stru_good(i_pos).mask_roi = mask_roi;
        tmp = floor(rota_original_img_2D.*mask_roi);
        stru_good(i_pos).rota_original_img_2D_masked = tmp;
        for i=1:3
           stru_good(i_pos).rota_original_img_masked(:,:,i) = tmp;
        end
         
    end
    
   
% if     stru_good(i_pos).ismasked then deal with else does not save or operate it.
   imwrite(uint8(rota_original_img_2D.*mask_roi), fn_ideal);
   imwrite(uint8(rota_original_img), fn_ideal_color);
   for i=1:5:776
   rota_original_img(i:i+5,384:387,1) = 255;
   end
   imwrite(uint8(rota_original_img), fn_ideal_color_sampleRedLine);
   
 
    % recover to original coordination of bump and gray point
    % Two step: (1) rotate inversely (2)parrallel move 
%     rota_center_p = [floor(size(rota_bwSkullBone,2)/2),floor(size(rota_bwSkullBone,1)/2)];
%     
%     [ xy1_bump,xy1_linept, rev ] = ...\
%         getOriPosition( xy2_bump,xy2_linept, rota_center_p, center, rotate_angle);
%     if rev ~= 0
%         return;
%     end
end



%%
%%  actural midline detection
%% ideal midline detection
% fprintf('\n   2.  start actural midline detection\n' );
% fprintf('\n     (1) approximate ideal midline detection \n' );
% fprintf('\n start actural midline detection\n' );
% % for windows
% templateDir ='./actual_midline_detection/atlas/template5.3/'; % tpdir1
% 
% % for linux
% % templateDir ='./actual_midline_detection/atlas/template5.3/'; % tpdir1
% 
% [mask_roi, rev] = getinnerbrainwhite(rota_original_img_2D, imStru.boneThreshold);
% if(rev ~= 0)
%     return; % broken skull.
% end
% 
% % imwrite(uint8(rota_original_img_2D.*mask_roi), fn_ideal);
% % imwrite(uint8(rota_original_img), fn_ideal_color);
% 
% %%%%%%%%%%%%%% repeat 5 6 7 for another method.
% [vent_map_kmean, rev] = Kmean_segmentation( ...\
%     rota_original_img_2D, mask_roi, isDecFormat, imStru.boneThreshold);
% 
% %% 6. For template and shape
% 
% % test_actual_midline %% generate the actual midline: img_actual_midline
% [ img_actual_midline_kmean,rev] ...\
%     = actual_midline_detection(vent_map_kmean,rota_original_img, imStru.boneThreshold + 1, templateDir);
% 
% imwrite(uint8(img_actual_midline_kmean), fn_actualKMean);
% close;

end