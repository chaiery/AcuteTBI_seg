
img_path  = '4_0.768brain.png'; %--image path for segmentation
img = imread(img_path);
img = medfilt2(img);
mask = imread('4_0.768mask.png');
iter          = 50;         %--# of iterations to be run
dt            = .5;           %--time step for update (<.5 to satisfy CFL)
alpha         = 1;         %--weight for curvature term
flag_approx   = 5;            %--flow by sign of gradient (faster convergence)

%pre-load mask for demo.
%--loads variable "mask" to automate segmentation
[result,pin,pout] = run(img,iter,dt,alpha,flag_approx,mask);

%display final result
imshow(img,'InitialMagnification', 200);
fat_contour(result);



%%
iter          = 20;         %--# of iterations to be run
dt            = .5;           %--time step for update (<.5 to satisfy CFL)
alpha         = 1;         %--weight for curvature term
flag_approx   = 1;            %--flow by sign of gradient (faster convergence)

pid = 175;
pred = sel(pid).mask;
annot = sel(pid).annotated_img;
 
brain =sel(pid).brain;
imgori = pad_brain(brain, 0.01);
imgori = medfilt2(imgori);
salient_map = saliency_map(brain);
%figure;imshow(salient_map)
se = strel('disk',1);
salient_map = imdilate(salient_map,se);

if ~isempty(brain)
    out = post_processing(brain, pred);
    if length(find(out==1))>length(find(pred==1))*0.2
        pred = out;
    end

    s = regionprops(logical(pred),'Area','PixelIdxList');

    pred_new = zeros(size(pred));
    for j = 1 : numel(s)
        mean_intensity = mean(brain(s(j).PixelIdxList));
        if s(j).Area>100 && mean_intensity>50
            pred_new(s(j).PixelIdxList)=1;
        end
    end
    figure;imshow(pred_new)
    [pred_new,pin,pout] = run(brain,iter,dt,alpha,flag_approx,pred_new);
    figure;imshow(brain,'InitialMagnification', 200);
    fat_contour(pred_new);
   %#figure;imshow(pred_new)
end