%

for i = 1:8
    pid = PatientsData(i).Pid;
    datatype = PatientsData(i).Datatype;
    pos_index = PatientsData(i).pos_idx;
    neg_index = PatientsData(i).neg_idx;
    index = sort([pos_index, neg_index]);
    [pixel_spacing, output] = ExtractOriginalImgs(pid, datatype, index);
    
    pid_data = PatientsData(i);
    pid_data.dcm_slices = output;
    pid_data.pixel_spacing = pixel_spacing;
    save(['patient_',num2str(i)], 'pid_data', '-v7.3')
end


