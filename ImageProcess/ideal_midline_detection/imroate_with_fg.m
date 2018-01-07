%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Wenan Chen
%% September, 2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% This function rotate the image by only specify the foreground pixels
%% There will be some small holes inside the rotated image, not solved yet
function rota_img=imroate_with_fg(centered_img, angle, method)

%% input: centered_img is the image to be rotated. Only deals with m*n
%% images

if(nargin<3)
    method='loose';
end
n_dim=ndims(centered_img);
if(n_dim==3)
    fprintf('Error: only deals with m*n images\n');
    rota_img=[];
    return;
end

[m,n]=size(centered_img);Canvas=zeros(m*2,n*2);
origin_x=floor(n/2); origin_y=floor(m/2); 
origin_x_new=n; origin_y_new=m;
[ind_m,ind_n]=find(centered_img);

N=length(ind_m);
angle_rad=angle*pi/180;
cos_angle=cos(angle_rad);
sin_angle=sin(angle_rad);
rotation_matrix=[cos_angle, sin_angle; -sin_angle, cos_angle];


% for i=1:N
%     x=ind_n-origin_x;
%     y=origin_y-ind_m;
%     p1=[x,y];
%     p_new=floor(p1*rotation_matrix);
%     ind_m_new=origin_y_new-p_new(2);
%     ind_n_new=p_new(1)+origin_x_new;
%     Canvas(ind_m_new,ind_n_new)=1;
% end

%% get the above into matrix computing
X=ind_n-repmat(origin_x,N,1);
Y=repmat(origin_y,N,1)-ind_m;
P1=[X,Y];
P_new=floor(P1*rotation_matrix);
Ind_m_new=repmat(origin_y_new,N,1)-P_new(:,2);
Ind_n_new=P_new(:,1)+repmat(origin_x_new,N,1);
Ind=sub2ind(size(Canvas),Ind_m_new, Ind_n_new);
Canvas(Ind)=centered_img(sub2ind(size(centered_img),ind_m, ind_n));

if(strcmp(method,'loose'))
    rota_img=Canvas;
elseif(strcmp(method,'crop'))
    rota_img=Canvas([floor(m/2):floor(m/2)+m-1],[floor(n/2):floor(n/2)+n-1]);
else
    fprintf('wrong input of input\n');
end

    