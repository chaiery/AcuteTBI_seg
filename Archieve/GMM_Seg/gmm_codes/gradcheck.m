function y = gradcheck()
y=1;
if hgradd>-22.5 && hgradd<=22.5
%     imgclean(yloc,xloc:xloc+k)=imgclean(yloc,xloc+k);
    
elseif hgradd>22.5 && hgradd<=67.5
    
elseif hgradd>67.5 && hgradd<=112.5
    
elseif hgradd>112.5 && hgradd<=157.5
    
elseif abs(hgradd)>157.5 && abs(hgradd)<=180 
    
elseif hgradd>-157.5 && hgradd<=-112.5
    
elseif hgradd>-112.5 && hgradd<=-67.5
    
elseif hgradd>-67.5 && hgradd<=-22.5
    
end