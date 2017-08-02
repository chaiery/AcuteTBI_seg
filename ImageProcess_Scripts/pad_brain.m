function out = pad_brain (brain, step_size)
%gabor_wlen, gabor_orie

out = zeros(512);

stats = regionprops(logical(ceil(brain)), 'BoundingBox');
if size(stats,1) == 0
    return; 
end

center = [stats.BoundingBox(1) + stats.BoundingBox(3)/2,...
          stats.BoundingBox(2) + stats.BoundingBox(4)/2];
sc_ftr = 1.2;


method = 0;

switch method
    case 0
        out = replicate_padding(brain, center, sc_ftr, step_size);
    case 1
        out = mirror_padding(brain , sc_ftr, step_size);
end
%imshow(out);
return;
end % function 

function brain_tmp = replicate_padding (brain, center, sc_ftr, step_size)
brain_tmp = brain;
while sc_ftr > 1
    try
        % Find enlarged brain
        sc_mat = [sc_ftr, 0,      0; ...
                  0,      sc_ftr, 0; ...
                  0,      0,      1];
        brain_lg = imwarp(brain, affine2d(sc_mat));
        mask_lg = imerode(logical(ceil(brain_lg)), strel('disk', 3));
        
        % Find center shift between original brain and enlarged and shifted brain
        lg_stats = regionprops(bwareafilt(mask_lg,1,'largest'), 'BoundingBox');
        lg_ctr = [lg_stats.BoundingBox(1) + lg_stats.BoundingBox(3)/2,...
            lg_stats.BoundingBox(2) + lg_stats.BoundingBox(4)/2];
        ctr_shift = floor(lg_ctr - center);
        
        % Map coordinates from enlarged brain coordinates to orig. coord.
        mapped_mask = false(512);
        for i = 1:512
            for j = 1:512
                if (i + ctr_shift(2)>size(mask_lg,1) || ...
                        j + ctr_shift(1)>size(mask_lg,2))
                    mapped_mask(i,j) = false;
                else
                    mapped_mask(i,j) = ...
                        mask_lg(i + ctr_shift(2),j + ctr_shift(1));
                end
            end
        end
        
        % Draw large image on orig. image
        if (sum(mapped_mask(:)) == sum(mask_lg(:)))
            brain_tmp(mapped_mask) = brain_lg(mask_lg);
        end % if
    catch % In case of weirdness
        disp('DEBUG : Weird case in pad brain, replicate method');
    end % try
    sc_ftr = sc_ftr - step_size;
end % 2hile
brain_tmp=imgaussfilt(brain_tmp,0.75);
% Draw the orig. image on the new iamge
new_mask = imerode(logical(ceil(brain)), strel('disk', 3));
brain(~new_mask) = 0;
brain_tmp(new_mask) = brain(new_mask);
end % function 


function brain_l = mirror_padding (brain, sc_ftr, step_size)
brain(~imerode(logical(ceil(brain)), strel('disk', 3))) = 0;
brain_l = brain;
brain_s = brain;
  
while sc_ftr > 1
    try
        % Find OG enlarged brain and eroded brain mask - without this step
        og_l_mask = logical(ceil(brain_l));
        og_s_mask = logical(ceil(brain_s));
        
        % Find new enlarged brain and eroded brain mask
        lg_mask = imdilate(og_l_mask, strel('disk', 2));
        sm_mask = imerode(og_s_mask, strel('disk', 2));
        
        % Find to fill and to delete mask
        to_fill = xor(og_l_mask, lg_mask);
        to_dele = xor(og_s_mask, sm_mask);
        
        % For every pixel outside of new eroded mask, find the nearest
        % point on the new eroded small mask
        [~, cloest_idx] = bwdist(sm_mask);
        
        % Fill every pixel on the to_fill mask with the point found above,
        % and set the points on the to delete mask to 0
        brain_l(to_fill) = brain_s(cloest_idx(to_fill));
        brain_s(to_dele) = 0;
    catch % In case of weirdness
        disp('DEBUG : Weird case in pad brain, mirror method');
    end % try
    sc_ftr = sc_ftr - step_size;
end % while
end % function 

