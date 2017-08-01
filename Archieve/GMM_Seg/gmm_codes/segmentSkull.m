function [img_skull] = segmentSkull(imgStruct)

% Segment skull bone from head CT scans
% input:
% imgStruct: image struct must contain .img_Mattress and img_bone field
%           if img_bone is not empty, it is used for bone segmentation if
%           not, img_Mattress is used for bone segmentation
% Output:
% img_skull: image containing only of skull
%
% Written by: Eunji Kang 11/2015 University of Michigan

            img_bone = imgStruct.img_bone;
            img_Mattress = imgStruct.img_Mattress;
            
            if isempty(img_bone) == 0
                % if it was dicom image, then we could use the contrast
                % adjusted image to extract the bone (this is more
                % accurate)
                
                % After bone was extracted, there were little brain tissue.
                % Thus 10 is used as boneThreshold
                img_skull=getmainbonemaskwhite(img_bone,10);
                
                % I found using strel which is used to find ball-shaped
                % element may make the bone region larger than it should
                % be. And hematoma may happed near the skull. 
                %{
                se = strel('ball',3,3);
                temp = imdilate(img_skull,se);
                id_bone = temp > 3;
                id_other = temp <= 3;
                temp(id_bone) = 1;
                temp(id_other) = 0;
                img_skull_2 = temp;
                figure; imshow(img_skull)
                figure; imshow(img_skull_2)
                %}
            else
                img_skull=getmainbonemaskwhite(img_Mattress,100);
            end