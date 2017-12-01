function shift = shiftU(M)
% shiftU(M) shifts the matrix up duplicating the bottom-most column
  shift = shiftL(M')';
