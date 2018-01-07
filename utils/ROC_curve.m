function [AUC, collection] = ROC_curve(score, Y, step, status)
% Input:
% score: Prediction score from predictive models
% Y: ground truth, have to be binary (0 or 1)
% step: to control the precision
% status: True: draw the ROC plot, False: don't draw the plot
% Return:
% AUC: AUC value
% collection: the first row are sensitivities, and the second row 
% are corresponding specificities 
    
    if nargin <3
        step = 0.001;
        status = True;
    elseif nargin == 3
        status = True;
    end
    
    % First, calculate true negative and positive index
    scorelist = score(:,2);
    scoreNeg = scorelist(Y==0);
    scorePos = scorelist(Y==1);

    sp = 0:step:1;
    num = length(sp);
    sn = zeros(1, length(sp));
    for i = 1:num
        thre = prctile(scoreNeg, sp(i)*100);
        sn(i) = mean(scorePos>thre);
    end

    sn_2 = [sn(2:end), sn(end)];
    midpoint = (sn+sn_2)/2;
    AUC = sum(midpoint(1:end-1))*step;
    
    if status
        figure; plot(1-sp, sn)
        xlim([0 1]); ylim([0 1])
    end

    collection = mat2cell(cat(1,sn, sp),2, num);

end