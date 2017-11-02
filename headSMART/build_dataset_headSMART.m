function [PatientsData] = build_dataset_headSMART(PatientsData)
    
    for pid = 1:length(PatientsData)
        pd = PatientsData(pid);
        meta = pd.meta;
        brains = pd.rota_brains;
        brains = brains(:,:,meta.startI:meta.endI);
        intensity_mean = pd.intensity_mean;
        slices_features = struct('features',{});
        dim = size(brains);
        
        if length(dim)==2
            features = feature_extraction(brains,  intensity_mean);
            slices_features(1).features = features;
            slices_features(1).brain = brains;

        elseif length(dim)>2
            num = dim(3);
            for i = 1:num
            #for i =1
                i
                brain_img = brains(:,:,i);
                features = slicesfeature(brain_img, intensity_mean);
                slices_features(i).features = features;
                slices_features(i).brain = brain_img;
            end
        end
        PatientsData(pid).slices_features = slices_features;
    end
end

function [structs] = slicesfeature(brain, intensity_mean)
    num_sp = 10000;
    [labels, ~] = superpixels(brain,num_sp);
    components = regionprops(labels, brain, 'PixelIdxList','MeanIntensity', 'BoundingBox','PixelValues', 'WeightedCentroid');
    idx = [];
    for i = 1:length(components)
        components(i).label=0;
        if (components(i).MeanIntensity > 10)
            idx(end+1) = i;
        end
    end
    components = components(idx);
    structs = feature_extraction(components, brain, intensity_mean);
end
