function [struct_1, struct_0] = superpixels_slic(img_sub)
    [labels, numlabels] = slicmex(img_sub,1000,10);
    components = regionprops(labels, img_sub, 'PixelIdxList','MeanIntensity','BoundingBox','PixelValues', 'WeightedCentroid');
    
    struct_1 = [];
    struct_0 = [];
    index_1 = 1;
    index_0 = 1;
    
    
    % hema = zeros(size(img_sub));
    for i = 1:length(components)
        if components(i).MeanIntensity>180  % This threshold should be tuned
            % hema(components(i).PixelIdxList) = 255;
            struct_1(index_1).PixelIdxList = components(i).PixelIdxList;
            struct_1(index_1).WeightedCentroid = components(i).WeightedCentroid;
            struct_1(index_1).label = 1;
            struct_1(index_1).BoundingBox = components(i).BoundingBox;
            index_1 = index_1+1;
        elseif components(i).MeanIntensity>0 && components(i).MeanIntensity<120  % This threshold should be tuned
            % hema(components(i).PixelIdxList) = 255;
            struct_0(index_0).PixelIdxList = components(i).PixelIdxList;
            struct_0(index_0).WeightedCentroid = components(i).WeightedCentroid;   
            struct_0(index_0).label = 0;
            struct_0(index_0).BoundingBox = components(i).BoundingBox;
            index_0 = index_0+1;
        end
    end
    % figure;imshow(hema)
end

 
