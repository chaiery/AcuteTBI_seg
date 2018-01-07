function [normalizedImg,bone,ind] = normalization(fullImageDirRoot,startS,endS)
 imgList = dir(strcat(fullImageDirRoot, '/', '*'));
 bone=[];
 normalizedImg=[];
 ind=[];
%  azmoonBrain=[];
%  brainArea=[];
 
 for i= 3: length(imgList)-1
     inf= dicominfo([fullImageDirRoot,'\',imgList(i).name]);
     %if  strcmp (inf.SeriesDescription,'HEAD 5mm STND')
     if  MyStrCmp(imgList(i).name,startS) ~= -1 & ... 
             MyStrCmp(endS,imgList(i).name) ~= -1
         rawImg=dicomread([fullImageDirRoot,'\',imgList(i).name]);
         rawImg=uint16(rawImg);
         I = ContAdj(rawImg,30,80);
         selected=I(I>1500);
         boneIntensity=mode(selected);
         normalizedImg=cat(3,normalizedImg,round(I*2500/double(boneIntensity)));
         bone1=zeros(size(rawImg));
         bone1(round(I*2500/double(boneIntensity))==2500)=1;
         bone=cat(3,bone,bone1);
         ind=[ind;imgList(i).name];
         
%          filledSkull=imfill(bone1,'holes');
%          hole=filledSkull-bone1; %for sure there's easier way to mask holes
%          CC = bwconncomp(hole);
%          numPixels = cellfun(@numel,CC.PixelIdxList);
%          [biggest,idx] = max(numPixels);
%          brain=zeros(size(hole));
%          brain(CC.PixelIdxList{idx})=1; %label the largest component as brain
%          azmoonBrain=cat(3,azmoonBrain,brain);
%          brainArea=[brainArea,sum(brain(:))];
     end
 end
 CC = bwconncomp(bone);
 numPixels = cellfun(@numel,CC.PixelIdxList);
 [biggest,idx] = max(numPixels);
 bone=zeros(size(bone));
 bone(CC.PixelIdxList{idx})=1;
 ind=cellstr(ind);
end