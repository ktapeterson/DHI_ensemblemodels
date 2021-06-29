clear all

%% The goal in this figure is to show how different species perform with a particular reintroduction alternative

% How many alternatives are there?
ALTNAME = 'AlternativeNames_23';
[D,TXT] = xlsread(['Data/' ALTNAME '.xlsx']);
NumInt = length(TXT);

TranslocationAlternativesNames
for InteractionMatrix = 1:7 % loop over transition matrices
    load(['Data/SimulationSetBIGIM' num2str(InteractionMatrix)],'ReintroductionSimulations','TOUT')
    load(['Data/OutcomesSetBIGIM' num2str(InteractionMatrix)],'*Failures')
    NumMod = size(WhichFailures,1);
    
    % Load the species names
    [d,Names] = xlsread('Data/DHINames.xlsx');
    [~,Names_S] = xlsread('Data/DHINames_short.xlsx');
    
    figure(5), clf, set(gcf,'color','w'); CLs = get(gca,'colororder'); CLs = [CLs; CLs]; axis off; FS = 10;
    FF = 5; ha = tight_subplot(23,13,0.07./FF,[0.08 0.03]./FF,[0.1 0.03]./FF,0);
    axes_count = 0;
    
    for Alternative = 1:23
        
        
        for spp = 1:13
            axes_count = axes_count + 1;
            Si = ReintroductionSimulations{1,Alternative}(:,spp)'; Si(Si==0) = [];
            S = Si; clear Si
            for nm = 2:1000
                
                % We only care about this model if the results aren't the same for every intervention
                AllSame = 1;
                for i = 1:NumInt-1
                    % Is the ith set the same as the (i+1)th set?
                    if isequal(WhichFailures{nm,i},WhichFailures{nm,i+1}) == 0
                        AllSame = 0;
                    end
                end
                
                if AllSame == 0 % As long as all the outcomes aren't the same
                    Si = ReintroductionSimulations{nm,Alternative}(:,spp)'; Si(Si==0) = [];
                    if isempty(Si) == 0
                        if isnan(Si(1)) == 0
                            S = [S; Si]; clear Si
                        end
                    end
                end
                
            end
            
            % Get rid of pre-release elements from the time-vector
            Si = ReintroductionSimulations{nm,Alternative}(:,spp)';
            DLE = find(Si == 0); T = TOUT; T(DLE) = [];
            
            % Normalise the abundance timeseries by the initial value (otherwise it's too parameter dependent)
            
            LB = 0.75; % This is the lower plotting bound (pseudo-zero)
            axes(ha(axes_count)); hold on
            if min(size(S)) > 1 & isempty(S) == 0
                % Calculate and plot the quantiles
                S = S./repmat(S(:,1),1,length(T))./5; % There are 5 regions, so the initial abundance is one fifth of maximum
                Q = quantile(S,[0.025 0.1 0.5 0.9 0.975]);
                
                plot([min(T) T],[LB Q(3,:)],'-','linewidth',3,'color',CLs(spp,:))
                pp = patch([T T(end:-1:1)],[Q(1,:) Q(5,end:-1:1)],'g');
                set(pp,'facealpha',0.4,'edgecolor','none','facecolor',CLs(spp,:));
                pp = patch([T T(end:-1:1)],[Q(2,:) Q(4,end:-1:1)],'g');
                set(pp,'facealpha',0.4,'edgecolor','none','facecolor',CLs(spp,:));
            end
            set(gca,'yscale','log')
            xlim([2016 2050]);
            ylim([0.75 70])
            ylabel([Names_S{spp} ' rel abund'],'fontweight','normal','interpreter','latex');
            title(['Reintro alt ' num2str(Alternative)],'fontweight','normal','interpreter','latex');
            set(gca,'fontsize',FS)
            
            if mod(axes_count,13) == 1
                set(gca,'ytick',[1 2 5 10 50],'yticklabel',{'1','2','5','10','50'})
            end
            if axes_count > 286
                set(gca,'xtick',[2020:10:2100],'xticklabel',[2020:10:2060])
                xlabel('Year','interpreter','latex');
            end
        end
    end
    Make_TIFF(['SuppFig_Reintro_timeseries_' num2str(InteractionMatrix) '.tiff'],[0 0 30 45]*2)
end