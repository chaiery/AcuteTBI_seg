function rev = print_stru(stru)
    rev = 0;
    
    num = length(stru);
    if num == 0 
        rev = 1;
        return;
    end
    
    fprintf('\n---------------------------------------------------------------\n');
%     fprintf('Person is : %s.  \nThe number of CT slices: %d \n'  , stru(1).imgnameWithoutExtendName(1:33),num );
    for i_pos=1:num
        fprintf('           Filename for No. %d is:   %s \n', i_pos ,stru(i_pos).imgname);      
    end
    fprintf('\n' );  
end