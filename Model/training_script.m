
%%
feature_index = feature_rank_1(1:100);
%feature_index = [1:100];
%%
pid_index = randsample(24,24); 
%%
train_index =pid_index(1:12);
test_index = pid_index(13:24);

%%
[train_1_features, train_0_features_edge, train_0_features_remain] = build_train_and_test(ModelFeatures(train_index));


%%
train_1 = train_1_features(randsample(length(train_1_features), 8000), feature_index);
train_0_edge = train_0_features_edge(randsample(length(train_0_features_edge), 4000), feature_index);
train_0_remain = train_0_features_remain(randsample(length(train_0_features_remain), 4000), feature_index);
train_features = [train_1; train_0_edge; train_0_remain];
%train_features = [train_1; train_0_edge];
    
train_mean = mean(train_features);

train_std = std(train_features,0,1);

train_class = [repelem(1,length(train_1)), repelem(0,length([train_0_edge; train_0_remain]))]';
train_norm = feature_normalization(train_features, train_mean, train_std);
%train_norm(:,[2,4]) = [];

%%
model_SVM = fitcsvm(train_norm, train_class, 'KernelFunction', 'linear','Cost', [0 2;1 0]);

%%
[test_1_features, test_0_features_edge, test_0_features_remain] = build_train_and_test(ModelFeatures(test_index));
%%
test_1 = test_1_features(:,feature_index);
test_0_features = [test_0_features_edge; test_0_features_remain];
test_0 = test_0_features(:,feature_index);
test_features = [test_1; test_0];
test_class = [repelem(1,length(test_1)), repelem(0,length(test_0))]';

test_norm = feature_normalization(test_features, train_mean, train_std);
%test_norm(:,[2,4]) = [];

%%
test_pred_y = trainedModel3.predictFcn(test_norm);
%% Calculate test sensitivity, specificity, accuracy
test_pred_y = predict(model_SVM,test_norm);

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
[result, dice_list] = evaluate_test(ModelFeatures,  pid_index , feature_index, train_mean, train_std, model_SVM);


%%
[result, dice_list] = evaluate_test(ModelFeatures,  1:47, feature_index, means, stds, model_SVM);



%%
stats = [];
for i = 1:length(PatientsData)
    brains = cat(3, PatientsData(i).brain_pos, PatientsData(i).brain_neg);
    [counts, nbin] = imhist(brains);
    counts(1:5) = 0;
    [~,b] = max(counts);
    stats(i).Pid = PatientsData(i).Pid;
    stats(i).imhist = b;
    stats(i).dice = dice_list(i);
end

%%
for i = 1:length(PatientsData)
    brains = cat(3, PatientsData(i).brain_pos, PatientsData(i).brain_neg);
    plist = brains(:);
    index = find(plist==0);
    plist(index) = [];
    stats(i).mean = mean(plist);
    stats(i).median = median(plist);
    stats(i).mode = mode(plist);
end

%%
for i = 1:length(PatientsData)
    brains = cat(3, PatientsData(i).brain_pos, PatientsData(i).brain_neg);
    plist = brains(:);

    plist(plist==0) = [];
    thre = prctile(plist,80);
    plist(plist>thre) = [];
    stats(i).mean_try = mean(plist);
end

%%
for i = 1:length(ModelFeatures)
    patient = ModelFeatures(i).annotated_slices;
    pixels = [];
    for j = 1:length(patient)
        annot = patient(j).img_annot;
        brain = patient(j).brain;
        if ~isempty(brain)
            index_list = find_annotated_pixelList(annot, brain);
            pixels = [pixels; brain(index_list)];
        end
    end
    stats(i).hematoma = mean(pixels);
end
%%
 figure;scatter([stats.mean_try], [stats.hematoma])