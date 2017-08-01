%  Modified using code from Chunming Li

function brain = drlse_demo (im,normalizedImg)

    DEBUG = false;

    % Find center of the image
    
    center_row = int16(sum(im,2)'*(1:512)'/sum(im(:)));
    center_col = int16(sum(im,1)*(1:512)'/sum(im(:)));
    
    CC = bwconncomp(im);
    S = regionprops(CC,'Centroid');
    
    center_col=round(S(1).Centroid(1));
    center_row=round(S(1).Centroid(2));
    
    im = 255*im;
    brain = ones(size(im));
    % close all;
    % clear all;
   
    % parameter setting
    timestep = 5;       % time step
    mu = 0.2 / timestep;  % coefficient of the distance regularization term R(phi)
    iter_inner = 5;
    iter_outer = 50;
    lambda = 9;       % coefficient of the weighted length term L(phi)
    alfa = -25;       % coefficient of the weighted area term A(phi)
    epsilon = 1.5;    % papramater that specifies the width of the DiracDelta function
    OUTA = alfa;
    OUTL = lambda;
    sigma = 6.8;     % scale parameter in Gaussian kernel
    G = fspecial('gaussian',15,sigma);
    Img_smooth = conv2(im,G,'same');  % smooth image by Gaussiin convolution
    [Ix,Iy] = gradient(Img_smooth);
    f = Ix .^ 2 + Iy .^ 2;
    g = 1 ./ (1 + f);  % edge indicator function.

    
    % initialization (as binary step function)
    c0 = 2;
    initialLSF = c0*ones(size(im));
    width = 30;
    height = 30;
    initialLSF(center_row-height:center_row+height,center_col-width:center_col+width) = -c0; %center of mass for 3d skull of 282, slice 260
    %initialLSF(190:210,240:260)=-c0; % center of mass for 3d skull of 282

    phi=initialLSF;
    if DEBUG
        figure(1);
        mesh(-phi);   % for a better view, the LSF is displayed upside down
        hold on;  contour(phi, [0,0], 'r','LineWidth',2);
        title('Initial level set function');
        view([-80 35]);

        figure(2);
        imagesc(im,[0, 255]); axis off; axis equal; colormap(gray); hold on;  contour(phi, [0,0], 'r');
        title('Initial zero level contour');
        pause(0.5);
    end
    potential=2;  
    if potential ==1
        potentialFunction = 'single-well';  % use single well potential p1(s)=0.5*(s-1)^2, which is good for region-based model 
    elseif potential == 2
        potentialFunction = 'double-well';  % use double-well potential in Eq. (16), which is good for both edge and region based models
    else
        potentialFunction = 'double-well';  % default choice of potential function
    end


    % start level set evolution
    for n=1:iter_outer
        phi = drlse_edge(phi, g, lambda, mu, alfa, epsilon, timestep, iter_inner, potentialFunction);
        if DEBUG
        if mod(n,2)==0
            figure(2);
            imagesc(im,[0, 255]); axis off; axis equal; colormap(gray); hold on;  contour(phi, [0,0], 'r');
        end
        end
        phi(im==255)=2; % This condition is added by Negar to remove potential bone components from initialization
        phi(normalizedImg<50)=2;
        %%%%% this condition is added by nrgar to keep the largest component.
        phiBinary = ones(size(phi));
        phiBinary(phi>0)=0;
        CC = bwconncomp(phiBinary);
        phiBinary = ones(size(phi));
        numPixels = cellfun(@numel,CC.PixelIdxList);
        [biggest,idx] = max(numPixels);
        if length(CC.PixelIdxList)>0
            phiBinary(CC.PixelIdxList{idx}) = 0;
        end
        phi ( phiBinary==1)=2;
        %%%%%
    end

    % refine the zero level contour by further level set evolution with alfa=0
    alfa=0;
    iter_refine = 10;
    phi = drlse_edge(phi, g, lambda, mu, alfa, epsilon, timestep, iter_inner, potentialFunction);
    phi(im==255)=2; % This condition is added by Negar

    finalLSF=phi;
    if DEBUG
        figure(2);
        imagesc(im,[0, 255]); axis off; axis equal; colormap(gray); hold on;  contour(phi, [0,0], 'r');
        hold on;  contour(phi, [0,0], 'r');
        str=['itr = ', num2str(iter_outer*iter_inner+iter_refine), ', a = ', num2str(OUTA), ', l = ', num2str(OUTL)];
        title(str);

        pause(1);
        figure;
        mesh(-finalLSF); % for a better view, the LSF is displayed upside down
        hold on;  contour(phi, [0,0], 'r','LineWidth',2);
        str=['itr = ', num2str(iter_outer*iter_inner+iter_refine), ', a = ', num2str(OUTA), ', l = ', num2str(OUTL)];
        title(str);

        drlse=1;

        axis on;
    end
            brain(phi==2)=0;
end
