function pixel_list = superpixel_based_selection(list, num)
    group = unique(list(:,2));
    pixel_list = [];
    if (length(group)>=num)
        index = randsample(length(group),num);
        group_new = group(index);
        for i = 1:length(group_new)
            points = list(list(:,2)==group_new(i),1);
            pixel_list = [pixel_list points(randsample(length(points),1))];
        end
        
    else
        rep = floor(num/length(group));
        for i = 1:length(group)
            points = list(list(:,2)==group(i),1);
            pixel_list = [pixel_list points(randsample(length(points),rep))];
        end
        remain = setdiff(list(:,1), pixel_list);
        pixel_list = [pixel_list remain(randsample(length(remain),num-length(group)*rep))'];
    end
end