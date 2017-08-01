% Active Learning based on unlabeled images

%% First, we need an intitial model
%% Read Images
ImgDir = '/home/hemingy/Developer/AcuteTBI/Images/al_train';
%ImgDir = 'C:\Users\hemingy\Dropbox\TBI\al_train';
ImgFiles = dir(ImgDir);
ImgFiles = ImgFiles(~strncmpi('.', {ImgFiles.name},1));
%ImgFiles = ImgFiles(1:4);
ImgDir = '/home/hemingy/Developer/AcuteTBI/Images/Select_for_annotation';
%ImgDir = 'C:\Users\hemingy\Dropbox\TBI\Select_for_annotation';
[train_1, train_0] = build_dataset(ImgFiles, ImgDir);

%train_0 = train_0(randsample(length(train_0), length(train_1)));
train_1_all = train_1;
train_0_all = train_0;

%% Randomly pick up 1:1
index = randsample(length(train_0_all), length(train_0_all));
train_0 = train_0_all(index(1:60));
rest_0 = train_0_all(index(61:end));

index = randsample(length(train_1_all), length(train_1_all));
train_1 = train_1_all(index(1:60));
rest_1 = train_1_all(index(61:end));

%%
train = [train_1, train_0];
train_class = repelem(0,length(train))';

train_features  = [];
for i = 1:length(train)
   train_features(i,:) = train(i).features;
   train_class(i) = train(i).label; 
end

train_mean = mean(train_features);
train_std = std(train_features,0,1);
train_features_norm = feature_normalization(train_features);

%% Test for test dataset
ImgDir = '/home/hemingy/Developer/AcuteTBI/Images/al_test';
ImgFiles = dir(ImgDir);
ImgFiles = ImgFiles(~strncmpi('.', {ImgFiles.name},1));
ImgDir = '/home/hemingy/Developer/AcuteTBI/Images/Select_for_annotation';
[test_1, test_0] = build_dataset(ImgFiles, ImgDir);
test = [test_1, test_0];

test_features = [];
test_class = repelem(0,length(test))';
for i = 1:length(test)
   test_features(i,:) = test(i).features;
   test_class(i) = test(i).label;
end

test_features_norm = feature_normalization(test_features, train_mean, train_std);

%% Construct the initial model
%feature_index = feature_rank(1:50,:);
train_features_norm_sub = train_features_norm(:,feature_index);
model_SVM = fitcsvm(train_features_norm_sub, train_class, 'KernelFunction', 'linear','Cost', [0 1;1 0]);

%% Test the initial model
test_features_norm_sub = test_features_norm(:,feature_index);
score_model = fitSVMPosterior(model_SVM);
[label, score] = predict(score_model,test_features_norm_sub);
%ss = max(score')';
[X,Y,T,AUC] = perfcurve(test_class,score(:,2),1);
figure; plot(X, Y)


%% Initiation
ImgDir = '/home/hemingy/Developer/AcuteTBI/Images/al_pool/';
ImgFiles = dir(ImgDir);
ImgFiles = ImgFiles(~strncmpi('.', {ImgFiles.name},1));
ImgDir = '/home/hemingy/Developer/AcuteTBI/Images/Select_for_annotation';
[pool_1_all, pool_0_all] = build_dataset(ImgFiles, ImgDir);
%%
pool_1 = [pool_1_all, rest_1];
pool_0 = [pool_0_all, rest_0];

pool_1_features = [];
pool_0_features = [];

for i = 1:length(pool_1)
    features = pool_1(i).features;
    if sum(isnan(features))==0
        pool_1_features(end+1,:) = features;
    end
end

for i = 1:length(pool_0)
    features = pool_0(i).features;
    if sum(isnan(features))==0
        pool_0_features(end+1,:) = features;
    end
end

pool_1_features_norm = feature_normalization(pool_1_features, train_mean, train_std);
pool_1_features_norm_sub = pool_1_features_norm(:,feature_index);
pool_0_features_norm = feature_normalization(pool_0_features, train_mean, train_std);
pool_0_features_norm_sub = pool_0_features_norm(:,feature_index);

%% Using Active leanring with Clusters
pool_1_adaptive = pool_1_features_norm_sub;
pool_0_adaptive = pool_0_features_norm_sub;
train_features_adaptive = train_features_norm_sub;
train_class_adaptive = train_class;
score_update = score_model;

AUCs = [];
[~, score] = predict(score_model, test_features_norm_sub);
[~,~,~,AUC] = perfcurve(test_class,score(:,2),1);
AUCs(end+1) = AUC;


for loop = 1:40
    num_cluster = 10;
    [samples_in, pool_1_adaptive] = al_sampling(pool_1_adaptive, score_update,num_cluster);
    train_features_adaptive = [train_features_adaptive; samples_in];
    train_class_adaptive = [train_class_adaptive; repelem(1,num_cluster)'];
    
    [samples_in, pool_0_adaptive] = al_sampling(pool_0_adaptive, score_update,num_cluster);
    train_features_adaptive = [train_features_adaptive; samples_in];
    train_class_adaptive = [train_class_adaptive; repelem(0,num_cluster)'];
    
    model_update = fitcsvm(train_features_adaptive, train_class_adaptive, 'KernelFunction', 'linear','Cost', [0 1;1 0]);
    score_update = fitSVMPosterior(model_update);

    [~, score] = predict(score_update,test_features_norm_sub);
    [~,~,~,AUC] = perfcurve(test_class,score(:,2),1);
    AUCs(end+1) = AUC;
end

%%


%% Using Random Selection
pool_1_adaptive = pool_1_features_norm_sub;
pool_0_adaptive = pool_0_features_norm_sub;
train_features_adaptive = train_features_norm_sub;
train_class_adaptive = train_class;
score_update = score_model;

AUCs = [];
[~, score] = predict(score_model, test_features_norm_sub);
[~,~,~,AUC] = perfcurve(test_class,score(:,2),1);
AUCs(end+1) = AUC;


for loop = 1:39
    number = 10;
    index = randsample(length(pool_1_adaptive), length(pool_1_adaptive));
    samples_in = pool_1_adaptive(index(1:10),:);
    pool_1_adaptive = pool_1_adaptive(index(11:end),:);
    train_features_adaptive = [train_features_adaptive; samples_in];
    train_class_adaptive = [train_class_adaptive; repelem(1,number)'];
    
    index = randsample(length(pool_0_adaptive), length(pool_0_adaptive));
    samples_in = pool_0_adaptive(index(1:10),:);
    pool_0_adaptive = pool_0_adaptive(index(11:end),:);
    train_features_adaptive = [train_features_adaptive; samples_in];
    train_class_adaptive = [train_class_adaptive; repelem(0,number)'];
    
    model_update = fitcsvm(train_features_adaptive, train_class_adaptive, 'KernelFunction', 'linear','Cost', [0 1;1 0]);
    score_update = fitSVMPosterior(model_update);

    [~, score] = predict(score_update,test_features_norm_sub);
    [~,~,~,AUC] = perfcurve(test_class,score(:,2),1);
    AUCs(end+1) = AUC;
end


%% Using Active learning without cluster

pool_1_adaptive = pool_1_features_norm_sub;
pool_0_adaptive = pool_0_features_norm_sub;
train_features_adaptive = train_features_norm_sub;
train_class_adaptive = train_class;
score_update = score_model;

AUCs = [];
[~, score] = predict(score_model, test_features_norm_sub);
[~,~,~,AUC] = perfcurve(test_class,score(:,2),1);
AUCs(end+1) = AUC;


for loop = 1:60
    number = 50;
    [samples_in, pool_1_adaptive] = active_learning_strategy(pool_1_adaptive, score_model,number);
    train_features_adaptive = [train_features_adaptive; samples_in];
    train_class_adaptive = [train_class_adaptive; repelem(1,number)'];
    
    [samples_in, pool_0_adaptive] = active_learning_strategy(pool_0_adaptive, score_model,number);
    train_features_adaptive = [train_features_adaptive; samples_in];
    train_class_adaptive = [train_class_adaptive; repelem(0,number)'];
    
    
    model_update = fitcsvm(train_features_adaptive, train_class_adaptive, 'KernelFunction', 'linear','Cost', [0 1;1 0]);
    score_update = fitSVMPosterior(model_update);

    [~, score] = predict(score_update,test_features_norm_sub);
    [~,~,~,AUC] = perfcurve(test_class,score(:,2),1);
    AUCs(end+1) = AUC;
end


%%
%% Test the final model
test_features_norm_sub = test_features_norm(:,feature_index);
score_model = fitSVMPosterior(model_update);
[label, score] = predict(score_model,test_features_norm_sub);
%ss = max(score')';
[X,Y,T,AUC] = perfcurve(test_class,score(:,2),1);
figure; plot(X, Y)

%{
%%

images = [];
images(1).features = feature_normalization(unlabel_features, train_mean, train_std);
images(1).class = [repelem(1,length(unlabel_1)), repelem(0,length(unlabel_0))]';
images(1).flag = repelem(0,length(images(1).class));


%% We need initiate labels when test AL for multiply times 
images(1).flag = repelem(0,length(images(1).class));

%% Active learning based on entropy
train_update = train_features_norm_sub;
train_class_update = train_class;
method = 'entropy';
model_update = model_SVM;
score_update = fitSVMPosterior(model_update);

AUCs = [];
[~, score] = predict(score_update,test_features_norm_sub);
[~,~,~,AUC] = perfcurve(test_class,score(:,2),1);
AUCs(end+1) = AUC;

%orders = randsample(440,440);
for loop = 1:200
    % Pick up the superpixel which need to be annotated
    %[image_index, col_index] = active_learning_strategy_loss(images, 'loss_function', feature_index, train_features_norm_sub, train_class, test_features_norm_sub, test_class)
    
    [image_index, col_index] = active_learning_strategy(images, method, feature_index, score_update);
    
    % The label of this superpixl is set to 1 so this one won't be selected
    % next times
    loop
    image_index = 1;
    %col_index = orders(loop);
    images(image_index).flag(col_index) = 1; 
    
    % Extract image info where the selected superpixel from
    unlabel_features_norm = images(image_index).features;
    class = images(image_index).class;
    annotation = class(col_index);

    % Add the point with maximal entropy to trainding datast
    % And delete it in the test dataset
    train_update(end+1,:) = unlabel_features_norm(col_index,feature_index);
    train_class_update(end+1) = annotation;
    
    % Update model
    model_update = fitcsvm(train_update, train_class_update, 'KernelFunction', 'linear','Cost', [0 2;1 0]);
    score_update = fitSVMPosterior(model_update);
    
    % Test
    [~, score] = predict(score_update,test_features_norm_sub);
    %ss = max(score')';
    [~,~,~,AUC] = perfcurve(test_class,score(:,2),1);
    AUCs(end+1) = AUC;
end



train_update = train_features_norm_sub;
train_class_update = train_class;
method = 'entropy';
model_update = model_SVM;
score_update = fitSVMPosterior(model_update);

AUCs_2 = [];
[~, score] = predict(score_update,test_features_norm_sub);
[~,~,~,AUC] = perfcurve(test_class,score(:,2),1);
AUCs_2(end+1) = AUC;
orders = randsample(440,440);

for loop = 1:200
    % Pick up the superpixel which need to be annotated
    %[image_index, col_index] = active_learning_strategy_loss(images, 'loss_function', feature_index, train_features_norm_sub, train_class, test_features_norm_sub, test_class)
    
    %[image_index, col_index] = active_learning_strategy(images, method, feature_index, score_update);
    
    % The label of this superpixl is set to 1 so this one won't be selected
    % next times
    loop
    image_index = 1;
    col_index = orders(loop);
    images(image_index).flag(col_index) = 1; 
    
    % Extract image info where the selected superpixel from
    unlabel_features_norm = images(image_index).features;
    class = images(image_index).class;
    annotation = class(col_index);

    % Add the point with maximal entropy to trainding datast
    % And delete it in the test dataset
    train_update(end+1,:) = unlabel_features_norm(col_index,feature_index);
    train_class_update(end+1) = annotation;
    
    % Update model
    model_update = fitcsvm(train_update, train_class_update, 'KernelFunction', 'linear','Cost', [0 2;1 0]);
    score_update = fitSVMPosterior(model_update);
    
    % Test
    [~, score] = predict(score_update,test_features_norm_sub);
    %ss = max(score')';
    [~,~,~,AUC] = perfcurve(test_class,score(:,2),1);
    AUCs_2(end+1) = AUC;
end
%}



