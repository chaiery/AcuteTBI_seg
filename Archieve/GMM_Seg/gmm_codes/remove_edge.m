function fimg = remove_edge(x,y,img)

[n,m] = size(img);
angles1 = 0:22.5:157.5;
angles2 = angles1+180;
dist = ones(length(angles1),2)*30;
r = 1; bReach=zeros(length(angles1),1);xnew = x;ynew = y;
while sum(bReach)<4 && r<6
    for t = 1:length(angles1)
        xnew = ceil(r * cosd(angles1(t)) + x);
        ynew = ceil(-r * sind(angles1(t)) + y);
        if 1<ynew && ynew<n && 1<xnew && xnew<m
            if img(ynew,xnew)==0 && bReach(t)~=1 
             dist(t,1) = r; bReach(t)=1;
            end
        end
    end
    r = r+1;
end
r = 1; bReach=zeros(length(angles1),1);xnew = x;ynew = y;
while sum(bReach)<4 && r<6
    for t = 1:length(angles2)
        xnew = ceil(r * cosd(angles2(t)) + x);
        ynew = ceil(-r * sind(angles2(t)) + y);
        if 1<ynew && ynew<n && 1<xnew && xnew<m
            if img(ynew,xnew)==0 && bReach(t)~=1 
             dist(t,2) = r; bReach(t)=1;
            end
        end
    end
    r = r+1;
end


min_width = min(sum(dist,2));
% min_dir = mean(angles1(sum(dist,2)==min_width));

if min_width <6
%     r1 = mean(dist(sum(dist,2)==min_width,1));
%     r2 = mean(dist(sum(dist,2)==min_width,2));
% 
%     rmax = max(r1,r2);
    [nzy,nzx] = find(img);
    nzidx = find((nzy-y).^2+(nzx-x).^2<=min_width.^2);
    img(nzy(nzidx),nzx(nzidx)) = 0;
    
%     for i = 1:0.5:ceil(r1)
%       img(ceil(-i * sind(min_dir) + y),ceil(i * cosd(min_dir) + x)) = 0;  
%     end
%     
%     
%     for i = 1:0.5:r2
%       img(ceil(-i * sind(180+min_dir) + y),ceil(i * cosd(180+min_dir) + x)) = 0;  
%     end
end

fimg = img;

end
















