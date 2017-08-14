%%
for i = 7
    img = result(i).pred_img;
    annot = result(i).annotated_img;
    brain =result(i).brain;
    pm = result(i).probability_map;
    %img_tv2=PDHG(double(brain),.05,10^(-3));
    %img_tv2(img_tv2<5)=0;
    %img_med = double(medfilt2(brain));
    figure;imshow(img)
    figure;imshow(pm*100)
    %figure;imshow(uint8(img_med))
   
    figure;imshow(annot)
end

%%
brain =  result(15).brain;
mask = find(brain==brain(1));
brain(mask) = 0;
%imgori = pad_brain(brain, 0.1);
%%

% imgori = double(medfilt2(imgori));
% img_tv2=PDHG(double(imgori),.05,10^(-3));
% img_tv2(img_tv2<5)=0;

%img_ori = double(medfilt2(brain));
img_ori = pad_brain(brain, 0.01);

% img_tv2=PDHG(double(img_ori),.05,10^(-3));
% img_tv2(img_tv2<5)=0;

ismooth = imguidedfilter(img_ori);
img_gabor = ismooth;

%%
   %% 3. Gabor filter ** 
    % The number of features: 4*6*6 = 144
    % Build Gabor filters
    %img_gabor = pad_brain(imgori,0.01);
    numRows = 100; % Need to be tuned 256?
    numCols = 100;  % Need to be tuned 256?
    wavelengthMin = 4/sqrt(2);
    wavelengthMax = hypot(numRows,numCols);
    n = floor(log2(wavelengthMax/wavelengthMin));
    wavelength = 2.^(0:0.5:(n-2)) * wavelengthMin;
    deltaTheta = 30;
    orientation = 0:deltaTheta:(180-deltaTheta);
    % These combinations of frequency and orientation are taken  from [Jain,1991] 

    g = gabor(wavelength,orientation);
    gabormag = imgaborfilt(img_gabor,g);
    % Filter 
%     for i = 1: length(dataset) 

%        
%        gabor_features_mean = repelem(0,length(g));
%        gabor_features_var = repelem(0,length(g));
%        gabor_features_mean_32 = repelem(0,length(g));
%        gabor_features_var_32 = repelem(0,length(g));
% 
%        for j = 1:length(g)
%         output = gabormag(:,:,j);
%         output(mask)=0;
%         %output_32 = output(dataset(i).y_range_32, dataset(i).x_range_32);
%         output = output(dataset(i).PixelIdxList);
%         
%         gabor_features_mean(j) = mean(outp,ut(:));
%         gabor_features_var(j) = var(output(:));
%         %gabor_features_mean_32(j) = mean(output_32(:));
%         %gabor_features_var_32(j) = var(output_32(:));
%         %gabor_features_skew(j) = skewness(output(:));
%         %gabor_features_kurt(j) = kurtosis(output(:));
%        end
% 
%        dataset(i).gabor = [gabor_features_mean, gabor_features_var];
%        %feature_index = [30    12     6     9    11    42    29    24    56     4];
%        %dataset(i).gabor = dataset(i).gabor;
    
    
    %%
    %% 
    for i = 1:7
        x = i + 7*0;
        test = gabormag(:,:,x);
        test(mask) = 0;
        subplot(2,4,i);imshow(uint8(test))

    end