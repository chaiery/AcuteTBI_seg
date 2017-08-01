function yesno = isContained(box1, box2)
    yesno = 1;
    if (max(box1(1,1),box2(1,1)) < min(box1(1,1)+box1(1,3),box2(1,1)+box2(1,3))) && (max(box1(1,2),box2(1,2)) < min(box1(1,2)+box1(1,4),box2(1,2)+box2(1,4)))
        overlaparea = (min(box1(1,1)+box1(1,3),box2(1,1)+box2(1,3))-max(box1(1,1),box2(1,1)))*(min(box1(1,2)+box1(1,4),box2(1,2)+box2(1,4))-max(box1(1,2),box2(1,2)));
        if overlaparea/(box1(1,3)*box1(1,4))<.75
           yesno = 0; 
        end
    else
        yesno = 0;
    end
end
