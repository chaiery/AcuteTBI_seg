ImgDir = '/Users/apple/Dropbox/TBI/al_test';
SaveDir = '/Users/apple/Dropbox/TBI/GMM_output/';
ImgFiles = dir(ImgDir);
ImgFiles = ImgFiles(~strncmpi('.', {ImgFiles.name}, 1));
for i = 1:length(ImgFiles)
   fname = ImgFiles(i).name;
   img = imread([ImgDir,'/', fname]);
   [img_out,~] = detectHematoma(img,1);
   SaveFileName = [SaveDir, 'GMM', fname];
   imwrite(img_out, SaveFileName);
end  