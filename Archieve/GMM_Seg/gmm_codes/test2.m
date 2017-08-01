% function isdetected = detectEd(filename,RotatedDir,EdemaDir)
% 
% hema_file_name = [hemaDir, filename];
% edema_file_name = [EdemaDir, filename];
img = imread('18.png');
% img = imread([RotatedDir, filename]);
% img = rgb2gray(imread('14.jpg'));
% img = rgb2gray(imread('13.png'));
% img = imrotate(img,-2.5);
% img = img(:,1:size(img,2)/2);
% img = img(:,size(img,2)/2+1:end);
imshow(img)
hold on;
% %%
%  img = imadjust(img);
%  imshow(img)

%% Create Ventricle Templates
rp = imfill(double(img),'holes');
rp(rp>0) = max(max(rp));

[rpb,~] = bwlabel(rp);
rpbox = regionprops(rpb,'BoundingBox','Centroid');


rectangle('Position',rpbox(1).BoundingBox,'EdgeColor','r');
xl = rpbox(1).BoundingBox(1,1);
yl = rpbox(1).BoundingBox(1,2);
w = rpbox(1).BoundingBox(1,3);
h = rpbox(1).BoundingBox(1,4);

centx = rpbox(1).Centroid(1,1);
centy = rpbox(1).Centroid(1,2);

% cx = centx;
% cy = centy;

cx = xl+w/2;
cy = yl+h/2;

xl2 = cx-w/6;
yl2 = cy-h/6-h/12;
w2 = w/3;
h2 = h/3+h/24;
box2 = [xl2 yl2 w2 h2];
rectangle('Position',box2,'EdgeColor','g');


xl3 = cx-w/4+w/24;
yl3 = cy+h/8-h/24;
w3 = w/8;
h3 = h/4;
box3 = [xl3 yl3 w3 h3];
rectangle('Position',box3,'EdgeColor','b');


xl4 = cx+w/4-w3-w/24;
yl4 = cy+h/8-h/24;      
box4 = [xl4 yl4 w3 h3];
rectangle('Position',box4,'EdgeColor','b');



%Set1 Edema
%%
% -------------------------------------------------------------------------
white = imfill((img),'holes');
white(white>0) = 1;
% max(max(white));

%% Intracranial Extraction conversion into white image
img2new = ones(size(img))*255;
img2new = img2new.*(1-double(white))+ double(img).*double(white);
imshow(uint8(img2new));

img2n = double(medfilt2(img2new));

%% Median Filtering
img2n = double(medfilt2(img2new));
imshow(uint8(img2n));
%%
%  finalim = zeros(size(img2n));
%  finalim(innerbrain_mask==1) = double(img_Mattress_2d(innerbrain_mask==1));
% x = double(img2n(:));
% label = emgm(x',5);
% k = reshape(label,size(img2n,1),size(img2n,2));
% figure, imshow(mat2gray(k)),title('GMM on normal image');


%% Histogram of intracranial matter and Subracting graymatter intensit
% [a,~]=hist(img2n(:),256);
[a,~]=hist(double(img2n(:)),256);
[~,grval]=max(a(10:end));
img2f = double(img2n);
img2f(img2f>grval) = 255;
% - (img2n>0)*(grval);
figure,imshow(uint8(img2f));
% figure, plot(a(10:end));
% img2f = double(img2n) - (~white2)*(grval);
% img2n(img2n<grval)=0;
% imshow(uint8(img2n));
% hist(double(img2fin(:)))

%%
img2f = medfilt2(double(img2f));
figure,imshow(uint8(img2f));
%%
% Linear Contrast Stretching for Edema
[a,~]=hist(img2n(:),256);
[~,grval]=max(a(10:end));
img2fin = imadjust(uint8(img2n),[0 0.5],[]);
figure,imshow(uint8(img2fin)),title('LCS');
% -------------------------------------------------------------------------
%% Running GMM after Subtracting Grey matter Intensity
% x2 = [double(img2n(:)) double(img2f(:)) double(img2fin(:))];
% x2 = [double(img2f(:)) double(img2fin(:))];
x2 = [double(img2fin(:)) double(img2f(:))];    
% x2 = [double(img2fin(:)) double(img2n(:))];
% x2 = [double(img2n(:)) double(img2fin(:))];
% x2 = double(img2f(:));
label = [];maxiter = 5;id=0;
while length(unique(label))~=4 && id<maxiter 
    label = emgm(x2',4);
    k2 = reshape(label,size(img2f,1),size(img2f,2));
    id = id+1;
end
if length(unique(label))~=4
    display('Changing Features..')
    x2 = [double(img2f(:)) double(img2fin(:)) double(img2n(:))];id=0;
    while length(unique(label))~=4 && id<maxiter 
        label = emgm(x2',4);
        k2 = reshape(label,size(img2f,1),size(img2f,2));
        id = id+1;
    end
end

% figure,imshow(mat2gray(k2)),title('GMM after Subtracting GreyIntensity');
% [~, threshold] = edge(img2fin, 'sobel');
% fudgeFactor = .5;
% BWs = edge(img2fin,'sobel', threshold * fudgeFactor);
% figure, imshow(BWs), title('binary gradient mask');
% I = uint8(mat2gray(k));
%%
s2 = regionprops(k2,'centroid','Area','PixelIdxList','PixelList','FilledArea','FilledImage','ConvexImage','Image','Extent','Extrema','Eccentricity');
% centroids = cat(1, s.Centroid);
% imshow(mat2gray(k2))
% hold on
% plot(centroids(:,1), centroids(:,2), 'b*')


%Hematoma
% -------------------------------------------------------------------------
%% Separate component masks
    s=s2;
    comps = zeros([size(img2n) numel(s)]);
 for i = 1 : numel(s)
     complot = zeros(size(img2n));
     for j = 1:length(s(i).PixelList)
        complot(s(i).PixelList(j,2),s(i).PixelList(j,1)) = 1;
    end
    comps(:,:,i) = complot;
 end
 
 %% Calculate mean intensity for each connected component
 compsInt = zeros(numel(s),1);
 for i = 1: numel(s)
    temp =  comps(:,:,i).*255;
    compsInt(i) = mean(img2n(find(temp)));
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


hImg = repmat(img2n,1,1,3);
hImg(:,:,1) = hImg(:,:,1) + comps(:,:,hIdx).*255;
hImg(:,:,2) = hImg(:,:,1).*(~comps(:,:,hIdx));
hImg(:,:,3) = hImg(:,:,1).*(~comps(:,:,hIdx));
% figure,imshow(uint8(hImg));
if areas(hIdx)<BrArea*(0.4)
    figure,imshow(uint8(hImg));
    isdetected = strcat('Hematoma Image saved ', filename); 
else
    isdetected = strcat('Edema not detected in ', edema_file_name);
    imwrite(uint8(img2n), edema_file_name);
end
%Edema
% -------------------------------------------------------------------------
% % % %% Linear Contrast Stretching
% % % 
% % % img2fin = imadjust(uint8(img2f));
% % % figure, imshow(uint8(img2fin)),title('LCS');

% ------------------------------------
% % % %% Choosing the largest connected components
% % % %%
% % % x = double(img2ff(:));
% % %     label = emgm(x',4);
% % %     k = reshape(label,size(img2n,1),size(img2n,2));
% % %     subplot(1,4,4), imshow(mat2gray(k)),title('GMM after LCS');
% % % toc
% -------------------------------------------------------------------------
