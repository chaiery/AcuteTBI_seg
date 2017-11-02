% Show the region with label 1
img_test = imgori_sub;

for i = 1:length(struct_1_features)
    pixels = struct_1_features(i).PixelIdxList;
    img_test(pixels) = 255;
    
end

figure;imshow(uint8(img_test))