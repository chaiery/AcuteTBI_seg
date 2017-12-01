%% Data Preparation

%% Extract brain imags from each patient
%Patients_Protected = [43, 76, 80, 81, 88, 90, 94, 113, 122, 125, 183, 241, 244, 247, 250, 265, 269, 278, ...
%    280, 284, 297, 308, 320, 332, 380];
%Patients_TrauImg = [147, 149, 176, 177, 180, 190, 209, 212, 222,256, 264, 270, 271, 273, 282, 283, 289,  324, 366, 378, 380, 389, 390];

%PatientsData = [];
prefix = '/Users/apple/Documents';
path_proR = [prefix '/Project_Data/TBI/Data_Huge/Data_Protected_Red'];
path_proG = [prefix '/Project_Data/TBI/Data_Huge/Data_Protected_Green'];
path_Trau = [prefix '/Project_Data/TBI/Data_Huge/Data_TrauImg_Annotation'];
path_Trau_img = [prefix '/Project_Data/TBI/Data_Huge/Data_TrauImg'];
path_Neg = [prefix '/Project_Data/TBI/Data_Huge/Negative'];
path_Neg_P = [prefix '/Project_Data/TBI/Data_Huge/Negative_Protected'];

PatientsData = struct('brains', {}, 'rota_brains', {}, 'annots', {}, 'dicomImgs', {},...
    'meta', {}, 'intensity_mean', {}, 'Pid', {}, 'Datatype', {},  'masks', {});
    
Patients = dir(path_proR);
Patients = Patients(~strncmpi('.', {Patients.name},1));
index = 0;
for p = 1:length(Patients)
%for p = 1
    %%
    index = index + 1;
    pid = Patients(p).name
    DcmDir = [path_proR, '/', pid '/' 'DICOM/'];
    ImgDir = [path_proR, '/', pid '/'];
    pd = BrainImage_pid( 'Protected', DcmDir, ImgDir);
    pd.Pid = pid;
    pd.Datatype = 'Protected_Red';
    PatientsData(index) = pd;
    %%
end

Patients = dir(path_proG);
Patients = Patients(~strncmpi('.', {Patients.name},1));
for p = 1:length(Patients)
%for p = 1
    index = index + 1;
    pid = Patients(p).name
    DcmDir = [path_proG, '/', pid '/' 'DICOM/'];
    ImgDir = [path_proG, '/', pid '/'];
    pd = BrainImage_pid( 'Protected', DcmDir, ImgDir);
    pd.Pid = pid;
    pd.Datatype = 'Protected_Green';
    PatientsData(index) = pd;
end

%%

Patients = dir(path_Trau);
Patients = Patients(~strncmpi('.', {Patients.name},1));
for p = 1:length(Patients)
%for p = 1
    index = index + 1;
    pid = Patients(p).name
    DcmDir = [path_Trau_img, '/', pid '/'];
    ImgDir = [path_Trau, '/', pid '/'];
    pd = BrainImage_pid( 'TrauImg', DcmDir, ImgDir);
    pd.Pid = pid;
    pd.Datatype = 'TrauImg';
    PatientsData(index) = pd;
end

Patients = dir(path_Neg);
Patients = Patients(~strncmpi('.', {Patients.name},1));
for p = 1:length(Patients)
%for p = 1
    index = index + 1;
    pid = Patients(p).name
    DcmDir = [path_Neg, '/', pid '/'];
    ImgDir = '';
    pd = BrainImage_pid( 'Negative', DcmDir, ImgDir);
    pd.Pid = pid;
    pd.Datatype = 'Negative';
    PatientsData(index) = pd;
end

Patients = dir(path_Neg_P);
Patients = Patients(~strncmpi('.', {Patients.name},1));
for p = 1:length(Patients)
%for p = 1
    index = index + 1;
    pid = Patients(p).name
    DcmDir = [path_Neg_P, '/', pid '/DICOM/'];
    ImgDir = '';
    pd = BrainImage_pid( 'Protected', DcmDir, ImgDir);
    pd.Pid = pid;
    pd.Datatype = 'Negative_Protected';
    PatientsData(index) = pd;
end

%% Extracted Features for Every Slice for every Patient
%for p = 1:length(ModelData)
ModelFeatures = struct('annotated_slices', {}, 'annotated_features', {}, 'Pid', {}, 'Datatype', {}, 'mean_intensity', {});
%parfor p = 1:length(PatientsData)
%parfor p = 1:39
tic
parfor p = 1:length(PatientsData)
 %for p = 1
    p
    brains =  PatientsData(p).rota_brains;
    
    plist = brains(:);
    plist(plist==0) = [];
    intensity_mean = mean(plist);
      
    annots =  PatientsData(p).annots;
    
    %brain_pos = brain_pos(:,:,1);
    %annots = annots(:,:,:,1);
    [annotated_slices, annotated_features] = build_dataset(brains, annots, intensity_mean);
    
    ModelFeatures(p).annotated_slices = annotated_slices;
    ModelFeatures(p).annotated_features = annotated_features;
    ModelFeatures(p).Pid = PatientsData(p).Pid;
    ModelFeatures(p).Datatype = PatientsData(p).Datatype;
    ModelFeatures(p).mean_intensity = intensity_mean;
end
toc
save('ModelFeatures', 'ModelFeatures', '-v7.3')
