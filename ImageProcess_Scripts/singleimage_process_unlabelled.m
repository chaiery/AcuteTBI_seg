function [struct_features, imgori_sub_ori, imgori_sub_adjust] = singleimage_process_unlabelled(imgori)

    % Unlabeled data
    % Extract Head Region
    label_img = bwlabel(imgori, 4);
    rpbox = regionprops(label_img,'BoundingBox');

    y1 = floor(rpbox(1).BoundingBox(1,1));
    x1 = floor(rpbox(1).BoundingBox(1,2));
    w = rpbox(1).BoundingBox(1,3);
    h = rpbox(1).BoundingBox(1,4);

    imgori_sub = imgori(x1-5:x1+h+5,y1-5:y1+w+5);

    imgori_sub_ori = imgori_sub;
    imgori_sub = removeMidline(imgori_sub);
    
    % Process original images by ajusting contrast
    win_min = 80;
    win_width = 255-win_min;
    imgori_sub_adjust = uint8(double(imgori_sub - win_min)*255 / double(win_width));
    imgori_sub_adjust  = medfilt2(imgori_sub_adjust);

    [labels, ~] = slicmex(imgori_sub_adjust,1000,8);
    components = regionprops(labels, imgori_sub_adjust,'PixelIdxList','MeanIntensity','BoundingBox','WeightedCentroid');
    %{
    figure
    BW = boundarymask(labels);
    imshow(imoverlay(imgori_sub,BW,'cyan'),'InitialMagnification',67)
    %}

    struct = [];
    index_1 = 1;
    for i = 1:length(components)
        if components(i).MeanIntensity> 10  
            % hema(components(i).PixelIdxList) = 255;
            struct(index_1).PixelIdxList = components(i).PixelIdxList;
            struct(index_1).WeightedCentroid = components(i).WeightedCentroid;
            struct(index_1).BoundingBox = components(i).BoundingBox;
            struct(index_1).MeanIntensity = components(i).MeanIntensity;
            index_1 = index_1+1;
        end
    end

    struct_features = feature_extraction(struct, imgori_sub_adjust);

end