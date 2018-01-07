function cond = annotation_exist(img, mode)
    if nargin ==1
        mode = 1;
    end
    dim = size(img);
    dim_2d = dim(1:2);
    x = dim(1);
    y = dim(2);
    indexs = [];
    cond = 0;
    
    img_new = zeros(dim_2d);
    img_new2 = img;
    
    for i = 1:x
        for j = 1:y
            value = img(j,i,:);
            if mode ==2
                if (value(1)==value(2)&&value(2)~=value(3))|| ...
                    (sum(value(:)==[255,242,0]')==3)
                    index = sub2ind(dim_2d, j, i);
                    indexs(end+1) = index;
                end
            elseif mode==1
                if ~(value(1)==value(2)&&value(2)==value(3))
                    index = sub2ind(dim_2d, j, i);
                    indexs(end+1) = index;
                end
            end
        end
    end
    
    img_new(indexs)= 255;

    BW = bwlabel(img_new);
    ImFilled = imfill(BW, 'holes');

    regions = regionprops(ImFilled, 'PixelList');

    for i = 1:length(regions)
        pixellist = regions(i).PixelList;
        if (length(pixellist)>5)
            cond = 1;
            break
%             for j = 1:length(pixellist)
%                 x = pixellist(j,1);
%                 y = pixellist(j,2);
%                 img_new2(y,x,:) = [255;0;0];
%             end
        end
    end
    
end