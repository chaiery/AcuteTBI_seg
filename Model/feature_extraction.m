function [dataset] = feature_extraction(dataset, imgori)
    
    sizeofsub = size(imgori);
    
    mask = find(imgori==imgori(1));
    imgori(mask) = 0;
    
    rp = imfill(double(imgori),'holes');
    rp(rp>0) = max(max(rp));

    [rpb,~] = bwlabel(rp);
    rpbox = regionprops(rpb,'Centroid');
    cent_x = rpbox(1).Centroid(1,1);
    cent_y = rpbox(1).Centroid(1,2);
    
    imgori = pad_brain(imgori, 0.01);
    imgori = imguidedfilter(imgori);
    
    %% Total variation denoising
%     img_tv2=PDHG(double(imgori),.05,10^(-3));
%     img_tv2(img_tv2<5)=0;
%     imgori = img_tv2;
%     
    %% Median
    %Ismooth = imguidedfilter(imgori);
    %imgori = Ismooth;

    
    %% Extract Rectangular region around superpixel
    for i = 1: length(dataset)
        x1 = floor(dataset(i).BoundingBox(1,1));
        if x1 == 0
            x1 = 1;
        end
        y1 = floor(dataset(i).BoundingBox(1,2));
        if y1 == 0
            y1 = 1;
        end
        w = dataset(i).BoundingBox(1,3);
        h = dataset(i).BoundingBox(1,4);
        
        [m,n] = size(imgori);
        if (y1+h)>m
            h = h-1;
        end
        if (x1+w)>n
            w = w-1;
        end
        
        dataset(i).recpatch = imgori(y1:y1+h,x1:x1+w);
        dataset(i).y_range = y1:y1+h;
        dataset(i).x_range = x1:x1+w;
        
        % Then extend to 32*32
        % Find the center of the recpatch
        y_center = floor((y1+y1+h)/2);
        x_center = floor((x1+x1+w)/2);
        if x_center<16
            x_range = 1:32;
        elseif sizeofsub(2)-x_center<16
            x_range = sizeofsub(2)-31:sizeofsub(2);
        else
            x_range = x_center-15:x_center+16;
        end
            
        if y_center<16
            y_range = 1:32;
        elseif sizeofsub(1)-y_center<16
            y_range = sizeofsub(1)-31:sizeofsub(1);     
        else
            y_range = y_center-15:y_center+16;
        end
            
        dataset(i).recpatch32 = imgori(y_range,x_range);
        dataset(i).y_range_32 = y_range;
        dataset(i).x_range_32 = x_range;
    end
    
    
    %% Gradient 
    [Gmag, Gdir] = imgradient(imgori);

    for i = 1:length(dataset)
        f1 = [mean(Gmag(dataset(i).PixelIdxList)), var(Gmag(dataset(i).PixelIdxList)), mean(Gdir(dataset(i).PixelIdxList)), var(Gdir(dataset(i).PixelIdxList))];
        cent_sp = dataset(i).WeightedCentroid;
        d1 = cent_sp(1,1) - cent_x;
        d2 = cent_sp(1,2) - cent_y;
        distance = (d1^2+d2^2)^0.5;
        angle = d1/(d2+0.01);
        direction = d1/abs(d1);
        dataset(i).gradient= [f1,distance,angle,direction];
    end
    %% 1. Intensity **
    % Median of pixels' intensities
    % The number of features: 4
    %intensity_median = mean(imgori(:));
    %imgori_2 = imgori - intensity_median;
    for i = 1: length(dataset)
        sp_intensity = double(imgori(dataset(i).PixelIdxList));
        dataset(i).intensity_features = [mean(sp_intensity), var(sp_intensity),skewness(sp_intensity),kurtosis(sp_intensity)];
    end
    
    
    %% 2. Entropy calculation
    % The number of features: 1    
    for i = 1:length(dataset)
        patch = dataset(i).recpatch;
        dataset(i).entropy = [entropy(dataset(i).recpatch), entropy(dataset(i).recpatch32)];
    end
    
    
   %% 3. Gabor filter ** 
    % The number of features: 4*6*6 = 144
    % Build Gabor filters
    %img_gabor = pad_brain(imgori,0.01);
    numRows = 100; % Need to be tuned 256?
    numCols = 100;  % Need to be tuned 256?
    wavelengthMin = 4/sqrt(2);
    wavelengthMax = hypot(numRows,numCols);
    n = floor(log2(wavelengthMax/wavelengthMin));
    wavelength = 2.^(0:(n-2)) * wavelengthMin;
    deltaTheta = 30;
    orientation = 0:deltaTheta:(180-deltaTheta);
    % These combinations of frequency and orientation are taken from [Jain,1991] 

    g = gabor(wavelength,orientation);
    gabormag = imgaborfilt(imgori,g);
    % Filter 
    for i = 1: length(dataset)
       
       gabor_features_mean = repelem(0,length(g));
       gabor_features_var = repelem(0,length(g));
       gabor_features_mean_32 = repelem(0,length(g));
       gabor_features_var_32 = repelem(0,length(g));

       for j = 1:length(g)
        output = gabormag(:,:,j);
        output(mask)=0;
        %output_32 = output(dataset(i).y_range_32, dataset(i).x_range_32);
        output = output(dataset(i).PixelIdxList);
        
        gabor_features_mean(j) = mean(output(:));
        gabor_features_var(j) = var(output(:));
        %gabor_features_mean_32(j) = mean(output_32(:));
        %gabor_features_var_32(j) = var(output_32(:));
        %gabor_features_skew(j) = skewness(output(:));
        %gabor_features_kurt(j) = kurtosis(output(:));
       end

       dataset(i).gabor = [gabor_features_mean, gabor_features_var];
       %feature_index = [30    12     6     9    11    42    29    24    56     4];
       %dataset(i).gabor = dataset(i).gabor;
    end
    
    %% Another Gabor
    % The number of features: 4*6*6 = 144
    % Build Gabor filters
    for i = 1 : size(gabormag, 3)
         output = medfilt2(gabormag(:, :, i));
         output(mask) = 0;
         mean_img(:, :, i) = output;
    end
    
    num_wlen = size(wavelength, 2);
    num_orie = size(orientation, 2);
    
    % TODO stats of gabor response
    stat_features = {'mean'; 'var'; 'skewness'; 'kurtosis'};
    % Number of features: Gabor response + stats of each wavelength
    num_features = num_wlen * num_orie + size(stat_features, 1) * num_wlen; %TODO
    
    % Extract features
    for i = 1: size(dataset, 1)
        % Allocate space
        gabor_feature_i = zeros(num_features, 1);
        
        % Gabor response
        for j = 1 : size(mean_img, 3)
            gabor_feature_i(j) = mean_img(sub2ind(size(mean_img), ...
                floor(dataset(i).WeightedCentroid(2)), ...
                floor(dataset(i).WeightedCentroid(1)), j));
        end
        
        % Reshape into [wavelength, orientation]
        feature_i_tmp = reshape(...
            gabor_feature_i(1 : num_wlen * num_orie), num_wlen, num_orie)';
        
        % Stats of Gabor response
        ct = num_wlen * num_orie + 1;
        for j = 1 : size(stat_features, 1)
            stat_fh = str2func(stat_features{j});
            gabor_feature_i(ct : ct + num_wlen - 1) = stat_fh(feature_i_tmp)';
            ct = ct + num_wlen;
        end

        dataset(i).gabor2 = gabor_feature_i';
    end
    %}

    % Each Gabor magnitude image contains some local variations, even within well segmented regions of constant texture.
    % These local variations will throw off the segmentation. 
    % We can compensate for these variations using simple Gaussian low-pass filtering to smooth the Gabor magnitude information.
    % We choose a sigma that is matched to the Gabor filter that extracted each feature. We introduce a smoothing term K that controls how much smoothing is applied to the Gabor magnitude responses.
    
    
    %% 4. GLCM (gray-level co-occurrence matrix )
    % The number of features: 4+3=7
    for i = 1:length(dataset)
        rec = dataset(i).recpatch;
        glcm = graycomatrix(rec,'NumLevels',8, 'GrayLimits', []);
        stats = graycoprops(glcm);
        glcm_2 = graycomatrix(rec)/length(rec(:));
        
        rec_32 = dataset(i).recpatch32;
        glcm_32 = graycomatrix(rec_32,'NumLevels',8,'GrayLimits', []);
        stats_32 = graycoprops(glcm_32);
        
        dataset(i).glcm = [struct2array(stats), struct2array(stats_32)];
    end
    
    
     %% 5. Distance to edge of skull
%     % The number of features: 2
%     img_adjust = imgori - imgori(1);
%     label_img = bwlabel( img_adjust, 4);
%     ImFilled = imfill(label_img, 'holes');
%     bw_edge = edge(ImFilled, 'Canny');
%     
%     for i = 1:length(dataset)
%         distance = distance_skull(dataset(i).WeightedCentroid, bw_edge, imgori);
%         dataset(i).distances = [distance, dataset(i).WeightedCentroid(1), dataset(i).WeightedCentroid(2)];
%     end
%     
    %% 6. Discrete Fourier Transform (DFT). **
    % The number of features: 4+32*4 =132
    % the maximal, minimal, median and mean value of the amplitude of DFT, as well as the frequency corresponding to the median value
    % of amplitude of DFT are extracted as the texture features
    for i = 1:length(dataset)
        Iroi = dataset(i).recpatch;
        DFT = fft2(double(Iroi));
        DFT2 = fftshift(DFT);
        DFT3 = log(1+DFT2);       

        DFTstats.min = min(abs(DFT3(:)));
        DFTstats.median = median(abs(DFT3(:)));
        [min_val,medfreq] = min(abs(abs(DFT3(:)) - DFTstats.median));  % consider including more than just one freq
        [ri, ci] = ind2sub(size(Iroi),medfreq);
        DFTstats.medfreqR = ri;
        DFTstats.medfreqC = ci;
        DFTstats.medval = min_val;
        dft1 = struct2array(DFTstats);
        
        
        Iroi = dataset(i).recpatch32;
        DFT = fft2(double(Iroi));
        DFT2 = fftshift(DFT);
        DFT3 = log(1+DFT2);  
        
        DFTstats.min = min(abs(DFT3(:)));
        DFTstats.median = median(abs(DFT3(:)));
        [min_val,medfreq] = min(abs(abs(DFT3(:)) - DFTstats.median));  % consider including more than just one freq
        [ri, ci] = ind2sub(size(Iroi),medfreq);
        DFTstats.medfreqR = ri;
        DFTstats.medfreqC = ci;
        DFTstats.medval = min_val;
        dft2 = struct2array(DFTstats);
        %index = isinf(DFT3);
        %DFT3(index) = 10;
        %[coeff,score,latent] = pca(abs(DFT3));

        %dft2 = [coeff(:,1)', coeff(:,2)', score(:,1)', score(:,2)'];
        dataset(i).dft = [dft1 dft2];
        %feature_index =  [84    8    34    80    79    86    90    91    35    15];
        %dataset(i).dft = dataset(i).dft(feature_index);
    end    

    
    
    %% 7. wavelet packet transformation **
    % The number of features: 16
    % second level with Haar wavelet
    % Then the energy of each image is calculated as
    % texture features. The last feature is the entropy calculated using the energy features.
    for i = 1:length(dataset)
        Iroi = dataset(i).recpatch;
        wpack = wpdec2(Iroi, 2, 'haar');
        dataset(i).wpenergy = wenergy(wpack);
    end
    
    %% 8. Contour Features **
    % The number of features: 5*4 =20
    nlevels = [0] ;        % Decomposition level
    pfilter = 'pkva' ;              % Pyramidal filter
    dfilter = 'pkva' ;              % Directional filter

    % We need to re-extract superpixels 
    % Need try using different filters
    % Contourlet decomposition
    for i = 1:length(dataset)
        patch = dataset(i).recpatch32;
        %  figure;imshow(img(1:16,1:16))
        coeffs = pdfbdec(double(patch), pfilter, dfilter, nlevels);
        % imcoeff = showpdfb( coeffs );
        c2 = coeffs{1,2};
        cvcell = {coeffs(1), c2(1), c2(2), c2(3)};
        
        %{
        cv(1) = pdfb2vec(coeffs(1));
      
        cv = pdfb2vec(c2(1));
        cv3 = pdfb2vec(c2(2));
        cv4 = pdfb2vec(c2(3));
        %}
        
        contour_fs = cell2mat(arrayfun(@(x)[mean(pdfb2vec(cvcell{1,x})),var(pdfb2vec(cvcell{1,x})), skewness(pdfb2vec(cvcell{1,x})),kurtosis(pdfb2vec(cvcell{1,x})), energy(pdfb2vec(cvcell{1,x}))],1:4,'un',0));
        dataset(i).contour = contour_fs;
        %feature_index = [13     2     6     4    14     1     3     5     8    16];
        %dataset(i).contour = dataset(i).contour(feature_index);
    end
    
    
    %% 9. Radon Features **
    % The number of features: 5*4 =20   
%     for i = 1:length(dataset)
%         patch = dataset(i).recpatch32;
%         theta = 0:30:180;
%         [R,xp] = radon(patch,theta);
%         
%         % Using PCA
%         [coeff,score,latent] = pca(R);
%         radon_fs = [coeff(:,1)', coeff(:,2)', mean(R), var(R), skewness(R), kurtosis(R)];
%         dataset(i).radon = radon_fs;
%         
%     end
   

    
    %% 10. Saliency Features
    % 1. Calculate the distances pairwise
    % Extablish centroid matrix
    %centroids = zeros(length(dataset),2);
%     centroids = [];
%     for i  = 1:length(dataset)
%         centroids(end+1,:) = dataset(i). WeightedCentroid;
%     end
%     
%     for i = 1:length(dataset)
%         distances = pdist2(centroids, dataset(i).WeightedCentroid,'euclidean');
%         [~, I] = sort(distances);
%         %index_near = I(2:6);
%         index_rand = I(randsample(length(I),min(40,length(I))));
%         
%         %near = cell2mat(arrayfun(@(x) (dataset(index_near(x)).MeanIntensity-dataset(i).MeanIntensity)^2,1:5,'un',0));
%         rand = cell2mat(arrayfun(@(x) (dataset(index_rand(x)).MeanIntensity-dataset(i).MeanIntensity)^2,1:min(40,length(I)),'un',0));
%         dataset(i).saliency = [mean(rand), var(rand)];
%     end

    
    % 2. Extract 5 near the target patch and 10 random patches
    % 3. Calculate feature distances between target patches and others
    % extracted
    
  
    %% 11. Local binary patterns
    %extractLBPFeatures
    

    %% Final Features
    %new_dataset = [];
    for i = 1: length(dataset)
        %dataset(i).features = [dataset(i).radon];
        dataset(i).features = [dataset(i).gradient, dataset(i).intensity_features, dataset(i).entropy, dataset(i).gabor, dataset(i).gabor2 ...
dataset(i).glcm, dataset(i).dft, dataset(i).wpenergy,dataset(i).contour];

    end

    
end

function distance = distance_skull(center, bw_edge, imgori)
    points = find(bw_edge==1);
    
    edge_points = [];
    for i = 1:length(points)
        index = points(i);
        [coor_x, coor_y] = ind2sub(size(imgori),index);
        %{
        coor_y = mod(index, size_h);
        if coor_y == 0
            coor_x = floor(index/size_h);
        else
            coor_x = floor(index/size_h)+1;
        end 
        %}
        edge_points(i,:) = [coor_y, coor_x];
    end
    distance = min(pdist2(edge_points,center,'euclidean'));
end


function energy = energy(vec)
    vec = vec(:);
    energy = mean(vec.*vec);
end