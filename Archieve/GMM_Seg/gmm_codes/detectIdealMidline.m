function [] = detectIdealMidline(inputDir, outputDir)


imgList = dir(strcat(fullImageDirRoot, '/', '*.jpg'));

lenList = length(imgList);
% imgNames = zeros(lenList,1);

selectedImageList = cell(4);

for i = 1:length(selectedImageList)
    selectedImageList{i} =  imgList(lenList-i).name;
end



end
