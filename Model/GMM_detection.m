function [GMM_output] = GMM_detection(BrainImgs, rotation)
    %% Preprocess the CT images
    
    GMM_output = zeros([size(BrainImgs,1),size(BrainImgs,2),3,size(BrainImgs,3)]);
    if rotation
        rota = rotate_method(BrainImgs);
    else
        rota = BrainImgs;
    end

    disp(' Completed image rotation and alignment');

    %% run hematoma segmentation algorithm
    %for i = 1:numel(imgStruct_2)
    for i = 1:size(BrainImgs,3)
        fprintf('Starting file %i out of %i \n', i, size(BrainImgs,3));
        img = rota(:,:,i);
        [img_out,isDetected] = detectHematoma(img,1);
        %imgStruct_2(i).HemaDetected = isDetected;
        if isDetected == 1
            GMM_output(:,:,:,i) = img_out;
            %SaveNameOrig = [SaveDir, imgStruct_2(i).fname(1:end-4), 'Orig.png'];
            %imwrite(img, SaveNameOrig);
            %SaveName = [SaveDir, imgStruct_2(i).fname(1:end-4), '.png'];
            %imwrite(img_out, SaveName);
        else
            output = zeros([size(img),3]);
            output(:,:,1) = uint8(img);
            output(:,:,2) = uint8(img);
            output(:,:,3) = uint8(img);
            GMM_output(:,:,:,i) = output;
        end
    end
end