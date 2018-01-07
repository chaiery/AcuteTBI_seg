function [ rotate_angle,center,choosing, outerBw, innerBw, rev ] =  ...
                    getRotatedAngleAndCenterOfAM( bwSkullBone )
% get the segmented image rotated to the place where the midline is the center of the image
%   Detailed explanation goes here

rev = 0;

rotate_angle=0;
ceter=zeros(1,2);
choosing=1;
outerBw = 0;
innerBw = 0;

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

[rotate_angle1, dis_vec1, best_j1, center1]=rota_search(bw1);
[rotate_angle2, dis_vec2, best_j2, center2]=rota_search(bw2);
dissymm1=dis_vec1(best_j1);
dissymm2=dis_vec2(best_j2);
choosing=1;
if(rotate_angle2==rotate_angle1)
    choosing=1;
elseif(abs(dissymm1-dissymm2)/min(dissymm1,dissymm2)<0.2)
    % compare stablity using derivative
    if(best_j1==1)
        stb1=dis_vec1(best_j1+1)-dissymm1;
    elseif(best_j1==size(dis_vec1))
        stb1= dissymm1-dis_vec1(best_j1-1);
    else
        stb1=min(dis_vec1(min(best_j1+1,length(dis_vec1)))-dissymm1, -dissymm1+dis_vec1(max(best_j1-1, 1)));
    end
    if(best_j2==1)
        stb2=dis_vec1(best_j2+1)-dissymm2;
    elseif(best_j2==size(dis_vec2))
        stb2= dissymm2-dis_vec1(best_j2-1);
    else
        stb2=min(dis_vec2(min(best_j2+1,length(dis_vec2)))-dissymm2, -dissymm2+dis_vec2(max(best_j2-1,1)));
    end
    if(stb1<stb2)
        choosing=1;
    else
        choosing=2;
    end
elseif(abs(dissymm1-dissymm2)/min(dissymm1,dissymm2)>1.5)
    if(dissymm2<dissymm1)
        choosing=2;
    end
elseif(dissymm1<dissymm2)
    choosing=1;
     % change easy to best_j2 for bw1 && unacceptable for bw2 to best_j1;
    if((dis_vec1(best_j2)+dis_vec1(best_j1))<(dis_vec2(best_j1)+dis_vec2(best_j2)))
        choosing=2;
    end
else
    choosing=2;
     % change easy to best_j1 for bw2 && unacceptable for bw1 to best_j2;
    if((dis_vec1(best_j2)+dis_vec1(best_j1))<(dis_vec2(best_j1)+dis_vec2(best_j2)))
        choosing=1;
    end
end

if(choosing==1)
    rotate_angle=rotate_angle1;
    center=center1;
else
    rotate_angle=rotate_angle2;
    center=center2;
end

fprintf('choosing = %f, angle= %f\n',choosing, rotate_angle);

end


function [rotate_angle, dis_vec, best_j, center]=rota_search(seg_skull)

seg_skull(find(seg_skull))=1;

% calulate the mass center of the brain tissue edge
[x,y]=mass_center(seg_skull);

x_c=floor(x);
y_c=floor(y);

coord_img=seg_skull;
coord_img(y_c,x_c)=1;
% figure;imshow(coord_img)

% let the image centered with the mass center
[m,n]=size(seg_skull);
Canvas=zeros(m*2,n*2);
lcm=floor(m/2); lcn=floor(n/2); % left corner where the image paste 
% paste image to the canvas
Canvas(lcm+1:lcm+m,lcn+1:lcn+n)=coord_img(1:m,1:n);
% get the centered image by cropping
cropRect=[x_c,y_c,m-1,n-1];
centered_img=imcrop(Canvas,cropRect);

[rotate_angle, dis_vec, best_j]=rota_symm_search(centered_img,-45,45,2);

center(1)=x_c; center(2)=y_c;

end

