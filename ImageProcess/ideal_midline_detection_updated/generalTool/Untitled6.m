
boneThreshold = 250;
% gray_CTimage = imread('D:\myNetDriver\qxgbuy2011\paperAndThesis\Thesis_project\paper_1 figures\3541228_2\15.jpg');
% 
% gray_CTimage = imread('C:\dataset_thesis\thesis_paper1_jpgData_12_19_2012\3542819\3542819--2008-10-13-CT7685295-2-s-123.2.jpg');
% 
% gray_CTimage = imread('C:\dataset_thesis\thesis_paper1_jpgData_12_19_2012\3542819\3542819--2008-10-13-CT7685295-2-s-123.2.jpg');
% 
% % good sample crack detection failure but convexity detection remove it.
% % May be not.
% gray_CTimage = imread('C:\dataset_thesis\thesis_paper1_jpgData_12_19_2012\3545692\3545692--2008-09-19-CT7624540-2-s-194.8.jpg');
% 
% gray_CTimage = imread('C:\dataset_thesis\thesis_paper1_jpgData_12_19_2012\3549259\3549259--2008-10-08-CT7689279-2-s-70.3.jpg');
% 
% gray_CTimage = imread('D:\myNetDriver\qxgbuy2011\paperAndThesis\Thesis_project\paper_1 figures\3541228_2\21.jpg');
% 
% 
% 
% gray_CTimage = imread('D:\myNetDriver\qxgbuy2011\paperAndThesis\Thesis_project\paper_1 figures\3541228_2\19.jpg');
% 
% 
% gray_CTimage = imread('C:\conferenceP1\ForSkull\6626639\6626639--2005-01-02-79244559-602-s-228.482.jpg');
%        
% gray_CTimage = imread('C:\_conP2\the skull with bone chip\9779928--2008-09-24-DX7685593-3-s010.jpg');

imageDirRoot = 'C:\_conP2\the skull with bone chip\original!2\';
imageDirRootSave = 'C:\_conP2\the skull with bone chip save\';

dirList = dir(imageDirRoot);

% do loop for cur_patient
for cur_patient=1:length(dirList)
    dirnametmp = dirList(cur_patient).name;
       
    if strcmp(dirnametmp,'.')
        continue;
    end
    if strcmp(dirnametmp,'..')
        continue;
    end

    tmpDirSave = '';
    tmpDirSave = [imageDirRootSave, num2str(cur_patient)];
    tmpDirSave = [tmpDirSave, '\'];
    
    if ~exist([imageDirRootSave, num2str(cur_patient)],'dir')
        mkdir([imageDirRootSave, num2str(cur_patient)]);
    end
    
    
    gray_CTimage = imread([imageDirRoot,dirnametmp]);
    
imwrite(uint8(gray_CTimage),[tmpDirSave, '_originalImg.jpg']);
         
dimsOfgray_CTimage = length(size(gray_CTimage));

if dimsOfgray_CTimage == 3
    A = gray_CTimage(:,:,1);
%   A = rgb2gray(double(gray_CTimage)); 
elseif dimsOfgray_CTimage ==2
   A =  uint16(gray_CTimage) ; 
else
   rev = 1;
end

mainbone_mask=zeros(size(A));

if(isempty(boneThreshold))
    boneThreshold = 250;
end

im=double(A);


allBoneOri = uint8(zeros(size(im)));

allBoneOri(find(A>boneThreshold))=255; %% bone range intensity>boneThreshold
allBoneOri(find(A<=boneThreshold))=0;
imwrite(uint8(allBoneOri),[tmpDirSave, 'allBoneOri.jpg']);

% set interior edge of the skull as ROI
% segmentation of the brain tisure, suppose the skull is connected
seg_img=getmainbonemaskwhite(im,boneThreshold);

BW = seg_img;
[reg_img,num]=bwlabel(BW,8);
s= regionprops(reg_img, 'Area');
s_area=zeros(num,1);
for i=1:num
    s_area(i)=s(i).Area;
end
[area_sort, ind]=sort(s_area, 'descend');
% note: area_sort = s_area(ind) (28,25,5,3)'
% note:  s_area(i)=s(i).Area; i=1:num  every area made by some points.
% note: reg_img(i) is the ith region of num 
pert=0.8;
p_sum=0;
s_sum=sum(area_sort);
thresh=s_sum*pert; num =1 ;
for i=1:num % for every region 
    mainbone_mask(find(reg_img==ind(i)))=1; %% bone labeled as 1
    p_sum=p_sum+area_sort(i);
    if(p_sum>thresh)
        break;
    end
end

seg_img_save = seg_img;
seg_img = mainbone_mask;

% use close to prevent crack of skull
seg_img=imclose(seg_img, ones(7,7));
seg_img2=1-seg_img;

[label_img,num]=bwlabel(seg_img2);
%% use threshold to remove smaller parts. 
s= regionprops(label_img, 'Area');
s_area=zeros(num,1);

threshForRemoveHole=200;
sum_region = 0;

skull_fin = seg_img; % for fill the bone hole
for i=1:num
    s_area(i)=s(i).Area;
    
    if s(i).Area < threshForRemoveHole    
        
        ccc = zeros(size(A));
        ccc(find(label_img==i))=255;
         label_img(find(label_img==i)) = 0;
       
         
         fn = ['SSACrash_hole',num2str(i)];
         fn = [tmpDirSave,fn];
         fn = [fn, '.jpg'];
         imwrite(uint8(ccc),fn);
        
    else
        sum_region = sum_region + 1;
        
        ddd = zeros(size(A));
        ddd(find(label_img==i))=255;
        
         fn = ['SSACrash_bone',num2str(i)];
         fn = [tmpDirSave,fn];
         fn = [fn, '.jpg'];
         imwrite(uint8(ddd),fn);
         
    end    
end
 
% [area_sort, ind]=sort(s_area, 'descend');
% 
% skull_fin = seg_img;
% skull_fin(find(uint8(label_img)==ind(1)))= 1;
% 
        
         
% figure, imshow(label_img,[])

% figure, imshow(skull_fin,[])

f_img = zeros(size(A));
f_img = uint8(f_img);
f_img(find(label_img==0)) = 255;
 fn = ['finalBone', '.jpg'];
 fn = [tmpDirSave,fn];
         imwrite(uint8(f_img),fn);
% figure, imshow(f_img,[])


if sum_region == 2
    fprintf('bone is ok.\n'); 
else
    fprintf('bone is crash, and crash level is %d. \n', sum_region-2);
end

imwrite(uint8(seg_img_save*255),[tmpDirSave,'candidate80PerBone.jpg']);
imwrite(uint8(mainbone_mask*255),[tmpDirSave,'candidateMainBone.jpg']);
imwrite(uint8((1-mainbone_mask)*255),[tmpDirSave,'candidateMainBoneReverse.jpg']);

end
