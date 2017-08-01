intensities = [];
for i = 1:length(PatientsData_features)
    pos_dataset = PatientsData_features(i).PosData;
    neg_dataset = PatientsData_features(i).NegData;
    intensities(i).pos_intensity = cell2mat(arrayfun(@(x) pos_dataset(x).MeanIntensity, 1:length(pos_dataset),'un',0));
    intensities(i).neg_intensity = cell2mat(arrayfun(@(x) neg_dataset(x).MeanIntensity,1:length(neg_dataset),'un',0));
end

%% 
for i = 1:length(intensities)
    pos_intensity = intensities(i).pos_intensity;
    neg_intensity = intensities(i).neg_intensity;
    %x = min(pos_intensity);
    total = [pos_intensity, neg_intensity];
    x = quantile(total, 0.2);
    index_pos = find(pos_intensity<x);
    index_neg = find(neg_intensity<x);

    intensities(i).percent_pos = length(index_pos)/length(pos_intensity);
    intensities(i).percent_neg = length(index_neg)/length(neg_intensity);
end

%%
for i = 1:length(intensities)
    pos_intensity = intensities(i).pos_intensity;
    neg_intensity = intensities(i).neg_intensity;
    %x = min(pos_intensity);
    total = [pos_intensity, neg_intensity];
    x = 50;
    index_pos = find(pos_intensity<x);
    index_neg = find(neg_intensity<x);

    intensities(i).percent_pos_value = length(index_pos)/length(pos_intensity);
    intensities(i).percent_neg_value = length(index_neg)/length(neg_intensity);
end