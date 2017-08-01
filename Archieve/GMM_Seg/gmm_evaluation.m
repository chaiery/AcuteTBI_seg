function [Acc,Sn,Sp,Pre,MCC,Sorenson_Dice] = GMM_evaluation()
    TP = 0; TN = 0; FP = 0; FN = 0; Ps = 0;
    ImgDir = '/Users/apple/Dropbox/TBI/al_test';
    ImgFiles = dir(ImgDir);
    ImgFiles = ImgFiles(~strncmpi('.', {ImgFiles.name},1));
    ImgFiles = ImgFiles(1:4);
    ImgDir_A = '/Users/apple/Dropbox/TBI/Select_for_annotation';
    ImgDir_P = '/Users/apple/Dropbox/TBI/GMM_output';
    
    
    for num = 1:length(ImgFiles)
        
        fname = ImgFiles(num).name;
        imgori = imread([ImgDir_A, '/', fname]);
        imgP = imread([ImgDir_P, '/', fname]);
        fname_A = [fname(1:end-4), 'A.png'];
        imgA = imread([ImgDir_A,'/',fname_A]);
        imgA = process_annotated_imgs(imgA);
        
        
        label_img = bwlabel(imgori, 4);
        rpbox = regionprops(label_img,'BoundingBox');

        y1 = floor(rpbox(1).BoundingBox(1,1));
        x1 = floor(rpbox(1).BoundingBox(1,2));
        w = rpbox(1).BoundingBox(1,3);
        h = rpbox(1).BoundingBox(1,4);

        imgA = imgA(x1-5:x1+h+5,y1-5:y1+w+5,:);
        imgP = imgP(x1-5:x1+h+5,y1-5:y1+w+5,:);
        
        figure;imshow(imgP)
        [x,y,~] = size(imgA);
        img_label = zeros(x,y);
        for i = 1:x
            for j = 1:y
                value = imgA(i,j,:);
                if sum(value(:)==[255;0;0])==3
                    img_label(i,j) = 1;
                end
            end
        end
        
        [x,y,~] = size(imgP);
        img_pred = zeros(x,y);
        for i = 1:x
            for j = 1:y
                value = imgP(i,j,:);
                if sum(value(:)==[255;0;0])==3
                    img_pred(i,j) = 1;
                end
            end
        end       
        
        
        TP = TP + sum(sum(img_pred.*img_label));
        TN = TN + sum(sum((1-img_pred).*(1-img_label)));
        FP = FP + sum(sum(img_pred.*(1-img_label)));
        FN = FN + sum(sum((1-img_pred).*img_label));

        Ps = Ps + sum(img_pred(:))+sum(img_label(:));    
    end
    
    Acc = (TN+TP)/(TN+TP+FN+FP);
    Sn = TP/(TP+FN);
    Sp = TN/(TN+FP);
    Pre = TP/(TP+FP);
    MCC = (TP*TN-FP*FN)/((TP+FN)*(TP+FP)*(TN+FN)*(TN+FP))^0.5;
    Sorenson_Dice = 2*TP/Ps;

end