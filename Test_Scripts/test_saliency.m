%%
imgs = PatientsData(6).brain_pos;
annots = PatientsData(6).annots;

index = 5;
brain = imgs(:,:,index);
annot = annots(:,:,:,index);
figure;imshow(brain)
figure;imshow(annot)

%%
img_pad = pad_brain(brain, 0.1);


%%
sel_index = [97];
%%
index = 220; 
brain = result(index).brain;
annot = result(index).annotated_img;
pred = result(index).pred_img_overlap;

figure;imshow(annot)
figure;imshow(pred)

%img_pad = pad_brain(brain, 0.1);
img_pad = pad_brain(brain, 0.01);
img_pad = imguidedfilter(img_pad);
out = saliency_map(img_pad);
out(brain==0) = 0;
figure;imshow(out)


%%
img_pad = pad_brain(brain, 0.01);
%img_med = imguidedfilter(img_pad);
%img_med2 = medfilt2(img_pad);
img_med = img_pad;

[Gx, Gy] = imgradientxy(img_med,'sobel');
Gx(brain==0)=0;
Gy(brain==0)=0;
down = prctile( Gx(:) , 1 );
up = prctile( Gx(:) , 99 );
Gx(Gx<down) = down;
Gx(Gx>up) = up;
Gx = (double(Gx) - down)/(up-down);

down = prctile( Gy(:) , 1 );
up = prctile( Gy(:) , 99 );
Gy(Gy<down) = down;
Gy(Gy>up) = up;
Gy = (double(Gy) - down)/(up-down);

imshowpair(Gx, Gy, 'montage');

