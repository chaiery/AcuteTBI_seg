% This is the function to segment the CT image into skull and get rid of
% other small parts with the same intensity of skull.

function mainbone_mask=getmainbonemaskwhite(B,boneThreshold)
% get the bone of brain skull (like loop) which is white

if(isempty(boneThreshold))
    boneThreshold = 250;
end
siz=size(B);
mainbone_mask=zeros(size(B));

C=B;
% use median filter to get rid of small spots: this will remove local
% details
% C=medfilt2(C);

%% use threshold to classify background and foreground
C(find(C>boneThreshold))=255; %% bone range intensity>boneThreshold
C(find(C<=boneThreshold))=0;

%% figure; imshow(C);

%% use the skeleton of the image
% BW=bwmorph(C,'skel',Inf);

%% use dilation to get small crack merged: this will change local details
% SE=strel('square',3);
% BW=imdilate(C,SE);
%% use close
BW = bwmorph(C,'close');

BW(find(B>boneThreshold))=1;
% D=B; BW(find(B>boneThreshold))=1;
% BW=C;

%% get the skull segment as the largest region with bone intensity
%% [reg_img,reg_labels]=cal_region(BW); %% this is the function I write
[reg_img,num]=bwlabel(BW,8);
%% use threshold to remove smaller parts. 
s= regionprops(reg_img, 'Area','BoundingBox');
s_area=zeros(num,1);
for i=1:num
    s_area(i)=s(i).Area;
    % N: start
    % To reject CT machine's interference as a bone 
    box=s(i).BoundingBox;
    if((box(1)<(siz(1,2)/40)) || (box(2)<siz(1,1)/40) || ((box(1)+box(3))> 39/40*siz(1,2))|| (box(2)+box(4))> 39/40*siz(1,1))
        s_area(i)=0;
    end
    % N: end 
end
[area_sort, ind]=sort(s_area, 'descend');
% note: area_sort = s_area(ind) (28,25,5,3)'
% note:  s_area(i)=s(i).Area; i=1:num  every area made by some points.
% note: reg_img(i) is the ith region of num 
pert=0.8;
p_sum=0;
s_sum=sum(area_sort);
thresh=s_sum*pert;
for i=1:num % for every region 
    mainbone_mask(find(reg_img==ind(i)))=1; %% bone labeled as 1
    p_sum=p_sum+area_sort(i);
    if(p_sum>thresh)
        break;
    end
end

 %figure;imshow(mainbone_mask);


    







