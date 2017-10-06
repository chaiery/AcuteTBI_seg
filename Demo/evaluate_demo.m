function [result, dice, volume] = evaluate_demo(PatientsData,  feature_index, train_mean, train_std, model_SVM)
    record = 0;
    annotated_slices = PatientsData.annotated_slices;
    annotated_features = PatientsData.annotated_features;
   
    n = length(annotated_slices);
    dice_belows = zeros(1, n);
    dice_ups = zeros(1, n);
    volume = 0;
    result = zeros(512,512,n);
    
    for slice_index = 1:n
      %%
        struct_0 = annotated_features(slice_index).struct_0_features;
        if ~isempty(struct_0)
        record = record+1;
        annotated_img = annotated_slices(slice_index).img_annot;
        brain = annotated_slices(slice_index).brain;
        struct_1 = annotated_features(slice_index).struct_1_features;
      %%

        num_features = length(struct_0(1).features);
        test_1_features = zeros(length(struct_1),num_features);
        test_0_features = zeros(length(struct_0),num_features);

        for i = 1:length(struct_1)
           test_1_features(i,:) = struct_1(i).features;
        end

        for i = 1:length(struct_0)
           test_0_features(i,:) = struct_0(i).features;
        end

        [a,~]= find(isnan(test_1_features)==1);
        test_1_features(a,:) = [];
        struct_1(a) = [];


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

        %
        %test_pred_y = predict(model_SVM,test_norm);
        test_pred_y = predict(model_SVM, test_norm);

        %%
        distance = test_norm*model_SVM.Beta+model_SVM.Bias;
        prob = sigmf(distance,[1,0]);

     %%
        %TP = sum(test_class==test_pred_y & test_class==1);
        %TN = sum(test_class==test_pred_y & test_class==0);

     %%
        struct_all = [struct_1, struct_0];


        pred_img = zeros(size(brain));
        prob_map = zeros(size(brain));
        for i = 1:length(struct_all)

            if test_pred_y(i)==1
                pred_img(struct_all(i).PixelIdxList) = 1;
            end
        end

        for i = 1:length(struct_all)
               prob_map(struct_all(i).PixelIdxList) =prob(i);
        end

        pred_img =  post_processing(brain, pred_img);
        pred_img(brain==brain(1))=0;
        pred_list_pos = find(pred_img==1);
        pred_list_neg = find(pred_img==0);


        brain_region = find(brain>brain(1));
        pred_list_neg = intersect(brain_region, pred_list_neg);

        annotated_pos = find_annotated_pixelList(annotated_img, brain);
        annotated_neg = setdiff(brain_region, annotated_pos);

        TP = length(intersect(pred_list_pos, annotated_pos));
        dice_below = length(pred_list_pos)+length(annotated_pos);
        dice_up = 2*TP;

        result(:,:,slice_index) = pred_img;

        dice_belows(i) = dice_below;
        dice_ups(i) = dice_up;
        volume  = volume + length(pred_list_pos);

        end
    end
    dice = sum(dice_ups)/sum(dice_belows);
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
