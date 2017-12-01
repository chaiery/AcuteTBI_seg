function D = sussman(D, dt)
% SUSSMAN(D, dt) Corrects distance function so that it maintains |Dt| = 1
% (slope of 1) using method presented in Sussman "Level Set Approach in
% Two-Phase Flow":
%
% G(D) = sqrt( max[(a+)^2, (b-)^2] + max[(c+)^2, (d-)^2] ) - 1   if D > 0
%      = sqrt( max[(a-)^2, (b+)^2] + max[(c-)^2, (d+)^2] ) - 1   if D < 0
%      = 0                                                       otherwise
%
% Applies one iteration of:
%   Dt+1 = Dt - dt * S(D)*G(D)
  
  % forward/backward differences
  a = D - shiftR(D); % backward
  b = shiftL(D) - D; % forward
  c = D - shiftD(D); % backward
  d = shiftU(D) - D; % forward
  
  % setup defaults for the positive and negative filtered versions
  a_p = a;  a_n = a; % a+ and a-
  b_p = b;  b_n = b;
  c_p = c;  c_n = c;
  d_p = d;  d_n = d;
  
  % positive ones are defined as having only those values that are
  % positive, otherwise zero, for example:
  %  a_p(i,j) = a_p(i,j)   if a_p(i,j) > 0
  %           = 0          otherwise
  a_p(find(a < 0)) = 0;
  a_n(find(a > 0)) = 0;
  b_p(find(b < 0)) = 0;
  b_n(find(b > 0)) = 0;
  c_p(find(c < 0)) = 0;
  c_n(find(c > 0)) = 0;
  d_p(find(d < 0)) = 0;
  d_n(find(d > 0)) = 0;
  
  
  dD = zeros(size(D));
  D_neg_ind = find(D < 0);
  D_pos_ind = find(D > 0);
  dD(D_pos_ind) = sqrt(max(a_p(D_pos_ind).^2, b_n(D_pos_ind).^2) ...
                       + max(c_p(D_pos_ind).^2, d_n(D_pos_ind).^2)) - 1;
  dD(D_neg_ind) = sqrt(max(a_n(D_neg_ind).^2, b_p(D_neg_ind).^2) ...
                       + max(c_n(D_neg_ind).^2, d_p(D_neg_ind).^2)) - 1;
  
  D = D - dt .* sussman_sign(D) .* dD;
