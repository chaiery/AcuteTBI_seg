%%%%%%%%%%%%%%%%%%%%%%%MAIN FUNCTION TO RUN ALGORITHM%%%%%%%%%%%%%%%%%%%%%%
function [result,pin,pout] = run(img,iter,dt,alpha,flag_approx,pre_mask)
%Coded by:  Romeil Sandhu
%Function:  This is a 'run me' file that checks necessary information and
%           sets up segmentation method.  This just a matlab wrapper for 
%           "Tryphon_NB"



%safety checks for inputs, sets defaults if necessary 

if(~exist('iter','var')); iter = 1000; end
if(~exist('alpha','var')); alpha = .0005; end;
if(~exist('dt','var')); dt = .4; end;
if(~exist('flag_approx','var')); flag_approx = 0; end;

%read img path
img = double(img);
if(size(img,3)~=1);
    disp(['WARNING:  Code only works for gray scale, please modify '...,
          'code. Will continue will process input image as gray scale.']);
     img = (img(:,:,1)+img(:,:,2)+img(:,:,3))/3;
end

%if no pre_mask given, display image so user can select initialization
if(~exist('pre_mask','var')); 
    %imshow(img,'InitialMagnification',200);
    mask = double(get_rect_mask(img));
else
    mask = pre_mask;
end

%compute sdf function
phi = bwdist(mask) - bwdist(1-mask)+im2double(mask);

%run active contour
[result,pin,pout] = Tryphon_NB_2(img, phi, iter, dt, alpha,flag_approx);

end

% GET_RECT_MASK Allows user to draw a rectangle on an axis
function mask = get_rect_mask(img)
  global INPUT
  
  imagesc(img); axis image off;
  r = round(getrect);
  
  if all(r(3:4) == [0 0])
    r = INPUT;
  else
    INPUT = r;
  end
  mask = false(size(img));
  mask(r(2)+(1:r(4)), r(1)+(1:r(3))) = true;
end
