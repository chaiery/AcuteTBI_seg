function [I,peak]= ContAdj_Intensity(rawImg, inf, ref)
    


end
    


% function [I,peak]= ContAdj_Intensity(rawImg, inf, ref)
%     x1 = double(rawImg)/3000;
%     ref1 = double(ref)/3000;
%     
% 
%     [count,~] = imhist(ref1,1000);
%     [~,b1] = sort(count,'descend');
%     b1(b1<50) = [];
%     
%     [count,~] = imhist(x1,1000);
%     [~,b2] = sort(count,'descend');
%     b2(b2<50) = [];
%     
% 
%     adjust = (x1+(b1(1)-b2(1))*1/1000)*3000;
% 
%     I = ContAdj_fixed(adjust,inf);
%     peak = b2(1);
% end
