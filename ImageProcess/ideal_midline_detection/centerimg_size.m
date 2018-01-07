%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Wenan Chen
% September, 2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% This function center the image with the given center.
function centered_img=centerimg_size(img,center,width, height)

%% input: img is the image to be centered, center is the coordinate with 
%% (x,y). x is the horizontal coordinate, y is the vertical coordinate.
%% width, height is the size of returned image.

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

% get the image cropped around the center with the given width and height
x1=n-floor(width/2);
y1=m-floor(height/2);
centered_img=Canvas([y1:y1+height-1],[x1:x1+width-1],:);
