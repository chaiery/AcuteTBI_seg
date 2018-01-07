%%%%% Under development
%% Build the initial dataset for the first SVM model and pool dataset for active learning
% PatientData
% Train_index
% Test_index

%% Split the dataset into train set and test set
% pid_index_pos = randsample(62,62); 
% pid_index_neg = randsample(30,30)+62; 
% 
% train_index =[pid_index_pos(1:50); pid_index_neg(1:25)];
% test_index = setdiff(1:92, train_index);
% save('train_index', 'train_index')
% save('test_index', 'test_index')
%%
train_index = load('./SavedData/train_index.mat');
test_index = load('./SavedData/test_index.mat');

PD_train = PatientData(train_index);
PD_test = PatientData(test_index);

[train_1_features, train_0_features_edge, train_0_features_remain] = build_train_and_test(ModelFeatures(train_index));
[test_1_features, test_0_features_edge, test_0_features_remain] = build_train_and_test(ModelFeatures(test_index));
% rng('default')
% index = randperm(length(train_index));

%% The whole training dataset
train_1_features = train_1_features(:,feature_index);
train_0_features_edge = train_0_features_edge(:,feature_index);
train_0_features_remain = train_0_features_remain(:,feature_index);

train_features = [train_1_features; train_0_features_edge; train_0_features_remain];
train_mean = mean(train_features);
train_std = std(train_features,0,1);

%The whole test set
test_1 = test_1_features(:,feature_index);
test_0_features = [test_0_features_edge; test_0_features_remain];
test_0 = test_0_features(:,feature_index);
test_features = [test_1; test_0];
test_class = [repelem(1,length(test_1)), repelem(0,length(test_0))]';

test_norm = feature_normalization(test_features, train_mean, train_std);

%% Split the whole training set into initila and active learning pool
train_1_pool = train_1_features;
train_0_pool_edge = train_0_features_edge;
train_0_pool_remain = train_0_features_remain;

initial_size = 2000;
rng('default')
index = randsample(length(train_1_features),initial_size);
train_1_initial = train_1_features(index,:);
train_1_pool(index,:) = [];

rng('default')
index = randsample(length(train_0_features_edge),initial_size/2);
train_0_initial_edge = train_0_features_edge(index,:);
train_0_poo_edgel(index,:) = [];

rng('default')
index = randsample(length(train_0_features_remain),initial_size/2);
train_0_initial_remain = train_0_features_remain(index,:);
train_0_pool_remain(index,:) = [];

train_initial = [train_1_initial; train_0_initial_edge; train_0_initial_remain];
train_initial_class = [repelem(1,initial_size), repelem(0,initial_size)]';
train_initial_norm = feature_normalization(train_initial , train_mean, train_std);

train_1_pool_norm = feature_normalization(train_1_pool , train_mean, train_std);
train_0_pool_norm = feature_normalization(train_0_pool , train_mean, train_std);

%%
model_SVM = fitcsvm(train_initial_norm, train_initial_class, 'KernelFunction', 'linear','Cost', [0 1;10 0]);
%%
score_model = fitSVMPosterior(model_SVM);
[label, score] = predict(score_model,test_features_norm(:,feature_index));
[X,Y,T,AUC] = perfcurve(test_class,score(:,2),1);
figure; plot(X, Y)


%% Based on distance and change ratio
pool_1_adaptive = train_1_pool_norm;
pool_0_adaptive = train_0_pool_norm;
train_features_adaptive = train_initial_norm;
train_class_adaptive = train_initial_class;
%score_update = score_model;

AUCs = [];
values_1 = [];
values_0 = [];

ratio = sum(train_class_adaptive==0)/sum(train_class_adaptive==1);
%model = model_SVM; 

%model = fitcsvm(train_features_adaptive,train_class_adaptive,'KernelFunction','linear', 'Cost',[0 1;10 0]);

%%
result_1 = evaluate_test(PatientsData,  test_index, feature_index, train_mean, train_std, model_SVM);
% score_update = fitSVMPosterior(model);
% [~, score] = predict(score_update, test_features_norm(:,feature_index));
% [~,~,~,AUC] = perfcurve(test_class,score(:,2),1);
% AUCs(end+1) = AUC;
%%
for loop = 1:1
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
    
    ratio = sum(train_class_adaptive==0)/sum(train_class_adaptive==1);
    %%
    model = fitcsvm(train_features_adaptive, train_class_adaptive, 'KernelFunction', 'linear','Cost', [0 1;7.5 0]);
    %%
    result_3 = evaluate_test(PatientsData,  test_index, feature_index, train_mean, train_std, model);
    
%     score_update = fitSVMPosterior(model_update);
%     [~, score] = predict(score_update,test_features_norm(:,feature_index));
%     [~,~,~,AUC] = perfcurve(test_class,score(:,2),1);
%     AUCs(end+1) = AUC;
%     AUCs
end



