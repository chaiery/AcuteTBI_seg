function segmentation=MRF_Seg(image, al_pred, al_prob_1)
    maxItr = 10;
    segmentation = al_pred;
    
    [x,y,~] = size(image);
    img_energy_0 = zeros(x,y);
    img_energy_1 = ones(x,y);
    
    
    iter = 0;
    while(iter<maxItr)
        for i = 2:(x-1)
            for j = 2:(y-1)
                label_sub = segmentation(i-1:i+1,j-1:j+1);
                prob = al_prob_1(i,j);
                intensity_sub = image(i-1:i+1,j-1:j+1);
                [energy_0, energy_1] = MRF_energy(label_sub,prob,intensity_sub);
                img_energy_0(i,j) = energy_0;
                img_energy_1(i,j) = energy_1;
            end
        end
        energy_0s = imstack2vectors(img_energy_0);
        energy_1s = imstack2vectors(img_energy_1);
        energy = [energy_0s, energy_1s];
        
        [~,segmentation]=min(energy,[],2);
        segmentation = segmentation-1;
        segmentation = double(reshape(segmentation, size(image)));
        figure;imshow(segmentation)
        iter=iter+1;
    end
    %figure;imshow(segmentation)
end
