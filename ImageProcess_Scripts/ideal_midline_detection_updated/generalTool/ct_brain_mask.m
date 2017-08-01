function brain_mask=ct_brain_mask(im)

im=double(im);
%% set interior edge of the skull as ROI
%% segmentation of the brain tisure, suppose the skull is connected
seg_img=ct_seg(im);
%% use close to prevent crack of skull
seg_img=imclose(seg_img, ones(7,7));
seg_img2=1-seg_img;
label_img=bwlabel(seg_img2);
seg_inner=zeros(size(seg_img));
label_brain=label_img(floor(size(seg_img,1)/2),floor(size(seg_img,2)/2));
seg_inner(find(label_img==label_brain))=1;

brain_mask=seg_inner;