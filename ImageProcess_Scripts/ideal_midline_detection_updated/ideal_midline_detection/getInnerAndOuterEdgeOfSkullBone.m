
function [ outerBw, innerBw, rev ] = getInnerAndOuterEdgeOfSkullBone( bwSkullBone )
% get the outer edge and inner edge of skull

rev = 0;

ceter=zeros(1,2);

% calculate the mass center of the foreground object
% [x,y]=mass_center(bwSkullBone);

% segmentation of the brain tisure, suppose the skull is connected
bwSkullBone2=1-bwSkullBone;
label_img=bwlabel(bwSkullBone2);
seg_outer=zeros(size(bwSkullBone));
seg_outer(find(label_img==1))=1;
seg_skull_out=1-seg_outer;
bw1=edge(seg_skull_out, 'sobel'); % this is the outer edge of skull


seg_inner=zeros(size(bwSkullBone));
label_brain=label_img(floor(size(bwSkullBone,1)/2),floor(size(bwSkullBone,2)/2));
seg_inner(find(label_img==label_brain))=1;
seg_skull_in=1-seg_inner;
bw2=edge(seg_skull_in, 'sobel'); % this is the inner edge of skull

outerBw = bw1;
innerBw = bw2;

end