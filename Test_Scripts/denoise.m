mask = find(brain==brain(1));
img = pad_brain (brain, 0.1);


%% Total variation denoising
% img_tv1=PDHG(double(img),.5,10^(-3));
img_tv2=PDHG(double(img),.05,10^(-3));
% img_tv3=PDHG(double(img),.01,10^(-3));
% figure,imshow(uint8(img_tv1));
img_tv2(img_tv2<5)=0;
% img_tv2(img_tv3<10)=0;
% figure,imshow(uint8(img_tv3));

%% Median Filtering
img2med = double(medfilt2(img));
% img2n = medfilt2(img2new);
% imshow(uint8(img2n));
% img2n = double(img2n);

%%
Ismooth = imguidedfilter(img);

%%
img = pad_brain(img_tv2,0.01);

numRows = 100; % Need to be tuned 256?
numCols = 100;  % Need to be tuned 256?
wavelengthMin = 4/sqrt(2);
wavelengthMax = hypot(numRows,numCols);
n = floor(log2(wavelengthMax/wavelengthMin));
wavelength = 2.^(0:0.5:(n-2)) * wavelengthMin;
deltaTheta = 30;
orientation = 0:deltaTheta:(180-deltaTheta);
% These combinations of frequency and orientation are taken from [Jain,1991] 

g = gabor(wavelength,orientation);
gabormag = imgaborfilt(img,g);

%% 
for i = 1:7
    x = i + 7*1;
    test = gabormag(:,:,x);
    test(mask) = 0;
    subplot(2,4,i);imshow(uint8(test))
    
end