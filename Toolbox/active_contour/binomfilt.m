function [h] = binomfilt(order1,order2)
%Coded by: Romeil Sandhu
%Function:  Creates a Binomial Filter
h=zeros(order1+1,1);
for k=0:order1
    h(k+1)=nchoosek(order1,k);
end
h=h/(2^order1);

if (nargin>1)
    g=zeros(order2+1,1);
    for k=0:order2
        g(k+1)=nchoosek(order2,k);
    end
    g=g/(2^order2);
    h=h*g';
end