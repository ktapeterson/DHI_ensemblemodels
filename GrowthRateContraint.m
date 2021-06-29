function output = GrowthRateContraint(A,r,n_equil,Bounds)
% A is the coefficient matrix, 
% r is the proposed growth rate vector, 
% n_equil is the abundance of species at equilibrium for the given system
% Bounds is a 13*3 matrix with column 2 as lower bound and column 3 as 
% upper bound for growth rate

% calculate the intrinsic growth rate of the system
Rate = 10*(A.*(A>0))*n_equil;
Rate((end-5):end)=[];
% check that the intrinsic growth rate exists within the bounds
Check(:,1) = Rate < Bounds(:,2);
Check(:,2) = Rate > Bounds(:,3);

if sum(sum(Check,2)) > 0
    output = 0;
else 
    output = 1;
end


