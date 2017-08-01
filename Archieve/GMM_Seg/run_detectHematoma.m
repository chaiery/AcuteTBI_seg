addpath(genpath('/Users/apple/Documents/Lab_Winter/Heming'));


%% Define directories

%% change here
ImgDir = '/Users/apple/Documents/Lab_Winter/Heming/Imgs/testImgs';
fileDir = '/Users/apple/Documents/Lab_Winter/Heming';  %CHANGE!!!! according to how you are mapping the folder
RotatedDir = [fileDir '/h2/Rotated_test/']; %CHANGE!!!! % directory contains segmented intracranial sapce and rotated
SaveDir = [fileDir '/h2/Results_test/']; %CHANGE!!!!
%% change above
if ~exist(SaveDir,'dir')
    mkdir(SaveDir);
end
%% Preprocess the CT images
[imgStruct_2, angle1, rev] = headCT_preprocess(ImgDir, RotatedDir, 1, 2, 1);
disp(' Completed image rotation and alignment');


%% run hematoma segmentation algorithm
for i = 1:numel(imgStruct_2)
      
    fprintf('Starting file %i out of %i \n', i, numel(imgStruct_2) );
    img = imgStruct_2(i).rotated_resize_img_final;
    [img_out,isDetected] = detectHematoma(img,1);
    imgStruct_2(i).HemaDetected = isDetected;
    if isDetected == 1
        SaveNameOrig = [SaveDir, imgStruct_2(i).fname(1:end-4), 'Orig.png'];
        imwrite(img, SaveNameOrig);
        SaveName = [SaveDir, imgStruct_2(i).fname(1:end-4), '.png'];
        imwrite(img_out, SaveName);
    end
        
end


