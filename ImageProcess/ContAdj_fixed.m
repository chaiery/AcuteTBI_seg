function [contrastAdjustedImage, range]= ContAdj_fixed(Img, ImInfo)
    Img = Img(:, :, 1);

    y_min = 0;
    y_max = 255;

    im_adust = Img;
    if (isfield(ImInfo, 'RescaleIntercept') && isfield(ImInfo, 'RescaleSlope') &&...
             isfield(ImInfo, 'WindowCenter') && isfield(ImInfo, 'RescaleIntercept'))
         if (isnumeric(ImInfo.RescaleIntercept) && isnumeric(ImInfo.RescaleSlope) &&...
             isnumeric(ImInfo.WindowCenter) && isnumeric(ImInfo.RescaleIntercept))
             im_adust = ImInfo.RescaleSlope * im_adust + ImInfo.RescaleIntercept;
             %win_width = ImInfo.WindowWidth(1);
             %win_center = ImInfo.WindowCenter(1);
             win_width = 100;
             win_center = 40;
         end
    end
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
    y_max=min(3300,max(Img(:)));

    newRange=y_max-y_min;
    contrastAdjustedImage = round(double(im_adust - win_min)*(double(y_max-y_min) / double(win_width)) + y_min);
    contrastAdjustedImage(im_adust < win_min) = y_min;
    contrastAdjustedImage(im_adust > win_max) = y_max;
    contrastAdjustedImage = contrastAdjustedImage/(double(y_max));
    contrastAdjustedImage = uint8(contrastAdjustedImage*255);
end
