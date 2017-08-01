% curdir = pwd;
cd ..
cd ..
curdir = pwd;
origP = path;
addpath(genpath([curdir '\modules']));


%% Define directories

%% change here
fileDir = 'X:\TBI_Shared\JPGimages\h11final';  %CHANGE!!!! according to how you are mapping the folder
RotatedDir = [fileDir '\HematomaKatharine\Rotated\']; %CHANGE!!!! % directory contains segmented intracranial sapce and rotated
SaveDir = [fileDir '\HematomaKatharine\Results\']; %CHANGE!!!!
%% change above
if ~exist(SaveDir,'dir')
    mkdir(SaveDir);
end
%% Preprocess the CT images
[imgStruct_2, angle1, rev] = headCT_preprocess(fileDir, RotatedDir, 1, 2, 1);
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
disp(' Completed image rotation and alignment');


%% run hematoma segmentation algorithm
for i = 1:length(imgStruct_2)
      
    fprintf('Starting file %i out of %i \n', i, length(imgStruct_2) );
    img = imgStruct_2(i).rotated_resize_img_final;
    [img_out,isDetected] = detectHematoma(img,1);
    imgStruct_2(i).HemaDetected = isDetected;
    if isDetected == 1
        SaveNameOrig = [SaveDir, imgStruct_2(i).fname(1:end-4), 'Orig.png'];
        imwrite(img, SaveNameOrig);
        SaveName = [SaveDir, imgStruct_2(i).fname(1:end-3), 'png'];
        imwrite(img_out, SaveName);
    end
        
end



%% restore original search path
path(origP);