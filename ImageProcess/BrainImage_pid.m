function [pd] = BrainImage_pid(dataset, DcmDir, ImgDir)
    % Dataset: TrauImg, Protected
    % Input: patient: patient id
    %%
        
    if strcmp(dataset,'TrauImg')
        mode = 2;
    else
        mode = 1;
    end
    

    %%
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
      
    if strcmp(dataset,'Negative')
        series = DcmList(1).name(1:4);
        ind = [];
        for j = 1:length(DcmList) 
            name = DcmList(j).name;
            if strncmpi(name,series,4)
                ind = [ind j];
            end
        end
        DcmList = DcmList(ind);
    end
    
    
    [brains, dicomImgs, startI, endI, ~] = brain_extraction(DcmDir, DcmList);
    
   
    %%
    Annots = zeros([512,512,3,size(brains,3)]);
    masks = zeros([512,512,size(brains,3)]);
    ImgFiles = dir(ImgDir);
    ImgFiles = ImgFiles(~strncmpi('.', {ImgFiles.name},1));
    
    inxlist = [];
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
                    InstanceIdx = str2num(fname(end-7:end-4));
                    %PosImgs(count).InstanceIdx = InstanceIdx;
                    Annots(:,:,:,InstanceIdx) = img_annot;
                    inxlist = [inxlist, InstanceIdx];
                end
            end
        end
    end
    
    %%
    for i = 1 : length(inxlist)
        img_annot = Annots(:,:,:,inxlist(i));
        brain = brains(:,:,inxlist(i));
        if sum(img_annot(:))>0
            [~, ~, Annots(:,:,:,inxlist(i)), masks(:,:,inxlist(i))] = FindAnnotatedRegion(img_annot, brain, mode);
        end
    end
    
    %%
    
    Annots = uint8(Annots);
    
    temp = brains(:,:,startI:endI);
    [~, rotate_angle] =  rotate_method(temp);
    rota_brains = imrotate(brains, rotate_angle,'nearest','crop');
    annots = imrotate(Annots, rotate_angle,'nearest','crop');
    masks =  imrotate(masks, rotate_angle,'nearest','crop');
    %%%

    fname = DcmList(1).name;
    info= dicominfo([DcmDir, fname]);
        
    meta = [];
    meta.pixel_spacing = info.PixelSpacing;
    meta.dicom_inf = info;
    meta.rotate_angle = rotate_angle;
    meta.startI = startI;
    meta.endI = endI;

    pd = struct('brains', {}, 'rota_brains', {}, 'annots', {}, 'dicomImgs', {}, 'meta', {}, 'intensity_mean', {}, 'masks', {});
    pd(1).brains = brains;
    pd(1).rota_brains = rota_brains;
    pd(1).annots = annots;
    pd(1).meta = meta;
    pd(1).dicomImgs = dicomImgs;
    pd(1).masks = masks;
    plist = rota_brains(:);
    plist(plist==0) = [];
    intensity_mean = mean(plist);
    pd(1).intensity_mean = intensity_mean;
          
end

