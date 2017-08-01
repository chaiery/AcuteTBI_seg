function [SelectSlices] = slices_with_pixel_selection(Patients)
    %% Read Annotated and Original Images

    SelectSlices = [];
    NumPos = 30;
    NumNeg = 300;

    for p = 1:length(Patients)
        PatientImgs = BrainImage_pid(Patients(p));
        index = randsample(length(PatientImgs),min(length(PatientImgs),5));
        SelectSlices = [SelectSlices PatientImgs(index)];
    end

    %% For each Slice
    PositiveDataset = [];
    NegativeDataset = [];

    for slice = 1:length(SelectSlices)
        brain = SelectSlices(slice).brain;
        annot_list = SelectSlices(slice).annot_list;
        % Remove if the intensity is less than 80
        annot_index = cell2mat(arrayfun(@(i) sub2ind(size(brain),annot_list(i,2),annot_list(i,1)),1:length(annot_list),'un',0));
        annot_index = annot_index';

        win_min = 80;
        win_width = 255-win_min;
        imgori_adjust = uint8(double(brain - win_min)*255 / double(win_width));
        imgori_adjust  = medfilt2(imgori_adjust);

        %test = zeros(size(brain));
        sample = find(imgori_adjust>80);
        neg_pool = setdiff(sample, annot_index);
        pos_pool = intersect(annot_index, sample);
        
        %test(sample_list) = brain(sample_list);
        [L,~] = superpixels(brain,1000);

        neg_pool(:,2) = L(neg_pool);

        %positive_points = superpixel_based_selection(annot_index, NumPos);
        if (length(pos_pool)>NumPos)
            positive_points = pos_pool(randsample(length(pos_pool), NumPos))';
            negative_points = superpixel_based_selection(neg_pool, NumNeg);
            points = [positive_points, negative_points];

            features = pixel_feature_extraction(points,brain,imgori_adjust);
            SelectSlices(slice).PositiveDataset = features(1:NumPos);
            SelectSlices(slice).NegativeDataset = features(NumPos+1:end);
        end
        %PositiveDataset = [PositiveDataset features(1:NumPos)];
        %NegativeDataset = [NegativeDataset features(NumPos+1:end)];
    end
    
end


%for i = 1:length(PositiveDataset)
%    PositiveDataset(i).label = 1;
%end

%for i = 1:length(NegativeDataset)
%    NegativeDataset(i).label = 0;
%end
