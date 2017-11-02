i = 85;
brain = sel(i).brain;
annot = sel(i).annotated_img;
mask = sel(i).mask;

pred = compare(i).pred;
figure;imshow(brain)
figure;imshow(annot)
figure;imshow(mask)
figure;imshow(pred)
 