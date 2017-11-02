load('PatientsData.mat') % This contain 10 patients. The loading will take some time
load('Demo_params.mat')


%%
[brain, mask, dice, volume, pos_index] = detectAcuteHematoma(pid_data, param);
