% input: image and the folder of eclipse fitting
% output: the image marked eclipse fitting line
function printEclipseFittingIm(im,EF_Dir, fn)
% imgname = 'C:\dataset_thesis\thesis_paper1_jpgData_12_19_2012_rusult\9205361\SSAone_4VFM\9205361--2008-09-30-CT7623216-2-s-61.7.jpg';
% imgname = 'C:\dataset_thesis\thesis_paper1_jpgData_12_19_2012_rusult\9205361\SSAone_4VFM\9205361--2008-09-30-CT7623216-2-s-39.3.jpg';
% imgname = 'C:\dataset_thesis\thesis_paper1_jpgData_12_19_2012_rusult\9290109\SSAone_4VFM\9290109--2008-09-31-CT7623489-2-s-130.1.jpg';
% imgname = 'C:\dataset_thesis\thesis_paper1_jpgData_12_19_2012_rusult\9290540\SSAone_4VFM\9290540--2008-09-09-CT7628267-3-s-68.6.jpg';
% 
% 
% imgname = 'C:\dataset_thesis\thesis_paper1_jpgData_12_19_2012_rusult\5778522\SSAone_4VFM\5778522--2008-08-25-CT7625409-2-s-515.5.jpg';
% 
% im = imread(imgname);

% imnew(:,:) = im(:,:,1);
% im = imnew;


[ bwSkullBone,rev ]  = getSkullBone( im,250 );
if rev ~= 0
    return;
end

% figure, imshow(bwSkullBone);
                
outerBw = 0 ;
innerBw = 0; 
rev = 0;             

bwSkullBone2=1-bwSkullBone;
label_img=bwlabel(bwSkullBone2);
seg_outer=zeros(size(bwSkullBone));
seg_outer(find(label_img==1))=1;
seg_skull_out=1-seg_outer;
bw1=edge(seg_skull_out, 'sobel'); % this is the outer edge of skull
seg_inner=zeros(size(bwSkullBone));
label_brain=label_img(floor(size(bwSkullBone,1)/2),floor(size(bwSkullBone,2)/2));
seg_inner(find(label_img==label_brain))=1;
seg_skull_in=1-seg_inner;
bw2=edge(seg_skull_in, 'sobel'); % this is the inner edge of skull

outerBw = bw1;
innerBw = bw2;

bw=seg_skull_out;

s = regionprops(bw, 'Orientation', 'MajorAxisLength', ...
    'MinorAxisLength', 'Eccentricity', 'Centroid');

% imshow(bwSkullBone);
% hold on

phi = linspace(0,2*pi,50);
cosphi = cos(phi);
sinphi = sin(phi);


bw2 = seg_inner;
s2 = regionprops(bw2, 'Orientation', 'MajorAxisLength', ...
    'MinorAxisLength', 'Eccentricity', 'Centroid');

% imshow(bwSkullBone);
% hold on

phi2 = linspace(0,2*pi,50);
cosphi2 = cos(phi2);
sinphi2 = sin(phi2);



% 
% for k = 1:length(s)
%     xbar = s(k).Centroid(1);
%     ybar = s(k).Centroid(2);
% 
%     a = s(k).MajorAxisLength/2;
%     b = s(k).MinorAxisLength/2;
% 
%     theta = pi*s(k).Orientation/180;
%     R = [ cos(theta)   sin(theta)
%          -sin(theta)   cos(theta)];
% 
%     xy = [a*cosphi; b*sinphi];
%     xy = R*xy;
% 
%     x = xy(1,:) + xbar;
%     y = xy(2,:) + ybar;
%     
%     xyAxis =  R*[0,-a;0,a];
%        C1Axis = xyAxis(1,:) + xbar;
%       C2Axis = xyAxis(2,:) + ybar;
%      plot( [C1Axis(1),C2Axis(1)], [C1Axis(2),C2Axis(2)]);
%     plot(x,y,'r','LineWidth',2);
%     
% end

% hold off
% im2 = imrotate(im, 90 - s(k).Orientation - 180);
imshow(im);
hold on
for k = 1:length(s)
    xbar = s(k).Centroid(1);
    ybar = s(k).Centroid(2);

    a = s(k).MajorAxisLength/2;
    b = s(k).MinorAxisLength/2;

    theta = pi*s(k).Orientation/180;
   
    R = [ cos(theta)   sin(theta)
         -sin(theta)   cos(theta)];

    xy = [a*cosphi; b*sinphi];
    xy = R*xy;

    x = xy(1,:) + xbar;
    y = xy(2,:) + ybar;
    
%     xyAxis =  R*[0,-a;0,a];
%        C1Axis = xyAxis(1,:) + xbar;
%       C2Axis = xyAxis(2,:) + ybar;
%      plot( [C1Axis(1),C2Axis(1)], [C1Axis(2),C2Axis(2)]);
    plot(x,y,'r','LineWidth',2);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     x2bar = s2(k).Centroid(1);
    y2bar = s2(k).Centroid(2);

    a2 = s2(k).MajorAxisLength/2;
    b2 = s2(k).MinorAxisLength/2;

    theta2 = pi*s2(k).Orientation/180;

    R2 = [ cos(theta2)   sin(theta2)
         -sin(theta2)   cos(theta2)];
     
    xy2 = [a2*cosphi2; b2*sinphi2];
    xy2 = R2*xy2;

    x2 = xy2(1,:) + x2bar;
    y2 = xy2(2,:) + y2bar;
    
    plot(x2,y2,'y','LineWidth',2);   
    
    %%%%%%%%%%%%%%%%%%%%%
    line_x =1:512;
    k=tan( pi/2 - theta);
    line_y = s.Centroid(2)  + k*(line_x - s.Centroid(1));
    plot(line_x,line_y,'r','LineWidth',2);
    
    line_x =1:512;
    k= tan( -theta);
    line_y = s.Centroid(2)  + k*(line_x - s.Centroid(1));
    plot(line_x,line_y,'r','LineWidth',1);
    
    %%%%%%%%%%%%%%%%%%%%%
    line_x2 =1:512;
    k2=tan( pi/2 - theta2);
    line_y2 = s2.Centroid(2)  + k2*(line_x2 - s2.Centroid(1));
    plot(line_x2,line_y2,'y','LineWidth',2);
    
    line_x2 =1:512;
    k2=tan( - theta2);
    line_y2 = s2.Centroid(2)  + k2*(line_x2 - s2.Centroid(1));
    plot(line_x2,line_y2,'y','LineWidth',1);
    
    fileP_n = strcat(EF_Dir , '\' , fn, '.png' );
    print(gcf,'-dpng',fileP_n)  % ???jpg?????
end


hold off
 


% path = p;
 