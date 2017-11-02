%%
Img = dicomread('/Volumes/hemingy/Data/Data_TrauImg/155/IMG-0003-00016.dcm');
info = dicominfo('/Volumes/hemingy/Data/Data_TrauImg/155/IMG-0003-00016.dcm');
Img = info.RescaleSlope * Img + info.RescaleIntercept;

im_adust = Img;
win_min = 0;
win_max = 160;

contrastAdjustedImage = im_adust;
contrastAdjustedImage(im_adust < win_min) = win_min;
contrastAdjustedImage(im_adust > win_max) = win_max;
contrastAdjustedImage = double(contrastAdjustedImage-win_min)*255/(win_max-win_min);
contrastAdjustedImage = uint8(contrastAdjustedImage);

imtool(contrastAdjustedImage)


%%
Img_76 = dicomread('/Volumes/hemingy/Data/Data_Protected/80/DICOM/IMG-0001-00076.dcm');

info = dicominfo('/Volumes/hemingy/Data/Data_Protected/80/DICOM/IMG-0001-00023.dcm');


adjust = double(Img)+info.RescaleIntercept;
figure;imshow(uint8(adjust))

%%
figure;imshow(brain(:,:,15))
figure;imshow(rota_brains(:,:,15))

%%
[pixelList, index, img] =  FindAnnotatedRegion(img_annot, brain,mode);
test = zeros(size(brain));
test(index) = 1;

labels =bwlabel(test);

out = zeros(size(brain));
for idx = 1:length(unique(labels(:)))
    bg = zeros(size(brain));
    bg(labels==idx)=1;
    se = strel('disk',5);
    rem= imerode(bg ,se);
    if ~isempty(find(rem==1))
        out(labels==idx) = 1;
    end
end

%%
brain_pos = PatientsData(p).brain_pos;
annots = PatientsData(p).annots;

i = 8;
img_1 = brain_pos(:,:,i);
img_2 = annots(:,:,:,i);
figure;imshow(img_1)
figure;imshow(img_2)
