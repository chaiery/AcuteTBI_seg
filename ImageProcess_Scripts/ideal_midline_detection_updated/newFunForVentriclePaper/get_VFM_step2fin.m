function [seg_kmean, pixScale2 , rev] = get_VFM_step2fin(Img_M)

% filter the image and decrease the effect of edge gita curve caused by rotate
% Img_M = stru(i_pos).imStru.img_Mattress;

rev = 0;
pixScale2 = 0;            
seg_kmean = 0;
% Img_M(find(Img_M>250)) = 0; 
% rev = isCrashed(Img_M,250);
% if rev ~= 0 
%     return; 
% end
% 
% [innerbrain_mask, rev] = getinnerbrainwhite(Img_M,250);
% if rev ~= 0 
%     return; 
% end

% Img_M = uint8(innerbrain_mask.*double(Img_M));

[innerbrain_mask, rev] = getinnerbrainwhite(Img_M,250);

if rev ~= 0
    return;
end

Img_M(find(Img_M>250)) = 0;  
Img_M = Img_M.*uint8(innerbrain_mask);
    
 Img_M = medfilt2(Img_M, [5,5]);

%% use k-means for initialization
ind_mask = find(Img_M~=0);
gray_roi_vec = Img_M(ind_mask);

if length(gray_roi_vec) <5 
    rev = 1;
    return; 
end

k_c=4;
kseeds = [40, 80, 100, 255]';
[idx, mc]=kmeans(double(gray_roi_vec), k_c, 'start', kseeds, 'EmptyAction', 'singleton'); 

if(isempty(find(unique(idx)==1)))
    rev = 1;
    return;
end

if length(unique(mc)) < 4
    rev = 1;
    fprintf(' segementation error : not 4 class. \n');
    return;
end


pixnum = [length(find(idx==1)), length(find(idx==2)),length(find(idx==3)),length(find(idx==4))];
pixScale2 = 0;
% if pixnum(1) < 100 || pixnum(2)>37000 || pixnum(1) > 8000
%     pixScale = 0;
% else
%     pixScale = double(double(pixnum(2))/double(pixnum(1)));
%    
% end
if pixnum(1) < 100
   pixScale2 = 0; 
else
   pixScale2 = double(double(sum(pixnum))/double(pixnum(1)));
end

label_2D = zeros(size(Img_M));
label_2D(ind_mask) = idx;

vent_map_kmean = zeros(size(Img_M));

clu_count = 0;
% for i_k=1:k_c
i_k = 1;
lab_mask=zeros(size(label_2D));
lab_ind=find(label_2D==i_k);
clu_count=clu_count+1;
lab_mask(lab_ind)=clu_count;
% clear small spots
    [L, num]=bwlabel(lab_mask);
    for i=1:num
        ind_lab=find(L==i);
        if(length(ind_lab)<60)
            lab_mask(ind_lab)=0;
        end
    end
vent_map_kmean = vent_map_kmean + lab_mask;
seg_kmean = vent_map_kmean;

if sum(sum(seg_kmean)) < 120
    pixScale2 = 0;
end


 
  if pixScale2 ~=0
     pixScale2 = double(1/pixScale2); 
  end
%   fprintf('pixnum : %d %d %d %d    <---> VFM : %4.3f \n', ...\
%         pixnum(1),pixnum(2),pixnum(3),pixnum(4), pixScale2 ); 
%   
  
end
