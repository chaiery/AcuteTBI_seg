function [normalizedImg,bone,ind, EdgeBone] = normalization_for_gmm(fullImageDirRoot, imgList, startS, endS)
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
        I = ContAdj_for_gmm(rawImg,inf);
        
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


function [contrastAdjustedImage, range]= ContAdj_for_gmm(Img, ImInfo)
Img = Img(:, :, 1);

y_min = 0;
y_max = 255;

im_adust = Img;
if (isfield(ImInfo, 'RescaleIntercept') && isfield(ImInfo, 'RescaleSlope') &&...
         isfield(ImInfo, 'WindowCenter') && isfield(ImInfo, 'RescaleIntercept'))
     if (isnumeric(ImInfo.RescaleIntercept) && isnumeric(ImInfo.RescaleSlope) &&...
         isnumeric(ImInfo.WindowCenter) && isnumeric(ImInfo.RescaleIntercept))
         im_adust = ImInfo.RescaleSlope * im_adust + ImInfo.RescaleIntercept;
         win_width = ImInfo.WindowWidth(1);
         win_center = ImInfo.WindowCenter(1);
     end
end
% D = 1;
% if(size(win_width, 1) > 1)
%     D = 2;
% end
% win_width = win_width(D,1);
% win_center =win_center(D,1);

win_min = (win_center-win_width/2);
win_max = (win_center+win_width/2);

win_width = win_width;
oldRange = win_max - win_min;

range = [win_min win_max];

y_min=0;
y_max=min(3300,max(Img(:)));

newRange=y_max-y_min;
contrastAdjustedImage = round(double(im_adust - win_min)*(double(y_max-y_min) / double(win_width)) + y_min);
contrastAdjustedImage(im_adust < win_min) = y_min;
contrastAdjustedImage(im_adust > win_max) = y_max;
contrastAdjustedImage = double(contrastAdjustedImage)/(double(y_max));
contrastAdjustedImage = uint8(contrastAdjustedImage*255);
end