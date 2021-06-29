% This script calculates the scalar multiple for the diagonal of the
% coefficient matrix, so that we generate approximately 1000 samples in 24
% hours
% TransMatrix determines how uncertainty in the matrix is handled

% Choose a Transition Matrix
% set to be 1 if there is no uncertainty in matrix, and 2 if there is 
% uncertainty. Specifcally 1: 1,3,4,5,7, 2: 2,6
TransMatrix = 2; 

TAR = 10; % Number of coexisting ecosystems we want to average across
Timing = 0;
Iterations = 15; Iters = 0;
StepChange = 10.*2.^-(1:(Iterations+1));
Multiplier = 10; % initial multiplier guess
NumCoexisting = 1; % initialise number of coexisting


if TransMatrix == 1
    % Import Matrix
    A_sign = xlsread('Data\IM5.xlsx'); % change this for different interaction matrices
    A_sign = A_sign';
elseif TransMatrix == 2
    % Import Matrix
    [A_sign,STRx,~]=xlsread('Data\IM6.xlsx'); % change this for different interaction matrices
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

% read in constraints
R_constraints = xlsread('Data\RVector.xlsx');
ExtractCoexistenceConstraints;

NumSpp = length(A_sign);

while Iters<Iterations && (Timing/NumCoexisting > 95 || Timing/NumCoexisting < 75)
    count = 0; NumCoexisting = 0; Timing = 0;
    tic
    % This while loop creates coexisting communities into which to add new species
    while NumCoexisting < TAR && toc < 950
        if mod(count,500000) == 0; count, end
        count = count + 1;
        
        if TransMatrix == 2
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
        A = rand(NumSpp).*repmat(rand(NumSpp,1),1,NumSpp).*repmat(rand(1,NumSpp),NumSpp,1).*A_sign;
        A(1:NumSpp+1:end) = -Multiplier.*rand(1,NumSpp).*rand(1,NumSpp).*rand(1,NumSpp);
        r = rand(NumSpp,1);
        r([1:14 17:19]) = 0;
        
        % Test Subset Coexistence Constraints
        Pass =1; i = 1;
        while Pass == 1 && i<=7
            Pass = Coexistence_constraint(A,r,Subset{i},14:19);
            i=i+1;
        end
        
        if Pass == 1
            
            [Pass,~] = check_stability(A([5 6 14:19],[5 6 14:19]),r([5 6 14:19]));
            
            if Pass == 1
                
                [Pass,init] = check_stability(A(14:19,14:19),r(14:19));
                
                if Pass == 1
                    
                    % Check if the ecosystem has all species present at equilibrium.
                    [Coexist,n_equil] = check_stability(A,r);
                    
                    % If all species can coexist at a reasonable density (accepting that there are no units)
                    if Coexist == 1
                        
                        SatisfyGrowthConstraint = GrowthRateContraint(A,r,n_equil,R_constraints);
                        
                        if SatisfyGrowthConstraint == 1
                            NumCoexisting = NumCoexisting + 1
                            Timing = toc;
                        end
                    end
                end
            end
        end
    end
    % update multiplier
    Iters = Iters + 1
    if NumCoexisting == 0
        Multiplier = Multiplier + StepChange(Iters)
        NumCoexisting = 1;
    elseif Timing/NumCoexisting > 95
        Timing/NumCoexisting
        Multiplier = Multiplier + StepChange(Iters)
    elseif Timing/NumCoexisting < 75
        Timing/NumCoexisting
        Multiplier = Multiplier - StepChange(Iters)
    end
    
end
% Output Final Multiplier and timing
FinalMult = Multiplier
FinalTime = Timing/NumCoexisting
