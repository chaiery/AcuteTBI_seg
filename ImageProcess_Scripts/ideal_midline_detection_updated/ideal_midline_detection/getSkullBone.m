function [ bwSkullBone,rev ]  = getSkullBone( img_Mattress,boneThreshold )
% get skull bone
%   Detailed explanation goes here

rev = 0;
bwSkullBone = zeros(size(img_Mattress));

C = img_Mattress;
% C = medfilt2(C);

%% use threshold to classify background and foreground
C(find(C<=boneThreshold))=0;
C(find(C>boneThreshold))=1; 

%% use close
BW = bwmorph(C,'close');
[reg_img,num]=bwlabel(BW,8);
if num == 0
    rev = 1; % bone threshold not correct or skull bone crasp.
    return;
end

%% use threshold to remove smaller parts. 
s = regionprops(reg_img, 'Area');
s_area = zeros(num,1);
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
thresh=s_sum*pert;
for i=1:num % for every region 
    bwSkullBone(find(reg_img==ind(i)))=1; %% bone labeled as 1
    p_sum=p_sum+area_sort(i);
    if(p_sum>thresh)
        break;
    end
end

end

