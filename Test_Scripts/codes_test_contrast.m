%%
%['38','43','76','80'];

patient = 43;
ImgDir = ['/Volumes/med-kayvan-lab/Datasets/mTBI/ForAnnotation/' num2str(patient) '/DICOM/'];
ImgFiles = dir(ImgDir);
ImgFiles = ImgFiles(~strncmpi('.', {ImgFiles.name},1));
inf= dicominfo([ImgDir, ImgFiles(15).name]);
rawImg=dicomread([ImgDir,ImgFiles(15).name]);
I = ContAdj(rawImg,inf);
figure;imshow(I)



%Pre_processing images
ImgDir = '/Users/apple/Dropbox/Select/'; 

ImgFiles = dir(ImgDir);
ImgFiles = ImgFiles(~strncmpi('.', {ImgFiles.name}, 1));

ImgDir = '/Users/apple/Dropbox/Results/';

for i = 1:length(ImgFiles)
    fname = ImgFiles(i).name;
    img = imread([ImgDir, '/', fname]);
    fori = [fname(1:end-4), 'Orig.png'];
    imgori = imread([ImgDir,'/',fori]);
    
    label_img = bwlabel(imgori, 4);
    rpbox = regionprops(label_img,'BoundingBox');

    y1 = floor(rpbox(1).BoundingBox(1,1));
    x1 = floor(rpbox(1).BoundingBox(1,2));
    w = rpbox(1).BoundingBox(1,3);
    h = rpbox(1).BoundingBox(1,4);

    img_sub = img(x1-5:x1+h+5,y1-5:y1+w+5,:);
    imgori_sub = imgori(x1-5:x1+h+5,y1-5:y1+w+5);
    
 % Process original images by ajusting contrast
    win_min = 60;
    win_width = 220-win_min;
    imgori_sub = uint8(double(imgori_sub - win_min)*255 / double(win_width));
    imgori_sub  = medfilt2(imgori_sub);
    %Superpixels
    [labels, ~] = slicmex(imgori_sub,1000,8);

    figure
    BW = boundarymask(labels);
    imshow(imoverlay(imgori_sub,BW,'cyan'),'InitialMagnification',67)
end


% Adjuct contrast 
currentpath = pwd;
addpath(currentpath);

ImgDir = [currentpath '/Rotated_contrast/'];  %CHANGE!!!! according to how you are mapping the folder

ImgFiles = dir(ImgDir);
ImgFiles = ImgFiles(~strncmpi('.', {ImgFiles.name}, 1));

ImgFiles = ImgFiles(1:8);
% Run through all image files
for i = 1:numel(ImgFiles)
    fname = ImgFiles(i).name;
    if length(fname)>3
        imgori = imread([ImgDir, fname]);
        %img_dcm = dicomread([ImgDir, fname]);
        %WW WL 
        %imgori = ContrastAdjustCT_Uint8(img_dcm,100,50); % change the threshold to show tissue (will be used to segment hematoma)
        [struct_features, imgori_sub, imgori_sub_adjust] = singleimage_process_unlabelled(imgori);
        figure; imshow(imgori_sub)
        img_test = zeros(size(imgori_sub));

        for i = 1:length(struct_features)
            img_test(struct_features(i).PixelIdxList) = imgori_sub(struct_features(i).PixelIdxList);
        end
        figure;imshow(uint8(img_test))
        
    end
end

%{
label_img = bwlabel(img_adj, 4);
ImFilled = imfill(BW, 'holes');
figure; imshow(ImFilled)
bw_edge = edge(ImFilled, 'Canny');
img_adj(bw_edge) = 0;
figure; imshow(img_adj)

bw_edge2 =  edge(~ImFilled, 'Canny');
img_adj(bw_edge2) = 0;
figure; imshow(img_adj)
%}

%Superpixels
[labels, ~] = slicmex(imgori_sub,1000,8);

figure
BW = boundarymask(labels);
imshow(imoverlay(img_sub,BW,'cyan'),'InitialMagnification',67)

img_test = zeros(size(imgori_sub));
struct_all = [struct_1, struct_0];
for i = 1:length(struct_all)
    if struct_all(i).MeanIntensity>40
        img_test(struct_all(i).PixelIdxList) = imgori_sub(struct_all(i).PixelIdxList);
    end
end
figure;imshow(uint8(img_test))
        
img_test = zeros(size(imgori_sub));
img_test(struct_1(1).PixelIdxList) = 255;
    