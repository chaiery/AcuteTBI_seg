function [PixelSpacing, output] = ExtractOriginalImgs(patient, dataset, index)
    % Dataset: TrauImg, Protected
    % Input: patient: patient id
    %%
    if strcmp(dataset,'Protected')
        %/media/hemingy/781E90171E8FCD16/Data/Data_Huge
        ImgDir = ['/Volumes/hemingy/Project_Data/TBI/Data_Huge/Data_', dataset, '/', num2str(patient) '/'];
        DcmDir = [ImgDir 'DICOM/'];
        
    elseif strcmp(dataset,'TrauImg')
        DcmDir = ['/Volumes/hemingy/Project_Data/TBI/Data_Huge/Data_', dataset, '/' num2str(patient) '/'];
        %DcmDir = ['/Volumes/hemingy/Data_Huge/Data_', dataset, '/' num2str(patient) '/'];
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
    
    DcmImgs =  zeros([512,512,length(DcmList)]);
    dcminfo = dicominfo([DcmDir,DcmList(1).name]);
    PixelSpacing = dcminfo.PixelSpacing;
    
    for i = 1:length(DcmList)
        DcmImgs(:,:,i)=dicomread([DcmDir,DcmList(i).name]);
    end
    output = DcmImgs(:,:,index);
end

