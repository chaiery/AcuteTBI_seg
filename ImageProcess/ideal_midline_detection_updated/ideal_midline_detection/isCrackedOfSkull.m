function rev = isCrackedOfSkull( bwSkullBone )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

%% output: rev 1 means crack, 0 means no crack

rev = 0; % default the skull bone is not cracked.

L=bwlabel(bwSkullBone,8);
s=regionprops(L, 'Centroid');
mcent=s(1).Centroid;
x=mcent(1);
y=mcent(2);

%% suppose there is no bone on mass center and it is inside the brain. 
%% if there is crack, then mass center will keep not filled, else it will
%% be filled as the bone
img_fill=imfill(bwSkullBone, 'holes');
if(img_fill(floor(y),floor(x))==1)
    rev=0;
else
    rev=1;
end

end

