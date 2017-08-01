function [train_1_features, train_0_features] = build_train_and_test(dataset)
    PositiveDataset = [];
    NegativeDataset = [];

    for i = 1:length(dataset)
        PositiveDataset = [PositiveDataset;dataset(i).PosData];
        NegativeDataset = [NegativeDataset;dataset(i).NegData];
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

    [a,~]= find(isnan(train_1_features)==1);
    train_1_features(a,:) = [];
    
    [a,~]= find(isnan(train_0_features)==1);
    train_0_features(a,:) = [];
end