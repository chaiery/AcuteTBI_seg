function pdf = create_pdf(I)
%Coded by:  Romeil Sandhu
%Function:  Creates a smooth pdf
x = imhist(uint8(I));
x(find(x == 0)) = 1;
x = x./sum(x);

k = binomfilt(15)';
k = k / sum(k);

x = wkeep(conv(x, k), 256);
x = x/(sum(x)+eps);
pdf = x;

