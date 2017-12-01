%%
for i = 1:length(output)
    pid = output(i).pid;
    annots = output(i).annots;
    brains = output(i).brains;
    masks = output(i).masks;
    pathpre = '/home/hemingy/Documents/Results/AcuteTBI/';
    path = [pathpre, pid];
    if ~isdir(path)
        mkdir(path);
    end

    for i = 1:size(brains,3)
        pred = masks(:,:,i)*255;
        brain = brains(:,:,i);
        annot = annots(:,:,i)*255;
        x = cat(2, brain, annot);
        x = cat(2, x, pred);
        imwrite(uint8(x), [path '/' int2str(i) '.png']);
    end
end
%%
pathpre = '/home/hemingy/Documents/Results/AcuteTBI/';
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
    mask = result(i).pred_mask;
    
    %imgori = pad_brain(brain, 0.01);
    %imgori = imguidedfilter(imgori);
    %salient_map = saliency_map(imgori);
    %salient_map(brain==0)=0;
    
    imwrite(brain, [path '/' slice_index '_' dice 'brain.png']);
    imwrite(annot, [path '/' slice_index '_' dice 'annot.png']);
    imwrite(pred, [path '/' slice_index '_' dice 'pred.png']);
   % imwrite(prob, [path '/' slice_index '_' dice 'prob.png']);
    %imwrite(mask, [path '/' slice_index '_' dice 'mask.png']);
    %imwrite(salient_map, [path '/' slice_index '_' dice 'saliency.png']);
    
end

%%
str1 = '128-10';
str2 = '-';
k = findstr(str1, str2);

%%
pathpre = '/home/hemingy/Documents/InputImages/';
for i = 1:length(PatientsData)
    pd = PatientsData(i);
    pid = pd.Pid;
    path = [pathpre, pid];
    if ~isdir(path)
        mkdir(path);
    end
    
    dcmimg = pd.dicomImgs;
    brain = result(i).brain;
    annot = result(i).annotated_img;
    pred = result(i).pred_img;
    prob = result(i).prob_map;
    mask = result(i).pred_mask;
    
    imgori = pad_brain(brain, 0.01);
    %imgori = imguidedfilter(imgori);
    salient_map = saliency_map(imgori);
    salient_map(brain==0)=0;
    
    imwrite(brain, [path '/' slice_index '_' dice 'brain.png']);
    imwrite(annot, [path '/' slice_index '_' dice 'annot.png']);
    imwrite(pred, [path '/' slice_index '_' dice 'pred.png']);
    imwrite(prob, [path '/' slice_index '_' dice 'prob.png']);
    imwrite(mask, [path '/' slice_index '_' dice 'mask.png']);
    imwrite(salient_map, [path '/' slice_index '_' dice 'saliency.png']);
    
end

