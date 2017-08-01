% need to update this later using the identified midline 

function pidx = isContained3(part_pix, box2)
    yesno = 0;
    total = size(part_pix,1);
    mask = zeros(total,1);
    pidx = find(((part_pix(:,1)>=box2(1)).*(part_pix(:,1)<=box2(1)+box2(3))).*((part_pix(:,2)>=box2(2)).*(part_pix(:,2)<=box2(2)+box2(4))));
end