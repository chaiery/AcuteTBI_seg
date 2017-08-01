function [normalizedImg,bone,ind, EdgeBone] = normalization(fullImageDirRoot, imgList, startS, endS)
    % A list of files in the image directory 
    %imgList = dir(strcat(fullImageDirRoot, '*'));
    %imgList = imgList(~strncmpi('.', {imgList.name},1));
    bone=[]; 
    EdgeBone=[];
    normalizedImg=[];
    ind=[];
    fnamelis = [];
   
    for i= 1 : length(imgList)
        fname = imgList(i).name;
        inf= dicominfo([fullImageDirRoot, fname]);
        InstanceIdx = inf.InstanceNumber;
        fnamelis(InstanceIdx).fname = fname;
    end
    
    for i= startS : endS
        % Read input file information
        %inf= dicominfo([fullImageDirRoot,'\',imgList(i).name]);
        %if  strcmp (inf.SeriesDescription,'HEAD 5mm STND')
        % If the name of the file in the range
        fname = fnamelis(i).fname;
        inf= dicominfo([fullImageDirRoot, fname]);
        % Read input image
        rawImg=dicomread([fullImageDirRoot,imgList(i).name]);
        I = ContAdj(rawImg,inf);
        
        % Creating an 3D image of the normalized image
        normalizedImg=cat(3,normalizedImg,uint8(I));
        %if DEBUG % For visualization, this is the old method
        bonec=zeros(size(rawImg));
        bonec(I==255)=1;
        %end

        % ---- vvvv START skull segmentation vvvv ---------------------
%             [bone1, previous_bone_thres]= ...
%                 bone_segmentation(rawImg, 100, previous_bone_thres, DEBUG);
%             if DEBUG % For visualization
%                 %figure; imshow(IB, []);
%                 %imcontrast;
%                 fprintf('Using thres value %i\n', previous_bone_thres(1))
%                 imshowpair(bone1, bonec); 
%                 % the purple area shows pixels in the old 
%                 % bone mask but not in the new one
%                 pause(.01);
%             end
        % ---- ^^^^ END   skull segmentation ^^^^ ---------------------

        EdgeBone=cat(3,EdgeBone,edge(bonec));
        bone=cat(3,bone,bonec);
        % ind is an array of file names for each layer
        ind=[ind;imgList(i).name];

        % filledSkull=imfill(bone1,'holes');
        % hole=filledSkull-bone1; %for sure there's easier way to mask holes
        % CC = bwconncomp(hole);
        % numPixels = cellfun(@numel,CC.PixelIdxList);
        % [biggest,idx] = max(numPixels);
        % brain=zeros(size(hole));
        % brain(CC.PixelIdxList{idx})=1; %label the largest component as brain
        % azmoonBrain=cat(3,azmoonBrain,brain);
        % brainArea=[brainArea,sum(brain(:))];
     end

     % c: CC = connected components
     CC = bwconncomp(bone);
     numPixels = cellfun(@numel,CC.PixelIdxList);
     [biggest,idx] = max(numPixels);
     bone=zeros(size(bone));
     bone(CC.PixelIdxList{idx})=1;
     ind=cellstr(ind);
     
end