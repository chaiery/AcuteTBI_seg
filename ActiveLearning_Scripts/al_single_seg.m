function [imgori_sub, img_pred, img_prob_1, imgori_sub_adjust] = al_single_seg(ImgFile, ImgDir,model_update,feature_index,train_mean,train_std)

        fname = ImgFile(1).name;
        imgori = imread([ImgDir, '/', fname]);
        fname_A = [fname(1:end-4), 'A.png'];
        imgA = imread([ImgDir,'/',fname_A]);
        imgA = process_annotated_imgs(imgA);

        [test_1, test_2, imgori_sub, imgori_sub_adjust, img_sub] = singleimage_process_with_label(imgori,imgA);
        test = [test_1, test_2];
        %imshow(imgori_sub)

        test_features = [];
        test_class = repelem(0,length(test))';
        for i = 1:length(test)
           test_features(i,:) = test(i).features;
           test_class(i) = test(i).label;
        end

        test_features_norm = feature_normalization(test_features, train_mean, train_std);
        test_features_norm_sub = test_features_norm(:,feature_index);

        %%
        score_model = fitSVMPosterior(model_update);
        [~, score] = predict(score_model,test_features_norm_sub);
        threshold = 0.3000;
        index_1 = find(score(:,2)>threshold);
        test_pred_y = zeros(length(test_class),1);
        test_pred_y(index_1) = 1;

        img_pred = zeros(size(imgori_sub));
        for i = 1:length(test)
           if test_pred_y(i) == 1
               img_pred(test(i).PixelIdxList) = 1;
           end
        end
        
        img_prob_1 = zeros(size(imgori_sub));
        for i = 1:length(test)
            img_prob_1(test(i).PixelIdxList) = score(i,2);
        end
        
        hema = imgori_sub;
        for i = 1:length(test)
           if test_pred_y(i) == 1
               hema(test(i).PixelIdxList) = 255;
           end
        end
        
        [x,y,~] = size(img_sub);
        img_label = zeros(x,y);
        for i = 1:x
            for j = 1:y
                value = img_sub(i,j,:);
                if sum(value(:)==[255;0;0])==3
                    img_label(i,j) = 1;
                end
            end
        end

end
