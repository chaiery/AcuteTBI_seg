path = '/home/hemingy/Developer/HeadSMART';
PatientsData =  BrainImage_headSMART(path);
PatientFeatures =  build_dataset_headSMART(PatientsData);


%%
i=1;
load('Demo_params.mat');
pid_data = PatientFeatures(i);
[result, volume] = detectAcuteHematoma(pid_data, param);

%%