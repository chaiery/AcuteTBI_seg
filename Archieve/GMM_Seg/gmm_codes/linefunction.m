function f = linefunction(finalimg, img)

white = double(img)>0;
white  = bwmorph(white,'close');
white  = bwmorph(white,'fill');
white  = bwmorph(white,'remove');

hb = finalimg.*white;
hb= hb>0;

[bpy,bpx] = find(hb);
num = length(bpx);

for i = 1:num
finalimg = remove_edge(bpx(i),bpy(i),finalimg);   
end

f = finalimg;
% figure, imshow(finalimg);

end