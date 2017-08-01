function img2_new = removeMidline(imgsub)

    %%
    label_img = bwlabel(imgsub, 4);
    rpbox = regionprops(label_img,'BoundingBox', 'Centroid');
    x_center = rpbox(1).Centroid(1);

    img2 = uint8(double(imgsub - 80)*255 / 200);

    %se = strel('line',10,90);
    %new = imdilate(img2,se);
    %img2 = new;
    %{
    label_img_detect
    H = fspecial('disk',2);
    new = imfilter(img2,H);
    figure;imshow(new);
    img2 = new;
    %}

    %%
    BW = edge(img2,'Sobel');
    %figure;imshow(BW);
    [H,T,R] = hough(BW, 'Theta',-15:0.5:15);

    index = find((R<x_center+20).*(R>x_center-20));
    H = H(index,:);
    R = R(index);

    %%
    % Find peaks in the Hough transform of the image.
    P  = houghpeaks(H,10,'threshold',ceil(0.3*max(H(:))));

    %%
    % Find lines and remove them.
    lines = houghlines(BW,T,R,P,'FillGap',15,'MinLength',5);

    img2_new = imgsub;
    for k = 1:length(lines)
        xy = [lines(k).point1;lines(k).point2];
        ys = xy(:,1);
        xs = xy(:,2);
        indeximg = zeros(size(img2));
        indeximg(min(xs)-1:max(xs)+1,min(ys):max(ys)) = 1;
        index = find(indeximg==1);    
        sub = imgsub(min(xs)-1:max(xs)+1,min(ys):max(ys));
        se = offsetstrel('ball',3,2);
        sub2 = imerode(sub,se);
        %sub2 = medfilt2(sub,[10 10]);

        img2_new(index) = sub2(:);
        %figure;imshow(img2_new);
    end
    %figure;imshow(img2_new);

end

    %{
    for k = 1:length(lines)
        xy = [lines(k).point1;lines(k).point2];
        ys = xy(:,1);
        xs = xy(:,2);
        indeximg = zeros(size(img2));
        indeximg(min(xs):max(xs),min(ys):max(ys)) = 1;
        index = find(indeximg==1);
        img2_new(index) = 0;
        figure;imshow(img2_new);
    end
    %}

    %{
    sub = img2(:,90:130);
    figure;imshow(sub)

    se = offsetstrel('ball',5,5);
    sub2 = imerode(sub,se);
    figure;imshow(sub2);
    %}
    %{
    figure, imshow(img2), hold on
    max_len = 0;
    for k = 1:length(lines)
       xy = [lines(k).point1; lines(k).point2];
       plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

       % Plot beginnings and ends of lines
       plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
       plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

       % Determine the endpoints of the longest line segment
       len = norm(lines(k).point1 - lines(k).point2);
       if ( len > max_len)
          max_len = len;
          xy_long = xy;
       end
    end
    %}
