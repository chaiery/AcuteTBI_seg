fileDir = 'Z:\Projects\Brain Injury Detection\Eunji_Code\10efinal';
addpath('C:\Projects\math_code\GLRL\GLRL');

filename = '16.png';
RotatedDir = [fileDir '\Processed\dir_ideal\'];
img = imread([RotatedDir, filename]);

%% for now explore different areas of the image
figure; imshow(img);
[x,y]=ginput(1);
half_W = 32;
half_H = 32;
top = y-half_H+1; top = uint32(top);
bottom = y+half_H; bottom = uint32(bottom);
left = x-half_W+1; left = uint32(left);
right = x+half_W; right = uint32(right);
Iroi = img(top:bottom, left:right);
hold on;
rectangle('Position',[left,top,2*half_H, 2*half_W]);
%

%% 1. Histogram Variance and Smoothness (R)
numBin = 10;
hist1 = histogram(Iroi,numBin); % change the bin size to see if it shows any difference
histVal = hist1.Values;
binVal = (hist1.BinEdges(2:end) + hist1.BinEdges(1:end-1))/2;
histProbability = histVal / sum(histVal);
histMean = sum(binVal .* histProbability);
histVar = sum((binVal.^2) .* (histProbability)) - histMean^2;
smoothnessR = 1 - 1/(1+histVar);


%% 2. Run Gray Level Run Length Matrix (GLRLM) and its statistics
[GLRLMS,SI] = grayrlmatrix(double(Iroi),'NumLevels',255,'G',[min(Iroi(:)) max(Iroi(:))]);
GLRLMstats = grayrlprops(GLRLMS);
%figure; imagesc(stats)

%% 3. Discrete Fourier Transform (DFT).
% the maximal, minimal, median and mean
% value of the amplitude of DFT, as well as the frequency corresponding to the median value
% of amplitude of DFT are extracted as the texture features
DFT = fft2(double(Iroi));
DFT2 = fftshift(DFT);
DFT3 = log(1+DFT2);

DFTstats.max = max(abs(DFT3(:)));
DFTstats.min = min(abs(DFT3(:)));
DFTstats.mean = mean(abs(DFT3(:)));
DFTstats.median = median(abs(DFT3(:)));
[min_val,medfreq] = min(abs(abs(DFT3(:)) - DFTstats.median));  % consider including more than just one freq
[ri, ci] = ind2sub(size(Iroi),medfreq);
DFTstats.medfreqR = ri;
DFTstats.medfreqC = ci;


%% 4. wavelet packet transformation
% second level with Haar wavelet
% Then the energy of each image is calculated as
% texture features. The last feature is the entropy calculated using the energy features.
wpack = wpdec2(Iroi, 2, 'haar');

%% 5. Dual Tree Complex Wavelet Transform (DTCWT)
% the entropies calculated from
% coefficients of the lowpass sub-band and the highpass sub-band of each level are used as
% texture features.

dtcplx = dddtree2('cplxdt',double(Iroi),2,'dtf3');
dtDWT = dddtree2('dwt',double(Iroi),2,'farras');

%% 5. Image Local statistics
ImgStat.range = rangefilt(img);
ImgStat.std = stdfilt(img);
ImgStat.entropy = entropyfilt(img);


%% 6. Co-occurrence matrix
[glcm, SIcm] = graycomatrix(Iroi, 'NumLevels', 16); % change the num of levels to see the effect
figure; imagesc(glcm)
GLCMstats = graycoprops(glcm,{'contrast','homogeneity'});

%% Sliding window

[row, col] = size(img);

half_W = 8; % half width and also step size
half_H = 8;
rCount = 0;
cCount = 0;
GLCMcontrast =[];
GLCMhomogeneity = []; GLCMcorr = []; GLCMenergy =[];
for r = 1:half_H:row
    rCount = rCount + 1;
    cCount = 0;
    for c = 1:half_W:col
        
        y = r+half_H;
        x = c+half_W;
        
        bottom = y+half_H; bottom = uint32(bottom);
        if bottom > row
            bottom = row;
        end
        top = bottom-2*half_H; top = uint32(top);
        
        right = x+half_W; right = uint32(right);
        if right > col
            right = col;
        end
        left = right - 2*half_W; left = uint32(left);
        
        Iroi = img(top:bottom, left:right);
        
        cCount = cCount + 1;
        [glcm, SIcm] = graycomatrix(Iroi, 'NumLevels', 16); % change the num of levels to see the effect
        cCount;
        stats = graycoprops(glcm,{'contrast','homogeneity','Correlation','Energy'});
        GLCMcontrast(rCount,cCount) = stats.Contrast;
        GLCMhomogeneity(rCount,cCount) = stats.Homogeneity;
        GLCMcorr(rCount,cCount) = stats.Correlation;
        GLCMenergy(rCount,cCount) = stats.Energy;
    end
    
end

%%

