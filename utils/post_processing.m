function out=post_processing(brain, pred)

brain(brain==brain(1)) = 0;
brain = pad_brain(brain, 0.1);
%%
% conimg = brain;
% %conimg(conimg<50) = 0;
% conimg = uint8(double(conimg)/200*255);
%%
img = medfilt2(brain);
ismooth = imguidedfilter(img);

BW= edge(ismooth/(max(ismooth(:))+50),'Canny');
%BW= edge(ismooth/(max(ismooth(:))),'Canny');

BW2 = bwmorph(BW, 'bridge');
BW3 = imfill(BW2,'holes');

s = regionprops(BW3,'Area','PixelIdxList');

mask = zeros(size(brain));
for i = 1 : numel(s)
    if s(i).Area>100 
        mask(s(i).PixelIdxList)=1;
    end
end

se = strel('disk',2);
mask = imdilate(mask,se);
%%
brain_label = logical(brain);
brain_label = imfill(brain_label,'holes');
roi_temp = xor(brain, imerode(logical(brain_label ), strel('disk', 35))); 
roi_temp = ~logical(roi_temp);
roi_1 = roi_temp .* logical(brain);

%%
roi_temp = zeros(size(brain));
roi_temp(brain>240) = 1;
se = strel('disk',20);
roi_temp = imdilate(roi_temp,se);
roi_2 = ~logical(roi_temp);

%%
mask = or(mask, roi_1);
mask = mask.*roi_2;
%%
out = mask.*pred;
%figure;imshow(out)

end

%% when build predicted images, remove mean intensity higher than 230?
