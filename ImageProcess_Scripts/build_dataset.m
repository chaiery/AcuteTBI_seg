function [annotated_slices, annotated_features] = build_dataset(brains, annotation, intensity_mean)
    %positive_dataset = [];
    %negative_dataset = [];
    dim = size(brains);
    annotated_slices = struct('struct_1',{}, 'struct_0',{}, 'img_annot',{}, 'brain',{});
    annotated_features = struct('struct_1_features',{}, 'struct_0_features',{});
    
    if length(dim)==2
        brain_img = brains;
        annots_img = annotation;
        [struct_1, struct_0, struct_1_features, struct_0_features] = singleimage_process_with_label(brain_img, annots_img, intensity_mean);
        
        annotated_slices(1).struct_1 = struct_1;
        annotated_slices(1).struct_0 = struct_0;
        annotated_slices(1).img_annot = annots_img;
        annotated_slices(1).brain = brain_img;
        
        annotated_features(1).struct_1_features = struct_1_features;
        annotated_features(1).struct_0_features = struct_0_features;
        
        %positive_dataset = [positive_dataset; struct_1];
        %negative_dataset = [negative_dataset; struct_0];

    elseif length(dim)>2
        %%
        num = dim(3);
        for i = 1:num
            i
            brain_img = brains(:,:,i);
            annots_img =annotation(:,:,:,i);
            %try
            [struct_1, struct_0, struct_1_features, struct_0_features] = singleimage_process_with_label(brain_img,  annots_img, intensity_mean);

            %positive_dataset = [positive_dataset; struct_1];
            %negative_dataset = [negative_dataset; struct_0];

            annotated_slices(i).struct_1 = struct_1;
            annotated_slices(i).struct_0 = struct_0;
            annotated_slices(i).img_annot = annots_img;
            annotated_slices(i).brain = brain_img;

            annotated_features(i).struct_1_features = struct_1_features;
            annotated_features(i).struct_0_features = struct_0_features;
            %catch
         end
    end
end

