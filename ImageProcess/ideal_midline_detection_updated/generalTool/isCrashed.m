function rev = isCrashed( gray_CTimage,boneThreshold)
% To judge the skull is crashed or not
%   Detailed explanation goes here

rev = 0;

dimsOfgray_CTimage = ndims(gray_CTimage);
if dimsOfgray_CTimage == 3
    A = gray_CTimage(:,:,1);
%   A = rgb2gray(double(gray_CTimage)); 
elseif dimsOfgray_CTimage ==2
   A =  uint16(gray_CTimage) ; 
else
   rev = 1;
end

if(isempty(boneThreshold))
    boneThreshold = 250;
end

inner_regin_white = getinnerbrainwhite(A,boneThreshold);

% test B is three area or not, if not , rev = 1 return;
%[L_B, num] =bwlabel(B);

area_sum = regionprops(inner_regin_white,'Area');

if( ndims(area_sum) ~=2)
    rev = 1;
    return;
end

if( inner_regin_white(2,2) == 1 || inner_regin_white(1,1) == 1 || inner_regin_white(end,end) == 1 )
    rev = 1;
    return;
end

area_white = 0;
area_black = 0;

area_white = get_BW_whitePart_Area(inner_regin_white);
area_black = get_BW_whitePart_Area(ones(size(inner_regin_white))-inner_regin_white);

if( area_white > area_black)
    rev = 1;
    return;
end

end

