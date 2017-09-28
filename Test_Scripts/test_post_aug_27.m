%%
for i = 25
    pos_brain = PatientsData(i).brain_pos;
    annots = PatientsData(i).annots;
    img1 = pos_brain(:,:,8);
    img2 = annots(:,:,:,8);
    figure;imshow(img1)
    figure;imshow(img2)
end

%%
for i = 9
    pred = result(i).pred_img_overlap;
    brain = result(i).brain;
    annot = result(i).annotated_img;

    figure;imshow(pred)
    figure;imshow(brain)
    figure;imshow(annot)
end

%%
pred = result(i).pred_img;
out = bwmorph(pred, 'bridge');
rp = imfill(double(out),'holes');

s = regionprops(logical(rp),'Area','PixelIdxList');

pred_new = zeros(size(pred));
for j = 1 : numel(s)
    mean_intensity = mean(brain(s(j).PixelIdxList));
    if s(j).Area>80 && mean_intensity<180
        pred_new(s(j).PixelIdxList)=1;
    end
end

%%
rp = imfill(double(brain),'holes');
rp(rp>0) = max(max(rp));

[rpb,~] = bwlabel(rp);
rpbox = regionprops(rpb,'BoundingBox','Centroid');


% rectangle('Position',rpbox(1).BoundingBox,'EdgeColor','r');
xl = rpbox(1).BoundingBox(1,1);
yl = rpbox(1).BoundingBox(1,2);
w = rpbox(1).BoundingBox(1,3);
h = rpbox(1).BoundingBox(1,4);

% centx = rpbox(1).Centroid(1,1);
% centy = rpbox(1).Centroid(1,2);

% cx = centx;
% cy = centy;

cx = xl+w/2;
cy = yl+h/8*7; %centroid position

% xl2 = cx-w/12;
% yl2 = cy-h/12;
% w2 = w/6;
% h2 = h/2+h/12;
xl2 = cx-w/12;
yl2 = cy - h/12;
w2 = w/6;
h2 = h/6+h/12;
%box2 = [xl2 yl2 w2 h2]; %ventricle box region

mask = brain;
mask(floor(yl2):ceil(yl2+h2), floor(xl2):ceil(xl2+w2)) = 0;


%%
index = [];
for i = 1:length(result)
    if isempty(result(i).dice)
        index = [index, i];
    end
end
%%
result(index) = [];

%% mean_dice
dice_list = [];
for i = 1:length(result)
    dice_list = [dice_list, result(i).dice];
end
mean(dice_list)
%%
dice_list = [];
for i = 1:length(compare)
    dice_list = [dice_list, compare(i).post_dice];
end

%%
pos = PatientsData(11).brain_pos;
img = pos(:,:,1);
figure;imshow(img)


%%
num_sp = 10000;
B = imresize(img,2);
[labels, ~] = superpixels(B,num_sp,'Compactness', 12);

BW = boundarymask(labels);
figure;imshow(imoverlay(B,BW,'cyan'),'InitialMagnification',67)
