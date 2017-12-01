function [train_1_features, train_0_features_edge, train_0_features_remain] = build_train_and_test(dataset)
    PositiveDataset = [];
    NegativeDataset_edge = [];
    NegativeDataset_remain = [];
    
    for tid = 1:length(dataset)
        pid = dataset(tid).Pid;
        pid
        annotated_slices =dataset(tid).annotated_slices;
        annotated_features = dataset(tid).annotated_features;
        dice  = [];
        for slice_index = 1:length(annotated_slices)
            PositiveDataset = [PositiveDataset, annotated_features(slice_index).struct_1_features];
            
            negative_samples = annotated_features(slice_index).struct_0_features;
            [neg_edge, neg_remain] = find_points_close_to_edge(annotated_slices(slice_index).brain, negative_samples);
            
            NegativeDataset_edge = [NegativeDataset_edge, neg_edge];
            NegativeDataset_remain = [NegativeDataset_remain, neg_remain];
        end
    end
    
    num_features = length(NegativeDataset_edge(1).features);
    sel = [];
    %sel = [164, 168];
    
    train_1_features = build_feature_matrix(PositiveDataset, num_features, sel);
    train_0_features_edge = build_feature_matrix(NegativeDataset_edge, num_features, sel);
    train_0_features_remain = build_feature_matrix(NegativeDataset_remain, num_features, sel);
    
end


function [neg_edge, neg_remain] = find_points_close_to_edge(brain, components)
    brain_label = logical(brain);
    brain_label = imfill(brain_label,'holes');
    roi_temp = xor(brain, imerode(logical(brain_label ), strel('disk', 15))); 
    pixellist = find(roi_temp==1);

    %%
    idx_1 = [];
    idx_2 = [];
    for i = 1:length(components)
        pixels = components(i).PixelIdxList;
        if ~isempty(intersect(pixels, pixellist))
            idx_1 = [idx_1, i];
        else
            idx_2 = [idx_2, i];
        end
    end

    %%
    neg_edge  = components(idx_1);
    neg_remain = components(idx_2);

end


function [features] = build_feature_matrix(data, num_features, sel)
    
    features = zeros(length(data),num_features);

    for i = 1:length(data)
       features(i,:) = data(i).features;
    end
    
    features(:,sel) = [];
    
    [a,~]= find(isnan(features)==1);
    features(a,:) = [];
    
    [a,~]= find(isinf(features)==1);
    features(a,:) = [];
end