function closedFracture = closeFracture(img_Mattress)
            
            closedFracture= zeros(size(img_Mattress));
            mainbone_mask=getmainbonemaskwhite(img_Mattress,250);  
            %to close fracture 
            % baraye inke convex konim, input convhull column vector hast.
            CC = bwconncomp(mainbone_mask);
            numOfObjects=CC.NumObjects;
            a=[];
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