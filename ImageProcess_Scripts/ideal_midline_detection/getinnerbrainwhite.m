function [innerbrain_mask, rev,nobrain] = getinnerbrainwhite(im,boneThreshold)
% get the inner brain which is white.

rev = 0;
nobrain=0;
siz=size(im);
if(isempty(boneThreshold))
    boneThreshold = 250;
end

im=double(im);

% set interior edge of the skull as ROI
% segmentation of the brain tisure, suppose the skull is connected
seg_img=getmainbonemaskwhite(im,boneThreshold);

% use close to prevent crack of skull
seg_img=imclose(seg_img, ones(7,7));
seg_img2=1-seg_img;
label_img=bwlabel(seg_img2,4);
seg_inner=zeros(size(seg_img));

% label_brain is the inner brain label
label_brain=label_img(floor(size(seg_img,1)/2),floor(size(seg_img,2)/2));
% N: start , if brain is not noticable and there is a completely filled 
% skull it returns nobrain=1, it is usefull for test_ideal_midline_updated
if (label_brain==0)
    nobrain=1;
end
% To remove slices if they does not show brain and the skull is not passing
% form the center of slice.
if (label_brain == label_img(1,1)|| label_brain==label_img(siz(1,1),1) || label_brain==label_img(1,siz(1,2))||label_brain==label_img(siz(1,1),siz(1,2)))
    nobrain=1;
end
% N: end
seg_inner(find(label_img==label_brain))=1;

innerbrain_mask=seg_inner;