%% Active learning Evaluation

%% Initiation - for seperate images
ImgDir = '/Users/apple/Dropbox/TBI/Validation';
ImgFiles = dir(ImgDir);
ImgFiles = ImgFiles(~strncmpi('.', {ImgFiles.name},1));
images = [];
ImgDir = '/Users/apple/Dropbox/TBI/Select_for_annotation';
for i = 1: length(ImgFiles)
    fname = ImgFiles(i).name;
    imgori =  imread([ImgDir,'/',fname]);
    fname = [fname(1:end-4), 'A.png'];
    img =  imread([ImgDir,'/',fname]);
    img = process_annotated_imgs(img);
    [struct_1, struct_0, imgori_sub, ~,~] = singleimage_process_with_label(imgori, img);
    unlabel = [struct_1,struct_0];
    label = [repelem(1,length(struct_1)), repelem(0,length(struct_0))];
    %[unlabel, imgori_sub, ~] = singleimage_process_unlabelled(imgori);
    unlabel_features = [];
    for j = 1:length(unlabel)
       unlabel_features(j,:) = unlabel(j).features;
    end
    unlabel_features_norm = feature_normalization(unlabel_features, train_mean, train_std);
    
    images(i).imgori = imgori;
    images(i).imgori_sub = imgori_sub;
    images(i).features = unlabel_features_norm;
    images(i).flag = repelem(0, size(unlabel_features_norm,1));
    images(i).unlabel = unlabel;
    images(i).label = label;
end

%% We need initiate labels when test AL for multiply times - for seperate images
for i = 1:length(ImgFiles)
    images(i).flag = repelem(0, size(images(i).features,1));
end

%% Active learning based on entropy - for seperate images
train_update = train_features_norm_sub;
train_class_update = train_class;
method = 'entropy';
model_update = model_SVM;
score_update = fitSVMPosterior(model_update);

AUCs = [];
[~, score] = predict(score_update,test_features_norm_sub);
[~,~,~,AUC] = perfcurve(test_class,score(:,2),1);
AUCs(end+1) = AUC;

for loop = 1:20
    % Pick up the superpixel which need to be annotated
    [image_index, col_index] = active_learning_strategy(images, method, feature_index, score_update);
    
    % The label of this superpixl is set to 1 so this one won't be selected
    % next times
    images(image_index).flag(col_index) = 1; 
    
    % Extract image info where the selected superpixel from
    imgori_sub = images(image_index).imgori_sub;
    unlabel = images(image_index).unlabel;
    unlabel_features_norm = images(image_index).features;
    label = images(image_index).label;
    annotation = label(col_index);
    %{
    % Show the region and get labeled    
    testimg = zeros(size(imgori_sub));
    testimg(unlabel(col_index).PixelIdxList) = 255;
    edges = edge(testimg, 'Canny');
    edgepoints = find(edges==1);
    testimg = zeros([size(imgori_sub),3]);
    edgepoints = find(edges==1);

    testimg(:,:,1) = imgori_sub;
    testimg(:,:,2) = imgori_sub;
    testimg(:,:,3) = imgori_sub;

    for i =1:length(edgepoints)
        [coor_y, coor_x] = ind2sub(size(imgori_sub),edgepoints(i));
        testimg(coor_y,coor_x, 1) = 255;
        testimg(coor_y,coor_x, 2) = 0;
        testimg(coor_y,coor_x, 3) = 0;
    end

    imshow(uint8(testimg))
    annotation = input('input the label: ');
    %}
    
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



%% Examine performance
fname = ImgFiles(1).name;
img =  imread([ImgDir,'/',fname]);
fname = [fname(1:end-4) 'Orig.png'];
imgori = imread([ImgDir,'/',fname]);
[struct_1, struct_0, ~,~,~]  = singleimage_process_with_label(imgori,img);

test = [struct_1,struct_0];

test_features = [];
test_class = repelem(0,length(test))';
for i = 1:length(test)
   test_features(i,:) = test(i).features;
   test_class(i) = test(i).label;
end

test_features_norm = feature_normalization(test_features, train_mean, train_std);
%test_features_norm = test_features_norm(:,feature_index);
%%
score_model = fitSVMPosterior(model_update);
[~, score] = predict(score_model,test_features_norm_sub);
threshold = 0.3500;
index_1 = find(score(:,2)>threshold);
test_pred_y = zeros(length(test_class),1);
test_pred_y(index_1) = 1;

test_acc_1 = sum(test_class == test_pred_y)/length(test_class);
test_se_1 =  sum(test_class==test_pred_y & test_class==1)/sum(test_class==1);
test_sp_1 = sum(test_class==test_pred_y & test_class==0)/sum(test_class==0);

fname = ImgFiles(10).name;
img =  imread([ImgDir,'/',fname]);
fname = [fname(1:end-4) 'Orig.png'];
imgori = imread([ImgDir,'/',fname]);
[struct_1, struct_0, ~,~,~]  = singleimage_process_with_label(imgori,img);

test = [struct_1,struct_0];

test_features = [];
test_class = repelem(0,length(test))';
for i = 1:length(test)
   test_features(i,:) = test(i).features;
   test_class(i) = test(i).label;
end

test_features_norm = feature_normalization(test_features, train_mean, train_std);
%test_features_norm = test_features_norm(:,feature_index);

test_pred_y = predict(model_SVM, test_features_norm); 
test_acc_2 = sum(test_class == test_pred_y)/length(test_class);
test_se_2 =  sum(test_class==test_pred_y & test_class==1)/sum(test_class==1);
test_sp_2 = sum(test_class==test_pred_y & test_class==0)/sum(test_class==0);


%%

train_class_save = train_class;
train_features_norm_save = train_features_norm;

new_index = randsample(234,10);
train_features_norm_new = [train_features_norm_save; train_features_norm(new_index,:)];
train_class_new = [train_class_save; train_class(new_index)];

model_SVM = fitcsvm(train_features_norm_new, train_class_new, 'KernelFunction', 'linear','Cost', [0 5;1 0]);

new_index2 = randsample(234,10);
train_features_norm_new = [train_features_norm_new; train_features_norm(new_index2,:)];
train_class_new = [train_class_new; train_class(new_index2)];
model_SVM = fitcsvm(train_features_norm_new, train_class_new, 'KernelFunction', 'linear','Cost', [0 5;1 0]);



%{
test_pred_y = predict(model_SVM, test_features_norm); 

hema = imgori_sub;
for j = 1:length(test)
   if test_pred_y(j) == 1 && sum(imgori_sub(test(j).PixelIdxList)~=0)/length(test(j).PixelIdxList)>0.5
       hema(test(j).PixelIdxList) = 255;
   elseif test_pred_y(j) == 0
       hema(test(j).PixelIdxList) = imgori_sub(test(j).PixelIdxList);
   end
end
figure; imshow(uint8(hema))
figure; imshow(imgori_sub)
%}
