function prediction_model()
load('T.mat');
acc=[];
points=[];
FP=0;
FN=0;
TP=0;
for i = 1:size(unique(T(:,1)),1)
    
    [y_test, x_test, y_train, x_train] = prepare_data(T, i);
    %svm_model = fitcsvm(x_train, y_train, 'KernelFunction', 'gaussian', 'PolynomialOrder', [], 'KernelScale', 5, 'BoxConstraint', 1, 'Standardize', 1, 'Cost', [0,1;sum(y_train==0)/sum(y_train==1),0]);
    
    TreeBagger_model = TreeBagger(100,x_train, y_train);
    
    labels = predict(TreeBagger_model, x_test);        
    
    jav=cell2mat(labels); %for tree
    labels=str2num(jav); %for tree

    
    diff=labels-y_test;
    fp=length(find(diff==-1));
    FP=FP+fp;
    fn=length(find(diff==1));
    FN=FN+fn;
    tp=sum(dot(labels,y_test));
    TP=TP+tp;
    
    
    acc1 = 100*(1-sum(abs(labels-y_test))./length(labels));
    acc=[acc,acc1];
    points=[points,size(x_test,1)];
end
TN= sum(points(:))-(TP+FN+FP);
sen=TP/(TP+FN)
spec=TN/(TN+FP)
disp(dot(points,acc)/sum(points(:)))

disp(acc)
disp(mean(acc))
end


function [y_test,x_test,y_train,x_train] = prepare_data(T, i)

uni=unique(T(:,1));
test_ind = find(T.subject ==uni.subject(i));
train_ind = find(T.subject ~=uni.subject(i));

x_test=[T.age(test_ind),T.boneDist(test_ind),T.topDist(test_ind), ...
    T.minInt(test_ind), T.maxInt(test_ind), T.meanInt(test_ind), ...
    T.entropy(test_ind), T.stdInt(test_ind),T.smoothness(test_ind)];
y_test=[T.HEM(test_ind)]; 


x_train= [T.age(train_ind),T.boneDist(train_ind),T.topDist(train_ind), ...
    T.minInt(train_ind), T.maxInt(train_ind), T.meanInt(train_ind), ...
    T.entropy(train_ind), T.stdInt(train_ind),T.smoothness(train_ind)];
y_train= [T.HEM(train_ind)]; 


end