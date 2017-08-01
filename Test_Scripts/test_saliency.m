function saliency_set = test_saliency(x)
    ImgDir = '/Users/apple/Dropbox/TBI/al_pool/';
    ImgFiles = dir(ImgDir);
    ImgFiles = ImgFiles(~strncmpi('.', {ImgFiles.name},1));
    ImgDir = '/Users/apple/Dropbox/TBI/Select_for_annotation';

    fori = ImgFiles(x).name;

    imgori = imread([ImgDir,'/',fori]);

    label_img = bwlabel(imgori, 4);
    rpbox = regionprops(label_img,'BoundingBox');

    y1 = floor(rpbox(1).BoundingBox(1,1));
    x1 = floor(rpbox(1).BoundingBox(1,2));
    w = rpbox(1).BoundingBox(1,3);
    h = rpbox(1).BoundingBox(1,4);

    imgori_sub = imgori(x1-5:x1+h+5,y1-5:y1+w+5);
    imgori_sub_ori = imgori_sub;

    % Process original images by ajusting contrast
    win_min = 80;
    win_width = 255-win_min;
    imgori_sub_adjust = uint8(double(imgori_sub - win_min)*255 / double(win_width));
    imgori_sub_adjust  = medfilt2(imgori_sub_adjust);

    % Superpixels
    [labels, ~] = slicmex(imgori_sub_adjust,1000,8);

    %{
    figure
    BW = boundarymask(labels);
    imshow(imoverlay(img_sub,BW,'cyan'),'InitialMagnification',67)
    %}

    components = regionprops(labels, imgori_sub_adjust, 'PixelIdxList','MeanIntensity', 'BoundingBox','PixelValues', 'WeightedCentroid');
    
    
    for i = 1:length(components)
        inten = imgori_sub_adjust(components(i).PixelIdxList);
        index = find(inten<200);
        components(i).MeanIntensity = mean(inten(index));
    end
    
    struct_0 = [];
    index_0 = 1;

    for i = 1:length(components)
        if components(i).MeanIntensity > 10
            struct_0(index_0).PixelIdxList = components(i).PixelIdxList;
            struct_0(index_0).WeightedCentroid = components(i).WeightedCentroid;   
            struct_0(index_0).MeanIntensity = components(i).MeanIntensity;
            struct_0(index_0).BoundingBox = components(i).BoundingBox;
            index_0 = index_0+1;
        end
    end


    %struct_all = feature_extraction(struct_0, imgori_sub_adjust, components);
    dataset = struct_0;

    centroids = [];

    for i  = 1:length(components)
        if components(i).MeanIntensity > 10
            centroids(end+1,:) = components(i). WeightedCentroid;
        end
    end
    
    saliency_set = [];
    for i = 1:length(dataset)
        distances = pdist2(centroids, dataset(i).WeightedCentroid, 'euclidean');
        [~, I] = sort(distances);
        index_near = I(2:5);

        near = cell2mat(arrayfun(@(x) (components(index_near(x)).MeanIntensity-dataset(i).MeanIntensity)^2,1:4,'un',0));
        
        value = sum(exp(abs(near)*0.1));
        saliency_set(end+1) = mean(near);
    end
    
    [~, I] = sort(saliency_set, 'descend');
    
    output = imgori_sub;
    
    
    for i = 1:20
        output(dataset(I(i)).PixelIdxList) = 0;
    end
    
    %{
    for i = 1:length(dataset)
        if dataset(i).MeanIntensity>30
            output(dataset(I(i)).PixelIdxList) = 0;
        end
    end
    %}
    
    figure;imshow(imgori_sub);
    figure;imshow(output);
    
end


function distance = distance_skull(center, edge, imgori_sub)
    points = find(edge==1);
    
    edge_points = [];
    for i = 1:length(points)
        index = points(i);
        [coor_y, coor_x] = ind2sub(size(imgori_sub),index);
        %{
        coor_y = mod(index, size_h);
        if coor_y == 0
            coor_x = floor(index/size_h);
        else
            coor_x = floor(index/size_h)+1;
        end 
        %}
        edge_points(i,:) = [coor_x, coor_y];
    end
    distance = min(pdist2(edge_points,center,'euclidean'));
end
