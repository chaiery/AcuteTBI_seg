function [ imStru, rev ] = init( imFilePathAndName,isDecFormat )
%initialize the basic image structure
%   input: 

rev = 0;
imStru = [];

if isDecFormat
    info = dicominfo(imFilePathAndName); 
    img_Mattress = dicomread(info);
    imStru.im_ori = img_Mattress;
    
    % see instruction of 'RescaleSlope and RescaleIntercept' below
    img_Mattress = info.RescaleSlope*img_Mattress + info.RescaleIntercept;
    img_Mattress(img_Mattress<0) = 0;
    
    imStru.img_Mattress = img_Mattress;
    imStru.SliceThickness = info.SliceThickness;
    imStru.PixelSpacing = info.PixelSpacing;
    imStru.boneThreshold = 500; % default for jpg format
    
    % add RescaleSlope and RescaleIntercept to structure
    imStru.RescaleSlope = info.RescaleIntercept;
    imStru.RescaleIntercept = info.RescaleIntercept;
    
    
    
    % add info for backup
    % imStru.info = info;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Instruction for RescaleSlope and RescaleIntercept
%
%    Defined in DICOM Part 3
%    Table C.7.6.16-10 PIXEL VALUE TRANSFORMATION MACRO ATTRIBUTES
%    Output units = m*SV + b.
%    where
%    m is Rescale Slope (0028,1053)
%    b is Rescale Intercept (0028,1052)
%    SV is the pixel value from dicom pixel data.
%    Pixel Output value (x,y) = Stored Pixel Data(x, y) * Rescale Slope +
%    Rescale Intercept
%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
else
    img_Mattress = imread(imFilePathAndName);
    imStru.im_ori = img_Mattress;
%     img_MattressFractured = imread(imFilePathAndNameFractured); % N
%     imStru.im_oriFractured = img_MattressFractured; %N
    
    if ndims(img_Mattress) ~=2
        img_Mattress = img_Mattress(:,:,1);
    end
%     if ndims(img_MattressFractured) ~=2 %N
%         img_MattressFractured = img_MattressFractured(:,:,1); %N
%     end %N
    imStru.img_Mattress = img_Mattress;
%     imStru.img_MattressFractured = img_MattressFractured; %N
    imStru.SliceThickness = 4.5;
    imStru.PixelSpacing = [0.4492,0.4492]';
    imStru.boneThreshold = 250; % default for jpg format
    
    % add RescaleSlope and RescaleIntercept to structure
    imStru.RescaleSlope = 1;
    imStru.RescaleIntercept = 0;
end

end

