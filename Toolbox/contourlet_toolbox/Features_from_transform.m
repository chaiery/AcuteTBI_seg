% Using plot/statistics method to evaluate extracted features

%% First we need a set of data labeled 1 and labeled 0
ImgDir = '/Users/apple/Dropbox/Select';
ImgFiles = dir(ImgDir);
ImgFiles = ImgFiles(~strncmpi('.', {ImgFiles.name},1));
ImgDir = '/Users/apple/Dropbox/Results';

[train_1, train_0] = build_dataset(ImgFiles(1:4), ImgDir);
%Randomization
train_1  = train_1(randsample(length(train_1), length(train_1)));
train_0  = train_0(randsample(length(train_0), length(train_0)));

x = length(train_1);
train_sub = train_0(1:3*x);

%% Try intensity first
intensity_1 = cell2mat(arrayfun(@(x)train_1(x).MeanIntensity,1:length(train_1),'un',0));
intensity_0 = cell2mat(arrayfun(@(x)train_sub(x).MeanIntensity,1:length(train_sub),'un',0));

figure; hold on;
plot(sort(intensity_1));
plot(sort(intensity_0(1:x)));
plot(sort(intensity_0(x+1:2*x)));
plot(sort(intensity_0(2*x+1:3*x)));
hold off 

%% Try Contourlet 
% Parameteters:
nlevels = [0] ;        % Decomposition level
pfilter = 'pkva' ;              % Pyramidal filter
dfilter = 'pkva' ;              % Directional filter

% We need to re-extract superpixels 
% Need try using different filters
% Contourlet decomposition
for i = 1:length(train_1)
    patch = train_1(i).recpatch;
    %  figure;imshow(img(1:16,1:16))
    coeffs = pdfbdec( double(patch), pfilter, dfilter, nlevels );
    imcoeff = showpdfb( coeffs );
end

%% Radon Transform
theta = 0:180;
[R,xp] = radon(I,theta);


%% Salient
