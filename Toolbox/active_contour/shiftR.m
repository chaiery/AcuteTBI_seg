function shift = shiftR(M)
% shiftR(M) shifts the matrix right duplicating the leftmost column
  shift = [ M(:,1) M(:,1:size(M,2)-1) ];
