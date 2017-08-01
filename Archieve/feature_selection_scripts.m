valitrain_features = [train_1_features; train_0_features];
valitrain_label = [repelem(1,length(train_1_features)) repelem(0,length(train_0_features))];
valitrain_features_norm = feature_normalization(valitrain_features);

feature_rank_1 = mRMR_D(78, valitrain_features_norm, valitrain_label');
figure;plot(1:78,79-feature_rank_1)

%%
valitrain_features = [train_1_features(randsample(length(train_1_features),3000),:); train_0_features(randsample(length(train_0_features),3000),:)];
valitrain_label = [repelem(1,3000) repelem(0,3000)];
valitrain_features_norm = feature_normalization(valitrain_features);

feature_rank_4 = mRMR_D(78, valitrain_features_norm, valitrain_label');
figure;plot(1:78,79-feature_rank_4)