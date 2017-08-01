function Img = func_DrawLine(Img, X_0, Y_0, X_1, Y_1, nG)
% Connect two pixels in an image with the desired graylevel
%
% Command line
% ------------
% result = func_DrawLine(Img, Y_1, X_1, X2, Y2)
% input:    Img : the original image.
%           (Y_1, X_1), (X2, Y2) : points to connect.
%           nG : the gray level of the line.
% output:   result
%
% Note
% ----
%   Img can be anything
%   (Y_1, X_1), (X2, Y2) should be NOT be OUT of the Img
%
%   The computation cost of this program is around half as Cubas's [1]
%   [1] As for Cubas's code, please refer  
%   http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=4177  
%
% Example
% -------
% result = func_DrawLine(zeros(5, 10), 2, 1, 5, 10, 1)
% result =
%      0     0     0     0     0     0     0     0     0     0
%      1     1     1     0     0     0     0     0     0     0
%      0     0     0     1     1     1     0     0     0     0
%      0     0     0     0     0     0     1     1     1     0
%      0     0     0     0     0     0     0     0     0     1
%
%
% Jing Tian Oct. 31 2000
% scuteejtian@hotmail.com
% This program is written in Oct.2000 during my postgraduate in 
% GuangZhou, P. R. China.
% Version 1.0

Img(Y_0, X_0) = nG;
Img(Y_1, X_1) = nG;
if abs(Y_1 - Y_0) <= abs(X_1 - X_0)
   if X_1 < X_0
      k = Y_1; Y_1 = Y_0; Y_0 = k;
      k = X_1; X_1 = X_0; X_0 = k;
   end
   if (Y_1 >= Y_0) & (X_1 >= X_0)
      dy = X_1-X_0; dx = Y_1-Y_0;
      p = 2*dx; n = 2*dy - 2*dx; tn = dy;
      while (X_0 < X_1)
         if tn >= 0
            tn = tn - p;
         else
            tn = tn + n; Y_0 = Y_0 + 1;
         end
         X_0 = X_0 + 1; Img(Y_0, X_0) = nG;
      end
   else
      dy = X_1 - X_0; dx = Y_1 - Y_0;
      p = -2*dx; n = 2*dy + 2*dx; tn = dy;
      while (X_0 <= X_1)
         if tn >= 0
            tn = tn - p;
         else
            tn = tn + n; Y_0 = Y_0 - 1;
         end
         X_0 = X_0 + 1; Img(Y_0, X_0) = nG;
      end
   end
else if Y_1 < Y_0
      k = Y_1; Y_1 = Y_0; Y_0 = k;
      k = X_1; X_1 = X_0; X_0 = k;
   end
   if (Y_1 >= Y_0) & (X_1 >= X_0)
      dy = X_1 - X_0; dx = Y_1 - Y_0;
      p = 2*dy; n = 2*dx-2*dy; tn = dx;
      while (Y_0 < Y_1)
         if tn >= 0
            tn = tn - p;
         else
            tn = tn + n; X_0 = X_0 + 1;
         end
         Y_0 = Y_0 + 1; Img(Y_0, X_0) = nG;
      end
   else
      dy = X_1 - X_0; dx = Y_1 - Y_0;
      p = -2*dy; n = 2*dy + 2*dx; tn = dx;
      while (Y_0 < Y_1)
         if tn >= 0
            tn = tn - p;
         else
            tn = tn + n; X_0 = X_0 - 1;
         end
         Y_0 = Y_0 + 1; Img(Y_0, X_0) = nG;
      end
   end
end