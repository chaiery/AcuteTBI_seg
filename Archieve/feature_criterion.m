function criterion = feature_criterion(x,y)
    index_0 = find(y==0);
    index_1 = find(y==1);
    
    x_0 = x(index_0,:);
    y_0 = y(index_0,:);
    
    x_1 = x(index_1,:);
    y_1 = y(index_1,:);
    
    cvp_0 = cvpartition(y_0, 'Holdout', 0.25); 
    cvp_1 = cvpartition(y_1, 'Holdout', 0.25); 
    
    xtrain = [x_0(cvp_0.training,:); x_1(cvp_1.training,:)];
    ytrain = [y_0(cvp_0.training); y_1(cvp_1.training)];

    xtest = [x_0(cvp_0.test,:); x_1(cvp_1.test,:)];
    ytest = [y_0(cvp_0.test); y_1(cvp_1.test)];
    
    
    model_SVM = fitcsvm(xtrain, ytrain, 'KernelFunction', 'linear','Cost',[0 1;10 0]);
    test_pred_y = predict(model_SVM, xtest);
        
    accuracy = sum(ytest == test_pred_y)/length(ytest);
    test_se =  sum(ytest==test_pred_y & ytest==1)/sum(ytest==1);
    test_sp = sum(ytest==test_pred_y & ytest==0)/sum(ytest==0);
    %accuracy = (test_se*test_sp)^0.5;
    criterion = (1- accuracy);
    %criterion = accuracy;
end


