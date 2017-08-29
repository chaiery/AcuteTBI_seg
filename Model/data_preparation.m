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

%% Select random slices from patients
for p = 1:length(PatientsData)
    p
    brains = PatientsData(p).brain_pos;
    %mask = PatientsData(p).mask;
    annotations = PatientsData(p).annots;
    idx_list = [];
    for idx=1:size(brains,3)
        index_list = find_annotated_pixelList(annotations(:,:,:,idx), brains(:,:,idx));
        if length(index_list)>100
            idx_list = [idx_list idx];
        end
    end
    
    if length(idx_list)>4
        brains = brains(:,:,idx_list);
        annotations = annotations(:,:,:,idx_list);
        sel =randsample(size(brains, 3),4);
        brains = brains(:,:,sel);
        annotations = annotations(:,:,:,sel);
        ModelData(p).sel = idx_list(sel);
    elseif isempty(idx_list)
        brains = brains(:,:,idx_list);
        annotations = annotations(:,:,:,idx_list);
        ModelData(p).sel = idx_list;
    else
        brains = [];
        annotations = [];
        ModelData(p).sel = [];
    end
    
    
%     if ~isempty(brains)
%         [rota_brains, rotate_angle] =  rotate_method(brains);
%         rota_annots = imrotate(annotations,rotate_angle,'nearest','crop');
%     else
%         rota_brains = [];
%         rota_annots = [];
%     end
    
    ModelData(p).Pid = PatientsData(p).Pid;
    ModelData(p).Datatype = PatientsData(p).Datatype;
    ModelData(p).brains = brains;
    ModelData(p).annots = annotations;
    ModelData(p).rota_brains =  rota_brains;
    ModelData(p).rota_annots = rota_annots;
end

%%
idx_list = [];
for i = 1:length(ModelData)
    if isempty(ModelData(i).brains)
        idx_list = [idx_list, i];
    end
end

ModelData(idx_list) = [];

%% Extracted Features for Each Slice
%% Build Positive Dataset and Negative Dataset for each patient
for p = 1:length(ModelData)
%for p = 1
    p
    rota_brains =  ModelData(p).rota_brains;
    rota_annots =  ModelData(p).rota_annots;
    
    [~, ~, annotated_slices] = build_dataset(rota_brains, rota_brains, rota_annots);
    
%     idx_list = [];
%     for i = 1:length(annotated_slices)
%         if isempty(annotated_slices(i).struct_1)
%             idx_list = [idx_list, i];
%         end
%     end
    
    sel = ModelData(p).sel;
%     annotated_slices(idx_list) = [];
%     sel(idx_list) = [];
    
    ModelFeatures(p).annotated_slices = annotated_slices;
    ModelFeatures(p).Pid = ModelData(p).Pid;
    ModelFeatures(p).Datatype = ModelData(p).Datatype;
    ModelFeatures(p).sel  = sel;
end

%% Extracted Features for Every Slice for ProTECT Patients
%% Build Positive Dataset and Negative Dataset for each patient
%for p = 1:length(ModelData)
ModelFeatures = [];
%for p = 1:length(PatientsData_TrauImg)
for p = 18
    p
    brains =  PatientsData(p).brain_pos;
    annots =  PatientsData(p).annots;
    
    [~, ~, annotated_slices] = build_dataset(brains, brains, annots);
    
    ModelFeatures(p).annotated_slices = annotated_slices;
    ModelFeatures(p).Pid = PatientsData(p).Pid;
    ModelFeatures(p).Datatype = PatientsData(p).Datatype;
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
