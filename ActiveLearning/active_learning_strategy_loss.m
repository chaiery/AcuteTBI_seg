function [image_index, col_index] = active_learning_strategy_loss(images, method, feature_index, ...
    train_features_norm_sub, train_class, ...
    test_features_norm_sub, test_class)

    values = [];
    indexs = [];
    
    model_SVM = fitcsvm(train_features_norm_sub, train_class, 'KernelFunction', 'linear','Cost', [0 2;1 0]);
    
    for ind = 1:length(images)
        features_norm_sub = images(ind).features(:,feature_index);
        unlabel_class = images(ind).class;
        
        % for each superpixel
        AUCs = [];
        if strcmp(method, 'loss_function');
            for i = 1:length(features_norm_sub)
                train_update = train_features_norm_sub;
                train_class_update = train_class;               
                train_update(end+1,:) = features_norm_sub(i,:);
                train_class_update(end+1) = unlabel_class(i);
                
                model_SVM = fitcsvm(train_update, train_class_update, 'KernelFunction', 'linear','Cost', [0 2;1 0]);
                score_model = fitSVMPosterior(model_SVM);
                [~, score] = predict(score_model,test_features_norm_sub);
                %ss = max(score')';
                [~,~,~,AUC] = perfcurve(test_class,score(:,2),1);
                AUCs(end+1) = AUC;
            end

            index = (images(ind).flag==repelem(1,length(features_norm_sub)));
            AUCs(index) = 0;
            [x_value, x_index] = max(AUCs);
            values(end+1) = x_value;
            indexs(end+1) = x_index;
        end
    end
    
    [~,image_index] = max(values);
    image_index = image_index(1);
    col_index = indexs(image_index);

end

