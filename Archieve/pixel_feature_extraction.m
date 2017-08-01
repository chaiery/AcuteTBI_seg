function [dataset] = pixel_feature_extraction(pixel_list, brain, imgori_adjust)
    dataset = [];
    %% Extract Rectangular region around superpixel
    
    
    label_img = bwlabel(brain, 4);
    ImFilled = imfill(label_img, 'holes');
    bw_edge = edge(ImFilled, 'Canny');  
            
    %% Gabor filter
    % The number of features: 4*6*6 = 144
    % Build Gabor filters
    numRows = 256; % Need to be tuned
    numCols = 256;  % Need to be tuned
    wavelengthMin = 4/sqrt(2);
    wavelengthMax = hypot(numRows,numCols);
    n = floor(log2(wavelengthMax/wavelengthMin));
    wavelength = 2.^(0:(n-2)) * wavelengthMin;
    deltaTheta = 30;
    orientation = 0:deltaTheta:(180-deltaTheta);
    % These combinations of frequency and orientation are taken from [Jain,1991] 

    g = gabor(wavelength,orientation);
    gabormag = imgaborfilt(brain,g);
    
    for i = 1: length(pixel_list)
        dataset(i).pixel_index = pixel_list(i);
        [rowsub colsub] = ind2sub(size(brain), pixel_list(i));
        pixel_intensity = brain(pixel_list(i));
        recpatch = brain(rowsub-2:rowsub+2,colsub-2:colsub+2);
        dataset(i).recpatch = recpatch;
        dataset(i).recpatch32 = brain(rowsub-15:rowsub+16,colsub-15:colsub+16);
        
        PixelIdxList = [];
        for row = rowsub-2:rowsub+2
            for col = colsub-2:colsub+2
                PixelIdxList = [PixelIdxList sub2ind(size(brain),row,col)];
            end
        end
                    

        %% 1. Intensity
        % Median of pixels' intensities
        % The number of features: 5  
        intensities = double(recpatch(:));
        dataset(i).intensity_features = [double(pixel_intensity), mean(intensities), var(intensities), skewness(intensities), kurtosis(intensities)];
        
        %% 2. Entropy calculation
        dataset(i).entropy = entropy(recpatch);
        
        %% 3. Gabor filter 
        
       %sp = dataset(i).recpatch; 
       %gabormag = imgaborfilt(sp,g);
       
       gabor_features_mean = repelem(0,length(g));
       gabor_features_var = repelem(0,length(g));
       gabor_features_skew = repelem(0,length(g));
       gabor_features_kurt = repelem(0,length(g));

       for j = 1:length(g)
        %{
        sigma = 0.5*g(j).Wavelength;
        K = 3;
        gabormag(:,:,j) = imgaussfilt(gabormag(:,:,j),K*sigma);
        %}
        output = gabormag(:,:,j);
        output = output(PixelIdxList);
        
        gabor_features_mean(j) = mean(output(:));
        gabor_features_var(j) = var(output(:));
        gabor_features_skew(j) = skewness(output(:));
        gabor_features_kurt(j) = kurtosis(output(:));
       end

       dataset(i).gabor = [gabor_features_mean, gabor_features_var, gabor_features_skew, gabor_features_kurt];
       feature_index = [30    12     6     9    11    42    29    24    56     4];
       dataset(i).gabor = dataset(i).gabor(feature_index);

        %}

        % Each Gabor magnitude image contains some local variations, even within well segmented regions of constant texture.
        % These local variations will throw off the segmentation. 
        % We can compensate for these variations using simple Gaussian low-pass filtering to smooth the Gabor magnitude information.
        % We choose a sigma that is matched to the Gabor filter that extracted each feature. We introduce a smoothing term K that controls how much smoothing is applied to the Gabor magnitude responses.

        %% 4. GLCM (gray-level co-occurrence matrix )
        % The number of features: 4+3=7
        glcm = graycomatrix(recpatch,'NumLevels',16);
        stats = graycoprops(glcm);
        glcm_2 = graycomatrix(recpatch)/length(recpatch(:));
        dataset(i).glcm = [struct2array(stats), glcm_2(1,1), var(glcm_2(:)), sum(diag(glcm_2))];
        
        
        %% 5. Distance to edge of skull
        % The number of features: 3
        distance = distance_skull([rowsub, colsub], bw_edge, brain);
        dataset(i).distances = [distance, rowsub, colsub];
        

        %% 6. Discrete Fourier Transform (DFT).
        % The number of features: 4+32*4 =132
        % the maximal, minimal, median and mean value of the amplitude of DFT, as well as the frequency corresponding to the median value
        % of amplitude of DFT are extracted as the texture features
        Iroi = dataset(i).recpatch;
        DFT = fft2(double(recpatch));
        DFT2 = fftshift(DFT);
        DFT3 = log(1+DFT2);       

        DFTstats.min = min(abs(DFT3(:)));
        DFTstats.median = median(abs(DFT3(:)));
        [min_val,medfreq] = min(abs(abs(DFT3(:)) - DFTstats.median));  % consider including more than just one freq
        [ri, ci] = ind2sub(size(Iroi),medfreq);
        DFTstats.medfreqR = ri;
        DFTstats.medfreqC = ci;
        dft1 = struct2array(DFTstats);
        
        Iroi = dataset(i).recpatch32;
        DFT = fft2(double(Iroi));
        DFT2 = fftshift(DFT);
        DFT3 = log(1+DFT2);  
        
        index = isinf(DFT3);
        DFT3(index) = 10;
        [coeff,score,latent] = pca(abs(DFT3));

        dft2 = [coeff(:,1)', coeff(:,2)', score(:,1)', score(:,2)'];
        dataset(i).dft = [dft1 dft2];
        feature_index =  [84    8    34    80    79    86    90    91    35    15];
        dataset(i).dft = dataset(i).dft(feature_index);

    
    
        %% 7. wavelet packet transformation
        % The number of features: 16
        % second level with Haar wavelet
        % Then the energy of each image is calculated as
        % texture features. The last feature is the entropy calculated using the energy features.
        wpack = wpdec2(recpatch, 2, 'haar');
        dataset(i).wpenergy = wenergy(wpack);
    
        %% 8. Contour Features
        % The number of features: 5*4 =20
        nlevels = [0] ;        % Decomposition level
        pfilter = 'pkva' ;              % Pyramidal filter
        dfilter = 'pkva' ;              % Directional filter

        % We need to re-extract superpixels 
        % Need try using different filters
        % Contourlet decomposition
        patch = dataset(i).recpatch32;
        %  figure;imshow(img(1:16,1:16))
        coeffs = pdfbdec( double(patch), pfilter, dfilter, nlevels );
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
        feature_index = [13     2     6     4    14     1     3     5     8    16];
        dataset(i).contour = dataset(i).contour(feature_index);
 
    
    
        %% 9. Radon Features
        % The number of features: 5*4 =20   

        patch = dataset(i).recpatch32;
        theta = 0:30:180;
        [R,xp] = radon(patch,theta);
        
        % Using PCA
        [coeff,score,latent] = pca(R);
        radon_fs = [coeff(:,1)', coeff(:,2)', score(:,1)', score(:,2)'];
        dataset(i).radon = radon_fs;
        
        feature_index = [41    40    42    38    39    55    54    61    15    16    62    63    18    43    37 17    44    20    21    97];
        dataset(i).radon = dataset(i).radon(feature_index);
    end
    

    %% Final Features
    for i = 1: length(dataset)
        %dataset(i).features = [dataset(i).radon];
        dataset(i).features = [dataset(i).intensity_features, dataset(i).entropy, dataset(i).gabor ...
dataset(i).glcm, dataset(i).distances,dataset(i).dft, dataset(i).wpenergy,dataset(i).contour, dataset(i).radon];
    end

    
end

function distance = distance_skull(center, edge, imgori_sub)
    points = find(edge==1);
    
    edge_points = [];
    for i = 1:length(points)
        index = points(i);
        [coor_y, coor_x] = ind2sub(size(imgori_sub),index);
        %{
        coor_y = mod(index, size_h);
        if coor_y == 0
            coor_x = floor(index/size_h);
        else
            coor_x = floor(index/size_h)+1;
        end 
        %}
        edge_points(i,:) = [coor_x, coor_y];
    end
    distance = min(pdist2(edge_points,center,'euclidean'));
end


function energy = energy(vec)
    vec = vec(:);
    energy = mean(vec.*vec);
end