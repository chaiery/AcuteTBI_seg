function [PatientsData] = BrainImage_headSMART(path)
    % For test: path = '/home/hemingy/Developer/HeadSMART' 
    PatientsData = struct('brains', {}, 'rota_brains', {}, 'meta', {}, 'intensity_mean', {});
    %%
    patients = dir(path);
    patients = patients(~strncmpi('.', {patients.name},1));
    
    for i = 1:length(patients)
        DcmDir = [patients(1).folder '/' patients(1).name '/'];
        DcmList = dir(DcmDir);
        DcmList = DcmList(~strncmpi('.', {DcmList.name},1));
        
        fname = DcmList(1).name;
        inf= dicominfo([DcmDir, fname]);
        
        meta = [];
        meta.pixel_spacing = inf.PixelSpacing;
        [brains, meta.startI, meta.endI, meta.fnamelis] = brain_extraction(DcmDir, DcmList);

        [~,meta.rotate_angle] =  rotate_method(brains);
        rota_brains = imrotate(brains,meta.rotate_angle,'nearest','crop');
        PatientsData(i).brains = brains;
        PatientsData(i).rota_brains = rota_brains;
        PatientsData(i).meta = meta;
        
        plist = rota_brains(:);
        plist(plist==0) = [];
        intensity_mean = mean(plist);
        PatientsData(i).intensity_mean = intensity_mean;
    end
end
