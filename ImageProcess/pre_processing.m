%%
Patients = [38, 43, 76, 80, 100, 109, 113, 94, 284, 122, 183, 125, 332, 380];
test = zeros(512,512,length(Patients));
records = [];

%%
for index = 1: length(Patients)
    pid = Patients(index);
    
    DcmDir = ['/Users/apple/Developer/ForAnnotation/' num2str(pid) '/' 'DICOM/'];
    DcmList = dir(strcat(DcmDir, '*'));
    DcmList = DcmList(~strncmpi('.', {DcmList.name},1));
    
    ImgNew = [];
    
    for i= 1 : length(DcmList)
        fname = DcmList(i).name;
        if ~((strcmp(fname(end-2:end),'tif'))||(strcmp(fname(end-1:end),'db')))
            ImgNew = [ImgNew DcmList(i)];
        end
    end
    
    DcmList = ImgNew;
    
    [brain, startI, endI] = brain_extraction(DcmDir, DcmList);
    
    location = intersect(find(brain>0), find(brain<250));
    vec = brain(location);
    [count,band] = imhist(vec);
    [~, peak] = max(count);
    brain_new = uint8(double(brain) +80 - peak);
%     if index==1
%         figure;imshow(brain_new(:,:,19))
%     elseif index==2
%         figure;imshow(brain_new(:,:,31))
%     elseif index==3
%         figure;imshow(brain_new(:,:,26))
%     elseif index==4
%         figure;imshow(brain_new(:,:,21))
%     elseif index==5
%         figure;imshow(brain_new(:,:,26))
%     end
    test(:,:,index) = brain_new(:,:,25);
    
     % I need to build a 3d matrix for one patient, raw images
%     for i = 1:length(ImgFiles)
%         rawImg=dicomread([ImgDir, ImgFiles(i).name]);
%         rawVolume=cat(3,rawVolume,rawImg);
%     end
%    dim = size(normalizedImg);
    
    
    
%     for i = 1:dim(3)
%         location = find(normalizedImg(:,:,i)==0);
%         img = rawVolume(:,:,1);
%         imgforpeak = zeros(size(img));
%         imgforpeak(location)=0;
%         
%     end
    % I need to get a 3d matrix for normalized images (mask)
    % Use position from mask to have extracted raw images
    
end

Patients_2 = [190, 222, 273,147, 235, 283, 176, 256, 303, 177, ...
    271, 307, 180, 149, 324, 209, 155, 378, 212, 380, 389, ...
    270, 366, 390, 282, 369, 264, 289, 295, 392];

%%
for i = 1:length()
%%
subset = records([3,7,9,10,13,14]);

%% ContAdj
results = zeros([size(records(1).img), length(records)]);
for i = 1:length(subset)
    rawImg = subset(i).img;
    inf = subset(i).inf;
    I = ContAdj(rawImg,inf);
    results(:,:,i) = I;
    figure;imshow(uint8(results(:,:,i)))
end

%% ContAdj_Intensity
results = zeros([size(records(1).img), length(records)]);
ref = records(1).img;
for i = 1:length(subset)
    rawImg = subset(i).img;
    inf = subset(i).inf;
    I = ContAdj_Intensity(rawImg,inf, ref);
    results(:,:,i) = I;
    figure;imshow(uint8(results(:,:,i)))
end

%%
 I = ContAdj(subset(3).img,subset(3).inf);
 I2 = ContAdj(B,subset(3).inf);
 figure;imshow(I)
 figure;imshow(I2)
 
%% For one patient
images = [];
pid = Patients(1);
ImgDir = ['/Users/apple/Developer/ForAnnotation/' num2str(pid) '/DICOM/'];
ImgFiles = dir(ImgDir);
ImgFiles = ImgFiles(~strncmpi('.', {ImgFiles.name},1));

ImgNew = [];

for i= 1 : length(ImgFiles)
    fname = ImgFiles(i).name;
    if ~((strcmp(fname(end-2:end),'tif'))||(strcmp(fname(end-1:end),'db')))
        ImgNew = [ImgNew ImgFiles(i)];
    end
end

ImgFiles = ImgNew;

for i = 1:length(ImgFiles)
    fname = ImgFiles(i).name;
    inf= dicominfo([ImgDir, fname]);
    pat(i).WindowWidth = inf.WindowWidth;
    pat(i).WindowCenter = inf.WindowCenter;
    pat(i).img = dicomread([ImgDir,fname]);
    pat(i).inf = inf;
end

%%
results = zeros([size(records(1).img), length(pat)]);
ref = records(1).img;
for i = 1:length(pat)
    rawImg = pat(i).img;
    inf = pat(i).inf;
    [I, peak] = ContAdj_Intensity(rawImg,inf, ref);
    peak
    results(:,:,i) = I;
    %figure;imshow(uint8(results(:,:,i)))
end

%%