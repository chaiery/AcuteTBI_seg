function [rota_img, rota_seg, rtv, xy1_bump, xy1_linept] = test_ideal_midline(inputFile, outputFile)

A = imread(inputFile);
% % N: start
% rev=isCrashed(A,250);
% if(rev==1)
%    A=closeFracture(A); 
%    rev=0;
% end
% % N: end
B = ct_brain_mask(A(:,:,1));
[rota_img, rota_seg, rtv, xy1_bump, xy1_linept]=find_midline(A);
%[rota_img, rota_seg, rtv, xy1_bump, xy1_linept]=find_midline_N(A);
%figure; imshow(uint8(rota_img)); title('ideal midline detection');
if(~isempty(rota_img))
    imwrite(uint8(rota_img), outputFile); 
end