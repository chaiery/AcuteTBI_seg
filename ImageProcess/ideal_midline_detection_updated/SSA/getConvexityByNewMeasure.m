function [convexity ,rev] = getConvexityByNewMeasure(seg_skull_in)
convexity = 0;
rev = 0;

BW = seg_skull_in;
BWSave = BW;

[x,y] = mass_center_here(BW);
center = [x,y] ;
centered_img=centerimgHere(BW,center);

for k = 0:2:179
        
    imR = imrotate(centered_img, k);
    [row_ind, col_ind] = find(BW == 1);
    [row_sort, row_sort_ind] = sort(row_ind,'ascend');
    
    % yLen = length(row_sort);
    uni_row_ind = unique(row_ind);
    
    convexityInRow = 0;    
    for i=1:length(uni_row_ind)
       % point = [uni_row_ind(1),1];
        lineInImg = imR(uni_row_ind(i),:);
        indexForMinMax = find(lineInImg == 1);
        
        minIndex = uint8(min(indexForMinMax));
        maxIndex = uint8(max(indexForMinMax));
        
       % if minIndex ~= maxIndex
            
            convexityInRow = convexityInRow + length(find(lineInImg(minIndex:minIndex)==0))
       % end
    end
    
end

[row_ind, col_ind] = find(BW == 1);
[row_sort, row_sort_ind] = sort(row_ind,'ascend');

    
    yLen = length(row_sort);
    yLim = max( uint16((0.5*yLen -20)),0);
    y0 = row_sort(1) + 60;
    yUpper = y0 + yLim;
    
    diff = 0;
    diffNow = 0;
    diffPre = 0;
    j = 0; % y direction move ( the number of pixels decrease continuously)
   
    thresholdOfConvexity = 30;
    
    diffVec = zeros(yLim);
    for i=1:yLim
       
        y0 = y0 + 1;
        
        allPointsInThisRow = find(row_sort==y0);
        
        numOfPoints = length(allPointsInThisRow);
        if numOfPoints > 3
            j = j+1;
            if j > thresholdOfConvexity
                convexity = convexity - 500;
                j = 0;
            end
            continue;
        elseif numOfPoints < 2
            continue;
        else  
            diffPre = diffNow; 
            diffNow = abs( max(col_ind(allPointsInThisRow))...\ 
                         - min(col_ind(allPointsInThisRow)));   
            diffVec(i) = diffNow;
            if  (diffNow - diffPre) < -6   % give a descendent theshold  -6  
                j = j+1;
                    convexity = convexity - 20;
                if j > thresholdOfConvexity
                    convexity = convexity - 100;
                    j = 0;
                end
            end
        end

    end
    
%     diffTotal = diffNow(2:end) - diffNow(1:end-1);
%     ind = find(diffTotal > 0)
%     len = length(ind);
    
    
end



function [x,y]=mass_center_here(seg_imgBw)
% calculate the mass center of the object in the seg_imgBw.
%   Detailed explanation goes here

% inputs: seg_imgBw is the intensity image with 1 for foreground and
% 0 for background 

% outputs: [x,y] is the position of the mass center. 

[m,n]=size(seg_imgBw);

x_accu=0;
y_accu=0;
N_pixels=length(find(seg_imgBw==1));

% calculate x direction
for x_i=1:n
    yline=seg_imgBw(:,x_i);
    l_y=length(find(yline==1));
    x_accu=x_accu+x_i*l_y;
end
x=x_accu/N_pixels;

% calculate y direction
for y_i=1:m
    xline=seg_imgBw(y_i,:);
    l_x=length(find(xline==1));
    y_accu=y_accu+y_i*l_x;
end
y=y_accu/N_pixels;

end

% This function center the image with the given center.
function centered_img=centerimgHere(img,center,method)

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