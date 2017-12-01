function phi = Init_SDF(mask)
%calculates the sign distance function with given an initial zero level


%calculate distance outside
maskOut = bwfill(mask, 'holes');
phi_out = bwdist(maskOut);

%calculate distance inside
maskIn = maskOut - mask;
maskIn = ~maskIn;  %invert zeros and 1's
phi_in = bwdist(maskIn);

%compute phi
phi = phi_out - phi_in;



