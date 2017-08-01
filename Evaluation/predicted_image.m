% Build Predicted Slices
function [img] = predicted_image(slice, prediction)
    img = slice.brain;
    points = [slice.struct_1, slice.struct_0];
    points_1 = points(prediction==1);
    for i = 1:length(points_1)
        pixelList = points_1(i).PixelIdxList;
        img(pixelList) = 255;
    end
    
    points_0 = points(prediction==0);
    for i = 1:length(points_0)
        pixelList = points_0(i).PixelIdxList;
        img(pixelList) = 100;
    end
end