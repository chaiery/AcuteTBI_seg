%% Gradient

idx = [16, 33, 37];
%%
for i = 16
    annotated = result(i).annotated_img;
    brain = result(i).brain;
    pred_img = result(i).pred_img_overlap;
    pred_pos = compare(i).pred;
    figure;imshow(brain)
    figure;imshow(annotated)
    figure;imshow(pred_img)
    figure;imshow(pred_pos)
end

%%
brain = result(16).brain;
figure;imshow(brain)

%%
imgori = brain;
mask = find(imgori==imgori(1));
imgori(mask) = 0;

imgori = pad_brain(imgori, 0.1);
imgori = imguidedfilter(imgori);
brain = imgori;
%%
[Gmag, Gdir] = imgradient(brain,'prewitt');

figure, imshow(Gmag, []), title('Gradient magnitude')
figure, imshow(Gdir, []), title('Gradient direction')
