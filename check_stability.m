
function [flag,n] = check_stability(A,r)
% Input interaction matrix A and growth rate vector r.
% Output whether stable, nonnegative equilibrium exists (flag = 1) or not (flag = 0); and equilibrium
% abundance, n.

flag = 0; % initilise flag to 0
r = r(:); %ensure r is a column vector
n = A\(-r); %solve linear system of equations for equilibrium abundance
n_s = length(n); % number of species
if all(n > 0) % if all abundances are positive then check for stability
    jacobian = zeros(size(A)); %initialise array for jacobian
    for k = 1:n_s % generate jacobian by looping over rows
        jacobian(k,:) = A(k,:)*n(k); % add the alpha_{k,i}n_i terms to the row
        jacobian(k,k) = jacobian(k,k) + sum(A(k,:).*n'); %add the sum over all abundances to the diagnoal terms
    end
    jacobian(eye(n_s)==1) = jacobian(eye(n_s)==1) + r; %add the growh rates to the diagonal terms
    if  max(real(eig(jacobian))) < 0 %find eigenvalues and check if all real parts are negative
        flag = 1; %stable equilibrium exists - set flag to 1.
    end
end

