function [new_masks] = midline_remove(brains, masks, cond)
    n = size(masks, 3);
    if cond==1      
        new_masks = zeros(size(masks));
    else
        new_masks =masks;
    end
    for i = 1:n
        brain = brains(:,:,i);
        mask = masks(:,:,i);
        if sum(mask(:)) && sum(brain(:))
            img = logical(brain);
            mask = mask.*img;
            rpbox = regionprops(img,'BoundingBox','Centroid');
            xl = rpbox(1).BoundingBox(1,1);
            yl = rpbox(1).BoundingBox(1,2);
            w = rpbox(1).BoundingBox(1,3);
            h = rpbox(1).BoundingBox(1,4);
       
            mask = im2uint8(mask);

            new_mask = midline_remove_slice(mask, xl, w);
            new_mask = erosion(new_mask, xl, w);
            new_mask = endregion_remove_slice(new_mask, xl, yl, w,h);  
            
            new_masks(:,:,i) = new_mask;
        end
    end
end


function [mask] = endregion_remove_slice(mask, xl, yl, w,h)
    %% Remove small region at the end of midline or at the start od midline
    cx = xl+w/2;
    cy = yl+h/2; %centroid position
    xl2 = cx;
    yl2 = cy+h/4;
    w2 = w/6;
    h2 = h/2-h/6;
    test = zeros(size(mask));

    test(int32(yl2+h/12):min(int32(yl2+h2), 512), int32(xl2-w2):min(int32(xl2+w2), 512)) = 255;
    test(int32(yl):int32(yl+h2/2), int32(xl2-w2/2):int32(xl2+w2/2)) = 255;
     
    index_box = find(test==255);
    %mask_old = mask;
    %mask = test.*double(mask);
    lowest_point = yl+h;
    %% Components in Mask
    img = logical(mask);
    compos = regionprops(img, 'PixelIdxList', 'PixelList');
    index_remove = [];
    for i = 1:size(compos,1)
        tarindex = compos(i).PixelIdxList;
        perc = length(intersect(index_box, tarindex))/length(tarindex);
        if perc>0.9
            %If it is very close to the edge
            lis = compos(i).PixelList;
            lowest_y = max(lis(:,2));
            highest_y = min(lis(:,2));
            if abs(lowest_y-lowest_point)<10||abs(highest_y-yl)<10;
                index_remove = cat(1, index_remove, tarindex);
            end
        end
    end
    mask(index_remove)=0;
    %index_mask = find(mask==255);
    %index_new = setdiff(index_mask, index_remove);
    %new_mask = zeros(size(mask));
    %new_mask(index_new) = 255;
end


function [mask] = midline_remove_slice(mask, xl, w)
    %% For test
    % masks = PatientsData(23).masks;
    % brains = PatientsData(23).rota_brains;
    % 
    % brain = brains(:,:,18);
    % mask = masks(:,:,18);
    %% First, find the region of interest
    % Ref: ventricle box
    % Find the midline region
    cx = xl+w/2;
    %xl2 = cx-w/16;
    xl2 = cx;
    w2 = w/6;
    test = zeros(size(mask));
    test(:, int32(xl2-w2):int32(xl2+w2)) = 255;
    index_box = find(test==255);

    %% Components in Mask
    img = logical(mask);
    compos = regionprops(img, 'PixelIdxList', 'PixelList', 'MajorAxisLength', 'MinorAxisLength','Orientation');
    index_remove = [];
    for i = 1:size(compos,1)
        tarindex = compos(i).PixelIdxList;
        perc = length(intersect(index_box, tarindex))/length(tarindex);
        if length(tarindex)>10
            if perc==1
                ratio = compos(i).MajorAxisLength/compos(i).MinorAxisLength;
                orien = abs(abs(compos(i).Orientation) - 90);
                if orien<30 && ratio>4
                    index_remove = cat(1, index_remove, tarindex);
                end
%         %if perc==1 && length(tarindex)>10
%             % Use alphaShape to better fit a shape
%             pixellist = compos(i).PixelList;
%             x = pixellist(:,1);
%             y = pixellist(:,2);
%             %%
%             shp = alphaShape(x,y);
%             shp.Alpha=Inf;
%             [x, y] = meshgrid(1:512, 1:512);
%             shape = inShape(shp,x,y);
%             %%
%             % Create the Hough transform using the binary image.
%             BW = shape;
%             [H,~,~] = hough(BW, 'Theta',  -5:5);
% 
%             % Find peaks in the Hough transform of the image.
%             P  = houghpeaks(H,'threshold',40);
%             if P
%                 index_remove = cat(1, index_remove, tarindex);
%             end
            end
        else
            index_remove = cat(1, index_remove, tarindex);
        end
    end
    %% Build the new mask
    mask(index_remove)=0;
end

function [mask] = erosion(mask, xl, w)
    %% For test
    % masks = PatientsData(23).masks;
    % brains = PatientsData(23).rota_brains;
    % 
    % brain = brains(:,:,18);
    % mask = masks(:,:,18);
    %% First, find the region of interest
    % Ref: ventricle box
    % Find the midline region
    cx = xl+w/2;
    %xl2 = cx-w/16;
    xl2 = cx;
    w2 = w/6;
    test = zeros(size(mask));
    test(:, int32(xl2-w2):int32(xl2+w2)) = 255;
    index_box = find(test==255);

    %% Components in Mask
    img = logical(mask);
    compos = regionprops(img, 'PixelIdxList', 'PixelList', 'MajorAxisLength', 'MinorAxisLength','Orientation');
    index_remove = [];
    for i = 1:size(compos,1)
        tarindex = compos(i).PixelIdxList;
        index = intersect(index_box, tarindex);
        if ~isempty(index)
            img = zeros(size(mask));
            
            % Only for patient 56
            img(index)=1;
            
            % For all others
            %img(tarindex) = 1;

            mark = find((sum(img,2)<10)==0);
            img(mark,:)=0;
            img = logical(img);
            compos2 = regionprops(img, 'PixelIdxList', 'PixelList', 'MajorAxisLength', 'MinorAxisLength','Orientation');

            for j = 1:size(compos2,1)
                tarindex2 = compos2(j).PixelIdxList;
                ratio = compos2(j).MajorAxisLength/compos2(j).MinorAxisLength;
                orien = abs(abs(compos2(j).Orientation) - 90);
                overlap = intersect(index_box, tarindex2);
                if orien<30 && ratio>4 && (~isempty(overlap))
                    index_remove = cat(1, index_remove, tarindex2);
                end
            end
        end
    end
    mask(index_remove)=0;
end