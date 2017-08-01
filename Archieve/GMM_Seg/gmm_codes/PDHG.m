function [g] = PDHG( f,lambda,eps )
[m,n]=size(f);
[g,a,b,c,d,e,it]=TV_PDHG(zeros(m,n),zeros(m,n),f,lambda,20000000,eps,0);
it
end

