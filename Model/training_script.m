
%%
%feature_index = feature_rank_1(1:129);
feature_index = 1:129;
pid_index_pos = randsample(62,62); 
pid_index_neg = randsample(30,30)+62; 
train_index =[pid_index_pos(1:50); pid_index_neg(1:25)];
test_index = setdiff(1:92, train_index);

%%
%[train_1_features, train_0_features_edge, train_0_features_remain] = build_train_and_test(ModelFeatures(train_index));
[test_1_features, test_0_features_edge, test_0_features_remain] = build_train_and_test(ModelFeatures(test_index));

%%
% Train set
train_1 = train_1_features(randsample(length(train_1_features), 8000), feature_index);
train_0_edge = train_0_features_edge(randsample(length(train_0_features_edge), 4000), feature_index);
train_0_remain = train_0_features_remain(randsample(length(train_0_features_remain), 4000), feature_index);
train_features = [train_1; train_0_edge; train_0_remain];
%train_features = [train_1; train_0_edge];
    
train_mean = mean(train_features);

train_std = std(train_features,0,1);

train_class = [repelem(1,length(train_1)), repelem(0,length([train_0_edge; train_0_remain]))]';
train_norm = feature_normalization(train_features, train_mean, train_std);

% Test set
test_1 = test_1_features(:,feature_index);
test_0_features = [test_0_features_edge; test_0_features_remain];
test_0 = test_0_features(:,feature_index);
test_features = [test_1; test_0];
test_class = [repelem(1,length(test_1)), repelem(0,length(test_0))]';

test_norm = feature_normalization(test_features, train_mean, train_std);
%test_weights = test_norm*e_group;
%test_norm(:,[2,4]) = [];

%train_norm(:,[2,4]) = [];

%%

%% This block is used to explore the random selection
% Calculate AUC and plot ROC
model_SVM = fitcsvm(train_norm, train_class, 'KernelFunction', 'linear','Cost', [0 1;1 0]);
[pred, score] = predict(model_SVM, test_norm);
[AUC, collection] = ROC_curve(score, test_class,  0.001, true);

%% Evaluate Dice for individual patient
output = [];
for i = 1:length(test_index)
    model_SVM = TreeBagger_model;
    [masks, brains, annots, dice, ~] = evaluate_test(ModelFeatures(test_index(i)),  feature_index, train_mean, train_std, model_SVM);
    output(i).masks = masks;
    output(i).brains = brains;
    output(i).annots = annots;
    output(i).pid = ModelFeatures(test_index(i)).Pid;
    output(i).dice = dice;
end


%% Random Forest
lfs = 1000;
TreeBagger_model = TreeBagger(100, train_norm, train_class, ...
                              'Cost', [0, 3; 1, 0], ...
                              'MinLeafSize', lfs, ...
                              'NumPredictorsToSample', 50, ...
                              'Method', 'classification' ...
                             );
%save (['TreeBagger_',num2str(i)],'TreeBagger_model')
disp ('start prediction')
[labels, ~, cost] = predict(TreeBagger_model, test_norm);
        
test_pred_y = str2num(cell2mat(labels));
TP = sum(test_class==test_pred_y & test_class==1);
TN = sum(test_class==test_pred_y & test_class==0);

test_se =  TP/sum(test_class==1);
test_sp = TN/sum(test_class==0);
test_acc = (TP+TN)/length(test_class);



%% Calculate test sensitivity, specificity, accuracy
%test_norm = test_weights;
test_pred_y = predict(model_SVM,test_norm);
%test_pred_y = str2num(cell2mat(labels));
TP = sum(test_class==test_pred_y & test_class==1);
TN = sum(test_class==test_pred_y & test_class==0);

test_se =  TP/sum(test_class==1);
test_sp = TN/sum(test_class==0);
test_acc = (TP+TN)/length(test_class);
 

%%
%% Perform PCA to train_norm
cov_matrix = train_norm'*train_norm;
% Caculate eigenvectors
[V,D] = eig(cov_matrix);

% Find the best K
ev = abs(diag(D));
[A,index]=sort(ev,'descend');
cu = 0;
y = zeros(1, size(D,1));
for i =1:size(D,1)
    cu = cu+abs(D(index(i), index(i)));
    y(i) = cu;
end

y = y/y(end);

plot(1:size(D,1), y)
xlabel('The number of eigens')
ylabel('The percentage of variance expained by selected eigens')

%%
k = 80;
e_group = V(:,index(1:k));
weights = train_norm*e_group;
