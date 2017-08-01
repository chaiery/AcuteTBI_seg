function [closedFracture,  mainbone_mask] = closeFracture2(imgStruct)
            img_Mattress = imgStruct.img_Mattress;
            mainbone_mask = imgStruct.bwSkullBone;
%             img_bone = imgStruct.img_bone;
%  
%             closedFracture= zeros(size(img_Mattress));
%             if isempty(img_bone) == 0
%                 % if it was dicom image, then we could use the contrast
%                 % adjusted image to extract the bone (this is more
%                 % accurate)
% %                 temp = img_bone == max(img_bone(:));
% %                 temp = uint8(temp);
% %                 
% %                 mainbone_mask = temp.* img_bone;
%                 mainbone_mask=getmainbonemaskwhite(img_bone,max(img_bone(:))-1);
%             else
%                 mainbone_mask=getmainbonemaskwhite(img_Mattress,250);
%             end
            
            if(isCrashed(img_Mattress,250)) %check if skull is cracked
                %to close fracture
                % baraye inke convex konim, input convhull column vector hast.
                CC = bwconncomp(mainbone_mask);
                numOfObjects=CC.NumObjects;
                a=[];
                if numOfObjects > 0
                    for i= 1:numOfObjects
                        a=vertcat(a,CC.PixelIdxList{1,i});
                    end
                    % N: I could have used a=find(mainbonemask==1/?) instead of line7-12
                    siz= CC.ImageSize;
                    
                    [I,J] = ind2sub(siz,a);
                    k = convhull(I,J);
                    %             figure;plot(I(k),J(k),'r-',I,J,'b*');
                    
                    %to show
                    %             figure; imshow(img_Mattress)
                    %             for i=1:(length(k)-1)
                    %                 hold on
                    %                 line([J(k(i)),J(k(i+1))],[I(k(i)),I(k(i+1))],'color','r');
                    %             end
                    
                    %To apply points  to the CT-image
                    %             figure; imshow(mainbone_mask)
                    BW = roipoly(mainbone_mask,J(k),I(k)); %fills the whole area
                    BW2 = bwmorph(BW,'remove'); % The outer edge
                    se = strel('disk',5);
                    BW3= imdilate(BW2,se);
                    % mainbone_mask(BW2)=1;
                    % mainbone_mask=imclose(mainbone_mask, ones(7,7));
                    img_Mattress(BW3)= 255;
                    closedFracture = img_Mattress;
                else
                    closedFracture = img_Mattress;
                end
            else
                closedFracture = img_Mattress;
            end