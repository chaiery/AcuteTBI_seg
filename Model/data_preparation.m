%% Data Preparation

%% Extract brain imags from each patient
Patients_Protected = [43, 76, 80, 81, 88, 90, 94, 113, 122, 125, 183, 241, 244, 247, 250, 265, 269, 278, ...
    280, 284, 297, 308, 320, 332, 380];
Patients_TrauImg = [147, 149, 176, 177, 180, 190, 209, 212, 222,256, 264, 270, 271, 273, 282, 283, 289,  324, 366, 378, 380, 389, 390];

%PatientsData = [];
Patients = Patients_Protected;
for p = 1:length(Patients)
    p
    [PatientsData(p).brain_pos,  PatientsData(p).annots, PatientsData(p).brain_neg, ...
        PatientsData(p).pos_idx, PatientsData(p).neg_idx] = BrainImage_pid(Patients(p), 'Protected');
    PatientsData(p).Pid = Patients(p);
    PatientsData(p).Datatype = 'Protected';
end

PatientsData_Protected = PatientsData;
PatientsData = [];
Patients = Patients_TrauImg;
for p = 3:length(Patients)
    p
    [PatientsData(p).brain_pos,  PatientsData(p).annots, PatientsData(p).brain_neg, ...
        PatientsData(p).pos_idx, PatientsData(p).neg_idx] = BrainImage_pid(Patients(p), 'TrauImg');
    PatientsData(p).Pid = Patients(p);
     PatientsData(p).Datatype = 'TrauImg';
end

PatientsData_TrauImg = PatientsData;

PatientsData = [PatiensData_Protected, PatientsData_TrauImg];

%%
idx_list = [];
for i = 1:length(ModelData)
    if isempty(ModelData(i).brains)
        idx_list = [idx_list, i];
    end
end

ModelData(idx_list) = [];

%% Extracted Features for Every Slice for ProTECT Patients
%% Build Positive Dataset and Negative Dataset for each patient
%for p = 1:length(ModelData)
ModelFeatures = struct('annotated_slices', {}, 'annotated_features', {}, 'Pid', {}, 'Datatype', {}, 'mean_intensity', {});
for p = 1:length(PatientsData)
%for p = 1
    p
    brain_pos =  PatientsData(p).brain_pos;
    brain_neg = PatientsData(p).brain_neg;
    
    brains = cat(3, PatientsData(p).brain_pos, PatientsData(p).brain_neg);
    plist = brains(:);
    plist(plist==0) = [];
    intensity_mean = mean(plist);
    
    annots =  PatientsData(p).annots;
    
    %brain_pos = brain_pos(:,:,1);
    %annots = annots(:,:,:,1);
    [annotated_slices, annotated_features] = build_dataset(brain_pos, annots, intensity_mean);
    
    ModelFeatures(p).annotated_slices = annotated_slices;
    ModelFeatures(p).annotated_features = annotated_features;
    ModelFeatures(p).Pid = PatientsData(p).Pid;
    ModelFeatures(p).Datatype = PatientsData(p).Datatype;
    ModelFeatures(p).mean_intensity = intensity_mean;
end

%% GMM output
%for i = 1:length(ModelData)
GMM_output = [];
for i = 1:length(PatientsData_Protected)
    BrainImgs = ModelData(i).rota_brains;
    GMM_output(i).brains = BrainImgs;
    GMM_output(i).output = GMM_detection(BrainImgs, false);
    GMM_output(i).annotation = ModelData(i).rota_annots;
end

GMM_output = evaluate_GMM_output(GMM_output);
