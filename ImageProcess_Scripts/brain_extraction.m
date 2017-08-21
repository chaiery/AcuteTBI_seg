function [brain, startI, endI] = brain_extraction(DcmDir, DcmList)

%%
    % Input: patient: patient id
%     DcmDir = ['/Users/apple/Developer/ForAnnotation/' num2str(patient) '/' 'DICOM/'];
%     DcmList = dir(strcat(DcmDir, '*'));
%     DcmList = DcmList(~strncmpi('.', {DcmList.name},1));
%     
%     ImgNew = [];
%     
%     for i= 1 : length(DcmList)
%         fname = DcmList(i).name;
%         if ~((strcmp(fname(end-2:end),'tif'))||(strcmp(fname(end-1:end),'db')))
%             ImgNew = [ImgNew DcmList(i)];
%         end
%     end
%     
%     DcmList = ImgNew;
    
    [adjustImg, normalizedImg,bone,~,~] = normalization(DcmDir, DcmList, 1, length(DcmList));
   
    brain = zeros([512, 512, length(DcmList)]);
    
    %%
    for k = 10 : length(DcmList)-3
        if sum(sum(bone(:,:,k))) ~= 0
            center_row = int16(sum(bone(:,:,k),2)'*(1:512)'/sum(sum(bone(:,:,k))));
            center_col = int16(sum(bone(:,:,k),1)*(1:512)'/sum(sum(bone(:,:,k))));
            L = bwlabel(~bone(:,:,k));
            tissue = normalizedImg(:,:,k);
            
            if (center_row > 0 && center_col >0) %TODO need a better way
                if (L(center_row,center_col) == L(1))% || counter < 4 %connected
                    brain(:,:,k) = drlse_demo(bone(:,:,k),tissue);
                    temp = brain(:,:,k);
                    % To keep the largest component
                    if sum(temp(:)>0)
                        CC = bwconncomp(temp,4);
                        numPixels = cellfun(@numel,CC.PixelIdxList);
                        [biggest,idx] = max(numPixels);
                        temp=zeros(size(brain(:,:,k)));
                        temp(CC.PixelIdxList{idx}) = tissue(CC.PixelIdxList{idx});
                    end
                    brain(:,:,k) = temp;
                else % not connected
                    brain(:,:,k) = xor(bone(:,:,k), imfill(logical(bone(:,:,k)), ...
                        [double(center_row), double(center_col)]));
                    if ~sum(sum(brain(:,:,k)))
                        brain(:,:,k) = xor(bone(:,:,k), imfill(logical(bone(:,:,k)), ...
                            [double(center_row+5), double(center_col+5)]));
                    end
                    temp = brain(:,:,k);
                    if sum(temp(:))>0
                    % To keep the largest component
                        CC = bwconncomp(temp,4);    
                        numPixels = cellfun(@numel,CC.PixelIdxList);
                        [biggest,idx] = max(numPixels);
                        temp=zeros(size(brain(:,:,k)));
                        temp(CC.PixelIdxList{idx}) = tissue(CC.PixelIdxList{idx});
                    end
                    brain(:,:,k)=temp;
                end
            end
        end
    end
    %%
    brain = uint8(brain);
    
    for k = 1:size(brain,3)
        mask = brain(:,:,k);
        out = adjustImg(:,:,k);
        out(mask==0) = 0;
        brain(:,:,k) = out;
    end
    
    startI = 0;
    endI = length(DcmList);
    for k = 1:length(DcmList)
        img = brain(:,:,k);
        if sum(img(:))>0
            endI = k;
        elseif (sum(img(:))==0)&&(k<endI)
            startI = k;
        end
    end
    startI = startI + 1;
%%
end
