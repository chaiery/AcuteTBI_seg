function [ window_i, window_j, window_numOfPix, rev ] = getWFMWindowForOneSliceJournalPaper2(seg_kmean, windowStru )

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

bigWindow_width = windowStru(6);
bigWindow_heigh = windowStru(7);

pixTotalNum_max = 0;
% for i = 1:(bigWindow_width-window_width)   
%    for j = 1:2:uint16(2*uint16((bigWindow_heigh-window_heigh)/2)+1)
%  
%         pixTotalNum = sum(sum(seg_kmean(window_leftuppoint_y + j:window_leftuppoint_y + j + window_heigh, ...\ 
%                                 window_leftuppoint_x + i:window_leftuppoint_x + i + window_width ) ));
%         if pixTotalNum < pixThreholdInWindow   
%             continue;
%         end                 
%                             if( pixTotalNum > pixTotalNum_max)
%                                 pixTotalNum_max = pixTotalNum;
%                                 window_i = i;
%                                 window_j = j;
%                             end
%    end
% end

x_span = bigWindow_width-window_width;
x_span_half = uint16(x_span /2);
window_leftuppoint_x;
x_middle = window_leftuppoint_x + uint16(x_span /2) ;
window_rightuppoint_x = window_leftuppoint_x + x_span;

for j = 1:2:uint16(2*uint16((bigWindow_heigh-window_heigh)/2)+1)
    if  x_span_half>5
%     for i = (x_span_half-5):1:x_span
%         pixTotalNum = sum(sum(seg_kmean(window_leftuppoint_y + j:window_leftuppoint_y + j + window_heigh, ...\ 
%                                 window_leftuppoint_x + i-5:window_leftuppoint_x + i-5 + window_width ) ));
%         if pixTotalNum < pixThreholdInWindow   
%             continue;
%         end                 
%                             if( pixTotalNum > pixTotalNum_max)
%                                 pixTotalNum_max = pixTotalNum;
%                                 window_i = i-5;
%                                 window_j = j;
%                             end
%     end
%     else
%         for i = x_span_half:1:x_span
%         pixTotalNum = sum(sum(seg_kmean(window_leftuppoint_y + j:window_leftuppoint_y + j + window_heigh, ...\ 
%                                 window_leftuppoint_x + i:window_leftuppoint_x + i + window_width ) ));
%         if pixTotalNum < pixThreholdInWindow   
%             continue;
%         end                 
%                             if( pixTotalNum > pixTotalNum_max)
%                                 pixTotalNum_max = pixTotalNum;
%                                 window_i = i;
%                                 window_j = j;
%                             end
%         end
%     end
    
     for i = x_span_half:1:x_span
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
 
    for i = x_span_half:-1:1
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

windowR_i = 0;
windowR_j = 0;
for j = 1:2:uint16(2*uint16((bigWindow_heigh-window_heigh)/2)+1)
    window_leftuppoint_xnew = window_leftuppoint_x + x_span_half;
    for i = x_span_half:1:x_span
        pixTotalNum = sum(sum(seg_kmean(window_leftuppoint_y + j:window_leftuppoint_y + j + window_heigh, ...\ 
                                window_leftuppoint_xnew + i:window_leftuppoint_xnew + i + window_width ) ));
        if pixTotalNum < pixThreholdInWindow   
            continue;
        end                 
                            if( pixTotalNum > pixTotalNum_max)
                                pixTotalNum_max = pixTotalNum;
                                windowR_i = i;
                                windowR_j = j;
                            end
    end

end

% window_rightuppoint_xnew = window_leftuppoint_x+x_span_half+window_width;
%     for i = x_span_half:-1:1
%         pixTotalNum = sum(sum(seg_kmean(window_leftuppoint_y + j:window_leftuppoint_y + j + window_heigh, ...\ 
%                                 window_leftuppoint_xnew + i:window_leftuppoint_xnew + i + window_width ) ));
%         if pixTotalNum < pixThreholdInWindow   
%             continue;
%         end                 
%                             if( pixTotalNum > pixTotalNum_max)
%                                 pixTotalNum_max = pixTotalNum;
%                                 window_i = i;
%                                 window_j = j;
%                             end
%    end


if pixTotalNum_max == 0
    rev = 1;
end

window_numOfPix = pixTotalNum_max;

end