function shift = shiftL(M)
% shiftL(M) shifts the matrix left duplicating the rightmost column
  shift = [ M(:,2:size(M,2)) M(:,size(M,2)) ];
