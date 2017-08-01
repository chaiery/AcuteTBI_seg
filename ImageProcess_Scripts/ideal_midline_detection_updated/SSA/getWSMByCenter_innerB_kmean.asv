function  [WSM,winStru, rev] = getWSMByCenter_innerB_kmean(center, innerbrain_mask, seg_kmean )

WSM = 0; % window_numOfPix = 0;
window_i = 1;
window_j = 1;

pixThreholdInWindow = 120;

s_win_width = 120;
s_win_height = 200;
winStru = [window_i,window_j,s_win_width,s_win_height,pixThreholdInWindow];
rev = 0;
%  

% ????? center ? 
%          width = max(????, ???-30??
%          height = max?????, ???-30 ??
% ?? ???? ???? ??? ??? ??????1?
% ??? ? ??? ?? 120 ? 200 
% 
% ??????? ?? WFM -> ???? max-WFM ???


[L, Ne] = bwlabel(innerbrain_mask);
propied = regionprops(L, 'Orientation', 'MajorAxisLength', ...
      'MinorAxisLength', 'Eccentricity', 'Centroid','BoundingBox');

  if length(propied) ~= 1
    return;
  end

  cen = uint16(propied(1).Centroid);
  bbox = uint16(propied(1).BoundingBox);
  xleft_direction = uint16(min(bbox(1) + 40,cen(1) ));
  xright_direction = uint16(max( bbox(1) + bbox(3)-40 , cen(1)) );
  
  if xleft_direction == xright_direction
      return;
  end
  if (xright_direction-xleft_direction) < s_win_width
      s_win_width = xright_direction-xleft_direction;
     % return;
  end
  
  ytop = uint16(min(bbox(2) + 60,cen(2) )); 
  ybottom = uint16(max(ytop + (bbox(4)/2) - 20, cen(2)));
  
  if ytop == ybottom
      return;
  end
  if (ybottom-ytop) < s_win_height
     s_win_height = ybottom-ytop;
      % return;
  end
  
  pixTotalNum_max = 0;
  
for i = xleft_direction:(xright_direction-s_win_width)  
   for j = ytop:(ybottom-s_win_height)
        pixTotalNum = sum(sum(seg_kmean( j:j + s_win_height, ...\ 
                                i:i + s_win_width ) ));
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

WSM = pixTotalNum_max;
winStru = [window_i,window_j,s_win_width,s_win_height,pixThreholdInWindow];
 
  
% propied = regionprops(L, 'MajorAxisLength','MinorAxisLength','Orientation');
% figure, imshow(seg_kmean,[]); 
% for n = 1:size(propied,1)
%    rectangle('Position',propied(n).BoundingBox, 'EdgeColor', 'g', 'LineWidth',2);
%    rectangle('Position',propied(n).BoundingBox,'Curvature',[1,1], 'FaceColor','r');
% end

% figure, imshow(innerbrain_mask,[]);
% 
% hold on
% 
% phi = linspace(0,2*pi,50);
% cosphi = cos(phi);
% sinphi = sin(phi);
% 
% for k = 1:length(propied)
%     xbar = propied(k).Centroid(1);
%     ybar = propied(k).Centroid(2);
% 
%     a = propied(k).MajorAxisLength/2;
%     b = propied(k).MinorAxisLength/2;
% 
%     theta = pi*propied(k).Orientation/180;
%     R = [ cos(theta)   sin(theta)
%          -sin(theta)   cos(theta)];
% 
%     xy = [a*cosphi; b*sinphi];
%     xy = R*xy;
% 
%     x = xy(1,:) + xbar;
%     y = xy(2,:) + ybar;
% 
%     plot(x,y,'r','LineWidth',2);
% end
% hold off
% 
% imshow(seg_kmean);
% hold on
% 
% phi = linspace(0,2*pi,50);
% cosphi = cos(phi);
% sinphi = sin(phi);
% 
% for k = 1:length(propied)
%     xbar = propied(k).Centroid(1);
%     ybar = propied(k).Centroid(2);
% 
%     a = propied(k).MajorAxisLength/2;
%     b = propied(k).MinorAxisLength/2;
% 
%     theta = pi*propied(k).Orientation/180;
%     R = [ cos(theta)   sin(theta)
%          -sin(theta)   cos(theta)];
% 
%     xy = [a*cosphi; b*sinphi];
%     xy = R*xy;
% 
%     x = xy(1,:) + xbar;
%     y = xy(2,:) + ybar;
% 
%     plot(x,y,'r','LineWidth',2);
%     propied(k).Orientation
% end
% hold off

% 
% window_i = 0;
% window_j = 0;
% window_numOfPix = 0;
% rev = 0;
% 
% window_leftuppoint_x = windowStru(1);
% window_leftuppoint_y = windowStru(2);
% window_width = windowStru(3);
% window_heigh = windowStru(4);
% pixThreholdInWindow = windowStru(5);
% 
% pixTotalNum_max = 0;
% for i = 1:5    
%    for j = 1:2:41
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
% 
% if pixTotalNum_max == 0
%     rev = 1;
% end
% 
% window_numOfPix = pixTotalNum_max;



end