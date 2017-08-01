for i = 35
    masks = MLData(i).mask;
    annots = MLData(i).annots;
    for target = 1:size(annots,4)
        annot = annots(:,:,:,target);
        mask = masks(:,:,target);
        figure;imshow(annot)
        figure;imshow(mask)
    end
    
end

%% show components
test = brain;
for i = 1:length(components)
    index = components(i).PixelIdxList;
    test(index) = 255;
end

%% Try to find pixel near boundary and higher than 250
brain_2 = brain-base_value;
label_img = bwlabel(brain_2, 4);
ImFilled = imfill(label_img, 'holes');
bw_edge = edge(ImFilled, 'Canny');

edge =find(bw_edge==1);
for i = 1:length(edge)
    center = edge(i);
    [coor_y, coor_x] = ind2sub(size(bw_edge),center);
    window = 
end


%%
for p = 10
    brains = PatientsData(p).brain_pos;
    base_value = brains(1);
    mask = PatientsData(p).mask;
    roi = zeros(size(brains));
    annotations = PatientsData(p).annots;
    
    for target = 1
        % ROI
        brain = brains(:,:,target);
        
        % Mask for skull boundary
        brain_2 = brain-base_value;
        label_img = bwlabel(brain_2, 4);
        ImFilled = imfill(label_img, 'holes');
        bw_edge = edge(ImFilled, 'Canny');
        se = strel('disk', 3);
        mask1 = imdilate(bw_edge, se);
        mask2 = (brain>200);
        mask_edge = (double(mask1).*double(mask2)-1)*-1;
        brain_new = double(brain).*mask_edge;
        
        
        mask_roi = mask(:,:,target);
        se = strel('disk', 2);
        mask_x = imdilate(mask_roi, se);
        figure;imshow(annotations(:,:,:,target))
        figure;imshow(uint8(brain_new.*mask_roi));
        figure;imshow(uint8(brain_new.*mask_x));
    end
end

%%
test = brain;
for i = 1:length(struct_1)
    lis = struct_1(i).PixelIdxList;
    test(lis) = 255;
end
figure;imshow(test)

%%
if coor_y == 0
    coor_x = floor(1000/512);
    coor_y = size_h;
else
    coor_x = floor(1000/512)+1;
end 