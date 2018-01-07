function [struct_1, struct_0, struct_1_features, struct_0_features] = singleimage_process_with_label(brain, annotation, intensity_mean)

    % Labeled data
    % Extract Head Region
    %%
    if isempty(brain)
        struct_1=[]; struct_0=[]; 
        struct_1_features=[]; struct_0_features=[]; 
    else
        num_sp = 10000;
        [labels, ~] = superpixels(brain,num_sp);
        components = regionprops(labels, brain, 'PixelIdxList','MeanIntensity', 'BoundingBox','PixelValues', 'WeightedCentroid');
        idx = [];
        for i = 1:length(components)
            if (components(i).MeanIntensity > 10)
                idx(end+1) = i;
            end
        end
        components = components(idx);

        struct_1 = [];
        struct_0 = [];
        index_1 = [];
        index_0 = [];

        for i = 1:length(components)
            lis = components(i).PixelIdxList;
            counts = 0;
            for j = 1:length(lis)

                [coor_x, coor_y] = ind2sub(size(brain),lis(j));

                value = annotation(coor_x, coor_y,:);
                if sum(value(:)==[255;0;0])==3
                    counts = counts+1;
                end
            end

            if (components(i).MeanIntensity > 0 && components(i).MeanIntensity < 250)
                pixel = components(i).PixelValues;
                rnum = sum(pixel~=0);
                if ((sum(pixel>240)/rnum)<0.5)
                    if counts/length(lis) > 0.4
                        components(i).label = 1;
                        index_1(end+1) = i;
                    else
                        components(i).label = 0;
                        index_0(end+1) = i;
                    end
                end
            end

            struct_1 = components(index_1);
            struct_0 = components(index_0);
        end

        %%

        %%
        if isempty(struct_0)
            struct_1_features=[]; struct_0_features=[]; 
        else

        %%
            struct_all = feature_extraction([struct_1;struct_0], brain, intensity_mean);

            struct_1_features = struct_all(1:length(struct_1));
            struct_0_features = struct_all(length(struct_1)+1:length(struct_all));
        end
    end
end

    %%
%     label_img = logical(brain);
%     rpbox = regionprops(label_img,'BoundingBox');
%     
%     y1 = floor(rpbox(1).BoundingBox(1,1));
%     x1 = floor(rpbox(1).BoundingBox(1,2));
%     w = rpbox(1).BoundingBox(1,3);
%     h = rpbox(1).BoundingBox(1,4);
% 
%     img_sub = img_annot(x1-16:x1+h+16,y1-16:y1+w+16,:);
%     brain_sub = brain(x1-16:x1+h+16,y1-16:y1+w+16);
%     brain_sub_ori = brain_sub;
%     % brain_sub = removeMidline(brain_sub);
%     % Process original images by ajusting contrast
%     win_min = 40;
%     win_width = 255-win_min;
%     %brain_sub_adjust = brain_sub;
%     brain_sub_adjust = uint8(double(brain_sub - win_min)*255 / double(win_width));
%     %brain_sub_adjust  = medfilt2(brain_sub_adjust);
    
    % Superpixels
    %[x, y] = size(brain_sub_adjust);
    %num_sp = floor(x*y/10);
    %[labels, ~] = superpixels(brain_sub_adjust,num_sp);

    %{
    figure
    BW = boundarymask(labels);
    imshow(imoverlay(img_sub,BW,'cyan'),'InitialMagnification',67)
    %}
