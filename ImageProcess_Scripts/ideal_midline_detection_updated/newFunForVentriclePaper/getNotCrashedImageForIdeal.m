close all;
clc;

%add to path
p = path;
path(path, '../generalTool');
path(path, 'ideal_midline_detection');
path(path, 'ct_gmm_segmentation');
path(path, 'hemo_detection');
path(path, 'ct_kmean_segmentation');
path(path, 'actual_midline_detection');
path(path, 'actual_midline_detection/shapes');

path(path, 'newFunForVentriclePaper');

imStru = [];
% imStru.img_Mattress = img_Mattress;
% imStru.SliceThickness = info.SliceThickness;
% imStru.PixelSpacing = info.PixelSpacing;
%  set the depth of slices

% initial some value of imStru
% imStru.SliceThickness = 4.5;
% imStru.PixelSpacing = 0.46875;
% imStru.boneThreshold = 250; % default for jpg format

% set jpg format or dicom format
isDecFormat = false;
if isDecFormat
    imStru.boneThreshold = 500;
    imStru.isDecFormat = true;
else
    imStru.boneThreshold = 250;
    imStru.isDecFormat = false;
end

save_notcrashDir='C:\Users\Qi\Documents\MATLAB\project_2012\july10\test_result\dataset\forbk5\after_checkcrash\';

% for windows
imageDirRoot = 'D:\myNetDriver\qxgbuy2011\project_2012\data\testSample\';
imageDirRoot = 'D:\myNetDriver\qxgbuy2011\project_2012\data\testForActual\';


imageDirSaveRoot = 'D:\myNetDriver\qxgbuy2011\project_ventricle_paper\data_testResult\testSample\';
imageDirSaveRoot = 'D:\myNetDriver\qxgbuy2011\project_ventricle_paper\data_testResult\testli8IdealFin\';

imageDirRoot = 'C:\Users\Qi\Documents\MATLAB\project_2012\july10\new_case_control_3D\4272820\20051021.20.46\';
imageDirSaveRoot = 'C:\Users\Qi\Documents\MATLAB\project_2012\july10\test_result\Idealdetection\';

% bk 2
imageDirRoot = 'C:\Users\Qi\Documents\MATLAB\project_2012\july10\new_case_control_3D\4354716\20060714.17.28\';

% bk 3
imageDirRoot = 'C:\Users\Qi\Documents\MATLAB\project_2012\july10\new_case_control_3D\5501162\20050908.16.33\';

% bk 4
imageDirRoot = 'C:\Users\Qi\Documents\MATLAB\project_2012\july10\new_case_control_3D\case_3D\6338651\20051023.18.20\';

% bk 5
imageDirRoot = 'C:\Users\Qi\Documents\MATLAB\project_2012\july10\new_case_control_3D\case_3D\4272820\20051019.10.50\';

% bk 6 good the second one
imageDirRoot = 'C:\Users\Qi\Documents\MATLAB\project_2012\july10\new_case_control_3D\case_3D\4222004\20050501.01.48_602\';

% bk 7 
imageDirRoot = 'C:\Users\Qi\Documents\MATLAB\project_2012\july10\new_case_control_3D\case_3D\1248835\20051012.12.00\';

% bk 6 
imageDirRoot = 'C:\Users\Qi\Documents\MATLAB\project_2012\july10\test_result\dataset\forbk6\bk6_ori\';
save_notcrashDir = 'C:\Users\Qi\Documents\MATLAB\project_2012\july10\test_result\dataset\forbk6\after_checkcrash\';

% bk 5 
imageDirRoot = 'C:\Users\Qi\Documents\MATLAB\project_2012\july10\test_result\dataset\forbk5\bk5_ori\';
save_notcrashDir = 'C:\Users\Qi\Documents\MATLAB\project_2012\july10\test_result\dataset\forbk5\after_checkcrash\';

imageDirRoot = 'C:\Users\Qi\Documents\MATLAB\project_2012\july10\test_result\dataset\forbk7\bk7_ori\';
save_notcrashDir = 'C:\Users\Qi\Documents\MATLAB\project_2012\july10\test_result\dataset\forbk7\after_checkcrash\';




if ~exist(save_notcrashDir,'dir')
    mkdir(save_notcrashDir);
end
% for linux 
% imageDirRoot = '/home1/qix2/project/project_2012/data/Images_flat/';
% imageDirSaveRoot = '/home1/qix2/project/project_2012/data_testResult/';

% deal with the save directory
if ~exist(imageDirSaveRoot,'dir')
    mkdir(imageDirSaveRoot);
end

if isDecFormat
    imgList = dir([imageDirRoot, '*.dcm']);
else
    imgList = dir([imageDirRoot, '*.jpg']);
end

lenList = length(imgList); 

if lenList == 0
 imgList = dir([imageDirRoot, '*.png']);
 lenList = length(imgList); 
end

fprintf('lenList is : %d . \r\n',lenList);

imFilePathAndName_pre = '';
isFirstSliceOfFirstPerson = true;
person_postion = 0;
stru = '';
stru_good = '';
person_num = 1;

goodperson_postion = 0;
for i_img = 1: lenList
    person_postion = person_postion + 1;
    imgname = imgList(i_img).name;

    
    if isDecFormat
        in = strfind(imgname,'.dcm');
    else
        in = strfind(imgname,'.jpg');
    end
    
    firstPartOfFilename = imgname(1:in-1);
    imgnameWithoutExtendName = firstPartOfFilename;

    imFilePathAndName = [imageDirRoot,imgname];
    

        imgnameWithoutExtendName_pre = imgnameWithoutExtendName;
        
        
        img_Mattress = imread(imFilePathAndName);
        rev = isCrashed(img_Mattress,250);
        if rev == 0 
            goodperson_postion = goodperson_postion + 1;
            stru_good(goodperson_postion).imFilePathAndName =  imFilePathAndName;
            stru_good(goodperson_postion).imgnameWithoutExtendName =  imgnameWithoutExtendName;
            stru_good(goodperson_postion).imgname =  imgname;
            stru_good(goodperson_postion).imageDirSaveRoot =  imageDirSaveRoot;
            stru_good(goodperson_postion).isDecFormat =  isDecFormat;
            stru_good(goodperson_postion).imFilePathAndName =  imFilePathAndName; 
            
            tmp_fn = [save_notcrashDir, imgname];
            imwrite(uint8(img_Mattress),tmp_fn);
        end
        
end

% deal with the last person
% print_stru(stru);
print_stru(stru_good);
% not crashed
 
% rev = get_li8_ideal_onepersonjuly10(stru_good); 
% fprintf('The number of Person is %d \n', person_num);
% change back path
path(p);

