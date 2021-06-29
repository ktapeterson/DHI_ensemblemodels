clear all

%% The goal in this figure is to show how different species perform with a particular reintroduction alternative by plotting abundance data over time

% How many alternatives are there?
ALTNAME = 'AlternativeNames_23';
[D,TXT] = xlsread(['Data/' ALTNAME '.xlsx']);
NumInt = length(TXT);

TranslocationAlternativesNames
for InteractionMatrix = 7 % set interaction matrix
    load(['Data/SimulationSetBIGIM' num2str(InteractionMatrix)],'ReintroductionSimulations','TOUT')
    load(['Data/OutcomesSetBIGIM' num2str(InteractionMatrix)],'*Failures')
    NumMod = size(WhichFailures,1);
    
    % Load the species names
    [d,Names] = xlsread('Data/DHINames.xlsx');
    
    for Alternative = 1
        
        figure(5), clf, set(gcf,'color','w'); CLs = get(gca,'colororder'); CLs = [CLs; CLs]; axis off; FS = 15;
        ha = tight_subplot(2,3,0.07,[0.08 0.03],[0.07 0.04],0);
        
        axes_count = 0;
        for spp = [1 3 4 7 9 12]
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
            set(gca,'TickLabelInterpreter','latex')

            if min(size(S)) > 1 & isempty(S) == 0
                % Calculate and plot the quantiles
                S = S./repmat(S(:,1),1,length(T))./5;
                Q = quantile(S,[0.025 0.1 0.5 0.9 0.975]);
                
                plot([0 min(T)],[LB LB],':','linewidth',3,'color',CLs(spp,:))
                plot([min(T) T],[LB Q(3,:)],'-','linewidth',3,'color',CLs(spp,:))
                pp = patch([T T(end:-1:1)],[Q(1,:) Q(5,end:-1:1)],'g');
                set(pp,'facealpha',0.4,'edgecolor','none','facecolor',CLs(spp,:));
                pp = patch([T T(end:-1:1)],[Q(2,:) Q(4,end:-1:1)],'g');
                set(pp,'facealpha',0.4,'edgecolor','none','facecolor',CLs(spp,:));
            end
            set(gca,'yscale','log')
            xlim([2016 2060]);
            ylim([0.75 70])
            text(2058,1,Names{spp},'fontsize',FS,'fontweight','normal','interpreter','latex','horizontalalignment','right');
            set(gca,'ytick',[1 2 5 10 50],'xtick',[2020:20:2100],'xticklabel',[2020:20:2060],'yticklabel',{'1','2','5','10','50'},'fontsize',FS-2)
        end
        
        axes(ha(4))

        ylabel('Relative abundance','fontsize',FS+5,'fontweight','normal','interpreter','latex','horizontalalignment','left');
        Make_TIFF(['Reintro_timeseries.tiff'],[0 0 30 15],'-r400')
        Make_TIFF(['Reintro_timeseries_LowRes.tiff'],[0 0 30 15],'-r150')


    end
end