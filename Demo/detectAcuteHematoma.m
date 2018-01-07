function [brain, mask, dice, volume, pos_index] = detectAcuteHematoma(pid_data, param)
%%
feature_index = param.feature_index;
means = param.mean;
stds = param.std;
model_SVM = param.model;

%%
[result, dice, ~] = evaluate_demo(pid_data,  feature_index, means, stds, model_SVM);

pos_idx = pid_data.pos_idx;
neg_idx = pid_data.neg_idx;
brain_pos = pid_data.brain_pos;
brain_neg = pid_data.brain_neg;
total_depth = length(pos_idx) + length(neg_idx);

start = min([pos_idx, neg_idx]);
brain = zeros(512,512,total_depth);
mask =zeros(512,512,total_depth);
brain(:,:,pos_idx-start+1) = brain_pos;
brain(:,:,neg_idx-start+1) = brain_neg;
mask(:,:,pos_idx-start+1) = result;

mask = midline_remove(brain, mask);
volume = sum(mask(:));
pixel_spacing = pid_data.pixel_spacing;
volume = volume * pixel_spacing(1) * pixel_spacing(1) * 5 * 0.001;
brain = uint8(brain);

pos_index = find(sum(sum(mask,1),2)>0);

end
