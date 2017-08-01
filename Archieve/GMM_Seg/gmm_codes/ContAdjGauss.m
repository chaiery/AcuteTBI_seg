%This function enhances the pixel values belong to bones based on the histogram of the input image, "Img". 
%First, the histogram of the image is approximated with a mixture of two Gaussian functions.  %Gaussian functions 
function [H, contrastAdjustedImage, oldminval]= ContAdjGauss(Img, Nbin, newRange)
Img = Img(:, :, 1);
contrastAdjustedImage = Img;
H = 0;
oldminval = 0;
Nbin = min(Nbin, max(Img(:)));
if Nbin < 1
    return;
end
H = zeros(Nbin, 1);

MaxPixel = max(Img(:));
MinPixel = min(Img(:));

Step = double(Nbin-1)/double(MaxPixel-MinPixel);
%% Calculating the histogram
for j = 0 :Nbin-1
    H(j+1) = sum(round((Img(:)-MinPixel)*Step)+1==j);
end

%% Approximating the histogram with a mixture of two Gaussian functions

range = int16(0.1*Nbin:.9*Nbin); 
%0.1*Nbin is chosen to eliminate the black pixels (It is assumed that the values of these pixels are less than 0.1*Nbin).
%0.9*Nbin is chosen to eliminate the white pixels (It is assumed that the values of these pixels are greater than 0.9*Nbin).

Hp = H(range);
f2 = fit(double(range)', Hp,'gauss2');

%% Finding the second peak, a peak with the higher mean. 
%This peak shows where to look at the bones' pixels range

if min(f2.b1, max(range)) == max(range)
    miu = f2.b2;
    sigma = f2.c2;
else
    if min(f2.b2, max(range)) == max(range)
        miu = f2.b1;
        sigma = f2.c1;
    else
        if f2.b1 > f2.b2
            miu = f2.b1;
            sigma = f2.c1;
        else
            miu = f2.b2;
            sigma = f2.c2;
        end
    end
end

%% Approximating the second peak with a mixture of two Gaussian functions to calculate the more accurate values for the range of the bones.
range = int16(max(1, miu - 3 * sigma)) : int16(min(max(range), miu + 9 * sigma));
Hp = H(range);
if length(Hp) > 6
f2 = fit(double(range)', Hp,'gauss2');
end

%% Finding the second peak  
%%this peak shows where to look at the bones' pixels range more precisely ).
if min(f2.b1, max(range)) == max(range)
    miu = f2.b2;
    sigma = f2.c2;
else
    if min(f2.b2, max(range)) == max(range)
        miu = f2.b1;
        sigma = f2.c1;
    else
        if f2.b1 > f2.b2
            miu = f2.b1;
            sigma = f2.c1;
        else
            miu = f2.b2;
            sigma = f2.c2;
        end
    end
end

 
minThr = min(miu + 1 * sigma, max(range));
maxThr = min(miu + 7 * sigma, max(range));

oldminval = double(minThr) / Step + min(Img(:));
oldmaxval = double(maxThr) / Step + min(Img(:));

oldRange=(maxThr - minThr)/ Step;

newminval=newRange(1);
newmaxval=newRange(2);

newRange=newmaxval-newminval;
contrastAdjustedImage=zeros(size(Img));
contrastAdjustedImage(Img >=oldminval & Img<=oldmaxval) = double(Img(Img >=oldminval & Img<=oldmaxval) - oldminval)*newRange / double(oldRange) + newminval;
contrastAdjustedImage(Img >=oldmaxval) = newmaxval;

end
