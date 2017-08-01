function img_new2 = process_annotated_imgs(img)
    dims = size(img);
    dims_2d = dims(1:2);
    img_new = zeros(dims_2d);
    img_new2 = img;
    y = dims(1);
    x = dims(2);

    indexs = [];
    for i = 1:x
        for j = 1:y
            value = img(j,i,:);
            if (~(value(1)==value(2)&&value(2)==value(3)))
                index = sub2ind(dims_2d, j, i);
                indexs(end+1) = index;
            end
        end
    end

    img_new(indexs)= 255;

    BW = bwlabel(img_new);
    ImFilled = imfill(BW, 'holes');

    regions = regionprops(ImFilled, 'PixelList');

    for i = 1:length(regions)
        pixellist = regions(i).PixelList;
        for j = 1:length(pixellist)
            x = pixellist(j,1);
            y = pixellist(j,2);
            img_new2(y,x,:) = [255;0;0];
        end
    end

    %figure;imshow(uint8(img_new2));
end

