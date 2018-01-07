%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Wenan Chen
% September, 2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This function center the image with the given center.
function centered_img=centerimg(img,center,method)

% input: img is the image to be centered, center is the coordinate with 
% (x,y). x is the horizontal coordinate, y is the vertical coordinate.

if(nargin<3)
    method=='fullsize';
end

n_dim=ndims(img);
if(n_dim==2)
    [m,n]=size(img);
    Canvas=zeros(m*2,n*2);
else
    [m,n,p]=size(img);
    Canvas=zeros(m*2,n*2,p);
end

% paste the image to the Canvas with the image centered with center
left_corner_x=n-center(1);
left_corner_y=m-center(2);
Canvas([left_corner_y:left_corner_y+m-1],[left_corner_x:left_corner_x+n-1],:)=img;

% get the image cropped around the center
if(method=='crop')
    centered_img=Canvas([floor(m/2):floor(m/2)+m-1],[floor(n/2):floor(n/2)+n-1],:);
else
    centered_img=Canvas;
end
end