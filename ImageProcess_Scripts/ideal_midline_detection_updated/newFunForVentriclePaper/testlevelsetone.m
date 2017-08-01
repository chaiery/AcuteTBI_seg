% This Matlab file demomstrates a level set method in Chunming Li et al's paper
%    "Minimization of Region-Scalable Fitting Energy for Image Segmentation",
%    IEEE Trans. Image Processing, vol. 17 (10), pp.1940-1949, 2008.
% Author: Chunming Li, all rights reserved
% E-mail: li_chunming@hotmail.com
% URL:  http://www.engr.uconn.edu/~cmli/
%
% Note 1: This method with a small scale parameter sigma, such as sigma = 3, is sensitive to 
%         initialization of the level set function. Appropriate initial level set functions are given in 
%         this code for different test images.
% Note 2: There are several ways to improve the original LBF model to make it robust to initialization.
%         One of the improved LBF algorithms is implemented by the code in the folder LBF_v0.1


% clc;clear all;close all;
c0 = 2;

imgname='D:\myNetDriver\qxgbuy2011\project_ventricle_paper\data_testResult\dir_ideal\Patient 2338603_05202006 - 045944_17.png'
imgname='D:\myNetDriver\qxgbuy2011\literature\important\RSF_v0_v0.1\RSF_v0\1.bmp';
Img = imread(imgname);
Img_keep = Img;

Img_keep_3d = zeros([size(Img),3]);
Img_keep_3d(:,:,1) = Img;Img_keep_3d(:,:,2) = Img;Img_keep_3d(:,:,3) = Img;
Img_keep_3d(:,384,2) = 255;

% Img = imread([num2str(imgID),'.png']);
mask_new = zeros(size(Img)); 
% mask_new(260:380,320:450)=1;
mask_new(200:400,300:480)=1;
Img = floor(uint8(mask_new).*uint8(Img));

% Img = imread([num2str(imgID),'.bmp']);
Img = double(Img(:,:,1));

        iterNum =40;
        lambda1 = 1.0;
        lambda2 = 1.0;
        nu = 0.004*255*255;% coefficient of the length term
        initialLSF = ones(size(Img(:,:,1))).*c0;
%         initialLSF(20:70,30:90) = -c0;
%         initialLSF(150:300,170:280) = -c0;
%         initialLSF(280:380,350:450) = -c0;
%         initialLSF(261:379,321:449) = -c0;
        initialLSF(200:400,300:480) = -c0;
    
u = initialLSF;
figure;imagesc(Img, [0, 255]);colormap(gray);hold on;axis off,axis equal
title('Initial contour');
[c,h] = contour(u,[0 0],'r');
pause(0.1);

timestep = .1;% time step
mu = 1;% coefficient of the level set (distance) regularization term P(\phi)

epsilon = 1.0;% the papramater in the definition of smoothed Dirac function
sigma=3.0;    % scale parameter in Gaussian kernel
              % Note: A larger scale parameter sigma, such as sigma=10, would make the LBF algorithm more robust 
              %       to initialization, but the segmentation result may not be as accurate as using
              %       a small sigma when there is severe intensity inhomogeneity in the image. If the intensity
              %       inhomogeneity is not severe, a relatively larger sigma can be used to increase the robustness of the LBF
              %       algorithm.
K=fspecial('gaussian',round(2*sigma)*2+1,sigma);     % the Gaussian kernel
I = Img;
KI=conv2(Img,K,'same');     % compute the convolution of the image with the Gaussian kernel outside the iteration
                            % See Section IV-A in the above IEEE TIP paper for implementation.
                                                 
KONE=conv2(ones(size(Img)),K,'same');  % compute the convolution of Gassian kernel and constant 1 outside the iteration
                                       % See Section IV-A in the above IEEE TIP paper for implementation.

% start level set evolution
for n=1:iterNum
    u=RSF(u,I,K,KI,KONE, nu,timestep,mu,lambda1,lambda2,epsilon,1);
    if mod(n,20)==0
        pause(0.1);
        imagesc(Img, [0, 255]);colormap(gray);hold on;axis off,axis equal
        [c,h] = contour(u,[0 0],'r');
        iterNum=[num2str(n), ' iterations'];
        title(iterNum);
        hold off;
    end
end
close;

% imagesc(Img_keep, [0, 255]); colormap(gray);
% hold on;axis off,axis equal
h = figure, imshow(uint8(Img_keep_3d),[]); hold on;axis off,axis equal
[c,h] = contour(u,[0 0],'r');
totalIterNum=[num2str(n), ' iterations'];
title(['Final contour, ', totalIterNum]);

saveas(h, 'seg_result', 'png');
close;

% Img_d = imread('seg_result.png');
% Img_s = zeros([size(Img),3]);
% Img_s(:,:,:) = Img_d(67:834,217:984, :);
% 
% for i=1:3
% Img_s(1:768,1:768, i) = Img_d(67:834,217:384, i);
% end

figure;
h=mesh(u);
title('Final level set function');
saveas(h, 'levelSet_result', 'png');
close;
