% Let us find the best subset
feature_rank = mRMR_D(84, vali_features_norm, vali_class);

%% Find the best one from a range
AUCs = [];
for i = 30:60
    feature_index = feature_rank(1:i);
    train_features_norm_sub = train_features_norm(:,feature_index);
    model_SVM = fitcsvm(train_features_norm_sub, train_class, 'KernelFunction', 'linear','Cost', [0 2;1 0]);
    test_features_norm = feature_normalization(test_features, train_mean, train_std);
    test_features_norm_sub = test_features_norm(:,feature_index);
    score_model = fitSVMPosterior(model_SVM);
    [label, score] = predict(score_model,test_features_norm_sub);
    %ss = max(score')';
    [X,Y,T,AUC] = perfcurve(test_class,score(:,2),1);
    AUCs(end+1) = AUC;
end
    
%% Try for a number
feature_index = feature_rank(1:47);
train_features_norm_sub = train_features_norm(:,feature_index);
model_SVM = fitcsvm(train_features_norm_sub, train_class, 'KernelFunction', 'linear','Cost', [0 2;1 0]);
test_features_norm = feature_normalization(test_features, train_mean, train_std);
test_features_norm_sub = test_features_norm(:,feature_index);
score_model = fitSVMPosterior(model_SVM);
[label, score] = predict(score_model,test_features_norm_sub);
%ss = max(score')';
[X,Y,T,AUC] = perfcurve(test_class,score(:,2),1);
plot(X, Y)
