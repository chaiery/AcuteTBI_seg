function out = post_processing(brain, pred)
    if ~isempty(brain)
        % fill holes
        %out = post_processing_2(brain, pred);
        out = pred;
        out = bwmorph(out, 'bridge');
        rp = imfill(double(out),'holes');
        if length(find(rp==1))>1.5*length(find(pred==1))
            rp = pred;
        end
        s = regionprops(logical(rp),'Area','PixelIdxList');

        pred_new = zeros(size(pred));
        for j = 1 : numel(s)
            mean_intensity = mean(brain(s(j).PixelIdxList));
            if s(j).Area>50 && mean_intensity<180 && mean_intensity>30
                pred_new(s(j).PixelIdxList)=1;
            end
        end
        out = pred_new;
        
    end
end


function out=post_processing_previous(brain, pred)    
    if ~isempty(brain)
        out = post_processing_1(brain, pred);
        if length(find(out==1))>length(find(pred==1))*0.2
            pred = out;
        end
        %figure;imshow(pred)
        pred = post_processing_2(brain, pred);
        %figure;imshow(pred)
        
        s = regionprops(logical(pred),'Area','PixelIdxList');

        pred_new = zeros(size(pred));
        for j = 1 : numel(s)
            mean_intensity = mean(brain(s(j).PixelIdxList));
            if s(j).Area>80 && mean_intensity>50 && mean_intensity<200
                pred_new(s(j).PixelIdxList)=1;
            end
        end
        out = pred_new;
    end
end


function out=post_processing_2(brain, pred)

%% Create Ventricle Templates
rp = imfill(double(brain),'holes');
rp(rp>0) = max(max(rp));

[rpb,~] = bwlabel(rp);
rpbox = regionprops(rpb,'BoundingBox','Centroid');


% rectangle('Position',rpbox(1).BoundingBox,'EdgeColor','r');
xl = rpbox(1).BoundingBox(1,1);
yl = rpbox(1).BoundingBox(1,2);
w = rpbox(1).BoundingBox(1,3);
h = rpbox(1).BoundingBox(1,4);

% centx = rpbox(1).Centroid(1,1);
% centy = rpbox(1).Centroid(1,2);

% cx = centx;
% cy = centy;

cx = xl+w/2;
cy = yl+h/8*7; %centroid position

% xl2 = cx-w/12;
% yl2 = cy-h/12;
% w2 = w/6;
% h2 = h/2+h/12;
xl2 = cx-w/12;
yl2 = cy - h/12;
w2 = w/6;
h2 = h/6 + h/12;
%box2 = [xl2 yl2 w2 h2]; %ventricle box region

mask = ones(size(brain));
mask(floor(yl2):ceil(yl2+h2), floor(xl2):ceil(xl2+w2)) = 0;

%%
out = mask.*pred;

end


function out=post_processing_1(brain, pred)

brain(brain==brain(1)) = 0;

%% Padding
brain = pad_brain(brain, 0.1);
%%
% conimg = brain;
% %conimg(conimg<50) = 0;
% conimg = uint8(double(conimg)/200*255);
%%
img = medfilt2(brain);
ismooth = imguidedfilter(img);

BW= edge(ismooth/(max(ismooth(:))+50),'Canny');
%BW= edge(ismooth/(max(ismooth(:))),'Canny');

BW2 = bwmorph(BW, 'bridge');
BW3 = imfill(BW2,'holes');

labels = regionprops(BW3,'Area','PixelIdxList');
BW4 = zeros(size(brain));
for idx = 1:length(labels)
    if labels(idx).Area>100
        test = zeros(size(brain));
        test(labels(idx).PixelIdxList)=1;
        se = strel('disk',5);
        rem= imerode(test,se);
        if length(find(rem==1))>10
            BW4(labels(idx).PixelIdxList) = 1;
        end
    end
end
        
% s = regionprops(BW3,'Area','PixelIdxList');
% 
% mask = zeros(size(brain));
% for i = 1 : numel(s)
%     if s(i).Area>100 
%         mask(s(i).PixelIdxList)=1;
%     end
% end

se = strel('disk',1);
mask = imdilate(BW4,se);
%%
brain_label = logical(brain);
brain_label = imfill(brain_label,'holes');
roi_temp = xor(brain, imerode(logical(brain_label ), strel('disk', 35))); 
roi_temp = ~logical(roi_temp);
roi_1 = roi_temp .* logical(brain);

%%
roi_temp = zeros(size(brain));
roi_temp(brain>240) = 1;
se = strel('disk',20);
roi_temp = imdilate(roi_temp,se);
roi_2 = ~logical(roi_temp);

%%
mask = or(mask, roi_1);
mask = mask.*roi_2;
%%
out = mask.*pred;
%figure;imshow(out)

out = imfill(out);

end

%% when build predicted images, remove mean intensity higher than 230?
