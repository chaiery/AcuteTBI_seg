function pred = post_processing_demo(brain, pred)
%%
    iter          = 20;         %--# of iterations to be run
    dt            = .5;           %--time step for update (<.5 to satisfy CFL)
    alpha         = 1;         %--weight for curvature term
    flag_approx   = 5;    

    if ~isempty(find(pred,1))
        % fill holes
        %out = post_processing_2(brain, pred);
        out = pred;
        out = bwmorph(out, 'bridge');
        rp = imfill(double(out),'holes');
        if length(find(rp==1))>1.5*length(find(pred==1))
            rp = pred;
        end
        
        if ~isempty(find(rp,1))
            s = regionprops(logical(rp),brain,'Area','PixelIdxList','MeanIntensity');
            index = ~all([[s.Area]>50; [s.MeanIntensity]>50;[s.MeanIntensity]<150],1);
            s(index) = [];
            
            if ~isempty(s)
                pred_new = zeros(size(pred));
                pred_new(cat(1, s.PixelIdxList))=1;


                [pred_new,~,~] = run_2(brain,iter,dt,alpha,flag_approx,pred_new);

                pred = double(1-pred_new);
                pred(pred>0) = 1;
                pred(pred<0) = 0;

                na = find(isnan(pred)==1);
                pred(na) = 0;
                s = regionprops(logical(pred),brain,'Area','PixelIdxList','MeanIntensity');
                index = [s.Area]<50;
                s(index) = [];
            end
            pred = zeros(size(pred));
            pred(cat(1, s.PixelIdxList))=1;
        end
    end
end