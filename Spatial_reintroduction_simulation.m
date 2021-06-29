function Spatial_reintroduction_simulation()

% Spatial_reintroduction_simulation simulates the reintroduction of the
%  full suite of species to different locations on Dirk Hartog Island.
%
% [] = Spatial_reintroduction_simulation(OrderData,DispersalMatrix)
%
%   in:  OrderData is a 3xN matrix
%           Row 1 = The number identity of the species being reintroduced
%           Row 2 = The year (2017+) that the species was/will be introduced
%           Row 3 = The spatial location of the reintroduction
%
%        DispersalMatrix is a 4xS matrix
%           Each row indicates a dispersal path
%               Row 1 = Proportional dispersal between regions 1 & 2 (symmetric)
%               Row 2 = Proportional dispersal between regions 2 & 3 (symmetric)
%               Row 3 = Proportional dispersal between regions 3 & 4 (symmetric)
%               Row 4 = Proportional dispersal between regions 4 & 5 (symmetric)

% Extract the dispersal data
Disp{3} = xlsread('Data/DispTimeDelay.xlsx'); % dispersal delay
Disp{2} = xlsread('Data/DispUpperBound.xlsx');
Disp{1} = xlsread('Data/DispLowerBound.xlsx');
Disp{1} = Disp{1}(2:end,3:end); % Cut off the headers
Disp{2} = Disp{2}(2:end,3:end); % Cut off the headers
std_disp_time = 0.1; % This is variation around the delay before inter-zone dispersal starts. 0.1 = +/- 25%

% How many alternatives are there?
[D,TXT] = xlsread('Data/AlternativeNames.xlsx');
NumAlternatives = length(TXT);

% Extract all the translocation alternatives
for alternatives = 1:NumAlternatives
    ThisOrderData = xlsread(['Data/AllAlternatives/Alt' num2str(alternatives) '.xlsx']);
    
    % Make sure the introduction order is listed chronologically
    [~,I] = sort(ThisOrderData(2,:));
    ThisOrderData = ThisOrderData(:,I);
    
    % Store them all in a cell
    OrderData{alternatives,1} = ThisOrderData;
    
    % Determine the reintroduction density at each release, for each alternative
    % If we have two intros of the same species, we can't double translocate, it would be
    % unfair. Divide 5% of the population across all reintroduction events
    for spp = 1:13
        NumReleases = length(find(ThisOrderData(1,:)==spp));
        RI_multiplier_matrix(alternatives,spp) = 1/NumReleases;
    end
    
    clear I F DispersalStarts ThisOrderData NumberofIntroductions
end
RI_multiplier_matrix(isinf(RI_multiplier_matrix)) = 0;

% Translocation proportions of carrying capacity
% - 1%  for everyone
% - 15% for species 4
% - 5%  for species 7
RI_Multiplier_2 = 0.05.*ones(NumAlternatives,13);
RI_multiplier_matrix = RI_multiplier_matrix.*RI_Multiplier_2;

% Go through each of the proposed interaction matrices
for InteractionMatrix = 1:6

    tic
    % Load the model ensemble (stored in the variable "ParameterSet").
    load(['Data/ModelEnsembleIM' num2str(InteractionMatrix)])
    NumSpp = length(ParameterSet{1,1}); % How many species are there?
    
    % What decrease (proportional) is low enough to constitute a failed reintroduction?
    TolerableDecrease = 0.5;
    
    dt = 1/4;  % Run the model in small timesteps
    Tmax = 50; % Run the simulations for 100 years (i.e., until 2117)
    
    % Go through the elements of the model ensemble one-by-one, and apply the
    % translocation plan to each
    for PS = 1:length(ParameterSet)

        if mod(PS,10) == 0
            disp([num2str(round(toc)) ' seconds elapsed. Currently IM-' num2str(InteractionMatrix) '; PS-' num2str(PS)])
        end
        % Load the model ensemble member
        A = ParameterSet{PS,1}; % Quantitative interaction matrix
        r = ParameterSet{PS,2}; % Intrinsic population growth rates
        
        % Create an initial population vector for each region
        % The matrix "n_i" stores the abundance of each species (NumSpp rows) in each region (5 columns)
        n_i = ParameterSet{PS,4};
        n_i = repmat(n_i,1,1,5);
                
        % Define a single dispersal probability for each species and each region pair (these are random)
        ThisDisp{2} = Disp{3};
        ThisDisp{1} = Disp{1} + rand(size(Disp{1})).*(Disp{2} - Disp{1});
        
        for alternatives = 1:NumAlternatives
            
            % Define the abundance of the reintroduction for each species (N reintroductions => T/N individuals each time).
            RI = ParameterSet{PS,3}(1:13)'.*RI_multiplier_matrix(alternatives,:); % Equilibrium population abundances
            
            % Extract the translocation alternative
            ThisOrderData = OrderData{alternatives,1};
            
            % Calculate the date at which dispersal of species sp begins
            for sp = 1:13
                F = min(find(ThisOrderData(1,:) == sp));
                
                if isempty(ThisOrderData(2,F)) == 0
                    DispersalStarts(sp) = ThisOrderData(2,F) + max(0,Disp{3}(2,sp)*(1 + std_disp_time*randn));
                else
                    DispersalStarts(sp) = 1900;
                end
            end
            
            % Simulate the translocation alternative
            [tout,yout] = species_DE_spatial(dt,Tmax,n_i,RI,A,r,ThisDisp,DispersalStarts,ThisOrderData,TolerableDecrease);

            if PS <= 1000
                %% Record and assess reintroduction simulation outcomes
                PlottingOutput = sum(yout(:,1:5:end,:),3)'; TOUT = tout(1:5:end);
                ReintroductionSimulations{PS,alternatives,1} = PlottingOutput;
            end
            
            Y = sum(yout,3); Y(Y==0) = nan; % Aggregate abundance across all zones
            LowEbb = min(Y,[],2); % This is the lowest abundance each species hits after release
            WhichFailures{PS,alternatives} = find(LowEbb(1:13) < TolerableDecrease.*RI');
            NumberFailures(PS,alternatives) = length(WhichFailures{PS,alternatives});

        end
        
        if mod(PS,500) == 0
%             Save the current output every so often
            save(['Data/OutcomesSetBIGIM' num2str(InteractionMatrix)],'*Failures')
            save(['Data/SimulationSetBIGIM' num2str(InteractionMatrix)],'ReintroductionSimulations','TOUT')
        end
    end
end




