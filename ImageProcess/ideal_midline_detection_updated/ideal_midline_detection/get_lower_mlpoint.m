
%% This function get the point where the midline grows in the lower part by
%% detecting the gray midline in the lower part

function [rev,ml_pt]=get_lower_mlpoint(img_lower,mask_line)
rev = 0;
ml_pt=zeros(2,1);

if length(img_lower) == 3
    I=uint16(img_lower(:,:,1));
else
    I=uint16(img_lower);
end

delta_1=0;
[m,n]=size(I);

%% mask the points bellow mask_line-delta_1
% for i=[1:n]
%     I([mask_line(i)-delta_1:m],i)=0;
% end

%% mask using the highest point in mask_line
ind_min=min(mask_line');
if(ind_min==1)
    rev=1;
    return;
end
I2=I((1:ind_min-delta_1),:);
I2_temp=I2;

%% take off the valley by set all values bellow median the median
%% we need detect the ridge of the surface.
median_v=median(double(I2(:)));
Ind_med=find(I2<=median_v);
I2(Ind_med)=median_v;

%% use zero-cross edge detector
BW=edge(I2,'zerocross');
%% xyline=hough_proc(BW,BW);

%% use the intensity as the mask
tB=im2uint16(I2);
tB(find(tB==min(tB(:))))=0;
%% percentile cut, relative cut
perc=85;
thrd=prctile(tB(find(tB)),perc);
%% absolute value cut 
% because of the image format, the absolute threshold may be different.
% if(thrd>150)
%     thrd=150;
% end
tB2=tB;
tB2(find(tB>thrd))=1;
tB2(find(tB<=thrd))=0;
%% dilate the map
SE=ones(3);
tB_dilate=imdilate(tB2, SE);
%% mask the edge map
BW_temp=BW;
BW=BW.*double(tB_dilate);

%%  use sombel edge detector to get the edge
if(~(isa(I2,'single')||isa(I2,'double'))) I2=im2double(I2); end %% use single float

gh=imfilter(I2,fspecial('sobel')/8,'replicate');
gv=imfilter(I2,fspecial('sobel')'/8,'replicate');

%% mask all the points bellow mask_line-delta_2 as 0. This can get rid of the
%% edges created by skull and other parts.
% delta_2=6;
% [m,n]=size(gh);
% for i=[1:n]
%     gv([mask_line(i)-delta_2:m],i)=0;
%     gh([mask_line(i)-delta_2:m],i)=0;
% end

g_to=abs(gh)+abs(gv);

%% add the intensity influence to prefer high intensity
% g_t=double(-log2(I2)).*double(g_to);

g_t=g_to;

%% set threashold use median
% median_v=median(g_t(:));
%% use percentile
pert_v=prctile(g_t(find(g_t)), 80);
threashold=pert_v;  %% need to get automatically
g_t2=g_t;
g_t2(find(g_t2<threashold))=0;
g_t2(find(g_t2>threashold))=1;

BW2=double(g_t2).*double(BW);

BW3=BW2;

%% clear all clusters smaller than c_n pixels
c_n=floor(3*size(BW3,2)/121);
[imglabel, num]=bwlabel(BW3);
BW4=BW3;
for i=[1:num]
    num_clu=length(find(imglabel==i));
    if(num_clu<c_n)
        BW4(find(imglabel==i))=0;
    end
end

%% get the regions where pixels are croud
sum_column=sum(BW4);
[max_v,ind]=max(sum_column);
reg_width=10;
%% the first peak
reg_croud1=[max(ind-reg_width,1):min(ind+reg_width,size(BW4,2)),];

sum_column(reg_croud1)=0;
[max_v,ind]=max(sum_column);
reg_width=10;
%% the second peak
reg_croud2=[max(ind-reg_width,1):min(ind+reg_width,size(BW4,2)),];


sum_column(reg_croud2)=0;
[max_v,ind]=max(sum_column);
reg_width=10;
%% the third peak
reg_croud3=[max(ind-reg_width,1):min(ind+reg_width,size(BW4,2)),];

BW5=zeros(size(BW4));
BW5(:,reg_croud1)=1;
BW5(:,reg_croud2)=1;
BW5(:,reg_croud3)=1;

BW5=BW5.*BW4;


xyline=hough_proc(BW5,BW5);


%% return the lowest end point of the xyline
if(xyline(1,2)<xyline(2,2))
    ml_pt=xyline(2,:);
else
    ml_pt=xyline(1,:);
end

end
