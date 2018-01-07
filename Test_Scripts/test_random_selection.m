%% Generate different training dataset
rep = 4;
AUCs = zeros(1,rep);
nums = [4000, 4000, 4000, 4000];
feature_index = 1:129;
parfor i = 1:4
    tic
    num = nums(i);
    train_1 = train_1_features(randsample(length(train_1_features), num), feature_index);
    
    %train_0_features = cat(1, train_0_features_edge, train_0_features_remain);
    train_0 = train_0_features(randsample(length(train_0_features), num), feature_index);
    train_features = cat(1, train_1, train_0);
        
    %train_0_edge = train_0_features_edge(randsample(length(train_0_features_edge), num/2), feature_index);
    %train_0_remain = train_0_features_remain(randsample(length(train_0_features_remain), num/2), feature_index);
    %train_features = [train_1; train_0_edge; train_0_remain];

    train_mean = mean(train_features);
    train_std = std(train_features,0,1);

    train_class = cat(2, repelem(1, num)', repelem(0, num)');
    train_norm = feature_normalization(train_features, train_mean, train_std);
    %test_norm = feature_normalization(test_features, train_mean, train_std);
    %% Evaluate
    model_SVM = fitcsvm(train_norm, train_class, 'KernelFunction', 'linear','Cost', [0 1;1 0]);
    [pred, score] = predict(model_SVM, test_norm);
    [AUC, collection] = ROC_curve(score, test_class,  0.001, false);
    AUCs(i) = AUC;
    toc
end

