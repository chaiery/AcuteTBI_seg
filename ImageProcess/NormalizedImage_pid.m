function [normalizedImg] = NormalizedImage_pid(patient, InstanceLis, dataset)
    % Dataset: TrauImg, Protected
    % Input: patient: patient id
    %%
    PosImgs = zeros([512,512,3,100]);
    NegImgs = [];
    
    if strcmp(dataset,'Protected')
        %ImgDir = ['/Volumes/hemingy/Data/Data_', dataset, '/', num2str(patient) '/'];
        ImgDir = ['/home/hemingy/Data/Data_', dataset, '/', num2str(patient) '/'];
        mode = 1;
        DcmDir = [ImgDir 'DICOM/'];
        
    elseif strcmp(dataset,'TrauImg')
        ImgDir = ['/home/hemingy/Data/Data_', dataset, '_Annotation/' num2str(patient) '/'];
        mode = 2;
        DcmDir = ['/home/hemingy/Data/Data_', dataset, '/' num2str(patient) '/'];
    end

 
    %[normalizedImg,bone,ind] = normalization(DcmDir, InstanceLis); 
    DcmList = dir(strcat(DcmDir, '*'));
    DcmList = DcmList(~strncmpi('.', {DcmList.name},1));
    
    ImgNew = [];
    
    for i= 1 : length(DcmList)
        fname = DcmList(i).name;
        if ~((strcmp(fname(end-2:end),'tif'))||(strcmp(fname(end-1:end),'db')))
            ImgNew = [ImgNew DcmList(i)];
        end
    end
    
    DcmList = ImgNew;
    
    %%
    [normalizedImg,~,~,~] = normalization_for_gmm(DcmDir, DcmList, 1, length(DcmList));
    
    normalizedImg = normalizedImg(:,:,InstanceLis);
end

