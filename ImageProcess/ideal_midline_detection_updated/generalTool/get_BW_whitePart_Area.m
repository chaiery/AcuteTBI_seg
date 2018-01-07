%    Author: Xuguang Qi
%      Date: 2011/1/8
%   Version: 1.0 
%  Function: get area of white part of binary image
%  Modification history and specification:

%get area of white part of binary image
function [BW_area] = get_BW_whitePart_Area(BW_img)
%get area of white part of binary image

img = BW_img;
img = bwmorph(img,'clean');
img = bwmorph(img,'fill');

[L, num]=bwlabel(img);

stat_area = regionprops(L,'Area');

area = 0;

for i=1:num 
    index_reg = find(L == i);
    if img(index_reg(1)) == 1
        area = area + stat_area(i).Area;
    end
end

BW_area = area;

end