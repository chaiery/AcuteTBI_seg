function [center , rev]=MassCenterOfSkull(imStru)


bwSkullBone = imStru.bwSkullBone;
rev = 0;

% judge the skull is broken or not
rev = isCrackedOfSkull(bwSkullBone);
%N:  if rev ~= 0
%     return;
% end

[x,y]=mass_center(bwSkullBone);
rev=0; %N
center = [x,y];

end