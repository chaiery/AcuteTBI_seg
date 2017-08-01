%% Script for one image prediction and segmentation
i = 5;
ImgDir = '/Users/apple/Dropbox/TBI/al_test/';
ImgFiles = dir(ImgDir);
ImgFiles = ImgFiles(~strncmpi('.', {ImgFiles.name},1));
fname = ImgFiles(i).name;

ImgDir = '/Users/apple/Dropbox/TBI/Select_for_annotation';

imgori = imread([ImgDir, '/', fname]);
fname_A = [fname(1:end-4), 'A.png'];
imgA = imread([ImgDir,'/',fname_A]);
imgA = process_annotated_imgs(imgA);

[test_1, test_0, imgori_sub, imgori_sub_adjust, img_sub] = singleimage_process_with_label(imgori,imgA);
test = [test_1, test_0];

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
threshold = 0.200;
index_1 = find(score(:,2)>threshold);
index_0 = find(score(:,2)<threshold);
test_pred_y = zeros(length(test_class),1);
test_pred_y(index_1) = 1;

%test_pred_y = predict(model_update, test_features_norm_sub); 
test_acc = sum(test_class == test_pred_y)/length(test_class);
test_se =  sum(test_class==test_pred_y & test_class==1)/sum(test_class==1);
test_sp = sum(test_class==test_pred_y & test_class==0)/sum(test_class==0);

hema = zeros(size(imgori_sub));
for i = 1:length(test)
   if test_pred_y(i) == 1
       hema(test(i).PixelIdxList) = 1;
   end
end

figure; imshow(hema)
figure;imshow(img_sub)

% BW the annotated image
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

%% Evaluation
img_pred = hema;
TP = 0; TN = 0; FP = 0; FN = 0; Ps = 0;
TP = TP + sum(sum(img_pred.*img_label));
TN = TN + sum(sum((1-img_pred).*(1-img_label)));
FP = FP + sum(sum(img_pred.*(1-img_label)));
FN = FN + sum(sum((1-img_pred).*img_label));

Ps = Ps + sum(img_pred(:))+sum(img_label(:));


Acc = (TN+TP)/(TN+TP+FN+FP);
Sn = TP/(TP+FN);
Sp = TN/(TN+FP);
Pre = TP/(TP+FP);
MCC = (TP*TN-FP*FN)/((TP+FN)*(TP+FP)*(TN+FN)*(TN+FP))^0.5;
Sorenson_Dice = 2*TP/Ps;



%{
%%
% Script for unlabeled image
fnames = { '14409.960875670189287435592398615993174Orig.png',...
'14409.19932916720414881945503178399600107Orig.png', ...
'14409.14718765514351180448887920950660493Orig.png', ...
'14409.33428056793316298639236953954304733Orig.png'};


for i = 1:length(fnames)
    fname = char(fnames(i));
    imgori = imread([ImgDir,'/',fname]);
    [test, imgori_sub] = singleimage_process_unlabelled(imgori);
    test_features = [];
    for j = 1:length(test)
       test_features(j,:) = test(j).features;
    end
    test_features_select = test_features(:,feature_index);
    test_features_nom = feature_normalization(test_features_select);
    test_pred_y = predict(model_SVM, test_features_nom); 
    hema = zeros(size(imgori_sub));
    for j = 1:length(test)
       if test_pred_y(j) == 1 && sum(imgori_sub(test(j).PixelIdxList)~=0)/length(test(j).PixelIdxList)>0.5
           hema(test(j).PixelIdxList) = 255;
       elseif test_pred_y(j) == 0
           hema(test(j).PixelIdxList) = imgori_sub(test(j).PixelIdxList);
       end
    end
    figure; imshow(uint8(hema))
    figure; imshow(imgori_sub)
end


fnames = {'14409.7407411341119617383942830220358451Orig.png',...
'14409.529782143002727487321885679953667Orig.png',...
'14409.12456607947486951708744005342907617Orig.png',...
'14409.4343871824136560650482557587078534Orig.png',...
'14409.10479624223143731471186330833330396Orig.png',...
'14409.21318088411068879715883584980941485Orig.png'};





for i = 1:length(fnames)
    fname = char(fnames(i));
    fname2 = [fname(1:end-8) '.png'];
    imgori = imread([ImgDir,'/',fname]);
    img = imread([ImgDir,'/',fname2]);
    %[test, imgori_sub] = singleimage_process_unlabelled(imgori);
    [struct_1, struct_0, imgori_sub, img_sub] = singleimage_process_with_label(imgori,img);
    test = [struct_1, struct_0];
    test_features = [];
    for j = 1:length(test)
       test_features(j,:) = test(j).features;
    end
    test_features_select = test_features(:,feature_index);
    test_features_nom = feature_normalization(test_features_select);
    test_pred_y = predict(model_SVM, test_features_nom); 
    hema = zeros(size(imgori_sub));
   
    for j = 1:length(test)
       if test_pred_y(j) == 1 && sum(imgori_sub(test(j).PixelIdxList)~=0)/length(test(j).PixelIdxList)>0.5
           hema(test(j).PixelIdxList) = 255;
       elseif test_pred_y(j) == 0
           hema(test(j).PixelIdxList) = imgori_sub(test(j).PixelIdxList);
       end
    end
    
    hema_train = zeros(size(imgori_sub));
    for j = 1:length(test)
       if test(j).label == 1
           hema_train(test(j).PixelIdxList) = 255;
       elseif test(j).label == 0
           hema_train(test(j).PixelIdxList) = imgori_sub(test(j).PixelIdxList);
       end
    end
    figure; imshow(uint8(hema_train))
    
    figure; imshow(uint8(hema))
    %figure; imshow(imgori_sub)
end
%}
