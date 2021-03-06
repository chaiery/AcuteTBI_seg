function [ xy2_bump, xy2_linept, rota_original_img, rota_bwSkullBone, adjust_Ang_center, rev] ...\
        = getValidatedExtremePointByTactic( ...\ 
       bumpPoint, isFoundBump,  I_upper_lowest,  ...\
       linePoint, isFoundLowerUppest, I_lower_uppest, ...\  
       choosing, rota_bwSkullBone, rota_original_img, boneThreshold)

rev = 0;
xy2_bump = bumpPoint;
xy2_linept = linePoint;

center_x = floor(size(rota_bwSkullBone,2)/2);
center_y = floor(size(rota_bwSkullBone,1)/2);
if isempty(choosing)
    choosing = 1;
end

% the degree ( must less degree threhold) adjusted 
% the center (m_x, m_y)
% the rota_bwSkullBone and rota_original_img wil be rotated again with 
fan_angle = 0;
m_x=floor((bumpPoint(1)+linePoint(1))/2);
m_y=floor((bumpPoint(2)+linePoint(2))/2);   
    
if isFoundBump && isFoundLowerUppest
    xy2_bump = bumpPoint;
    xy2_linept = linePoint;
    
    % get the midpoint of the line
    m_x=floor((bumpPoint(1)+linePoint(1))/2);
    m_y=floor((bumpPoint(2)+linePoint(2))/2);    

    % get the angle of the rotate and rotate
    a = linePoint(1) - bumpPoint(1);
    b = linePoint(2) - bumpPoint(2);
    alpha=atan(-a/b);
    fan_angle = alpha*180/pi; 
           
    degree_th = 5;
    if abs(fan_angle) > degree_th
        % use previous approximate midline goten only by symmetry
        % This situation the same as ~isFoundBump && ~isFoundLowerUppest
        m_x = floor(size(rota_original_img,2)/2);
        m_y = floor(size(rota_original_img,1)/2);
        alpha = 0;
        fan_angle = 0;
        
        xy2_bump=[center_x, I_upper_lowest];
        xy2_linept=[center_x, I_lower_uppest];
    end          

    rota_original_img = centerimg(rota_original_img,[m_x,m_y],'crop');
    rota_original_img = imrotate(rota_original_img, fan_angle, 'nearest', 'crop');
    rota_bwSkullBone = centerimg(rota_bwSkullBone,[m_x,m_y],'crop');
    rota_bwSkullBone = imrotate(rota_bwSkullBone, fan_angle,'nearest','crop');
    
    %% mark the midline green
    rota_original_img(:,floor(size(rota_original_img,2)/2),2)=boneThreshold + 1;
    
elseif ~isFoundBump && isFoundLowerUppest
    %% use the line Point under lower region and small fan to detect the midline

    %% get the line point coordinate of the rotated image.
    line_pt_x=linePoint(1); 
    line_pt_y=linePoint(2);
    half_length=abs(line_pt_y-center_y);

    %% center the image with low line point
    centered_seg_bump=centerimg(rota_bwSkullBone, [line_pt_x, line_pt_y], 'crop');
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
    xy2_linept=[linePoint(1),linePoint(2)];

    %% plot the line on the image
    % plot([x_coord_lowest;x2],[y_coord_lowest;y2],'m.-');

    %% rotate to the new angle
    m_x=floor((line_pt_x+x2)/2);
    m_y=floor((line_pt_y+y2)/2);

    rota_original_img=centerimg(rota_original_img,[m_x,m_y],'crop');
    rota_original_img=imrotate(rota_original_img, fan_angle,'crop');
    rota_bwSkullBone=centerimg(rota_bwSkullBone,[m_x,m_y],'crop');
    rota_bwSkullBone=imrotate(rota_bwSkullBone, fan_angle,'crop');

    %% mark it yellow
    rota_original_img(:,floor(size(rota_original_img,2)/2),1)=boneThreshold + 1;
    rota_original_img(:,floor(size(rota_original_img,2)/2),2)=boneThreshold + 1;
elseif isFoundBump && ~isFoundLowerUppest
    %% get the bump point coordinate of the rotated image.
    bump_x=floor(size(rota_original_img,2)/2);
    half_length=abs(center_y-bumpPoint(2));

    bump_y=floor(floor(size(rota_original_img,1)/2)-half_length);

    %% center the image with bump point
    centered_seg_bump=centerimg(rota_bwSkullBone, [bump_x,bump_y], 'crop');
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
    x2=bumpPoint(1)+full_length*sin(rot_ang/180*pi);
    y2=bumpPoint(2)+full_length*cos(rot_ang/180*pi);

    %% for return value calculation later
    xy2_bump=[bumpPoint(1), bumpPoint(2)];
    xy2_linept=[x2,y2];


    %% plot the line on the image

    % plot([x_coord_lowest;x2],[y_coord_lowest;y2],'m.-');

    %% rotate to the new angle
    m_x=floor((bumpPoint(1)+x2)/2);
    m_y=floor((bumpPoint(2)+y2)/2);

    rota_original_img=centerimg(rota_original_img,[m_x,m_y],'crop');
    rota_original_img=imrotate(rota_original_img, fan_angle,'nearest','crop');
    rota_bwSkullBone=centerimg(rota_bwSkullBone,[m_x,m_y],'crop');
    rota_bwSkullBone=imrotate(rota_bwSkullBone, fan_angle,'nearest','crop');

    %% mark it yellow
    rota_original_img(:,floor(size(rota_original_img,2)/2),1)=boneThreshold + 1;
    rota_original_img(:,floor(size(rota_original_img,2)/2),2)=boneThreshold + 1;
    
else % no points are detected
    xy2_bump=[center_x, I_upper_lowest];
    xy2_linept=[center_x, I_lower_uppest];
    
    m_x = floor(size(rota_original_img,2)/2);
    m_y = floor(size(rota_original_img,1)/2); 
    
    %% mark the midline red
    rota_original_img(:,floor(size(rota_original_img,2)/2),1)=boneThreshold + 1;
end

adjust_Ang_center = [fan_angle, m_x, m_y];

end