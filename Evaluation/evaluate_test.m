function [result] = evaluate_test(PatientsData,  test_index, feature_index, train_mean, train_std, model_SVM)
    result = [];
    record = 0;
    for testi = 1:length(test_index)
        
        tid = test_index(testi);
        pid = PatientsData(tid).Pid;
       
        annotated_slices = PatientsData(tid).annotated_slices;
        dice  = [];
        for slice_index = 1:length(annotated_slices)
            record = record+1;
            annotated_img = annotated_slices(slice_index).img_annot;
            brain = annotated_slices(slice_index).brain;
            struct_1 = annotated_slices(slice_index).struct_1;
            struct_0 = annotated_slices(slice_index).struct_0;
            if length(struct_0)>0
            num_features = length(struct_0(1).features);
            test_1_features = zeros(length(struct_1),num_features);
            test_0_features = zeros(length(struct_0),num_features);
            
            for i = 1:length(struct_1)
               test_1_features(i,:) = struct_1(i).features;
            end

            for i = 1:length(struct_0)
               test_0_features(i,:) = struct_0(i).features;
            end
            
            %a1 = length(struct_1);
            [a,~]= find(isnan(test_1_features)==1);
            test_1_features(a,:) = [];
            struct_1(a) = [];
            %a2 = length(struct_1);
          
    
            [a,~]= find(isnan(test_0_features)==1);
            test_0_features(a,:) = [];
            struct_0(a) = []; 
       

            test_1 = test_1_features(:,feature_index);
            test_0 = test_0_features(:,feature_index);
            size_1 = size(test_1);
            size_0 = size(test_0);
            test = [test_1; test_0];
            test_class = [repelem(1,size_1(1)), repelem(0,size_0(1))]';
            test_norm = feature_normalization(test, train_mean, train_std);
            
            test_pred_y = predict(model_SVM,test_norm);

            TP = sum(test_class==test_pred_y & test_class==1);
            TN = sum(test_class==test_pred_y & test_class==0);

            test_se =  TP/sum(test_class==1);
            test_sp = TN/sum(test_class==0);
            test_acc = (TP+TN)/length(test_class);
            
            result(record).test_se_sp = test_se;
            result(record).test_sp_sp = test_sp;
            result(record).test_acc_sp = test_acc;
            
            struct_all = [struct_1; struct_0];
            
            
            pred_img = zeros(size(brain));
            
            for i = 1:length(struct_all)
                
                if test_pred_y(i)==1
                    pred_img(struct_all(i).PixelIdxList) = 1;
                end
            end
            
            pred_list_pos = find(pred_img==1);
            pred_list_neg = find(pred_img==0);
            brain_region = find(brain>brain(1));
            pred_list_neg = intersect(brain_region, pred_list_neg);
            
            annotated_pos = find_annotated_pixelList(annotated_img, brain);
            annotated_neg = setdiff(brain_region, annotated_pos);
            
            TP = length(intersect(pred_list_pos, annotated_pos));
            TN = length(intersect(pred_list_neg, annotated_neg));
            FP = length(intersect(pred_list_pos, annotated_neg));
            FN = length(intersect(pred_list_neg, annotated_pos));
            
            test_se = TP/(TP+FN);
            test_sp = TN/(TN+FP);
            test_acc = (TP+TN)/(TP+TN+FP+FN);
            test_dice = 2*TP/(length(pred_list_pos)+length(annotated_pos));
            
%             TP = sum(test_class==test_pred_y & test_class==1);
%             TN = sum(test_class==test_pred_y & test_class==0);
%             Ps = sum(test_class) + sum(test_pred_y);
%             test_se =  TP/sum(test_class==1);
%             test_sp = TN/sum(test_class==0);
%             test_acc = (TP+TN)/length(test_class);
%             test_dice = 2*TP/Ps;

            result(record).test_se = test_se;
            result(record).test_sp = test_sp;
            result(record).test_acc = test_acc;
            result(record).dice = test_dice;
            result(record).num_pos = length(annotated_pos);
            result(record).id  = strcat(num2str(pid), '-', num2str(slice_index));
            result(record).pred_img = pred_img;
            result(record).annotated_img = annotated_img;
            
            dice = [dice, test_dice];
            end
        end
        mean(dice)
    end
end
            

function index_list = find_annotated_pixelList(annotated_img, brain)

    dim = size(annotated_img);
    index_list = [];
    index_roi = find(brain>brain(1));
    for i = 1:dim(1)
        for j = 1:dim(2)
            value = annotated_img(i,j,:);
            if value(1)==255&&value(2)==0&&value(3)==0
                index = sub2ind(size(brain),i,j);
                index_list = [index_list, index];
            end
        end
    end
    
    index_list = intersect(index_list, index_roi);
end