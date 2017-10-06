load('PatientsData.mat')
load('param.mat')

subject_index = 5;

%%
pid_data = PatientsData(subject_index);
[brain, mask, dice, volume] = detectAcuteHematoma(pid_data, param);