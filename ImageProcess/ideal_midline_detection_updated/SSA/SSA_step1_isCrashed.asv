
function rev = SSA_step1_isCrashed( img_Mattress,boneThreshold)
% To judge the skull is crashed or not
%   Detailed explanation goes here

rev = 0;

p = path;
 
path(path, '../generalTool');

path(path, '../newFunForVentriclePaper');
% rev = isCrashed(img_Mattress,250);
rev = isCrashed(img_Mattress,boneThreshold);

path(p);

end

