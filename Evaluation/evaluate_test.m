function [masks, brains,annots, dice, volume] = evaluate_test(Model_features,  feature_index, train_mean, train_std, model_SVM)
    annotated_slices = Model_features.annotated_slices;
    annotated_features = Model_features.annotated_features;
    
    n = length(annotated_slices);
    masks = zeros(512,512,n);
    annots = zeros(512,512,n);
    brains = zeros(512,512,n);
    %%
    for slice_index = 1:n
      %%
        struct_0 = annotated_features(slice_index).struct_0_features;
        if ~isempty(struct_0)
        brain = annotated_slices(slice_index).brain;
        brains(:,:,slice_index) = brain;
        annots(:,:,slice_index) = find_mask(annotated_slices(slice_index).img_annot, brain);
        struct_1 = annotated_features(slice_index).struct_1_features;
      

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
        test = [test_1; test_0];
        test_norm = feature_normalization(test, train_mean, train_std);

        test_pred_y = predict(model_SVM, test_norm);
        test_pred_y = str2num(cell2mat(test_pred_y ));
        
        struct_all = [struct_1, struct_0];
        pred_img = zeros(size(brain));
        for i = 1:length(struct_all)
            if test_pred_y(i)==1
                pred_img(struct_all(i).PixelIdxList) = 1;
            end
        end

        pred_img =  post_processing_demo(brain, pred_img);
        pred_img(brain==brain(1))=0;

        masks(:,:,slice_index) = pred_img;
        end
    end
    
    %% Now we have predictions for this patient
    % Integrate 3D information!
    for slice_index = 2:n-1
        pred = masks(:,:,slice_index);
        new_slice = zeros(size(pred));
        boto = masks(:,:,slice_index-1);
        abov = masks(:,:,slice_index+1);
        boto_index = find(boto==1);
        abov_index =  find(abov==1);
        context = union(boto_index, abov_index);
        s = regionprops(logical(pred),'PixelIdxList');
        for i = 1:length(s)
            pixel_list = s(i).PixelIdxList;
            if intersect(pixel_list, context)
                new_slice(pixel_list) = 1;
            end
        end
        masks(:,:,slice_index) = new_slice;
    end
    
    %%
    x = masks.*annots;
    y = masks+annots;
    dice = 2*sum(x(:))/sum(y(:));
    volume = sum(masks(:));
end


function mask = find_mask(annotated_img, brain)
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
    mask = zeros(size(brain));
    mask(index_list) = 1;
end
