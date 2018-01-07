%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Wenan Chen
%% October, 2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% exhaustively search rotating angles that make the skull image as
%% symmetric as possible. delta_ang is the  degree of angle rotation each 

function [rotate_angle,dis_vec, best_j]=rota_symm_search(centered_img, angle1, angle2, delta_ang, method)

%% input: centered_img is the input image. rotation search will rotate the 
%% image with the center of the image. angle1 and angle2 is the rotation
%% search rangle

rotate_angle=0;
if(nargin<4)
    delta_ang=4;
end
if(nargin<5)
    method='mid2ct';
end
if(nargin==1)
    Max_ang=45; %% max angle to rotate left and right
    N_rot=floor(Max_ang/delta_ang);
    min_angle=-Max_ang;
    max_angle=Max_ang;
elseif(nargin==2||nargin>5)
    fprintf('wrong number of parameters, need two angles to specify the range\n');
    return;
elseif(nargin>=3)
    min_angle=min(angle1,angle2);
    max_angle=max(angle1,angle2);
end

rota_img=imroate_with_fg(centered_img,0,'crop');

%% for animation images
% folder='animation';
% if(isunix) 
%     del='/';
% else
%     del='\';
% end
% imwrite(rota_img, strcat('..',del,folder,del,'0.png'));


dissymm=dissymm_meas(rota_img, method)+1;
best_i=0;
% tic
range=[min_angle:delta_ang:max_angle];
dis_vec=zeros(1,length(i));
j=1;
best_j=1;
for it=range
%     rota_img=imrotate(centered_img,i,'nearest','crop');
    rota_img=imroate_with_fg(centered_img, it, 'crop');
    rota_img=bwmorph(rota_img, 'bridge');
     
     %% for animation images
%      imwrite(rota_img, strcat('..',del,folder,del,int2str(i),'.png'));
     
    %% imshow(rota_img);
    % dis = 1;
    dis=dissymm_meas(rota_img, method);
    dis_vec(j)=dis; 
    if(dis<dissymm)
        best_i=it;
        best_j=j;
        dissymm=dis;
    end
    j=j+1;
    %% output
%     fprintf('Angle rotated: %f, Dissymm: %f\n',it,dis);
end

%% output the best rotated angle
fprintf('Best rotated angle is: %f\n', best_i);
% toc

rotate_angle=best_i;

%% for animation images
% imwrite(imrotate(centered_img,best_i,'crop'), strcat('..',del,folder,del,'f.png'));