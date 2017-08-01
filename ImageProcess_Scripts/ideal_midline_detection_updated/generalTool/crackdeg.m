%% measure the crack degrees buy using the mass center as center, then scan
%% a full cirle to catch cracks and record the degree size of each crack
%% lasy now, so just tell whether there is crack or not
function deg=crackdeg(seg_img)
%% input: 
%% output: deg 1 means crack, 0 means no crack

L=bwlabel(seg_img,8);
s=regionprops(L, 'Centroid');
mcent=s(1).Centroid;
x=mcent(1);
y=mcent(2);

%% suppose there is no bone on mass center and it is inside the brain. 
%% if there is crack, then mass center will keep not filled, else it will
%% be filled as the bone
img_fill=imfill(seg_img, 'holes');
if(img_fill(floor(y),floor(x))==1)
    deg=0;
else
    deg=1;
end
