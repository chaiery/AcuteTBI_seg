function [brain, mask, dice, volume] = detectAcuteHematoma(pid_data, param)
%%
feature_index = param.feature_index;
means = param.mean;
stds = param.std;
model_SVM = param.model;

%%
[result, dice, volume] = evaluate_demo(pid_data,  feature_index, means, stds, model_SVM);

%%
pos_idx = pid_data.pos_idx;
neg_idx = pid_data.pos_idx;
brain_pos = pid_data.brain_pos;
brain_neg = pid_data.brain_neg;
total_depth = length(pos_idx) + length(neg_idx);

brain = zeros(512,512,total_depth);
mask =zeros(512,512,total_depth);
brain(:,:,pos_idx) = brain_pos;
brain(:,:,neg_idx) = brain_neg;
mask(:,:,pos_idx) = result;

end
