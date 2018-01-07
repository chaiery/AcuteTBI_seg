function [SizeNormScale,brainMask]= SizeNormalization(bone)

brainMask=zeros(512,512);

sliceNum=1;
maxArea=0;
maxBrain=zeros(512,512);
for i= 1: size(bone,3)
    filledSkull=imfill(bone(:,:,i),'holes');
    hole=filledSkull-bone(:,:,i); %for sure there's easier way to mask holes
    CC = bwconncomp(hole);
    numPixels = cellfun(@numel,CC.PixelIdxList);
    [biggest,idx] = max(numPixels);
    brain=zeros(size(hole));
    brain(CC.PixelIdxList{idx})=1; %label the largest component as brain
    brainMask= (brainMask | brain);
    if sum(brain(:))> maxArea
        maxArea=sum(brain(:));
        sliceNum=i;
        maxBrain=brain;
    end
end

stats = regionprops(maxBrain,'MajorAxisLength','MinorAxisLength');
SizeNormScale= (stats.MajorAxisLength+stats.MinorAxisLength)/2


