function [mask, imgs] = extract_region_of_interest(brains, pos_idx, pid, dataset, sel)

    imgs = NormalizedImage_pid(pid, pos_idx, dataset);
    imgs = imgs(:,:,sel);
    
    mask = zeros(size(brains));
    for target = 1:size(brains,3)
        brain = brains(:,:,target);
        img = imgs(:,:,target);
        
        img_new = img;
        img_new(brain==brain(1)) = 0;
        figure;imshow(img_new)
        
        isdetected = 0;
        count = 0;
        while (~isdetected)&&count<10
            [img_out,gmm_out,isdetected] = detectHematoma(img_new,1,4);
            count = count+1;
        end

        if length(unique(gmm_out))==4
            comp_intensity = [mean(brain(gmm_out == 1)), mean(brain(gmm_out == 2)), mean(brain(gmm_out == 3)), mean(brain(gmm_out == 4))];
            [~, label] = sort(comp_intensity);

            %index = union(find(gmm_out == label(3)), find(img_out==255));
            index = union(find(gmm_out == label(3)), find(gmm_out==label(4)));
        else
            index = find(img_new>0);
        end
    
        test = zeros(size(gmm_out));
        test(gmm_out == label(4)) = 1;
        figure;imshow(test)
        mask(:,:,target) = test;
        figure;imshow(double(test));
    end

end