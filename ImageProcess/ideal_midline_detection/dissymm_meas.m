%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Wenan Chen
%% Sep 24rd, 2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function dis=dissymm_meas(Img, method)
%% symmetric measument: symm=\sum{i=1}{n}(|l_i-r_i|), i is the row index
%% and l_i, r_i is the symmetry measure for each line. The center line 
%% is the just the image center line: x=floor(size(img,2)/2)

if(nargin<2)
    method='mid2ct';
end
sum_dis=0;
[m,n]=size(Img);
c_line=floor(n/2);
r_center=floor(m/2);
dis_arr=zeros(1,m);
%% debug
td=zeros(m,1);
lv=zeros(m,1);
rv=zeros(m,1);

for i=[1:m]%[r_center-100:1:r_center+255]
    left_pixels=Img(i,1:c_line);
    right_pixels=Img(i,c_line+1:n);
    r_i=vec_meas(right_pixels,method); 
    l_i=vec_meas(left_pixels(end:-1:1),method); %% reverse the vector to apply method
    if(r_i==0 || l_i==0) %% no need to count the crack for dissymmetry
        continue;
    end
    sum_dis=sum_dis+abs(r_i-l_i);
    lv(i)=l_i;
    rv(i)=r_i;
    td(i)=abs(r_i-l_i);
    dis_arr(i)=abs(r_i-l_i);
end


dis=sum_dis;

end

function vm=vec_meas(vec_pixels, method)

I=find(vec_pixels~=0);
if(isempty(I))
            vm=0;
            return;
end

switch method
    case 'force_tq'
        %% calculate the force torque with the leftmost pixel as the fulcurm point
        ft=0;
        n=length(I);
        ft=sum(I);
        vm=ft;
    case 'thickness'
        %% calculate the thickness
        vm = max(I)-min(I);
    case 'mid2ct'
        %% calculate the middle point of the skull cut to the center
        vm =(max(I)+min(I))/2;
    case 'max'
        vm = max(I);
    case 'min'
        vm = min(I);
        
        
end

end


