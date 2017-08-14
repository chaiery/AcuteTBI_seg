%%
PatientsData = ModelFeatures;
PatientsData([1, 2, 7, 8, 9, 10, 11, 16, 26]) = [];
%%
feature_index = feature_rank_1(1:50);
feature_index = [1:100];
%%
pid_index = randsample(44,44);
%%
train_index =pid_index(1:35);
test_index = pid_index(36:44);

%%
[train_1_features, train_0_features_edge, train_0_features_remain] = build_train_and_test(PatientsData(train_index));

%%
train_1 = train_1_features(randsample(length(train_1_features), 1000), feature_index);
train_0_edge = train_0_features(randsample(length(train_0_features), 20000), feature_index);
train_0_remain = train_0_features(randsample(length(train_0_features), 20000), feature_index);
train_features = [train_1; train_0_edge, train_0_remain];

train_mean = mean(train_features);
train_std = std(train_features,0,1);

train_class = [repelem(1,length(train_1)), repelem(0,length(train_0))]';
train_norm = feature_normalization(train_features, train_mean, train_std);
%train_norm(:,[2,4]) = [];

%%
model_SVM = fitcsvm(train_norm, train_class, 'KernelFunction', 'linear','Cost', [0 1;10 0]);

%%
[test_1_features, test_0_features_edge, test_0_features_remain] = build_train_and_test(PatientsData(test_index));
test_1 = test_1_features(:,feature_index);
test_0_features = [test_0_features_edge; test_0_features_remain];
test_0 = test_0_features(:,feature_index);
test_features = [test_1; test_0];
test_class = [repelem(1,length(test_1)), repelem(0,length(test_0))]';

test_norm = feature_normalization(test_features, train_mean, train_std);
%test_norm(:,[2,4]) = [];
%% Calculate test sensitivity, specificity, accuracy
test_pred_y = predict(model,test_norm);

TP = sum(test_class==test_pred_y & test_class==1);
TN = sum(test_class==test_pred_y & test_class==0);

test_se =  TP/sum(test_class==1);
test_sp = TN/sum(test_class==0);
test_acc = (TP+TN)/length(test_class);
 
%% Calculate AUC and plot ROC
score_model = fitSVMPosterior(model_SVM);
[label, score] = predict(score_model,train_norm);
%ss = max(score')';
[X,Y,T,AUC] = perfcurve(train_class,score(:,2),1);
figure; plot(X, Y)

%% Evaluate Dice for individual patient
result = evaluate_test(PatientsData,  test_index, feature_index, train_mean, train_std, model_SVM);

