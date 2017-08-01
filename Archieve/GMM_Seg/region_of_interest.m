%MLData = PatientsData;

for i = 1:5
    brains = MLData(i).brain_pos;
    annotations = MLData(i).annots;
    pos_idx = MLData(i).pos_idx;
    pid = MLData(i).Pid;
    dataset = MLData(i).Datatype;
    imgs = NormalizedImage_pid(pid, MLData(i).pos_idx, 'Protected');
    
    mask = zeros(size(brains));
    for target = 1:size(brains,3)
        brain = brains(:,:,target);
        img = imgs(:,:,target);

        img_new = img;
        img_new(brain==brain(1)) = 0;
                
        annotation = annotations(:,:,:,target);
  
        [img_out,gmm_out,~] = detectHematoma(img_new,1,4);

        if length(unique(gmm_out))==4
            index_1 = find(gmm_out == 1);
            index_2 = find(gmm_out == 2);
            index_3 = find(gmm_out == 3);
            index_4 = find(gmm_out == 4);
            comp_intensity = [mean(brain(index_1)), mean(brain(index_2)), mean(brain(index_3)), mean(brain(index_4))];
            [~, label] = sort(comp_intensity);

            index = union(find(gmm_out == label(3)), find(img_out==255));
        else
            index = find(brain_adjust>0);
        end

        test = zeros(size(gmm_out));
        test(index) = 1;
        mask(:,:,target) = test;
    end
	MLData(i).mask = mask;
end


%%
for i = 19
    %%
    brains = MLData(i).brain_pos;
    pos_idx = MLData(i).pos_idx;
    pid = MLData(i).Pid;
    dataset = MLData(i).Datatype;
    
    if size(brains, 3)>4
        sel =randsample(size(brains, 3),4);
    else
        sel = [1:size(brains,3)];
    end
    
    MLData(i).sel = [2];

    brains = brains(:,:,sel);
    
    [MLData(i).mask, MLData(i).normImgs] = extract_region_of_interest(brains, pos_idx, pid, dataset, sel);

end

%%
%for i = 1:length(MLData)
for i =19
    masks = MLData(i).mask;
    normImgs = MLData(i).normImgs;
    brains = MLData(i).brain_pos;
    sel = MLData(i).sel;
    annotations = MLData(i).annots;
    annotations = annotations(:,:,:,sel);
    brains = brains(:,:,sel);
    for target = 1:size(masks,3)
    %target =1;
        mask = masks(:,:,target);
        
      %% Mask Processing
        imgclean = bwmorph(mask,'clean');
        imgclean = bwmorph(imgclean,'majority');

        %imgclean = bwmorph(imgclean,'majority');

         [L,~] = bwlabel(imgclean);
        s3 = regionprops(L,'centroid','Area','PixelIdxList','PixelList','FilledArea','FilledImage','ConvexImage','Image','Extent','Extrema','Eccentricity', 'BoundingBox');

        %figure;imshow(imgclean)

        finalimg = zeros(size(imgclean));
        for i = 1 : numel(s3)
             if s3(i).Area>100
                finalimg(s3(i).PixelIdxList) = 1;
             end
        end

        rp = imfill(double(finalimg),'holes');
        %figure;imshow(rp)

        mask = bwmorph(rp,'majority');
        %figure;imshow(imgclean)
       %% 
        
        img = brains(:,:,target);
        figure;imshow(img)
        annot = annotations(:,:,:,target);
        img(mask==0) = 0;
        figure;imshow(img);
        figure;imshow(annot);
    end
end



%%
for i = 7
    brains = PatientsData(1).brain_pos;
    annotations = PatientsData(1).annots;
    for target = 1:size(brains,3)
        brain = brains(:,:,target);
        annotation = annotations(:,:,:,target);
        figure;imshow(brain)
        figure;imshow(annotation)
    end
end
