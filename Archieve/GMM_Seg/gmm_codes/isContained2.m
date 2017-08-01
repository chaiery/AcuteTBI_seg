function yesno = isContained2(part_pix, box2)
yesno = 0;
total = size(part_pix,1);
mask = zeros(total,1);
mask(find(((part_pix(:,1)>=box2(1)).*(part_pix(:,1)<=box2(1)+box2(3))).*((part_pix(:,2)>=box2(2)).*(part_pix(:,2)<=box2(2)+box2(4))))) = 1;

if sum(mask)/total>2/3
yesno = 1;
end
end
