%% Feature Selection
[train_1_features, train_0_features] = build_train_and_test(PatientsData(vali_index));

valitrain_features = [train_1_features(1:800,:); train_0_features(randsample(45000,20000),:)];
valitrain_label = [repelem(1,800) repelem(0,20000)];

valitrain_mean = mean(valitrain_features);
valitrain_std = std(valitrain_features,0,1);
valitrain_features_norm = feature_normalization(valitrain_features);
% valitest_features_norm = feature_normalization(valitest_features, valitrain_mean, valitrain_std);


feature_rank_1 = mRMR_D(78, valitrain_features_norm, valitrain_label');

figure;plot(1:78,79-feature_rank_1)