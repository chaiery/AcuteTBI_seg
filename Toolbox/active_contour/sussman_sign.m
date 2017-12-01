function S = sussman_sign(D)
% SUSSMAN_SIGN(D) Computes the sign of the distance function adding in
% blurring parameter using method presented in Sussman "Level Set Approach
% in Two-Phase Flow":
%
%  S(D) =    D
%          ----------
%        \/ D^2 + e^2        where e is smoothing constant usually taken to
%                            be grid size, that is e=dx=dy
%

  S = D ./ sqrt(D.^2 + 1);
