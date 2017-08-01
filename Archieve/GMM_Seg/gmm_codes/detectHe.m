function isdetected = detectHe(filename,RotatedDir,HemaDir,option)
if ~exist(HemaDir,'dir')
    mkdir(HemaDir);
end
hema_file_name = [HemaDir, filename];
% edema_file_name = [edeDir, filename];
img = imread([RotatedDir, filename]);
% img = rgb2gray(imread('14.jpg'));
% img = rgb2gray(imread('13.png'));
% img = imrotate(img,-2.5);
% img = img(:,1:size(img,2)/2);
% img = img(:,size(img,2)/2+1:end);
% % imshow(img)

%%
% img = imadjust(img);
% imshow(img)

%% Create Ventricle Templates
rp = imfill(double(img),'holes');
rp(rp>0) = max(max(rp));

[rpb,~] = bwlabel(rp);
rpbox = regionprops(rpb,'BoundingBox','Centroid');


% rectangle('Position',rpbox(1).BoundingBox,'EdgeColor','r');
xl = rpbox(1).BoundingBox(1,1);
yl = rpbox(1).BoundingBox(1,2);
w = rpbox(1).BoundingBox(1,3);
h = rpbox(1).BoundingBox(1,4);

% centx = rpbox(1).Centroid(1,1);
% centy = rpbox(1).Centroid(1,2);

% cx = centx;
% cy = centy;

cx = xl+w/2;
cy = yl+h/2; %centroid position

% xl2 = cx-w/12;
% yl2 = cy-h/12;
% w2 = w/6;
% h2 = h/2+h/12;
xl2 = cx-w/16;
yl2 = cy+h/8;
w2 = w/8;
h2 = h/2-h/8;
box2 = [xl2 yl2 w2 h2]; %ventricle box region

%%
% -------------------------------------------------------------------------
% % % white = double(img)>250;
% % % imshow(white)
% % % %%
% % % white  = bwmorph(white,'clean');
% % % imshow(white)
% % % %%
% % % white  = bwmorph(white,'close');
% % % imshow(white)
% % % %%
% % % se90 = strel('line', 2, 90);
% % % se0 = strel('line', 2, 0);
% % % white = imdilate(white, [se90 se0]);
% % % imshow(white);
% % % %% Intracranial Mask
% % % % locations = [1 1;1 512;512 1;512 512];
% % % locations = [1 1];
% % % white2 = imfill(white,locations);
% % % imshow(white2*255)
% % % 
% % % %% Intracranial Extraction 
% % % img2new = double(img).*(~white2)  ;
% % % imshow(uint8(img2new));

%% Total variation denoising
% img_tv1=PDHG(double(img),.5,10^(-3));
img_tv2=PDHG(double(img),.05,10^(-3));
% img_tv3=PDHG(double(img),.01,10^(-3));
% figure,imshow(uint8(img_tv1));
img_tv2(img_tv2<5)=0;
% img_tv2(img_tv3<10)=0;
% figure,imshow(uint8(img_tv3));

%% Median Filtering
img2med = double(medfilt2(img));
% img2n = medfilt2(img2new);
% imshow(uint8(img2n));
% img2n = double(img2n);

%% Histogram of intracranial matter and Subracting graymatter intensit
[a,~]=hist(img2med(:),256);
[~,grval]=max(a(10:end));
img2hist = double(img2med) - (img2med>0)*(grval);
% figure,imshow(uint8(img2hist));
% figure, plot(a);

%%
% Linear Contrast Stretching
img2lcs = imadjust(uint8(img2hist));
% figure, imshow(uint8(img2fin)),title('LCS');


%% Running GMM 
% x2 = [double(img(:)) double(img2lcs(:)) double(img2hist(:)) double(img_tv2(:))];
x2 = [double(img(:)) double(img2lcs(:)) double(img_tv2(:))];
% x2 = [double(img2lcs(:)) double(img_tv2(:))];
% x2 = [double(img2hist(:)) double(img_tv2(:))];    
% x2 = [double(img(:)) double(img_tv2(:))];    
% x2 = double(img_tv2(:));

label = [];maxiter = 3;id=0;
while length(unique(label))~=4 && id<maxiter 
    if option == 1
        label = emgm(x2',4);
    else
        label = vbgm(x2',4);
    end
    unique(label)
    k2 = reshape(label,size(img2hist,1),size(img2hist,2));
    id = id+1;
end
if length(unique(label))~=4
    fprintf('Changing Features..')
    x2 = [double(img2lcs(:)) double(img_tv2(:))];id=0;
    while length(unique(label))~=4 && id<maxiter 
        if option == 1
            label = emgm(x2',4);
        else
            label = vbgm(x2',4);
        end
        unique(label)
        k2 = reshape(label,size(img2hist,1),size(img2hist,2));
        id = id+1;
    end
end

% figure,imshow(mat2gray(k2))

%Hematoma
% -------------------------------------------------------------------------
%% Separate component masks
s = regionprops(k2,'centroid','Area','PixelIdxList','PixelList','FilledArea','FilledImage','ConvexImage','Image','Extent','Extrema');
comps = zeros([size(img2med) numel(s)]);
 for i = 1 : numel(s)
     complot = zeros(size(img2med));
     for j = 1:length(s(i).PixelList)
        complot(s(i).PixelList(j,2),s(i).PixelList(j,1)) = 1;
    end
    comps(:,:,i) = complot;
 end
 
 %% Calculate mean intensity for each connected component
 compsInt = zeros(numel(s),1);
 for i = 1: numel(s)
    temp =  comps(:,:,i).*255;
    compsInt(i) = mean(img2med(find(temp)));
 end
 
 %% Saving Hematoma image
 % Condition for hematoma to exist has to be included
 % Area Constraint
 areas = zeros(1,numel(s));
 for i = 1:numel(s)
     areas(1,i) = s(i).Area;
 end
BrArea = sum(areas)-max(areas); 
[~,hIdx] = max(compsInt);

if areas(hIdx)<(0.4)*BrArea
    imgclean = bwmorph(comps(:,:,hIdx),'clean');
   
    cc = bwconncomp(imgclean);
    curr_num = cc.NumObjects;last_num=0;
    while curr_num>10 && curr_num~=last_num

        numPixels = cellfun(@numel,cc.PixelIdxList);
                [smallest,~] = min(numPixels);
        for i = 1:cc.NumObjects
            if  numel(cc.PixelIdxList{i})<2*smallest
                 imgclean(cc.PixelIdxList{i}) = 0;
            end
        end
        cc = bwconncomp(imgclean);
        last_num = curr_num;
        curr_num =  cc.NumObjects;
    end
% Second labeling
    [L,~] = bwlabel(imgclean);
    s3 = regionprops(L,'centroid','Area','PixelIdxList','PixelList','FilledArea','FilledImage','ConvexImage','Image','Extent','Extrema','Eccentricity', 'BoundingBox');

    comps2 = zeros([size(img2med) numel(s3)]);
    finalimg = zeros(size(img2med));
    for i = 1 : numel(s3)
         complot2 = zeros(size(img2med));
         for j = 1:length(s3(i).PixelList)
            complot2(s3(i).PixelList(j,2),s3(i).PixelList(j,1)) = 1;
        end
        comps2(:,:,i) = complot2;
     end

%     for i  = 1:numel(s3)
%         if (~isContained2(s3(i).PixelList,box2))
% % % Remove the scope if present
%             if ~(mean(img2med(find(comps2(:,:,i))))>230) || ~(length(s3(i).PixelList)<200)
%                 finalimg = finalimg + comps2(:,:,i).*255;
%             end
%         end
%     end
    
    for i  = 1:numel(s3)
        pidx = isContained3(s3(i).PixelList,box2);
        if ~isempty(pidx)
            ptotal = s3(i).PixelList;
            comps2(ptotal(pidx,2),ptotal(pidx,1),i) = 0;
        end
        % % Remove the scope if present
            if ~(mean(img2med(find(comps2(:,:,i))))>230) || ~(length(s3(i).PixelList)<200)
                finalimg = finalimg + comps2(:,:,i).*255;
            end
    end
    
    ffimg = linefunction(finalimg,img);
%  figure,   imshow(finalimg);

% % Remove edge lines using sobel edge detector and erosion
    
%     finalimg = bwmorph(finalimg,'thin');
%     finalimg = bwmorph(finalimg,'erode');
    
    hImg = double(repmat(img,1,1,3));
    hImg(:,:,1) = hImg(:,:,1) + ffimg;
    hImg(:,:,2) = hImg(:,:,1).*(~ffimg);
    hImg(:,:,3) = hImg(:,:,1).*(~ffimg);
    % figure,imshow(uint8(hImg));

    imwrite(uint8(hImg), hema_file_name);
    isdetected = strcat('Hematoma Image saved ', filename);
%     imshow(uint8(hImg));
else
    isdetected = (strcat('Badfile : ', filename));
    imwrite(uint8(img), hema_file_name);
end
% -------------------------------------------------------------------------









% % % %% Linear Contrast Stretching
% % % 
% % % img2fin = imadjust(uint8(img2f));
% % % figure, imshow(uint8(img2fin)),title('LCS');

% ------------------------------------
% % % %% Choosing the largest connected components
% % % 
% % % img2ff = img2fin;
% % % cc = bwconncomp(img2ff);
% % % numPixels = cellfun(@numel,cc.PixelIdxList);
% % %         [biggest,idx] = max(numPixels);
% % % for i = 1:cc.NumObjects
% % %     if  numel(cc.PixelIdxList{i})<biggest
% % %          img2ff(cc.PixelIdxList{i}) = 0;
% % %     end
% % % end
% % % 
% % % % imshow(uint8(img2ff));
% % % %%
% % % x = double(img2ff(:));
% % %     label = emgm(x',4);
% % %     k = reshape(label,size(img2n,1),size(img2n,2));
% % %     subplot(1,4,4), imshow(mat2gray(k)),title('GMM after LCS');
% % % toc

