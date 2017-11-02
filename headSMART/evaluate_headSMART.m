function [result,  volume] = evaluate_headSMART(PatientsData,  feature_index, train_mean, train_std, model_SVM)
    record = 0;

    slices = PatientsData.slices_features;
    n = length(slices);
    volume = 0;
    result = zeros(512,512,n);
    
    for slice_index = 1:n
      %%
        record = record+1;
        brain = slices(slice_index).brain;
        structs = slices(slice_index).features;
      %%

        num_features = length(structs(1).features);
        test_features = zeros(length(structs),num_features);

        for i = 1:length(structs)
           test_features(i,:) = structs(i).features;
        end

        [a,~]= find(isnan(test_features)==1);
        test_features(a,:) = [];
        structs(a) = [];


        test = test_features(:,feature_index);
        test_norm = feature_normalization(test, train_mean, train_std);

        test_pred_y = predict(model_SVM, test_norm);


        pred_img = zeros(size(brain));
 
        for i = 1:length(structs)
            if test_pred_y(i)==1
                pred_img(structs(i).PixelIdxList) = 1;
            end
        end


        pred_img =  post_processing(brain, pred_img);
        pred_img(brain==brain(1))=0;

        pred_list_pos = find(pred_img==1);
        volume  = volume + length(pred_list_pos);
        result(:,:,slice_index) = pred_img;
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
