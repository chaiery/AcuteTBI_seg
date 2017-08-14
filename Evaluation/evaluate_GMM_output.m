function GMM_output = evaluate_GMM_output(GMM_output)
    %for pid = 1:length(GMM_output)
    for pid = 31:32
        outputs = GMM_output(pid).output;
        annotations = GMM_output(pid).annotation;
        brains = GMM_output(pid).brains;
        dice_list = [];
        for index = 1:size(outputs,4)
            output = outputs(:,:,:,index);
            annotation = annotations(:,:,:,index);
            brain = brains(:,:,index);
            pred_list_pos =  find_annotated_pixelList(output, brain);
            annotated_pos =  find_annotated_pixelList(annotation, brain);
            
            brain_region = find(brain>brain(1));
            pred_list_neg = setdiff(brain_region, pred_list_pos);
            annotated_neg = setdiff(brain_region, annotated_pos);
            
            TP = length(intersect(pred_list_pos, annotated_pos));
            TN = length(intersect(pred_list_neg, annotated_neg));
            FP = length(intersect(pred_list_pos, annotated_neg));
            FN = length(intersect(pred_list_neg, annotated_pos));
            
            test_dice = 2*TP/(length(pred_list_pos)+length(annotated_pos));
            dice_list = [dice_list, test_dice];
        end
        GMM_output(pid).dice = mean(dice_list);
    end


end