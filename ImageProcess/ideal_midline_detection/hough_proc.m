function longest_line=hough_proc(BW, BW2)

[H,theta,rho] = hough(BW);

%% find the median length of the curves in edge map

tB=BW;
[L,num]=bwlabel(tB);
max_len=0;
max_l=0;
len_vec=zeros(1,num);
for i=[1:num]
    len_vec(i)=length(find(L==i));
end
med_len=median(len_vec);


%% Display the transform. 
% figure;
% imshow(H,[],'XData',theta,'YData',rho,...
%         'InitialMagnification','fit');
% xlabel('\theta'), ylabel('\rho');
% axis on, axis normal, hold on;

%% Find the peaks in the Hough transform matrix, H, using the houghpeaks function. 
P = houghpeaks(H,9,'threshold',ceil(0.3*max(H(:))));

%% Plot the peaks. 
% x = theta(P(:,2)); 
% y = rho(P(:,1));
% plot(x,y,'s','color','white');

%% Find lines in the image. 
lines = houghlines(BW,theta,rho,P,'FillGap',3,'MinLength',5);

showlines=0;
%% Create a plot that superimposes the lines on the original image. 
if(showlines==1)
    figure, imshow(BW2),  %% set the image you want to show
    hold on
end
%% if no lines detected, just reture the left corner of the image
left_corner=[0,0;0,0];
if((length(lines)==0) || isempty(fieldnames(lines(1))))
    longest_line=left_corner;
    return;
end

max_len = 0;
xy_long = [];
sum_region=zeros(1,size(BW,2)); %% record the region of lines
angle_stat=zeros(1, length(lines));

angle=40;
cot_angle=cot((90-angle)/180*pi);
big_stamp=size(BW, 2)/size(BW,1);
   
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   
    if(abs(xy(2,2)-xy(1,2))<=0.001)    %% horizontal line
        linecolor='blue';
        angle_stat(k)=big_stamp; 
    else
    
   
   cot_angle_k=(xy(2,1)-xy(1,1))/(xy(2,2)-xy(1,2));
   
   abs_cot_angle = abs(cot_angle_k);
      
   if(abs_cot_angle<cot_angle)
       linecolor='green';
       sum_region([xy(1,1):xy(2,1)])=sum_region([xy(1,1):xy(2,1)])+1;
       sum_region([xy(2,1):xy(1,1)])=sum_region([xy(2,1):xy(1,1)])+1;
       angle_stat(k)=cot_angle_k;
   else
       linecolor='blue';
       angle_stat(k)=big_stamp;
   end
   end
   
   if(showlines==1)
       plot(xy(:,1),xy(:,2),'LineWidth',2,'Color',linecolor);

       % Plot beginnings and ends of lines 
       plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
       plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
   end
   
end

angle_stat2=angle_stat(find(angle_stat~=big_stamp));
if(isempty(angle_stat2)) longest_line=left_corner; return; end
angle_mean=mean(angle_stat2);
angle_std=std(angle_stat2);

[maxv,ind_max_region]=max(sum_region);
region_focus=[max(ind_max_region-15,1), min(ind_max_region+15,length(sum_region))];
center_thrd=0.25;
center_region=[center_thrd*size(BW,2), (1-center_thrd)*size(BW,2)];

for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
  
   if(abs(xy(2,2)-xy(1,2))<=0.001) continue; end %% horizontal line
   abs_cot_angle = abs((xy(2,1)-xy(1,1))/(xy(2,2)-xy(1,2)));
   
   % Determine the endpoints of the longest line segment with absolute angles 
   % below angle 
   len = norm(lines(k).point1 - lines(k).point2);
   
   %% at least one point must in the center region
   if((min(xy(:,1))>center_region(2))||(max(xy(:,1))<center_region(1)))
       continue;
   end
   
   %% must in the region of multiple lines
   if(((xy(1,1)<region_focus(1)) && (xy(2,1)<region_focus(1))) || ((xy(1,1)>region_focus(2)) && (xy(2,1)>region_focus(2))))
       continue;
   end
   
   %% must in the variance of angles
   if((angle_stat(k)>angle_mean+2*angle_std)||(angle_stat(k)<angle_mean-2*angle_std))
       continue;
   end
   if ( (len > max_len)&&( abs_cot_angle<cot_angle ))
      max_len = len;
      xy_long = xy;
   end
end

if(isempty(xy_long))
    longest_line=left_corner;
    return;
end

%% get the lowest point of the line of which the distance of the midpoint
%% to the longest line is smalleer than N_dist pixels.
%% suppost p1_p2 is the longest line, p1=(x1,y1), p2=(x2,y2). denote n=p2-p1=(x,y), 
%% z=(z1,z2)=m-p1 is the midpoint of the other line minus p1, then the distance can be calculated as:
%% z \dot n/abs(n) = abs(z1*x-z2*y)/sqrt(x^2+y^2);
N_dist=4;
lowest_y=0;
lowest_line=xy_long;
thrd=cos(10/180*pi);
for k = 1:length(lines)
    l_xy = [lines(k).point1; lines(k).point2];
    
    x1=xy_long(1,1);y1=xy_long(1,2);x2=xy_long(2,1);y2=xy_long(2,2);
    p1=[x1,y1];p2=[x2,y2]; L1=p2-p1;
    p3=l_xy(1,:); p4=l_xy(2,:); L2=p4-p3;
    x=x1-x2; y=y1-y2;
    
    %% make sure the two lines direction not very larger
    cos_angle_btw=abs(L2*L1')/(norm(L2)*norm(L1));
    if(cos_angle_btw<thrd) continue; end
    
    %% make sure this two lines are not very far way. use the 
    len2=norm(p4-p3);
    
    d1=norm(p4-p1);
    d2=norm(p4-p2);
    d3=norm(p3-p1);
    d4=norm(p3-p2);
    
    if(min([d1,d2,d3,d4]>len2)) continue; end
    
    z1=(l_xy(1,1)+l_xy(2,1))/2-x2;
    z2=(l_xy(1,2)+l_xy(2,2))/2-y2;

    
    dist=abs(z1*y-x*z2)/sqrt(x^2+y^2);
    if(dist<N_dist)
        if(lowest_y<max(l_xy(:,2)))
            lowest_line=l_xy;
            lowest_y=max(l_xy(:,2));
        end
    end
    
end 




%% return the longest line points
longest_line=lowest_line;
