function [positive_pixelList, annot_index, img_new2] = FindAnnotatedRegion(img_annot,brain, mode)
    if nargin==2
        mode = 1;
    end
    %%
    positive_pixelList = [];
    dims = size(img_annot);
    dims_2d = dims(1:2);
    img_new = zeros(dims_2d);
    img_new2 = cat(3, brain, brain, brain);

    y = dims(1);
    x = dims(2);

    indexs = [];
    for i = 1:x
        for j = 1:y
            value = img_annot(j,i,:);
            if mode==1
                if ~(value(1)==value(2)&&value(2)==value(3))
                    index = sub2ind(dims_2d, j, i);
                    indexs(end+1) = index;
                end
            elseif mode==2
                if (value(1)==value(2)&&value(2)~=value(3))|| ...
                    (sum(value(:)==[255,242,0]')==3)
                    index = sub2ind(dims_2d, j, i);
                    indexs(end+1) = index;
                end
            end
        end
    end

    img_new(indexs)= 255;

    BW = bwlabel(img_new);
    ImFilled = imfill(BW, 'holes');

    regions = regionprops(ImFilled, 'PixelList', 'PixelIdxList');
    %%
    for i = 1:length(regions)
        pixellist = regions(i).PixelList;
        if (length(pixellist)>5)
            bg = zeros(size(brain));
            bg(regions(i).PixelIdxList)=1;
            se = strel('disk',4);
            rem= imerode(bg ,se);
            if ~isempty(find(rem==1))
                positive_pixelList = [positive_pixelList; pixellist];
                for j = 1:length(pixellist)
                    x = pixellist(j,1);
                    y = pixellist(j,2);
                    if brain(y,x)~=0
                        img_new2(y,x,:) = [255;0;0];
                    end
                end
            end
        end
    end
    %%
    annot_index = cell2mat(arrayfun(@(i) sub2ind(size(brain),positive_pixelList(i,2),positive_pixelList(i,1)),1:length(positive_pixelList),'un',0));
    annot_index = annot_index';
end