% for windows
imageDirRoot = 'D:\myNetDriver\qxgbuy2011\project_ventricle_paper\data_testResult\testli8ActualFin\dir_ideal\';

imageDirSaveRoot1 = 'D:\myNetDriver\qxgbuy2011\project_ventricle_paper\data_testResult\testli8ActualFin\dir_actualLi8_win_slice\finalWithoutTitle\';
imageDirSaveRoot2 = 'D:\myNetDriver\qxgbuy2011\project_ventricle_paper\data_testResult\testli8ActualFin\dir_actualLi8_win_slice\finalWithTitle\';

% deal with the save directory
if ~exist(imageDirSaveRoot1,'dir')
    mkdir(imageDirSaveRoot1);
end
if ~exist(imageDirSaveRoot2,'dir')
    mkdir(imageDirSaveRoot2);
end
 
imgList = dir([imageDirRoot, '*.png']);
 
lenList = length(imgList); 

fprintf('lenList is : %d . \r\n',lenList);

for i_img = 1: lenList
    
    imgname = imgList(i_img).name;
    
    fprintf('  image name is : %s . \r\n',imgname);
    
    filenamewithpath = [imageDirRoot ,imgname ];
    
    savefilenamewithpath1 = [imageDirSaveRoot1 ,imgname ];
    savefilenamewithpath2 = [imageDirSaveRoot2 ,imgname ];
        
    levelsetImg_3D = imread(filenamewithpath);
    
    windows = [];
    
[midline_x, midline_y, fan_angle, ...\ 
    actualmidlineImgMarked, actualmidlineImgMarked_withTitle, rev] ...\
    = getActualImageAndCenterAndRotatedangle(levelsetImg_3D, windows);

if rev == 0
    imwrite( uint8(actualmidlineImgMarked) ,savefilenamewithpath1);
    imwrite( uint8(actualmidlineImgMarked_withTitle) ,savefilenamewithpath2);
    fprintf('      successful to detect actual midline \n');
    fprintf('      the angle rotated is %d. \n', fan_angle);
else
    fprintf('      fail to detect actual midline \n');
end
    fprintf('---------------------------------------------------- \n');
end