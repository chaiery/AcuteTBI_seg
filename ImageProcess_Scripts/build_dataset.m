function [positive_dataset, negative_dataset, annotated_slices] = build_dataset(brain, roi, annotation)
    positive_dataset = [];
    negative_dataset = [];
    dim = size(brain);
    
    if length(dim)==2
        brain_img = brain;
        roi_img = roi;
        annots_img = annotation;
        [struct_1, struct_0] = singleimage_process_with_label(brain_img, roi_img, annots_img);
        
        annotated_slices(1).struct_1 = struct_1;
        annotated_slices(1).struct_0 = struct_0;
        annotated_slices(1).img_annot = annots_img;
        annotated_slices(1).brain = brain_img;
        annotated_slices(1).roi = roi;
        
        positive_dataset = [positive_dataset; struct_1];
        negative_dataset = [negative_dataset; struct_0];

    elseif length(dim)>2
        num = dim(3);
        for i = 1:num
            i
            brain_img = brain(:,:,i);
            roi_img = roi(:,:,i);
            annots_img =annotation(:,:,:,i);
            try
                [struct_1, struct_0] = singleimage_process_with_label(brain_img, roi_img, annots_img);

                positive_dataset = [positive_dataset; struct_1];
                negative_dataset = [negative_dataset; struct_0];

                annotated_slices(i).struct_1 = struct_1;
                annotated_slices(i).struct_0 = struct_0;
                annotated_slices(i).img_annot = annots_img;
                annotated_slices(i).brain = brain_img;
                annotated_slices(i).roi = roi;
            catch
                annotated_slices(i).struct_1 = [];
                annotated_slices(i).struct_0 = [];
            end
        end
    end
end

