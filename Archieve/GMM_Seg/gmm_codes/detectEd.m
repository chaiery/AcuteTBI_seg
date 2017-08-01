function isdetected = detectEd(filename,RotatedDir,EdemaDir)
% 
edema_file_name = [EdemaDir, filename];
% edema_file_name = '5';
% img = imread(strcat('C:\Users\abafna\Desktop\New folder\',edema_file_name,'.png'));
img = imread([RotatedDir, filename]);
% img = rgb2gray(imread('14.jpg'));
% img = rgb2gray(imread('13.png'));
% img = imrotate(img,-2.5);
% img = img(:,1:size(img,2)/2);
% img = img(:,size(img,2)/2+1:end);
% imshow(img)
% hold on;
% %%
%  img = imadjust(img,[.3 .7],[]);
%  imshow(img)

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

mask = imread('mask.png');
smask = zeros(size(img));
smask(floor(yl):floor(yl+h)-1,floor(xl):floor(xl+w)-1) = imresize(mask,[h,w]);
% figure,imshow(smask);
% cx = centx;
% cy = centy;

cx = xl+w/2;
cy = yl+h/2;

% xl2 = cx-w/6;
% yl2 = cy-h/6-h/12;
% w2 = w/3;
% h2 = h/3+h/12;
% box2 = [xl2 yl2 w2 h2];
% 
% xl3 = cx-w/4+w/24;
% yl3 = cy+h/8-h/24;
% w3 = w/8;
% h3 = h/4;
% box3 = [xl3 yl3 w3 h3];
% 
% xl4 = cx+w/4-w3-w/24;
% yl4 = cy+h/8-h/24;      
% box4 = [xl4 yl4 w3 h3]; 


%Set2 Edema
%%
% -------------------------------------------------------------------------
imgn = double(medfilt2(img));
img2 = imadjust(img);
img2wn = double(medfilt2(img2));
% % figure,imshow(img2)
white = imfill((img2),'holes');
img2w = white-img2;
% figure,imshow(white)
% figure,imshow(img2w)

%% Non local means
Options.kernelratio=5;
 Options.windowratio=5;
 Options.verbose=true;
 J=NLMF(double(img2),Options);

 % figure,imshow(uint8(J)); figure,imshow(uint8(J2));

 
%% Total variation denoising
% img_tv1=PDHG(double(img),.5,10^(-3));
img_tv2=PDHG(double(img2),.5,10^(-3));
img_tv3=PDHG(double(img2w),.05,10^(-3));

img_tv2(img_tv2<15)=0;
img_tv3(img_tv3<15)=0;


% img_tv2(img_tv2==0) = 255;
% img_tv3(img_tv3==0) = 255;

% figure,imshow(uint8(img_tv3)); figure,imshow(uint8(img_tv2));



img_tv2d = imadjust(uint8(img_tv2),[.3 .7],[]);
img_tv3d = imadjust(uint8(img_tv3),[.2 .7],[]);
% figure,imshow(uint8(img_tv2d)); figure,imshow(uint8(img_tv3d))



%% Median Filtering
img2n = double(medfilt2(img2w));
% % imshow(uint8(img2n));
% img2n = double(img2n);
%%
[a,~]=hist(double(img2n(:)),256);
[~,grval]=max(a(10:end));
img2f = double(img2n) - (img2n>0)*(grval);
% % figure,imshow(uint8(img2n));

% %%
% img_w = img;
% img_w(img_w==0) = max(img_w(:));
% img_w = medfilt2(img_w);
% img_w = imadjust(img_w,[.2 .7],[]);
% figure,imshow(uint8(img_w))
%%
% Linear Contrast Stretching for Edema
[a,~]=hist(img2n(:),256);
[~,grval]=max(a(10:end));
img2fin = imadjust(uint8(img2f),[grval/255 1],[0 1]);
% figure, imshow(uint8(img2fin)),title('LCS');


% -------------------------------------------------------------------------
%% Running GMM after Subtracting Grey matter Intensity
%  x2 = [double(img2w(:)) double(img2fin(:)) double(img(:)) double(img_tv2d(:))];
% x2 = [double(img2n(:)) double(img2fin(:)) double(img(:))];
% x2 = [double(img2(:)) double(img2fin(:))];
% x2 = [double(img2f(:)) double(img2fin(:))];
% x2 = [double(img2f(:)) double(img2n(:))];    
% x2 = [double(img2fin(:)) double(img2n(:))];
% x2 = [double(img2n(:)) double(img2fin(:))];

% x2 = [double(img2n(:)) double(img_tv2(:)) double(img_tv3(:))];
% % % x2 = [double(img2n(:)) double(img_tv2(:)) double(img_tv3d(:)) J(:)]; 
% % % n = 4;
% % % label = [];maxiter = 3;id=0;
% % % while length(unique(label))~=n && id<maxiter 
% % %     label = emgm(x2',n);
% % %     k2 = reshape(label,size(img2f,1),size(img2f,2));
% % %     id = id+1;
% % % end
% % % if length(unique(label))~=n
% % %     display('Changing Features..')
% % % %     x2 = [double(img2(:)) double(img2fin(:))];
% % %     x2 = [double(img2n(:)) double(img_tv2(:)) double(img_tv3(:)) double(img_tv2d(:)) J(:)];
% % %     id=0;
% % %     while length(unique(label))~=3 && id<maxiter 
% % %         label = emgm(x2',3);
% % %         k2 = reshape(label,size(img2f,1),size(img2f,2));
% % %         id = id+1;
% % %     end
% % % end
% % % 
% % % % figure,imshow(mat2gray(k2))
% % % % ,title('GMM after Subtracting GreyIntensity');
% % % % [~, threshold] = edge(img2fin, 'sobel');
% % % % fudgeFactor = .5;
% % % % BWs = edge(img2fin,'sobel', threshold * fudgeFactor);
% % % % figure, imshow(BWs), title('binary gradient mask');
% % % % I = uint8(mat2gray(k));
% % % 
% % % % -------------------------------------------------------------------------
% % % %% Separate component masks
% % % s = regionprops(k2,'centroid','Area','PixelIdxList','PixelList','FilledArea','FilledImage','ConvexImage','Image','Extent','Extrema','Eccentricity');
% % % comps = zeros([size(img2n) numel(s)]);
% % %  for i = 1 : numel(s)
% % %      complot = zeros(size(img2n));
% % %      for j = 1:length(s(i).PixelList)
% % %         complot(s(i).PixelList(j,2),s(i).PixelList(j,1)) = 1;
% % %     end
% % %     comps(:,:,i) = complot;
% % %  end
% % %  
% % % %% Intensity Constraint
% % % %  Calculate mean intensity for each connected component
% % %  compsInt = zeros(numel(s),1);
% % %  for i = 1: numel(s)
% % %     temp =  comps(:,:,i).*255;
% % %     compsInt(i) = mean(img2n(find(temp)));
% % %  end
% % % [~,hIdx] = max(compsInt);
% % % 
% % % 
% % % %% Area Constraint
% % % % Clean number of elements to a maximum of 10
% % %  areas = zeros(1,numel(s));
% % %  for i = 1:numel(s)
% % %      areas(1,i) = s(i).Area;
% % %  end
% % % BrArea = sum(areas)-max(areas); 
% % % 
% % % if areas(hIdx)<BrArea*(0.4) 
% % % 
% % %     imgclean = bwmorph(comps(:,:,hIdx),'clean');
% % % 
% % %     cc = bwconncomp(imgclean);
% % %     curr_num = cc.NumObjects;last_num=0;
% % %     while curr_num>5 && curr_num~=last_num
% % % 
% % %     numPixels = cellfun(@numel,cc.PixelIdxList);
% % %             [smallest,~] = min(numPixels);
% % %     for i = 1:cc.NumObjects
% % %         if  numel(cc.PixelIdxList{i})<2*smallest
% % %              imgclean(cc.PixelIdxList{i}) = 0;
% % %         end
% % %     end
% % %     cc = bwconncomp(imgclean);
% % %     last_num = curr_num;
% % %     curr_num =  cc.NumObjects;
% % %     end
% % % 
% % % %     figure,imshow((imgclean));
% % % 
% % %     %%Anatomical Location
% % % 
% % %     [L,~] = bwlabel(imgclean);
% % %     s3 = regionprops(L,'centroid','Area','PixelIdxList','PixelList','Image','BoundingBox');
% % %     hold on;
% % % 
% % % %     figure,imshow(s3(1).Image)
% % % %     rectangle('Position',box2,'EdgeColor','g');
% % % %     rectangle('Position',box3,'EdgeColor','b');
% % % %     rectangle('Position',box4,'EdgeColor','b');
% % % 
% % % 
% % % % finalimg = imgclean.*(1-smask);
% % %     comps2 = zeros([size(img2n) numel(s3)]);
% % %     finalimg = zeros(size(img2n));
% % %     for i = 1 : numel(s3)
% % %          complot2 = zeros(size(img2n));
% % %          for j = 1:length(s3(i).PixelList)
% % %             complot2(s3(i).PixelList(j,2),s3(i).PixelList(j,1)) = 1;
% % %         end
% % %         comps2(:,:,i) = complot2;
% % %      end
% % % 
% % %     for i  = 1:numel(s3)
% % %         pbb = s3(i).BoundingBox;
% % %         excess = s3(i).Image .* (1-smask(floor(pbb(1,2)):floor(pbb(1,2)+pbb(1,4))-1,floor(pbb(1,1)):floor(pbb(1,1)+pbb(1,3))-1));
% % %         if sum(sum(excess))>s3(i).Area*3/4
% % % %         if (~isContained(s3(i).BoundingBox,box2))&&(~isContained(s3(i).BoundingBox,box3))&&(~isContained(s3(i).BoundingBox,box4))
% % %             finalimg = finalimg + comps2(:,:,i).*255;
% % %         end
% % %     end
% % % %    figure, imshow(finalimg);
% % % 
% % %     hImg = double(repmat(img,1,1,3));
% % %     hImg(:,:,1) = hImg(:,:,1) + finalimg;
% % %     hImg(:,:,2) = hImg(:,:,1).*(~finalimg);
% % %     hImg(:,:,3) = hImg(:,:,1).*(~finalimg);
% % %     % figure,imshow(uint8(hImg));
% % % 
% % % %     imwrite(uint8(hImg), edema_file_name);
% % % %     isdetected = strcat('Edema Image saved ', filename);
% % % %     figure,imshow(uint8(hImg));
% % %     hImg1 = hImg;
% % %  % display('Hematoma Image saved ' & filename); 
% % % else
% % %     hImg1 = img;
% % %     isdetected = strcat('Edema not detected in ', edema_file_name);
% % % %     imwrite(uint8(img), edema_file_name);
% % % end
% % % 
% % % 
% % % 
% % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % 
% % % x2 = [double(img2n(:)) double(img_tv2(:)) double(img_tv3(:)) double(img_tv2d(:))]; 
% % % n = 4;
% % % label = [];maxiter = 3;id=0;
% % % while length(unique(label))~=n && id<maxiter 
% % %     label = emgm(x2',n);
% % %     k2 = reshape(label,size(img2f,1),size(img2f,2));
% % %     id = id+1;
% % % end
% % % if length(unique(label))~=n
% % %     display('Changing Features..')
% % % %     x2 = [double(img2(:)) double(img2fin(:))];
% % %     x2 = [double(img2n(:)) double(img_tv2(:)) double(img_tv3(:)) double(img_tv2d(:))];
% % %     id=0;
% % %     while length(unique(label))~=3 && id<maxiter 
% % %         label = emgm(x2',3);
% % %         k2 = reshape(label,size(img2f,1),size(img2f,2));
% % %         id = id+1;
% % %     end
% % % end
% % % 
% % % % figure,imshow(mat2gray(k2))
% % % % ,title('GMM after Subtracting GreyIntensity');
% % % % [~, threshold] = edge(img2fin, 'sobel');
% % % % fudgeFactor = .5;
% % % % BWs = edge(img2fin,'sobel', threshold * fudgeFactor);
% % % % figure, imshow(BWs), title('binary gradient mask');
% % % % I = uint8(mat2gray(k));
% % % 
% % % % -------------------------------------------------------------------------
% % % %% Separate component masks
% % % s = regionprops(k2,'centroid','Area','PixelIdxList','PixelList','FilledArea','FilledImage','ConvexImage','Image','Extent','Extrema','Eccentricity');
% % % comps = zeros([size(img2n) numel(s)]);
% % %  for i = 1 : numel(s)
% % %      complot = zeros(size(img2n));
% % %      for j = 1:length(s(i).PixelList)
% % %         complot(s(i).PixelList(j,2),s(i).PixelList(j,1)) = 1;
% % %     end
% % %     comps(:,:,i) = complot;
% % %  end
% % %  
% % % %% Intensity Constraint
% % % %  Calculate mean intensity for each connected component
% % %  compsInt = zeros(numel(s),1);
% % %  for i = 1: numel(s)
% % %     temp =  comps(:,:,i).*255;
% % %     compsInt(i) = mean(img2n(find(temp)));
% % %  end
% % % [~,hIdx] = max(compsInt);
% % % 
% % % 
% % % %% Area Constraint
% % % % Clean number of elements to a maximum of 10
% % %  areas = zeros(1,numel(s));
% % %  for i = 1:numel(s)
% % %      areas(1,i) = s(i).Area;
% % %  end
% % % BrArea = sum(areas)-max(areas); 
% % % 
% % % if areas(hIdx)<BrArea*(0.4) 
% % % 
% % %     imgclean = bwmorph(comps(:,:,hIdx),'clean');
% % % 
% % %     cc = bwconncomp(imgclean);
% % %     curr_num = cc.NumObjects;last_num=0;
% % %     while curr_num>5 && curr_num~=last_num
% % % 
% % %     numPixels = cellfun(@numel,cc.PixelIdxList);
% % %             [smallest,~] = min(numPixels);
% % %     for i = 1:cc.NumObjects
% % %         if  numel(cc.PixelIdxList{i})<2*smallest
% % %              imgclean(cc.PixelIdxList{i}) = 0;
% % %         end
% % %     end
% % %     cc = bwconncomp(imgclean);
% % %     last_num = curr_num;
% % %     curr_num =  cc.NumObjects;
% % %     end
% % % 
% % % %     figure,imshow((imgclean));
% % % 
% % %     %%Anatomical Location
% % % 
% % %     [L,~] = bwlabel(imgclean);
% % %     s3 = regionprops(L,'centroid','Area','PixelIdxList','PixelList','Image','BoundingBox');
% % %     hold on;
% % % 
% % % %     figure,imshow(s3(1).Image)
% % % %     rectangle('Position',box2,'EdgeColor','g');
% % % %     rectangle('Position',box3,'EdgeColor','b');
% % % %     rectangle('Position',box4,'EdgeColor','b');
% % % 
% % % 
% % % % finalimg = imgclean.*(1-smask);
% % %     comps2 = zeros([size(img2n) numel(s3)]);
% % %     finalimg = zeros(size(img2n));
% % %     for i = 1 : numel(s3)
% % %          complot2 = zeros(size(img2n));
% % %          for j = 1:length(s3(i).PixelList)
% % %             complot2(s3(i).PixelList(j,2),s3(i).PixelList(j,1)) = 1;
% % %         end
% % %         comps2(:,:,i) = complot2;
% % %      end
% % % 
% % %     for i  = 1:numel(s3)
% % %         pbb = s3(i).BoundingBox;
% % %         excess = s3(i).Image .* (1-smask(floor(pbb(1,2)):floor(pbb(1,2)+pbb(1,4))-1,floor(pbb(1,1)):floor(pbb(1,1)+pbb(1,3))-1));
% % %         if sum(sum(excess))>s3(i).Area*3/4
% % % %         if (~isContained(s3(i).BoundingBox,box2))&&(~isContained(s3(i).BoundingBox,box3))&&(~isContained(s3(i).BoundingBox,box4))
% % %             finalimg = finalimg + comps2(:,:,i).*255;
% % %         end
% % %     end
% % % %    figure, imshow(finalimg);
% % % 
% % %     hImg = double(repmat(img,1,1,3));
% % %     hImg(:,:,1) = hImg(:,:,1) + finalimg;
% % %     hImg(:,:,2) = hImg(:,:,1).*(~finalimg);
% % %     hImg(:,:,3) = hImg(:,:,1).*(~finalimg);
% % %     % figure,imshow(uint8(hImg));
% % % 
% % % %     imwrite(uint8(hImg), edema_file_name);
% % % %     isdetected = strcat('Edema Image saved ', filename);
% % % %     figure,imshow(uint8(hImg));
% % %      hImg2 = hImg;
% % %  % display('Hematoma Image saved ' & filename); 
% % % else
% % %     isdetected = strcat('Edema not detected in ', edema_file_name);
% % %     hImg2 = img;
% % % %     imwrite(uint8(img), edema_file_name);
% % % end
% % % 
% % % 


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

x2 = [double(img2n(:)) J(:) double(img_tv2(:))]; 
n = 4;
label = [];maxiter = 3;id=0;
while length(unique(label))~=n && id<maxiter 
    label = emgm(x2',n);
    k2 = reshape(label,size(img2f,1),size(img2f,2));
    id = id+1;
end
if length(unique(label))~=n
    display('Changing Features..')
%     x2 = [double(img2(:)) double(img2fin(:))];
    x2 = [double(img2n(:)) J(:) double(img_tv2(:))];
    id=0;
    while length(unique(label))~=3 && id<maxiter 
        label = emgm(x2',3);
        k2 = reshape(label,size(img2f,1),size(img2f,2));
        id = id+1;
    end
end

% figure,imshow(mat2gray(k2))
% ,title('GMM after Subtracting GreyIntensity');
% [~, threshold] = edge(img2fin, 'sobel');
% fudgeFactor = .5;
% BWs = edge(img2fin,'sobel', threshold * fudgeFactor);
% figure, imshow(BWs), title('binary gradient mask');
% I = uint8(mat2gray(k));

% -------------------------------------------------------------------------
%% Separate component masks
s = regionprops(k2,'centroid','Area','PixelIdxList','PixelList','FilledArea','FilledImage','ConvexImage','Image','Extent','Extrema','Eccentricity');
comps = zeros([size(img2n) numel(s)]);
 for i = 1 : numel(s)
     complot = zeros(size(img2n));
     for j = 1:length(s(i).PixelList)
        complot(s(i).PixelList(j,2),s(i).PixelList(j,1)) = 1;
    end
    comps(:,:,i) = complot;
 end
 
%% Intensity Constraint
%  Calculate mean intensity for each connected component
 compsInt = zeros(numel(s),1);
 for i = 1: numel(s)
    temp =  comps(:,:,i).*255;
    compsInt(i) = mean(img2n(find(temp)));
 end
[~,hIdx] = max(compsInt);


%% Area Constraint
% Clean number of elements to a maximum of 10
 areas = zeros(1,numel(s));
 for i = 1:numel(s)
     areas(1,i) = s(i).Area;
 end
BrArea = sum(areas)-max(areas); 

if areas(hIdx)<BrArea*(0.5)

    imgclean = bwmorph(comps(:,:,hIdx),'clean');

    cc = bwconncomp(imgclean);
    curr_num = cc.NumObjects;last_num=0;
    while curr_num>5 && curr_num~=last_num

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

%     figure,imshow((imgclean));

    %%Anatomical Location

    [L,~] = bwlabel(imgclean);
    s3 = regionprops(L,'centroid','Area','PixelIdxList','PixelList','Image','BoundingBox');
    hold on;

%     figure,imshow(s3(1).Image)
%     rectangle('Position',box2,'EdgeColor','g');
%     rectangle('Position',box3,'EdgeColor','b');
%     rectangle('Position',box4,'EdgeColor','b');


% finalimg = imgclean.*(1-smask);
    comps2 = zeros([size(img2n) numel(s3)]);
    finalimg = zeros(size(img2n));
    for i = 1 : numel(s3)
         complot2 = zeros(size(img2n));
         for j = 1:length(s3(i).PixelList)
            complot2(s3(i).PixelList(j,2),s3(i).PixelList(j,1)) = 1;
        end
        comps2(:,:,i) = complot2;
     end

    for i  = 1:numel(s3)
        pbb = s3(i).BoundingBox;
        excess = s3(i).Image .* (1-smask(floor(pbb(1,2)):floor(pbb(1,2)+pbb(1,4))-1,floor(pbb(1,1)):floor(pbb(1,1)+pbb(1,3))-1));
        if sum(sum(excess))>s3(i).Area*3/4
%         if (~isContained(s3(i).BoundingBox,box2))&&(~isContained(s3(i).BoundingBox,box3))&&(~isContained(s3(i).BoundingBox,box4))
            finalimg = finalimg + comps2(:,:,i).*255;
        end
    end
%    figure, imshow(finalimg);

    hImg = double(repmat(img,[1 1 3]));
    hImg(:,:,1) = hImg(:,:,1) .*(~finalimg);
    hImg(:,:,2) = hImg(:,:,1).*(~finalimg);
    hImg(:,:,3) = hImg(:,:,1)+ finalimg;
    % figure,imshow(uint8(hImg));

    imwrite(uint8(hImg), edema_file_name);
    isdetected = strcat('Edema Image saved ', filename);
%     figure,imshow(uint8(hImg));
%      hImg3 = hImg;
else
    isdetected = strcat('Edema not detected in ', edema_file_name);
%      hImg3 = img;
    imwrite(uint8(img), edema_file_name);
end

% % %     figure; 
% % %     subplot(2,2,1); imshow(uint8(img));
% % %     subplot(2,2,2); imshow(uint8(hImg1));
% % %     subplot(2,2,3); imshow(uint8(hImg2));
% % %     subplot(2,2,4); imshow(uint8(hImg3));
% % %     
% % %     edema_file_namer = strcat(edema_file_name,'Result');
% % % %     saveas(gcf,strcat('C:\Users\abafna\Desktop\New folder\',hema_file_name),'png');
% % %     print( gcf, '-dpng', strcat('C:\Users\abafna\Desktop\New folder\',edema_file_namer));



end




