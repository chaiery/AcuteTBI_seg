lis = [10, 12, 18, 21, 22, 29, 33, 37, 41, 42, 43];
PatientsData = ModelFeatures(lis);
for i = 1:length(lis)
    PatientsData(i).brain_pos = ModelData(lis(i)).brain_pos;
    PatientsData(i).brain_neg = ModelData(lis(i)).brain_pos;
    PatientsData(i).pos_idx = ModelData(lis(i)).pos_idx;
    PatientsData(i).neg_idx = ModelData(lis(i)).neg_idx;
end