% curdir = pwd;
addpath(genpath('/Users/apple/Documents/Lab_Winter/Heming'));


%% Define directories

%% change here
ImgDir = '/Users/apple/Documents/Lab_Winter/Heming/Imgs/76_Original';
fileDir = '/Users/apple/Documents/Lab_Winter/Heming';  %CHANGE!!!! according to how you are mapping the folder
RotatedDir = [fileDir '/h2/76_series2/']; %CHANGE!!!! % directory contains segmented intracranial sapce and rotated
SaveDir = [fileDir '/h2/76_series2/']; %CHANGE!!!!
%% change above
if ~exist(RotatedDir,'dir')
    mkdir(RotatedDir);
end
if ~exist(SaveDir,'dir')
    mkdir(SaveDir);
end
%% Preprocess the CT images
[imgStruct_2, angle1, rev] = headCT_preprocess(ImgDir, RotatedDir, 2, 1, 1);
%--------- Inputs ------------
% ImgDir : Directory where the CT files are located
% SaveDir : Directory to save the results 
% optRotate : Can choose betwey two different options
%               1) Wenan's Original method
%               2) Negar's imrotate method
% optAngle : method to choose the best angle of rotation
%               1) Median
%               2) Wenan's method
% optSave : 1) Save the final image in the SaveDir
%           2) Do not save the final image 
disp(' Completed image rotation and alignment');


%{
%%
imgStruct_2 = [];
ImgFiles = dir(RotatedDir);
ImgFiles = ImgFiles(~strncmpi('.', {ImgFiles.name}, 1));
for i = 1:length(ImgFiles)
    fname = ImgFiles(i).name;
    imgStruct_2(i).rotated_resize_img_final = imread([ImgDir,'/', fname]);
    imgStruct_2(i).fname = fname(1:end-4);
end


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


%}