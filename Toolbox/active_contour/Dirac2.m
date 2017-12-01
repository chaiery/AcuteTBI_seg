function f = Dirac2(x, sigma)
%Coded by:  Romeil Sandhu
%Function:  Implements a dirac function (smoothed version)
f=(1/2/sigma)*(1+cos(pi*x/sigma));
b = (x<=sigma) & (x>=-sigma);
f = f.*b;
