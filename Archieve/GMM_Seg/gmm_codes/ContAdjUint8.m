function [contrastAdjustedImage, range]= ContAdjUint8(Img, WW, WL)
Img = Img(:, :, 1);

y_min = 0;
y_max = 255;
% WL = 143; %40
% WW = 279; %80
win_center = WL+1024;
win_width = WW;
im_adust = Img;
% if (isfield(ImInfo, 'RescaleIntercept') && isfield(ImInfo, 'RescaleSlope') &&...
%         isfield(ImInfo, 'WindowCenter') && isfield(ImInfo, 'RescaleIntercept'))
%     if (isnumeric(ImInfo.RescaleIntercept) && isnumeric(ImInfo.RescaleSlope) &&...
%         isnumeric(ImInfo.WindowCenter) && isnumeric(ImInfo.RescaleIntercept))
%         im_adust = ImInfo.RescaleSlope * im_adust + ImInfo.RescaleIntercept;
%         win_width = ImInfo.WindowWidth;
%         win_center = ImInfo.WindowCenter;
%     end
% end
% D = 1;
% if(size(win_width, 1) > 1)
%     D = 2;
% end
% win_width = win_width(D,1);
% win_center =win_center(D,1);

win_min = (win_center-win_width/2);
win_max = (win_center+win_width/2);
oldRange = win_max - win_min;

range = [win_min win_max];

y_min=0;

newRange=y_max-y_min;
contrastAdjustedImage = (double(im_adust - win_min)*(double(y_max-y_min) / double(win_width)) + y_min);
contrastAdjustedImage(im_adust < win_min) = y_min;
contrastAdjustedImage(im_adust > win_max) = y_max;
% contrastAdjustedImage = Img;
end
