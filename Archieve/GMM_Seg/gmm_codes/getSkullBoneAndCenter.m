function [ bwSkullBone ,center , rev]=getSkullBoneAndCenter(imStru)


bwSkullBone = '' ;
center = [0,0]; 
rev = 0;

%% get skull bone
[ bwSkullBone,rev ]  = getSkullBone( imStru.img_Mattress,imStru.boneThreshold );
% N: if rev ~= 0
% N:    return;
% N: end
%figure, imshow(bwSkullBone,[]);

% judge the skull is broken or not
rev = isCrackedOfSkull(bwSkullBone);
%N:  if rev ~= 0
%     return;
% end

[x,y]=mass_center(bwSkullBone);
rev=0; %N
center = [x,y];

end