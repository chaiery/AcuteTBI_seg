function [brain_pos, annots, brain_neg, InstanceLis, NotAnnot] = BrainImage_pid(patient, dataset)
    % Dataset: TrauImg, Protected
    % Input: patient: patient id
    PosImgs = zeros([512,512,3,100]);
    NegImgs = [];
    InstanceLis = [];
    
    if strcmp(dataset,'Protected')
        ImgDir = ['/home/hemingy/Data/Data_', dataset, '/', num2str(patient) '/'];
        mode = 1;
        DcmDir = [ImgDir 'DICOM/'];
        
    elseif strcmp(dataset,'TrauImg')
        ImgDir = ['/home/hemingy/Data/Data_', dataset, '_Annotation/' num2str(patient) '/'];
        mode = 2;
        DcmDir = ['/home/hemingy/Data/Data_', dataset, '/' num2str(patient) '/'];
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
    [brain, startI, endI] = brain_extraction(DcmDir, DcmList);
    location = intersect(find(brain>0), find(brain<250));
    vec = brain(location);
    [count,~] = imhist(vec);
    [~, peak] = max(count);
    brain = uint8(double(brain) +80 - peak);
    
    NotAnnot = setdiff(startI:endI, InstanceLis); %return
    InstanceLis = intersect(startI:endI, InstanceLis);
    %NotAnnot = NotAnnot(randsample(length(NotAnnot), min(length(NotAnnot),5)));
    brain_neg = brain(:,:,NotAnnot); % return
        
    brain_pos = brain(:,:,InstanceLis);
    annots = zeros(512,512,3,length(InstanceLis));
    
    
    for i = 1 : length(InstanceLis)
        img_annot = PosImgs(:,:,:,InstanceLis(i));
        brain = brain_pos(:,:,i);
        [~, ~,annots(:,:,:,i)] = FindAnnotatedRegion(img_annot, brain,mode);
    end
    annots = uint8(annots);
    
end



