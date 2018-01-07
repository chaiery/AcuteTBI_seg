function [convexity ,rev] = getConvexity(BW)
convexity = 0;
rev = 0;

[row_ind, col_ind] = find(BW == 1);
[row_sort, row_sort_ind] = sort(row_ind,'ascend');

    
    yLen = length(row_sort);
    yLim = max( uint16((0.5*yLen -20)),0);
    y0 = row_sort(1) + 60;
    yUpper = y0 + yLim;
    
    diff = 0;
    diffNow = 0;
    diffPre = 0;
    j = 0; % y direction move ( the number of pixels decrease continuously)
   
    thresholdOfConvexity = 30;
    
    diffVec = zeros(yLim);
    for i=1:yLim
       
        y0 = y0 + 1;
        
        allPointsInThisRow = find(row_sort==y0);
        
        numOfPoints = length(allPointsInThisRow);
        if numOfPoints > 3
            j = j+1;
            if j > thresholdOfConvexity
                convexity = convexity - 500;
                j = 0;
            end
            continue;
        elseif numOfPoints < 2
            continue;
        else  
            diffPre = diffNow; 
            diffNow = abs( max(col_ind(allPointsInThisRow))...\ 
                         - min(col_ind(allPointsInThisRow)));   
            diffVec(i) = diffNow;
            if  (diffNow - diffPre) < -6   % give a descendent theshold  -6  
                j = j+1;
                    convexity = convexity - 20;
                if j > thresholdOfConvexity
                    convexity = convexity - 100;
                    j = 0;
                end
            end
        end

    end
    
%     diffTotal = diffNow(2:end) - diffNow(1:end-1);
%     ind = find(diffTotal > 0)
%     len = length(ind);
    
    
end