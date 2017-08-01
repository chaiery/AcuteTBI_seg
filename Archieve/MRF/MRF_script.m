[image, al_pred, al_prob_1, image_adjust] = al_single_seg(ImgFiles(2), ImgDir,model_update,feature_index,train_mean,train_std);
segmentation = MRF_Seg(image_adjust, al_pred, al_prob_1);


%%
 [Acc,Sn,Sp,Pre,MCC,Sorenson_Dice] = al_prediction_evaluation(ImgFiles, ImgDir, model_update,feature_index,train_mean, train_std)
 
 %%
%ImgDir = '/Users/apple/Dropbox/TBI/For_MRF';

ImgDir = '/Users/apple/Dropbox/TBI/al_test';
ImgFiles = dir(ImgDir);
ImgFiles = ImgFiles(~strncmpi('.', {ImgFiles.name},1));
ImgDir = '/Users/apple/Dropbox/TBI/Select_for_annotation';

%%
[Acc,Sn,Sp,Pre,MCC,Sorenson_Dice] = MRF_prediction_evaluation(ImgFiles(5), ImgDir, model_update,feature_index,train_mean, train_std)