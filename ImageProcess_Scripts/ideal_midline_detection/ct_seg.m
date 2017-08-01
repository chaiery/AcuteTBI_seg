%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Wenan Chen
%% Sep 23rd, 2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% This is the function to segment the CT image into skull and get rid of
%% other small parts with the same intensity of skull.


function seg_img=ct_seg(B)
%% histogram of image
%% figure;
%% imhist(B);

%% segmentation according to histogram
seg_img=zeros(size(B));

C=B;
%% use median filter to get rid of small spots: this will remove local
%% details
% C=medfilt2(C);

%% use threshold to classify background and foreground
C(find(C>250))=255; %% bone range intensity>250
C(find(C<=250))=0;

%% figure; imshow(C);

%% use the skeleton of the image
% BW=bwmorph(C,'skel',Inf);

%% use dilation to get small crack merged: this will change local details
% SE=strel('square',3);
% BW=imdilate(C,SE);
%% use close
BW = bwmorph(C,'close');
% BW=C;

%% get the skull segment as the largest region with bone intensity
%% [reg_img,reg_labels]=cal_region(BW); %% this is the function I write
[reg_img,num]=bwlabel(BW,8);
%% use threshold to remove smaller parts. 
s= regionprops(reg_img, 'Area');
s_area=zeros(num,1);
for i=1:num
    s_area(i)=s(i).Area;
end
[area_sort, ind]=sort(s_area, 'descend');
pert=0.8;
p_sum=0;
s_sum=sum(area_sort);
thresh=s_sum*pert;
for i=1:num
    seg_img(find(reg_img==ind(i)))=1; %% bone labeled as 1
    p_sum=p_sum+area_sort(i);
    if(p_sum>thresh)
        break;
    end
end

%% figure;imshow(seg_img);


    







