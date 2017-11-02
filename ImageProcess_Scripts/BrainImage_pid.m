function [brain_pos, annots, brain_neg, InstanceLis, NotAnnot] = BrainImage_pid(patient, dataset)
    % Dataset: TrauImg, Protected
    % Input: patient: patient id
    %%
    PosImgs = zeros([512,512,3,100]);
    InstanceLis = [];
    
    if strcmp(dataset,'Protected')
        %/media/hemingy/781E90171E8FCD16/Data/Data_Huge
        ImgDir = ['/media/hemingy/781E90171E8FCD16/Data/Data_Huge/Data_', dataset, '/', num2str(patient) '/'];
        %ImgDir = ['/Volumes/hemingy/Data_Huge/Data_', dataset, '/', num2str(patient) '/'];
        mode = 1;
        DcmDir = [ImgDir 'DICOM/'];
        
    elseif strcmp(dataset,'TrauImg')
        ImgDir = ['/media/hemingy/781E90171E8FCD16/Data/Data_Huge/Data_', dataset, '_Annotation/' num2str(patient) '/'];
        %ImgDir = ['/Volumes/hemingy/Data_Huge/Data_', dataset, '_Annotation/' num2str(patient) '/'];
        mode = 2;
        DcmDir = ['/media/hemingy/781E90171E8FCD16/Data/Data_Huge/Data_', dataset, '/' num2str(patient) '/'];
        %DcmDir = ['/Volumes/hemingy/Data_Huge/Data_', dataset, '/' num2str(patient) '/'];
    end
    
    ImgFiles = dir(ImgDir);
    ImgFiles = ImgFiles(~strncmpi('.', {ImgFiles.name},1));
    
    count = 0;
    for fidx = 1:length(ImgFiles)
        fname = ImgFiles(fidx).name;
        if length(fname)>8
            if strcmp(fname(end-2:end),'tif')||strcmp(fname(end-3:end),'tiff')
                X = imread([ImgDir fname]);
                R = X(:,:,1);
                G = X(:,:,2);
                B = X(:,:,3);

                img_annot = cat(3,R,G,B);
                
                if annotation_exist(img_annot, mode)
                    count = count+1;
                    InstanceIdx = str2num(fname(end-7:end-4));
                    %PosImgs(count).InstanceIdx = InstanceIdx;
                    InstanceLis(end+1) = InstanceIdx;
                    PosImgs(:,:,:,InstanceIdx) = img_annot;
                end
            end
        end
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
    
    %[normalizedImg,bone,~,~] = normalization(DcmDir, DcmList, 1, length(DcmList));
    [brain, startI, endI, ~] = brain_extraction(DcmDir, DcmList);
    %location = intersect(find(brain>0), find(brain<250));
    %vec = brain(location);
    %[count,~] = imhist(vec);
    %[~, peak] = max(count);
    %brain = uint8(double(brain) +80 - peak);
    
    NotAnnot = setdiff(startI:endI, InstanceLis); %return
    InstanceLis = intersect(startI:endI, InstanceLis);

    brain_neg = brain(:,:,NotAnnot); % return
    brain_pos = brain(:,:,InstanceLis);
    
    % Remove slices which have no brain segmented (all zeros)
    idx = ~arrayfun(@(x) isempty(brain_neg(:,:,x)),1:size(brain_neg,3));
    brain_neg = brain_neg(:,:,idx);
    NotAnnot = NotAnnot(idx);
    
    idx = ~arrayfun(@(x) isempty(brain_pos(:,:,x)),1:size(brain_pos,3));
    brain_pos = brain_pos(:,:,idx);
    InstanceLis = InstanceLis(idx);
    
    
    %%
    annots = zeros(512,512,3,length(InstanceLis));
    idx = [];
    for i = 1 : length(InstanceLis)
        img_annot = PosImgs(:,:,:,InstanceLis(i));
        brain = brain_pos(:,:,i);
        [~, ap, annots(:,:,:,i)] = FindAnnotatedRegion(img_annot, brain,mode);
        if isempty(ap)
            idx = [idx, i];
        end
    end
    
    if ~isempty(idx)
        temp = brain_pos(:,:,idx);
        temp_index = InstanceLis(idx);
        brain_pos(:,:,idx) = [];
        annots(:,:,:,idx) = [];
        InstanceLis(idx) = [];
        brain_neg = cat(3,brain_neg, temp);
        NotAnnot = [NotAnnot, temp_index];
    end
    
    annots = uint8(annots);
    
    temp = cat(3, brain_pos, brain_neg);
    [~, rotate_angle] =  rotate_method(temp);
    rota_brains = imrotate(temp, rotate_angle,'nearest','crop');
    annots = imrotate(annots,rotate_angle,'nearest','crop');
    rotate_angle
    if ~isempty(InstanceLis)
        brain_pos = rota_brains(:,:,1:length(InstanceLis));
    end
    if ~isempty(NotAnnot)
        brain_neg = rota_brains(:,:,length(InstanceLis)+1:size(rota_brains,3));
    end
    
    
end

