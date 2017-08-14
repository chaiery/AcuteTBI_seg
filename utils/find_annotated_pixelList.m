function index_list = find_annotated_pixelList(annotated_img, brain)

    dim = size(annotated_img);
    index_list = [];
    index_roi = find(brain>brain(1));
    for i = 1:dim(1)
        for j = 1:dim(2)
            value = annotated_img(i,j,:);
            if value(1)==255&&value(2)==0&&value(3)==0
                index = sub2ind(size(brain),i,j);
                index_list = [index_list, index];
            end
        end
    end
    
    index_list = intersect(index_list, index_roi);
end
