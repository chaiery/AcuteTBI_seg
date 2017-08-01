%%Superpixel_based Learning

%%First, Read Patients' Slices

Patients = [38, 43, 76, 80, 100,109,113,94,284,122,183,125,332,380];

Patient_3 = [88,380];

PatientsData_1 = [];
for p = 1:length(Patients)
    [PatientsData(p).PosImgs PatientsData(p).NegImgs] = BrainImage_pid(Patients(p));
    PatientsData(p).Pid = Patients(p);
end

%%
PatientsData_1 = [];
pid = 380;
for p = 1
    [PatientsData_1(p).PosImgs PatientsData_1(p).NegImgs] = BrainImage_pid(pid);
    PatientsData_1(p).Pid = pid;
end


%% Extracted Features for Each Slice
%% Build Positive Dataset and Negative Dataset for each patient
%for p = 1:length(PatientsData)
for p = 1:13
    annotated_slices = PatientsData(p).PosImgs;
    not_annotated = PatientsData(p).NegImgs;
    if length(annotated_slices)>0
        [positive_dataset, negative_dataset, ~] = build_dataset(annotated_slices);
    end
    PatientsData(p).PosData = positive_dataset;
    PatientsData(p).NegData = negative_dataset;
end

for p = 14
    annotated_slices = PatientsData(p).PosImgs;
    not_annotated = PatientsData(p).NegImgs;
    if length(annotated_slices)>0
        [positive_dataset, negative_dataset, ~] = build_dataset(annotated_slices);
    end
    PatientsData(p).PosData = positive_dataset;
    PatientsData(p).NegData = negative_dataset;
end



%% Feature Selection
[train_1_features, train_0_features] = build_train_and_test(PatientsData(1:8));

valitrain_features = [train_1_features(1:3000,:); train_0_features(randsample(30000,30000),:)];
valitrain_label = [repelem(1,3000) repelem(0,30000)];

% valitest_features = [train_1_features(2000:3000,:); train_0_features(randsample(30000,1000)+40000,:)];
% valitest_label = [repelem(1,1000) repelem(0,1000)];

valitrain_mean = mean(valitrain_features);
valitrain_std = std(valitrain_features,0,1);
valitrain_features_norm = feature_normalization(valitrain_features);
% valitest_features_norm = feature_normalization(valitest_features, valitrain_mean, valitrain_std);


feature_rank_1 = mRMR_D(78, valitrain_features_norm, valitrain_label');

figure;plot(1:78,79-feature_rank_1)

%% Build the initial model
%% Will adjusted to 10-fold cross validation
train_index = [1,7,9,11,12,14,15,13];
test_index = [2,3, 4,6,8,10,5];

[train_1_features, train_0_features] = build_train_and_test(PatientsData(train_index));

train_features = [train_1_features; train_0_features];
train_mean = mean(train_features);
train_std = std(train_features,0,1);

%% Build the initial dataset for the first SVM model and pool dataset for active learning
train_1_pool = train_1_features;
train_0_pool = train_0_features;

index = randsample(length(train_1_features),3000);
train_1_initial = train_1_features(index,:);
train_1_pool(index,:) = [];

index = randsample(length(train_0_features),3000);
train_0_initial = train_0_features(index,:);
train_0_pool(index,:) = [];

train_initial = [train_1_initial; train_0_initial];
train_initial_class = [repelem(1,length(train_1_initial)), repelem(0,length(train_0_initial))]';
train_initial_norm = feature_normalization(train_initial , train_mean, train_std);

train_1_pool_norm = feature_normalization(train_1_pool , train_mean, train_std);
train_0_pool_norm = feature_normalization(train_0_pool , train_mean, train_std);

%% Build test dataset
[test_1_features, test_0_features] = build_train_and_test(PatientsData(test_index));

index_1 = randsample(length(test_1_features),length(test_1_features));
index_0 = randsample(length(test_0_features),length(test_0_features));
test_features = [test_1_features(index_1,:);test_0_features(index_0,:)];

test_class =  [repelem(1,length(index_1)), repelem(0,length(index_0))]';
test_features_norm = feature_normalization(test_features, train_mean, train_std);

%% Build the first SVM
feature_index = feature_rank(1:50,:);
model_SVM = fitcsvm(train_initial_norm(:,feature_index), train_initial_class, 'KernelFunction', 'linear','Cost', [0 1;1 0]);
score_model = fitSVMPosterior(model_SVM);


%% AUC Evaluation
[label, score] = predict(score_model,test_features_norm(:,feature_index));
%ss = max(score')';
[X,Y,T,AUC] = perfcurve(test_class,score(:,2),1);
figure; plot(X, Y)

%% Sp and Sn and Accuracy
test_pred_y = predict(model_SVM,test_features_norm(:,feature_index));

TP = sum(test_class==test_pred_y & test_class==1);
TN = sum(test_class==test_pred_y & test_class==0);

test_se =  TP/sum(test_class==1);
test_sp = TN/sum(test_class==0);
test_acc = (TP+TN)/length(test_class);

%% Use Active Learning Strategy without clusters

pool_1_adaptive = train_1_pool_norm(:,feature_index) ;
pool_0_adaptive = train_0_pool_norm(:,feature_index);
train_features_adaptive = train_initial_norm(:,feature_index);
train_class_adaptive = train_initial_class;
score_update = score_model;

AUCs = [];
values_1 = [];
values_0 = [];

model_update = fitcsvm(train_features_adaptive,train_class_adaptive,'KernelFunction','linear', 'Cost',[0 1;1 0]);
score_update = fitSVMPosterior(model_update);
[~, score] = predict(score_update, test_features_norm(:,feature_index));
[~,~,~,AUC] = perfcurve(test_class,score(:,2),1);
AUCs(end+1) = AUC;

for loop = 1:10
    number = 100;
    [samples_in, pool_1_adaptive, value_1] = active_learning_strategy(pool_1_adaptive, model_update, number);
    train_features_adaptive = [train_features_adaptive; samples_in];
    train_class_adaptive = [train_class_adaptive; repelem(1,number)'];
    values_1(end+1) = value_1;
    values_1
    
    [samples_in, pool_0_adaptive,value_2] = active_learning_strategy(pool_0_adaptive, model_update, number);
    train_features_adaptive = [train_features_adaptive; samples_in];
    train_class_adaptive = [train_class_adaptive; repelem(0,number)'];
    values_0(end+1) = value_2;
    values_0
    
    model_update = fitcsvm(train_features_adaptive, train_class_adaptive, 'KernelFunction', 'linear','Cost', [0 1;1 0]);
    score_update = fitSVMPosterior(model_update);

    [~, score] = predict(score_update,test_features_norm(:,feature_index));
    [~,~,~,AUC] = perfcurve(test_class,score(:,2),1);
    AUCs(end+1) = AUC;
    AUCs
end


%% Use Active Learning Strategy with clusters
pool_1_adaptive = train_1_pool_norm(:,feature_index) ;
pool_0_adaptive = train_0_pool_norm(:,feature_index);
train_features_adaptive = train_initial_norm(:,feature_index);
train_class_adaptive = train_initial_class;
%score_update = score_model;

AUCs = [];
model_update = fitcsvm(train_features_adaptive,train_class_adaptive,'KernelFunction','linear', 'Cost',[0 1;1 0]);
score_update = fitSVMPosterior(model_update);
[~, score] = predict(score_update, test_features_norm(:,feature_index));
[~,~,~,AUC] = perfcurve(test_class,score(:,2),1);
AUCs(end+1) = AUC;

for loop = 1:30
    num_cluster = 10;
    %[samples_in, pool_1_adaptive] = al_sampling(pool_1_adaptive, score_update,num_cluster);
    %train_features_adaptive = [train_features_adaptive; samples_in];
    %train_class_adaptive = [train_class_adaptive; repelem(1,num_cluster*10)'];
    number = 100;
    index = randsample(length(pool_1_adaptive), length(pool_1_adaptive));
    samples_in = pool_1_adaptive(index(1:number),:);
    pool_1_adaptive = pool_1_adaptive(index(number+1:end),:);
    train_features_adaptive = [train_features_adaptive; samples_in];
    train_class_adaptive = [train_class_adaptive; repelem(1,number)'];
    
    
    [samples_in, pool_0_adaptive] = al_sampling(pool_0_adaptive, score_update,num_cluster);
    train_features_adaptive = [train_features_adaptive; samples_in];
    train_class_adaptive = [train_class_adaptive; repelem(0,num_cluster*10)'];
    
    model_update = fitcsvm(train_features_adaptive, train_class_adaptive, 'KernelFunction', 'linear','Cost', [0 1;1 0]);
    score_update = fitSVMPosterior(model_update);

    [~, score] = predict(score_update,test_features_norm(:,feature_index));
    [~,~,~,AUC] = perfcurve(test_class,score(:,2),1);
    AUCs(end+1) = AUC;
    AUC
end

%% Random Selection
pool_1_adaptive = train_1_pool_norm(:,feature_index) ;
pool_0_adaptive = train_0_pool_norm(:,feature_index);
train_features_adaptive = train_initial_norm(:,feature_index);
train_class_adaptive = train_initial_class;
score_update = score_model;

AUCs = [];
[~, score] = predict(score_update, test_features_norm(:,feature_index));
[~,~,~,AUC] = perfcurve(test_class,score(:,2),1);
AUCs(end+1) = AUC;

for loop = 1:20
    number = 3000;
    index = randsample(length(pool_1_adaptive), length(pool_1_adaptive));
    samples_in = pool_1_adaptive(index(1:number),:);
    pool_1_adaptive = pool_1_adaptive(index(number+1:end),:);
    train_features_adaptive = [train_features_adaptive; samples_in];
    train_class_adaptive = [train_class_adaptive; repelem(1,number)'];
    
    index = randsample(length(pool_0_adaptive), length(pool_0_adaptive));
    samples_in = pool_0_adaptive(index(1:number),:);
    pool_0_adaptive = pool_0_adaptive(index(number+1:end),:);
    train_features_adaptive = [train_features_adaptive; samples_in];
    train_class_adaptive = [train_class_adaptive; repelem(0,number)'];
    
    model_update = fitcsvm(train_features_adaptive, train_class_adaptive, 'KernelFunction', 'linear','Cost', [0 1;1 0]);
    score_update = fitSVMPosterior(model_update);

    [~, score] = predict(score_update,test_features_norm(:,feature_index));
    [~,~,~,AUC] = perfcurve(test_class,score(:,2),1);
    AUCs(end+1) = AUC;
    AUCs
end

%% Baseline: The AUC when using all data

index = randsample(length(train_0_features),length(train_1_features));
All = [train_1_features; train_0_features(index,:)];
All_Class = [repelem(1,length(train_1_features)), repelem(0,length(index))];

feature_index = feature_rank(1:50,:);
model_SVM = fitcsvm(All(:,feature_index), All_Class, 'KernelFunction', 'linear','Cost', [0 1;1 0]);
score_model = fitSVMPosterior(model_SVM);

[label, score] = predict(score_model,test_features_norm(:,feature_index));
%ss = max(score')';
[X,Y,T,AUC] = perfcurve(test_class,score(:,2),1);
figure; plot(X, Y)


%% Baseline
train_features = [train_1_features; train_0_features];
AUC_all = [];
for loop = 1:30
    num = 5000;
    index_1 =  randsample(length(train_1_features), num);
    index_0 = randsample(length(train_0_features), num);
    train = [train_1_features(index_1,:);train_0_features(index_0,:)];
    train_norm = feature_normalization(train, train_mean, train_std);
    class = [repelem(1,num), repelem(0,num)]';
    model = fitcsvm(train_norm(:,feature_index), class, 'KernelFunction', 'linear','Cost', [0 1;1 0]);
    score_model = fitSVMPosterior(model);
    [label, score] = predict(score_model,test_features_norm(:,feature_index));
    %ss = max(score')';
    [X,Y,T,AUC] = perfcurve(test_class,score(:,2),1);
    AUC_all(end+1) = AUC;
    AUC_all
end


%% New try
pool_1_adaptive = train_1_pool_norm(:,feature_index) ;
pool_0_adaptive = train_0_pool_norm(:,feature_index);

pool_adaptive = [pool_1_adaptive; pool_0_adaptive];
pool_class_adaptive = [repelem(1,length(pool_1_adaptive)),repelem(0,length(pool_0_adaptive))]';

train_features_adaptive = train_initial_norm(:,feature_index);
train_class_adaptive = train_initial_class;
score_update = score_model;

AUCs = [];

[~, score] = predict(score_update, test_features_norm(:,feature_index));
[~,~,~,AUC] = perfcurve(test_class,score(:,2),1);

AUCs(end+1) = AUC;

for loop = 1:10
    number = 1000;
    [samples_in, sample_class, pool_adaptive, pool_class_adaptive] = active_learning_ratio(pool_adaptive, pool_class_adaptive, score_update, number);
    train_features_adaptive = [train_features_adaptive; samples_in];
    train_class_adaptive = [train_class_adaptive; sample_class];
    ratio = sum(train_class_adaptive==0)/sum(train_class_adaptive==1)
    model_update = fitcsvm(train_features_adaptive, train_class_adaptive, 'KernelFunction', 'linear','Cost', [0 1;ratio 0]);
    score_update = fitSVMPosterior(model_update);

    [~, score] = predict(score_update,test_features_norm(:,feature_index));
    
    [~,~,~,AUC] = perfcurve(test_class,score(:,2),1);
    AUCs(end+1) = AUC;
    AUCs
end

%% Based on distance and change ratio
pool_1_adaptive = train_1_pool_norm(:,feature_index) ;
pool_0_adaptive = train_0_pool_norm(:,feature_index);
train_features_adaptive = train_initial_norm(:,feature_index);
train_class_adaptive = train_initial_class;
score_update = score_model;

AUCs = [];
values_1 = [];
values_0 = [];

model = fitcsvm(train_features_adaptive,train_class_adaptive,'KernelFunction','linear', 'Cost',[0 1;10 0]);
score_update = fitSVMPosterior(model);
[~, score] = predict(score_update, test_features_norm(:,feature_index));
[~,~,~,AUC] = perfcurve(test_class,score(:,2),1);
AUCs(end+1) = AUC;
%%
for loop = 1:10
    threshold = 0.1;
    distance_1 = pool_1_adaptive*model.Beta + model.Bias;
    distance_0 = pool_0_adaptive*model.Beta + model.Bias;
    distance_1 = abs(distance_1);
    distance_0 = abs(distance_0);

    index_0 = find(distance_0<threshold);
    index_1 = find(distance_1<threshold);
    if ~(length(index_0)+length(index_1))
        break
    end
    train_features_adaptive = [train_features_adaptive; pool_1_adaptive(index_1,:)];
    train_class_adaptive = [train_class_adaptive; repelem(1,length(index_1))'];

    train_features_adaptive = [train_features_adaptive; pool_0_adaptive(index_0,:)];
    train_class_adaptive = [train_class_adaptive; repelem(0,length(index_0))'];

    pool_1_adaptive(index_1,:) = [];
    pool_0_adaptive(index_0,:) = [];
    
    model = fitcsvm(train_features_adaptive, train_class_adaptive, 'KernelFunction', 'linear','Cost', [0 1;20 0]);
    score_update = fitSVMPosterior(model_update);

    [~, score] = predict(score_update,test_features_norm(:,feature_index));
    [~,~,~,AUC] = perfcurve(test_class,score(:,2),1);
    AUCs(end+1) = AUC;
    AUCs
end

%%
model = fitcsvm(train_features_adaptive,train_class_adaptive,'KernelFunction','linear', 'Cost',[0 1;1 0]);
score_update= fitSVMPosterior(model);
[~, score] = predict(score_update, test_features_norm(:,feature_index));
[~,~,~,AUC] = perfcurve(test_class,score(:,2),1);
AUC

distance_1 = pool_1_adaptive*model.Beta + model.Bias;
distance_0 = pool_0_adaptive*model.Beta + model.Bias;
distance_1 = abs(distance_1);
distance_0 = abs(distance_0);
%[B_1, A_1] = sort(distance_1, 'ascend');
%[B_0, A_0] = sort(distance_0, 'ascend');

index_0 = find(distance_0<0.5);
index_1 = find(distance_1<0.5);
train_features_adaptive = [train_features_adaptive; pool_1_adaptive(index_1,:)];
train_class_adaptive = [train_class_adaptive; repelem(1,length(index_1))'];

train_features_adaptive = [train_features_adaptive; pool_0_adaptive(index_0,:)];
train_class_adaptive = [train_class_adaptive; repelem(0,length(index_0))'];

%%
model = fitcsvm(train_features_adaptive,train_class_adaptive,'KernelFunction','linear', 'Cost',[0 1;10 0]);
score_update= fitSVMPosterior(model);
[~, score] = predict(score_update, test_features_norm(:,feature_index));
[~,~,~,AUC] = perfcurve(test_class,score(:,2),1);
AUC
