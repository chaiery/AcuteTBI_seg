%% Try Threshold
ImgDir = '/Users/apple/Dropbox/TBI/al_pool';
ImgFiles = dir(ImgDir);
ImgFiles = ImgFiles(~strncmpi('.', {ImgFiles.name},1));
ImgDir = '/Users/apple/Dropbox/TBI/Select_for_annotation/';

%for i = 1:length(ImgFiles)
for i = 1:5
    name = ImgFiles(i).name;
    img = imread([ImgDir name]);
    label_img = bwlabel(img, 4);
    rpbox = regionprops(label_img,'BoundingBox');

    y1 = floor(rpbox(1).BoundingBox(1,1));
    x1 = floor(rpbox(1).BoundingBox(1,2));
    w = rpbox(1).BoundingBox(1,3);
    h = rpbox(1).BoundingBox(1,4);

    img_sub = img(x1-5:x1+h+5,y1-5:y1+w+5);
    win_min = 80;
    win_width = 255-win_min;
    img_sub_adjust = uint8(double(img_sub - win_min)*255 / double(win_width));
    
    [labels, ~] = slicmex(img_sub_adjust,1000,8);
    components = regionprops(labels, img_sub_adjust, 'PixelIdxList','MeanIntensity','BoundingBox','PixelValues', 'WeightedCentroid');
    struct = [];
    index_1 = 1;
    
    output = img_sub;
    for j = 1:length(components)
        if components(j).MeanIntensity< 10  
            output(components(j).PixelIdxList) = 0;
        end
    end
    figure;imshow(img_sub);
    figure;imshow(output)
    figure;imshow(img_sub_adjust)
end