pathpre = '/Users/apple/Developer/AcuteTBI_seg/result_analysis/';
for i = 1:length(result)
    id = result(i).id;
    pid = id(1:strfind(id,'-')-1);
    %path = [pid,'_result'];
    path = [pathpre, pid];
    if ~isdir(path)
        mkdir(path);
    end
    dice = num2str(round(result(i).dice,3));
    slice_index = id(strfind(id,'-')+1:end);
    brain = result(i).brain;
    annot = result(i).annotated_img;
    pred = result(i).pred_img;
    prob = result(i).prob_map;
    
    imwrite(brain, [path '/' slice_index '_' dice 'brain.jpg']);
    imwrite(annot, [path '/' slice_index '_' dice 'annot.jpg']);
    imwrite(pred, [path '/' slice_index '_' dice 'pred.jpg']);
    imwrite(prob, [path '/' slice_index '_' dice 'prob.jpg']);
end

%%
str1 = '128-10';
str2 = '-';
k = findstr(str1, str2);
