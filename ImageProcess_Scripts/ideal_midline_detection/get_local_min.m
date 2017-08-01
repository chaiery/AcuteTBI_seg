%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Wenan Chen
%% September, 2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% This function detection the lowest point of line stored in a 1*n vector 
function x_coord_lowest=get_local_min(vec_line);

%% get the first oder derivative of the line.
%% for digital image, that is: derivative(x)=f(x)-f(x-1)/(x-(x-1))=f(x)-f(x-1)

%% shift the vector to right of one element offset.
n=length(vec_line);
A=vec_line;
%% Because the direction of y aix of the image points down. Then the 
%% minimum of minus A is the maximum of A, that is the bump.
B=-A;
%% let last point not influenced by the -1 change  because it hit the
%% bottom of the box.
if((B(end)==1)&&(B(end-1)~=1))
    B(end)=B(end-1);
end
C=circshift(B',1)';
D=B-C; 
Deri1=D; 

%% get rid of the first and last derivative
Deri1(1,size(Deri1))=0;
%% set the derivative of all negative value in lines 0
Deri1(find(A<0))=0;  %% the point itself
Deri1(find(A<0)+1)=0;  %% the point after using the value of negative value

Deri1(find(A<0)+2)=0; %% no reason, ad hoc way to get rid of o-shape curve singularity in derivative.
Deri1(find(abs(Deri1)>50))=0; %% view abrupt change as abnormal and make it have no effect on detection

%% detect sign change with the second order derivative 
% D=circshift(Deri,1);
% E=D-Deri1;
% Deri2=E(2:n-1);

%% detect sign change with the following pattern
%% [-1, -1, -1, ..., -1, 0, +1, ..., +1, +1, +1]
N=9;   
sign_pattern=[-ones(1,N), 0, ones(1,N)];

sign_Deri1=sign(Deri1);
best_match=-2*N-1;
best_place=1;
delta=10;
flag=0;
for i=[2:n-1-length(sign_pattern)] %% don't use the first and last derivative
    %% In the case there is no minimal, return the left corner
    
    %% If it is the minimal, the sum of left side should be negative and the
    %% sum of the right side should be positive. If these conditions are
    %% vilated, then we think there is no minimal.
    %% use -5 to 4 range change for each side
    s=-5;
    while((sum(Deri1(max(2,i+s):i+N-1))>-2)||(sum(Deri1(i+N:min(i+2*N-1-s,length(B)-1)))<2))
        if(s==4) break; end
        s=s+1;
    end
    
    if(s==4) continue; end
    
    cor_value=Deri1([i:i+length(sign_pattern)-1])*sign_pattern';
    %% get weighted to prefer centeral minimal
    %% allow a certain error with no cost. 
    eps=25;
    if(abs(i+N-n/2)<=eps) 
        weight = 1;
    else
        weight = exp(-((abs(i+N-n/2)-eps)^2/delta^2));
    end
    cor_value=cor_value*weight;
    if(cor_value>best_match)
        flag=1;
        best_place=i;
        best_match=cor_value;
    end
end

% x_coord_lowest=best_place+N;

best_place_match=B(best_place+floor(N/2):best_place+N+floor(N/2));
min_V=min(best_place_match);
%% in case of many max_V, use the center point of these
min_I=floor(median(find(best_place_match==min_V)));
x_coord_lowest=best_place+floor(N/2)-1+min_I;

%% the new position should not deviate too far from the center.
total_range=length(vec_line);
if(abs(total_range/2-x_coord_lowest)>1/4*total_range)
    flag=0;
end
%% no fit
if(flag==0)
    x_coord_lowest=1;
end






    
        
   

