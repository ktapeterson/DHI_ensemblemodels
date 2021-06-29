clear all

%% This function produces an overall bar chart for the different translocation options.
for InteractionMatrix = 1:7
    figure(1), clf, hold on
    % How many alternatives are there?
    ALTNAME = 'AlternativeNames_23';
    [D,TXT] = xlsread(['Data/' ALTNAME '.xlsx']);
    NumInt = length(TXT);
    NumSpp = 19;
    Fails = zeros(NumInt,14); MeaningfulMod = 0;
    
    
    
    load(['Data/OutcomesSetBIGIM' num2str(InteractionMatrix)],'*Failures')
    NumMod = size(WhichFailures,1);
    
    for nm = 1:NumMod
        
        % We only care about this model if the results aren't the same for every intervention
        AllSame = 1;
        if sum(NumberFailures(nm,:)) > 0
            AllSame = 0;
        end
        
        if AllSame == 0
            for ni = 1:NumInt
                ThisFail = WhichFailures{nm,ni};
                ThisFail(ThisFail>13) = [];
                if isempty(ThisFail) == 0
                    NumExt = sum(ThisFail <= 13);
                    Fails(ni,NumExt+1) = Fails(ni,NumExt+1) + 1;
                else
                    Fails(ni,1) = Fails(ni,1) + 1;
                end
            end
            MeaningfulMod = MeaningfulMod + 1;
        end
    end
    Fails = Fails./MeaningfulMod;
    
    
    % Load the species names
    [d,Names] = xlsread('Data/DHINames.xlsx');
    
    CL = parula(NumInt); FS = 18; VisMin = 0.05;
    set(gcf,'color','w')
    for i = 1:12
        plot([i i],[-10 30],'-','color',[0.9 0.8 1])
    end
    
    x = 0:13; X = linspace(0,13,100);
    for i = 1:NumInt
        
        y = Fails(i,:); y(y<VisMin & y>0) = VisMin;
        Y = 0.7.*spline(x,y,X); Y(Y<0)=0;
        Y = 24-[i+Y i-Y(end:-1:1)];
        pp = patch([X X(end:-1:1)],Y,'g');
        set(pp,'facealpha',0.7,'facecolor',CL(1,:),'edgecolor',0.5.*ones(1,3))
        
        % Calculate the mean outcome
        MF = sum(Fails(i,:).*[0:13]);
        plot(MF,24-i,'.','markersize',25,'color','k')
    end
    MaxNumExt = sum(sum(Fails)>0)+1;
    TranslocationAlternativesNames
    
    ylim([0 NumInt+1])
    xlim([0 10])
    box on
    set(gca,'xtick',[0:14],'ytick',[1:NumInt],'fontsize',FS-7,'yticklabel',T_alt_simple_reverse)
    ylabel('Reintroduction alternative','fontsize',FS,'interpreter','latex');
    xlabel('Number of failed reintroductions','fontsize',FS,'interpreter','latex');
    title(Interaction_Mat_Name_anon_L{InteractionMatrix},'fontsize',FS,'interpreter','latex','fontweight','normal');
    
    Make_TIFF(['SuppFig_violin_' num2str(InteractionMatrix) '.tiff'],[0 0 20 30])
    clearvars -except InteractionMatrix
end


