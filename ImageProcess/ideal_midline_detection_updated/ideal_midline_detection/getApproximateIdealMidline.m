function [  rotate_angle,center,choosing, outerBw, innerBw, rev ]  = ...\ 
                                        getApproximateIdealMidline( bwSkullBone )
% approximate midline detection according to symmetry 
%   Detailed explanation goes here

rev = 0;

% get the center and rotated angle of approximate midline

[ rotate_angle,center,choosing, outerBw, innerBw,rev ] = ...\ 
    getRotatedAngleAndCenterOfAM( bwSkullBone );


end

