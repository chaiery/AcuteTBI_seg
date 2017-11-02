function [brain, result, volume] = detectHema(pid_data, param)
%%
feature_index = param.feature_index;
means = param.mean;
stds = param.std;
model_SVM = param.model;

brain = pid_data.brains;
%%
[result,volume] = evaluate_headSMART(pid_data,  feature_index, means, stds, model_SVM);

end
