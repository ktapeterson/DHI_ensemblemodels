function ExplainWhyExtinct()
% This function creates explanation figures for every species which goes 
% extinct in a simulation more than 15 times (out of 2000)  

% loop of transition matrices (MT) and species (SV)
for MT = 1:7
    for SV = 1:13
        sub_ExplainWhyExtinct(SV,MT)
        
    end
end

function sub_ExplainWhyExtinct(SpeciesValues,SimulationSet)

if nargin == 0
    SpeciesValues = 4;
    SimulationSet = 4;
end

% Select Method = 1 for IM1,IM3,IM4,IM5 and Method = 2 for IM2,IM6
if SimulationSet == 2 | SimulationSet == 6
    Method = 2;
else Method = 1;
end

% These can be changed to get results for a specific transisition matrix,
% or for the combined set. The second figure can only be generated with
% sets that also have a Simulation Set, so the All set can not be used.
load(['Data/ModelEnsembleIM' num2str(SimulationSet) '.mat'])
load(['Data/OutcomesSetBIGIM' num2str(SimulationSet) '.mat'])
load(['Data/SimulationSetBIGIM' num2str(SimulationSet) '.mat'])

[d,Names_S] = xlsread('Data/DHINames_short.xlsx');
[d,Names_M] = xlsread('Data/DHINames_medium.xlsx');
[d,Names_L] = xlsread('Data/DHINames.xlsx');
Names = Names_L;

% % Choose the species that you are interested in (can only take on 1 value at a time despite the name)
% if nargin == 0
%     SpeciesValues = 8;
% end

%%%%%%%%%%%% Does not need to be altered after this %%%%%%%%%%%%%%%%%
[m1,~] = size(WhichFailures);
ALTNAME = 'AlternativeNames_23'; % This can be changed to determine how many alternatives we wish to be included.
[~,TXT] = xlsread(['Data/' ALTNAME '.xlsx']);
n = length(TXT);
m2 = length(ReintroductionSimulations);
m = min([m1,m2]); % this is done because the simulation set is not always the same size as the observation set
Index = zeros(m,n);

% Find elements in the transition matrix which are nonzero
if Method == 1
    % for IM1,IM3,IM4,IM5 since these matrices do not change
    nonzeroelements = ParameterSet{1,1}(SpeciesValues,:) ~= 0;
else
    % for IM2, IM6 and All since these matrices do change
    Temp = zeros(1,19);
    for i = 1:m
        Temp = Temp + ParameterSet{i,1}(SpeciesValues,:) ~= 0;
    end
    nonzeroelements = Temp ~= 0;
end

% Identify if the interest species went extinct for a given parameter regime
% for each alternative
for i = 1:m
    for j = 1:n
        if isempty(find(WhichFailures{i,j}==SpeciesValues,1)) == 0
            Index(i,j) = 1;
        end
    end
end

% Identify a parameter set where a species went extinct
DeadRowIndex = find((sum(Index,2) >= 1) == 1);
lD = length(DeadRowIndex);
% Identify if a parameter regimes had at least one alive alternatives
AliveRowIndex = find((sum(Index,2) < n) == 1);
lA = length(AliveRowIndex);

% Only run the analyses if there were more than 15 parameter sets with an extinction
if lD < 15 | lA < 15
    return
end

% Fill the datasets with the appropriate parameter sets
DeadParameterSets = zeros(lD,19);
AliveParameterSets = zeros(lA,19);
for i = 1:lD
    DeadParameterSets(i,:) = ParameterSet{DeadRowIndex(i),1}(SpeciesValues,:);
end
for i = 1:lA
    AliveParameterSets(i,:) = ParameterSet{AliveRowIndex(i),1}(SpeciesValues,:);
end

% identify interaction terms which are nonzero
nonzeroindex = find(nonzeroelements == 1);

% % this identifies how many subplots across we use

% create histogram for just interaction term
cla, ind = 1;

IndexODeath = [];
EmptyCount = 0;
NonEmptyCount = 0;
for i = 1:lD 
    for j = 1:n % This is the alternative that resulted in extinction 
        if Index(DeadRowIndex(i),j) == 1
            TEMP = ReintroductionSimulations{DeadRowIndex(i),j}(:,SpeciesValues);
            TEMP(TEMP==0) = NaN;
            Temp = find(TEMP <= ParameterSet{DeadRowIndex(i),3}(SpeciesValues)*0.025/2,1,'first');
            if isempty(Temp) == 0
                IndexODeath = [IndexODeath; i,j, Temp-1];
                NonEmptyCount = NonEmptyCount + 1;
            else 
                EmptyCount = EmptyCount + 1;
            end

        end
    end
end
disp(EmptyCount/(NonEmptyCount+EmptyCount))
[LIOD,~] = size(IndexODeath);
IndexOAlive = [];
AliveCount = 0;
for i = 1:lA % ** Run this for all the alternatives
    for j = 1:n % This is the alternative that resulted in extinction (needs to vary with the number of alts)
        if Index(AliveRowIndex(i),j) == 0
            AliveCount = AliveCount + 1;
            IndexOAlive(AliveCount,:) = [i,j] ;
        end
    end
end
[LIOA,~] = size(IndexOAlive);

DeathComboResults = zeros(LIOD,length(nonzeroindex));
for i = 1:LIOD
    DeathComboResults(i,:) = ReintroductionSimulations{DeadRowIndex(IndexODeath(i,1)),IndexODeath(i,2)}(IndexODeath(i,3),nonzeroindex)...
                                .*DeadParameterSets(IndexODeath(i,1),nonzeroindex);
end
DeathComboResults(sum(isnan(DeathComboResults),2)>=1,:) = [];

AliveComboResults = zeros(LIOA,length(nonzeroindex));
for i = 1:LIOA 
    AliveComboResults(i,:) = ReintroductionSimulations{AliveRowIndex(IndexOAlive(i,1)),IndexOAlive(i,2)}(end,nonzeroindex)...
                                .*AliveParameterSets(IndexOAlive(i,1),nonzeroindex);
end
AliveComboResults(sum(isnan(AliveComboResults),2)>=1,:) = [];


F = find(nonzeroindex == SpeciesValues);
DeathComboResults(:,F) = [];
AliveComboResults(:,F) = [];
nonzeroindex(F) = [];

% In this figure, we show the relative size of the median effects
figure(1), set(gcf,'color','w')
clf, subplot('position',[0.15 0.15 0.7 0.7]); hold on, box off; FS = 12;
w = 0.1;
for i = 1:length(nonzeroindex)
    
%     Qd = quantile(DeathComboResults(:,i),[0.5]);
%     Qa = quantile(AliveComboResults(:,i),[0.5]);
    Qd = mean(DeathComboResults(:,i));
    Qa = mean(AliveComboResults(:,i));
    
    Rel = Qd./Qa - 1;
    if abs(Rel) < 0.15
        Rel = -1e-6;
    end
    
    pp = patch([0 0 Rel Rel],i+[-w w w -w],[0 0.5 0]);
    if sign(mean(AliveComboResults(:,i))) == -1
        set(pp,'facealpha',0.5,'facecolor',[0.5 0 0])
    else
        set(pp,'facealpha',0.5,'facecolor',[0 0.5 0])
    end
    
    if abs(Rel) > 1e-3
        if Rel < 0
%             message = sprintf([Names{nonzeroindex(i)} ' interaction was \n' num2str(abs(5*round(20*Rel))) '%% weaker than usual']);
            message = [Names{nonzeroindex(i)} ' interaction: ' num2str(abs(5*round(20*Rel))) '$\%$ weaker'];
            t = text(0.1,i,message);
            set(t,'fontsize',FS,'interpreter','latex')
        else
%             message = sprintf([Names{nonzeroindex(i)} ' interaction was \n' num2str(abs(5*round(20*Rel))) '%% stronger than usual']);
            message = [Names{nonzeroindex(i)} ' interaction: ' num2str(abs(5*round(20*Rel))) '$\%$ stronger'];
            t = text(-0.1,i,message);
            set(t,'HorizontalAlignment','right','fontsize',FS,'interpreter','latex'); 
            bb = get(t,'extent');
        end
    else
%         message = sprintf([Names{nonzeroindex(i)} ' interaction was no different']);
        message = sprintf(['Comparable ' Names{nonzeroindex(i)} ' interaction']);
        t = text(0.1,i,message);
        set(t,'fontsize',FS,'interpreter','latex')
    end

end
axis tight; XL = xlim; XL(1) = min([-1,XL(1)]); XL(2) = max([XL(2)+0.1,1]);
ylim([0.5 i+2.5]); YL = ylim;
xlim(max(abs(XL)).*[-1.05 1.05]); XL = xlim;
xlabel('Interaction strength during failure (relative to success)','fontsize',FS+4,'interpreter','latex')

plot([0 0],[0 i+0.25],'-','color',0.8.*ones(1,3))
set(gca,'ytick',[],'fontsize',FS);
G = get(gca,'xtick');
for g = 1:length(G)
    Gs{g} = [num2str(100*G(g)) '%'];
end
set(gca,'xtick',G,'xticklabel',Gs)
text(0,YL(2),['When ' Names_L{SpeciesValues} ' translocation failed: '],'fontsize',FS+3,'horizontalalignment','center','interpreter','latex')
ax = gca; ax.YColor = 'none';

pp = patch([0.95 0.9 0.9 0.95]*XL(1),[0.91 0.91 0.93 0.93].*YL(2),'g');
set(pp,'facealpha',0.5,'facecolor',[0.5 0 0])
text(0.89*XL(1),0.92*YL(2),'Negative interaction (e.g., predation)','fontsize',FS,'horizontalalignment','left','interpreter','latex')

pp = patch([0.95 0.9 0.9 0.95]*XL(1),[0.87 0.87 0.89 0.89].*YL(2),'g');
set(pp,'facealpha',0.5,'facecolor',[0 0.5 0])
text(0.89*XL(1),0.88*YL(2),'Positive interaction (e.g., consumption)','fontsize',FS,'horizontalalignment','left','interpreter','latex')
set(gca,'TickLabelInterpreter','latex')

Make_TIFF([Names_S{SpeciesValues} '_failure_ExpertMatrix_' num2str(SimulationSet) '.tiff'],[0 0 20 20]*1.25,'-r150')
return









