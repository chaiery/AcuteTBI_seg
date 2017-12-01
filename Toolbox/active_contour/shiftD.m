function shift = shiftD(M)
% shiftU(M) shifts the matrix up duplicating the bottom-most column
  shift = shiftR(M')';
