function [ window_i, window_j, window_numOfPix, rev ] = getOneli8WindowForOneSlicejuly10(seg_kmean, windowStru );

%  windowStru = [window_leftuppoint,window_width,window_heigh,pixThreholdInWindow];

window_i = 0;
window_j = 0;
window_numOfPix = 0;
rev = 0;

window_leftuppoint_x = windowStru(1);
window_leftuppoint_y = windowStru(2);
window_width = windowStru(3);
window_heigh = windowStru(4);
pixThreholdInWindow = windowStru(5);

pixTotalNum_max = 0;
for i = 1:5    
   for j = 1:2:41
        pixTotalNum = sum(sum(seg_kmean(window_leftuppoint_y + j:window_leftuppoint_y + j + window_heigh, ...\ 
                                window_leftuppoint_x + i:window_leftuppoint_x + i + window_width ) ));
        if pixTotalNum < pixThreholdInWindow   
            continue;
        end                 
                            if( pixTotalNum > pixTotalNum_max)
                                pixTotalNum_max = pixTotalNum;
                                window_i = i;
                                window_j = j;
                            end
   end
end

if pixTotalNum_max == 0
    rev = 1;
end

window_numOfPix = pixTotalNum_max;

end