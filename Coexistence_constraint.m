function Pass = Coexistence_constraint(A,r,Subset,Exogenous)

% This function determines whether a subset of species
% can coexist in a given ecosystem model. 
%
% Pass = Coexistence_constraint(A,r,Subset,Exogenous)
%
% INPUTS
%   A           is the matrix of interaction terms
%   r           is the vector of growth rates
%   Subset      is a vector listing the subset of species that 
%                   we're currently assessing
%   Exogenous   is a vector listing the species that 
%                   we assume are present in addition to the subset
%
% OUTPUTS
%   Pass is a binary flag indicating whether the subset can (1) or cannot (0) coexist
%

Include = [Subset, Exogenous];

% Check if the ecosystem has all species present at equilibrium.
Pass = check_stability(A(Include,Include),r(Include));



% 
% load ModelEnsemble A r n_equil
% 
% Subset = sort(randsample(13,4))
% Exogenous = [14;15]
% 
% % Introduce this species in isolation
% n_i = n_equil.*0; n_i(Include) = n_equil(Include);
% [tout,yout] = ode45(@(t,n)species_DE(t,n,A,r),[0,250],n_i);
% plot(tout,yout)
% set(gca,'yscale','log')
% 
% whos