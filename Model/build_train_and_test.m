function [train_1_features, train_0_features] = build_train_and_test(dataset)
    PositiveDataset = [];
    NegativeDataset = [];
    
    struct_1s = [];
    struct_0s = [];
    for tid = 1:length(dataset)
        pid = dataset(tid).Pid;
       
        annotated_slices =dataset(tid).annotated_slices;
        dice  = [];
        for slice_index = 1:length(annotated_slices)
            PositiveDataset = [PositiveDataset; annotated_slices(slice_index).struct_1];
            NegativeDataset = [NegativeDataset; annotated_slices(slice_index).struct_0];
        end
    end
    
    num_features = length(NegativeDataset(1).features);
    
    train_1_features = zeros(length(PositiveDataset),num_features);
    train_0_features = zeros(length(NegativeDataset),num_features);

    for i = 1:length(PositiveDataset)
       train_1_features(i,:) = PositiveDataset(i).features;
    end
    
    for i = 1:length(NegativeDataset)
       train_0_features(i,:) = NegativeDataset(i).features;
    end
    
   train_1_features(:,[164, 168]) = [];
   train_0_features(:,[164, 168]) = [];
   %train_1_features(:,[91:152, 164, 168]) = [];
   %train_0_features(:,[91:152, 164, 168]) = [];
    
    [a,~]= find(isnan(train_1_features)==1);
    train_1_features(a,:) = [];
    
    [a,~]= find(isnan(train_0_features)==1);
    train_0_features(a,:) = [];
end