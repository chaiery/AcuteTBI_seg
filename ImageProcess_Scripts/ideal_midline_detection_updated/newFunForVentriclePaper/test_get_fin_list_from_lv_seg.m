% fn_png_withoutIdeal = 'D:\myNetDriver\qxgbuy2011\project_ventricle_paper\data_testResult\July1st\dir_actualLi8_withoutIdeal\Patient 8722141_10042006-225106_13.png';

imageDirRoot = 'D:\myNetDriver\qxgbuy2011\project_ventricle_paper\data_testResult\July1st\seg_dir\';
imageDirRoot_ori = 'D:\myNetDriver\qxgbuy2011\project_ventricle_paper\data_testResult\data_after_idealmidline\dir_ideal\';

save_dir = 'D:\myNetDriver\qxgbuy2011\project_ventricle_paper\data_testResult\July1st\seg_dir_fin_image\';

if ~exist(save_dir,'dir')
    mkdir(save_dir);
end

imgList = dir([imageDirRoot, '*.png']);

lenList = length(imgList);

fprintf('lenList is : %d . \r\n',lenList);


for i_img = 1: lenList
    
    imgname = imgList(i_img).name;
    %
    %     if strncmp(imgname ,'Patient 8794417_08022006-030838_14_markedWithoutTitle.png',29)
    %         isNotCorrestTest = false;
    %     end
    %
    %     if isNotCorrestTest
    %         continue;
    %     end
    %
    
    in = strfind(imgname,'.png');
 
    firstPartOfFilename = imgname(1:in-1);
    imgnameWithoutExtendName = firstPartOfFilename;
    
    imFilePathAndName = [imageDirRoot,imgname];    
    levelsetImg_3D = imread(imFilePathAndName);
    
    
    imFilePathAndName_ori = [imageDirRoot_ori,imgname];    
    levelsetImg_3D_ori = imread(imFilePathAndName_ori);
    
    if ndims(levelsetImg_3D_ori) == 2
        tmp = levelsetImg_3D_ori;
        levelsetImg_3D_ori = zeros([size(levelsetImg_3D_ori),3]);
        levelsetImg_3D_ori(:,:,1) = tmp;    
        levelsetImg_3D_ori(:,:,2) = tmp; 
        levelsetImg_3D_ori(:,:,3) = tmp; 
        levelsetImg_3D_ori = uint8(levelsetImg_3D_ori);
    end
    
    % get marked actual midline
    windows = [];
    
%     [midline_x, midline_y, fan_angle, ...\
%         actualmidlineImgMarked, actualmidlineImgMarked_withTitle, rev] ...\
%         = getActualImageAndCenterAndRotatedangle(levelsetImg_3D, windows);

    [midline_x, midline_y, fan_angle, ...\
          vleft, vright, v_all, mask_midline_draw, ...\ 
    actualmidlineImgMarked, actualmidlineImgMarked_withTitle, rev] ...\
    = getLeftAndRitghtVentricleParameters(levelsetImg_3D);

    if rev ~= 0
        continue;
    end
    % path(p);
    
    %      actualmidlineImgMarked
    fn_marked_png = [imgnameWithoutExtendName, '_markedWithTitle'];
    fn_marked_png = [fn_marked_png, '.png']; 
    fn_marked_png_withoutIdeal =  [save_dir, fn_marked_png];

    %      actualmidlineImgMarked_withTitle
    fn_markedNoTitle_png = [imgnameWithoutExtendName, '_markedWithoutTitle'];
    fn_markedNoTitle_png = [fn_markedNoTitle_png, '.png']; 
    fn_markedNoTitle_png_withoutIdeal =  [save_dir, fn_markedNoTitle_png];
    
    
    actualmidlineImgMarked_ori = zeros(size(levelsetImg_3D_ori));
    actualmidlineImgMarked_ori_without_mid = levelsetImg_3D_ori;
    actualmidlineImgMarked_ori_without_mid(:,:,1) = uint8(double(actualmidlineImgMarked_ori_without_mid(:,:,1)) + double(v_all.*255));
    
    %      actualmidlineImgMarked_ori_without_mid
    fn_marked_png_ori_without_mid = [imgnameWithoutExtendName, '_ori_without_mid'];
    fn_marked_png_ori_without_mid = [fn_marked_png_ori_without_mid, '.png']; 
    fn_marked_png_ori_without_mid =  [save_dir, fn_marked_png_ori_without_mid];
    
    
    actualmidlineImgMarked_ori_with_mid = actualmidlineImgMarked_ori_without_mid;
    actualmidlineImgMarked_ori_with_mid = uint8(double(actualmidlineImgMarked_ori_with_mid) + double(mask_midline_draw));
    %      actualmidlineImgMarked_ori_with_mid
    fn_marked_png_ori_with_mid = [imgnameWithoutExtendName, '_ori_with_mid'];
    fn_marked_png_ori_with_mid = [fn_marked_png_ori_with_mid, '.png']; 
    fn_marked_png_ori_with_mid =  [save_dir, fn_marked_png_ori_with_mid];

    

%     %      actualmidlineImgMarked_with_mid
%     fn_markedNoTitle_png_ori = [imgnameWithoutExtendName, '_ori_markedWithoutTitle'];
%     fn_markedNoTitle_png_ori = [fn_markedNoTitle_png_ori, '.png']; 
%     fn_markedNoTitle_png_ori_withoutIdeal =  [save_dir, fn_markedNoTitle_png_ori];
%     actualmidlineImgMarked_ori = zeros(size(levelsetImg_3D_ori));
%     levelsetImg_3D_ori(:,:,1) = uint8(double(levelsetImg_3D_ori(:,:,1)) + double(v_all.*255));
    
    if rev == 0
        imwrite( uint8(actualmidlineImgMarked) ,fn_markedNoTitle_png_withoutIdeal);
        imwrite( uint8(actualmidlineImgMarked_withTitle) ,fn_marked_png_withoutIdeal);
        
        imwrite( uint8(actualmidlineImgMarked_ori_without_mid) ,fn_marked_png_ori_without_mid);
        imwrite( uint8(actualmidlineImgMarked_ori_with_mid) ,fn_marked_png_ori_with_mid);
        
        
        fprintf('      successful to detect actual midline \n');
        fprintf('      the angle rotated is %d. \n', fan_angle);
    else
        fprintf('      fail to detect actual midline \n');
    end
    
end