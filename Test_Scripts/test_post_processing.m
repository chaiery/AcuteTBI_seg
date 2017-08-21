for pid = 1:80
    pred = result(pid).pred_img;
    annot = result(pid).annotated_img;
    brain =result(pid).brain;
    if ~isempty(brain)
        pred = post_processing(brain, pred);
        
        pred_list_pos = find(pred==1);

        dim = size(brain);
        index_list = [];
        index_roi = find(brain>brain(1));
        for i = 1:dim(1)
            for j = 1:dim(2)
                value = annot(i,j,:);
                if value(1)==255&&value(2)==0&&value(3)==0
                    index = sub2ind(size(brain),i,j);
                    index_list = [index_list, index];
                end
            end
        end

        annotated_pos = intersect(index_list, index_roi);

        TP = length(intersect(pred_list_pos, annotated_pos));
        test_dice = 2*TP/(length(pred_list_pos)+length(annotated_pos));
        %result(pid).post_dice = test_dice;
        
        compare(pid).dice = result(pid).dice;
        compare(pid).post_dice_new = test_dice;
        compare(pid).pred = pred;
    end
end
%%
i = 17;
brain =result(i).brain;
figure;imshow(brain)

%%
%compare = [];
for pid = 1:80
    pred = result(pid).pred_img;
    annot = result(pid).annotated_img;
    brain =result(pid).brain;
    if ~isempty(brain)
        out = post_processing(brain, pred);
        if length(find(out==1))>length(find(pred==1))*0.2
            pred = out;
        end
        
        s = regionprops(logical(pred),'Area','PixelIdxList');

        pred_new = zeros(size(pred));
        for j = 1 : numel(s)
            mean_intensity = mean(brain(s(j).PixelIdxList));
            if s(j).Area>80 && mean_intensity>50
                pred_new(s(j).PixelIdxList)=1;
            end
        end
        pred = pred_new;
        
        pred_list_pos = find(pred==1);

        dim = size(brain);
        index_list = [];
        index_roi = find(brain>brain(1));
        for i = 1:dim(1)
            for j = 1:dim(2)
                value = annot(i,j,:);
                if value(1)==255&&value(2)==0&&value(3)==0
                    index = sub2ind(size(brain),i,j);
                    index_list = [index_list, index];
                end
            end
        end

        annotated_pos = intersect(index_list, index_roi);

        TP = length(intersect(pred_list_pos, annotated_pos));
        test_dice = 2*TP/(length(pred_list_pos)+length(annotated_pos));
        %result(pid).post_dice = test_dice;
        
        compare(pid).dice = result(pid).dice;
        compare(pid).post_dice_new = test_dice;
        compare(pid).pred = pred;
    end
end

%%
dice_list = [];
for i = 1:length(compare)
    %if result(i).num_pos>500
        dice_list = [dice_list, compare(i).post_dice_new];
    %end
end

%%
dice_list = [];
for i = 1:length(result)
    if result(i).num_pos>500
        dice_list = [dice_list, compare(i).post_dice_];
    end
end

%%
for i = 11
    brain = result(i).brain;
    pred_ori = result(i).pred_img_overlap;
    pred = compare(i).pred;
    annot = result(i).annotated_img;
    figure;imshow(brain);
    figure;imshow(pred_ori);
    figure;imshow(pred);
    figure;imshow(annot);
end
