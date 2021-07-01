% function CreateModelsForAll()
% FUNCTION CreateModels accepts an input associated with which Transition
% matrix we wish to use where
% 1 => Saul 1
% 2 => Random Excel Document
% Documents with strings must only include the strings 'no', 'po', 'np' or
% 'pno'.

% Choose a Transition Matrix
TransMatrix = 1;

TAR = 595; % Number of coexisting ecosystems we want
count = 0; NumCoexisting = 0;
load Multipliers
if TransMatrix == 1
    A_sign = xlsread('MatlabData/IM1.xlsx');
    Multiplier = Multipliers(1);
    A_sign = A_sign';
elseif TransMatrix == 2
    [A_sign,STRx,~]=xlsread('MatlabData/IM2.xlsx'); % This will be changed to be a
    % specific transition matrix and repeated for other T matrices with
    % these variables
    Multiplier = Multipliers(2);
    % Find Variables
    A_sign = A_sign';
    STRx = STRx';
    refno = find(cellfun(@(x)strcmp(x,'no'),STRx));
    refpo = find(cellfun(@(x)strcmp(x,'po'),STRx));
    refnp = find(cellfun(@(x)strcmp(x,'pn'),STRx));
    refpno= find(cellfun(@(x)strcmp(x,'pno'),STRx));
    refn = find(cellfun(@(x)strcmp(x,'n'),STRx));
    A_sign(refn) = [-1,-1];
end


R_constraints = xlsread('Rvector.xlsx');
ExtractCoexistenceConstraints;
tic
NumSpp = length(A_sign);
while NumCoexisting < TAR % This while loop creates coexisting communities into which to add new species
    if mod(count,500000) == 0; count, end
    count = count + 1;
    
    if TransMatrix == 2 % This must be updated for new transition matrices
        % Generate random values and enter into matrix
        % This uses if statements because if we reference the empty vector
        % it converts the matrix into a vector which I think will break
        % everything
        if ~isempty(refno)
            A_sign(refno) = randi([-1,0],1,length(refno));
        end
        if ~isempty(refpo)
            A_sign(refpo) = randi([0,1],1,length(refpo));
        end
        if ~isempty(refnp)
            A_sign(refnp) = 2*randi([0,1],1,length(refnp))-1;
        end
        if ~isempty(refpno)
            A_sign(refpno)= randi([-1,1],1,length(refpno));
        end
    end
    
    % Random generation of growth rates (r) and interaction values (A)
    A = rand(NumSpp).*A_sign;
    A(1:NumSpp+1:end) = -Multiplier.*rand(1,NumSpp);
    r = rand(NumSpp,1);
    r([1:14 17:19]) = 0;
    
    % Test Subset Coexistence Constraints
    Pass =1; i = 1;
    while Pass == 1 && i<=7
        Pass = Coexistence_constraint(A,r,Subset{i},14:19);
        i=i+1;
    end
    
    if Pass == 1
        
        [Pass,init] = check_stability(A([5 6 14:19],[5 6 14:19]),r([5 6 14:19]));
        
        if Pass == 1
            
            % Check if the ecosystem has all species present at equilibrium.
            [Coexist,n_equil] = check_stability(A,r);
            
            % If all species can coexist at a reasonable density (accepting that there are no units)
            if Coexist == 1
                
                SatisfyGrowthConstraint = GrowthRateContraint(A,r,n_equil,R_constraints);
                
                if SatisfyGrowthConstraint == 1
                    NumCoexisting = NumCoexisting + 1
                    % For future reference, save the ecosystem parameters
                    ParameterSet{NumCoexisting,1} = A;
                    ParameterSet{NumCoexisting,2} = r;
                    ParameterSet{NumCoexisting,3} = n_equil;
                    ParameterSet{NumCoexisting,4} = init;
                    save ModelEnsembleIM1v2 ParameterSet
                    toc
                end
            end
        end
    end
end
save ModelEnsembleIM1v2 ParameterSet
