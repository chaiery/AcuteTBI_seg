masks = PatientsData(23).masks;
brains = PatientsData(23).rota_brains;

new_masks = midline_remove(brains, masks);

%%
pathpre = '/Users/apple/Developer/Result_Evaluation/Remove_Midline/';
pid = '88/';

path = [pathpre, pid];
if ~isdir(path)
    mkdir(path);
end
    
for i = 1:size(masks,3)
    comb = cat(2, masks(:,:,i), brains(:,:,i));
    comb = cat(2, comb, new_masks(:,:,i));
    imwrite(comb, [path, num2str(i), '.png'])
end

%%
%%
pathpre = '/Users/apple/Developer/Result_Evaluation/Remove_Triangular/';

for i = 1:8
    pid = num2str(i);
    brains = result(i).brain;
    masks = result(i).mask;
    path = [pathpre, pid];
    if ~isdir(path)
        mkdir(path);
    end
    
    for j = 1:size(masks,3)
        comb = cat(2, masks(:,:,j), brains(:,:,j));
        imwrite(comb, [path, num2str(j), '.png'])
    end
end

%% Remove small triangular region at the end of midline
pid = 2;
brains = result(pid).brain;
masks = result(pid ).mask;
path = [pathpre, num2str(pid) '/'];
if ~isdir(path)
    mkdir(path);
end
    
for idx = 1:size(brains,3)
    brain = brains(:,:,idx);
    mask = masks(:,:,idx);
    mask = im2uint8(mask);
    
    if sum(brain(:))
        %%
        img = logical(brain);
        rpbox = regionprops(img,'BoundingBox','Centroid');

        xl = rpbox(1).BoundingBox(1,1);
        yl = rpbox(1).BoundingBox(1,2);
        w = rpbox(1).BoundingBox(1,3);
        h = rpbox(1).BoundingBox(1,4);

        cx = xl+w/2;
        cy = yl+h/2; %centroid position
        xl2 = cx;
        yl2 = cy+h/4;
        w2 = w/6;
        h2 = h/2-h/6;
        box2 = [xl2 yl2 w2 h2]; %ventricle box region
        test = brain;
        test(int32(yl2+h/12):int32(yl2+h2), int32(xl2-w2):int32(xl2+w2)) = 255;
        
        test(int32(yl):int32(yl+h2/2), int32(xl2-w2/2):int32(xl2+w2/2)) = 255;
        
        index_box = find(test==255);
        lowest_point = yl+h;
       
        %% Components in Mask
        img = logical(mask);
        compos = regionprops(img, 'PixelIdxList', 'PixelList'); 
        index_remove = []; 
        for i = 1:size(compos,1)
            %%
            tarindex = compos(i).PixelIdxList;
            test = zeros(size(mask));
            test(tarindex)=255;
            %figure;imshow(test)
            perc = length(intersect(index_box, tarindex))/length(tarindex);
            if perc==1
                %If it is very close to the edge
                lis = compos(i).PixelList;
                lowest_y = max(lis(:,2));
                highest_y = min(lis(:,2));
                if abs(lowest_y-lowest_point)<10||abs(highest_y-yl)<10;
                    index_remove = [index_remove; tarindex];
                end
            end
        end
    end
    %%
    index_mask = find(mask==255);
    index_new = setdiff(index_mask, index_remove);
    new_mask = zeros(size(mask));
    new_mask(index_new) = 255;

    comb = cat(2, mask, new_mask);
    comb = cat(2, brain, comb);
    imwrite(comb, [path, num2str(idx), '.png'])
end

%%
tic
[new_masks] = midline_remove(brains, masks);
toc

%% Test the function
pathpre = '/Users/apple/Developer/Result_Evaluation/Remove_Triangular/';
for pid = 1:8
    pid
    brains = result(pid).brain;
    masks = result(pid).mask;
    path = [pathpre, num2str(pid) '/']; 
    if ~isdir(path)
        mkdir(path);
    end
    [new_masks] = midline_remove(brains, masks);
    for sidx = 1:size(brains,3)
        comb = cat(2, im2uint8(masks(:,:,sidx)), new_masks(:,:,sidx));
        comb = cat(2, brains(:,:,sidx), comb);
        imwrite(comb, [path, num2str(sidx), '.png'])
    end
end

%%
%% Build for Traditional Method
pathpre = '/Users/apple/Developer/Result_Evaluation/Remove_Triangular/';
%for pid = 1:length(PatientsData_sel)
for pid = 56
    pid
    brains = uint8(PatientsData(pid).rota_brains);
    masks = PatientsData(pid).masks;
    path = [pathpre, num2str(pid) '/']; 
    if ~isdir(path)
        mkdir(path);
    end
    [new_masks] = midline_remove(brains, masks, 1);
    PatientsData(pid).masks = new_masks;
%     for sidx = 1:size(brains,3)
%         comb = cat(2, im2uint8(masks(:,:,sidx)), new_masks(:,:,sidx));
%         comb = cat(2, brains(:,:,sidx), comb);
%         imwrite(comb, [path, num2str(sidx), '.png'])
%     end
end

%%
for pid = 1:62
    PatientsData_sel(pid).masks = PatientsData(pid).masks;
end
%%
%for test
for pid = 32
    path = [pathpre, num2str(pid) '/']; 
    if ~isdir(path)
        mkdir(path);
    end
    brains = PatientsData_sel(pid).adjustImgs_static;
    masks = PatientsData_sel(pid).masks;
    for sidx = 1:size(brains,3)
        comb = cat(2, brains(:,:,sidx), masks(:,:,sidx));
        imwrite(comb, [path, num2str(sidx), '.png'])
    end
end

%%
for pid = 32
    path = [pathpre, num2str(pid) '/']; 
    if ~isdir(path)
        mkdir(path);
    end
    brains = PatientsData(pid).rota_brains;
    masks = PatientsData(pid).masks; 
    for sidx = 1:size(brains,3)
        comb = cat(2, brains(:,:,sidx), masks(:,:,sidx));
        imwrite(comb, [path, num2str(sidx), '.png'])
    end
end
%%
save('PatientsData_sel', 'PatientsData_sel', '-v7.3')