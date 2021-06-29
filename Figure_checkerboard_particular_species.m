% This script generates checkered figures which demonstrate the proportion
% of failed translocations for each species across the interaction matrices
% and translocation alternatives

clear all

% How many alternatives are there?
ALTNAME = 'AlternativeNames_23';
[D,TXT] = xlsread(['Data/' ALTNAME '.xlsx']);
NumInt = length(TXT);
NumSpp = 19;

[d,Names_S] = xlsread('Data/DHINames_short.xlsx');
[d,Names_M] = xlsread('Data/DHINames_medium.xlsx');
[d,Names_L] = xlsread('Data/DHINames.xlsx');
FS = 12;

OutcomesBlock = zeros(NumInt,13,7);
for InteractionMatrix = 1:7
    
    % Load the outcomes for this matrix
    load(['Data/OutcomesSetBIGIM' num2str(InteractionMatrix)],'*Failures')
    NumMod = size(WhichFailures,1); % This is the number of models we considered
    
    Fails = zeros(NumSpp,NumInt); MeaningfulMod = 0;
    for nm = 1:NumMod % Go through the models one-by-one
        
        % If anyone went extinct in any alternative, we'll consider the model for the summary statistics
        AllSame = 1;
        if sum(NumberFailures(nm,:)) > 0
            AllSame = 0;
        end
        
        if AllSame == 0 % As long as all the outcomes aren't the same
            for ni = 1:NumInt % Go through each of the interventions
                ThisFail = WhichFailures{nm,ni}; % Which species failed this time?
                for wf = 1:length(ThisFail) % Go through them one by one
                    Fails(ThisFail(wf),ni) = Fails(ThisFail(wf),ni) + 1; % Record how frequently each species failed in each intervention
                end
            end
            MeaningfulMod = MeaningfulMod + 1;
        end
    end
    Fails = Fails(1:13,1:NumInt)./MeaningfulMod;
    OutcomesBlock(:,:,InteractionMatrix) = Fails';
end


% Now plot how each alternative works for different interaction matrices
figure(1), clf
ha = tight_subplot(2,3,0.08,[0.05 0.03],[0.05 0.125],1);
axes_counter = 0;
for spp_num = [1 4 7 9 10 11]
    axes_counter = axes_counter + 1;
    
    axes(ha(axes_counter)), cla, hold on, box on
    II = imagesc((squeeze(OutcomesBlock(end:-1:1,spp_num,:))), 'AlphaData', .78);
    set(gca,'TickLabelInterpreter','latex','fontsize',FS-2)

    % Grey out sections with no negative consequences
    for i = 1:7
        for j = 1:NumInt
            if OutcomesBlock(end-j+1,spp_num,i) < 0.01
                ppp = patch(i+[0 1 1 0]-0.5,j+[0 0 1 1]-0.5,'w'); set(ppp,'edgecolor','none','facecolor',0.9.*ones(1,3))
            end
        end
    end
    
    % White out species with no translocation
    for i = 1:7
        for j = 1:NumInt
            if spp_num == 10 % Boodies
                if j == 6 % No boodies
                    ppp = patch(i+[0 1 1 0]-0.5,24-j+[0 0 1 1]-0.5,'w'); set(ppp,'edgecolor','none')
                    ppp = plot(i,24-j,'kx'); set(ppp,'markersize',8,'linewidth',1.5)
                end
            end
            if spp_num == 9 % Mulgara
                if j == 7 | j == 21
                    ppp = patch(i+[0 1 1 0]-0.5,24-j+[0 0 1 1]-0.5,'w'); set(ppp,'edgecolor','none')
                    ppp = plot(i,24-j,'kx'); set(ppp,'markersize',8,'linewidth',1.5)
                end
            end
        end
    end

    TranslocationAlternativesNames
    
    yticks([1:length(T_alt)]); xticks([1:13]);
    yticklabels(T_num_reverse)
    xticklabels(Names_S);
    xticklabels(Interaction_Matrix_Name_S);
    xtickangle(90)
    axis tight
    colormap(parula)
    caxis([0 0.15])
    ylim([0.5 length(T_alt)+0.5])
    xlim([0.5 7.5])
    title(Names_L{spp_num},'fontsize',FS,'interpreter','latex')
    
    
    for i = 1:7 %%
        line([i i]+0.5, 0.5+[0 length(T_alt)], 'Color',0.5.*ones(1,3),'linewidth',1);
    end
    for i = 1:length(T_alt)
        line([0 13]+0.5, 0.5+i+[0 0], 'Color',0.5.*ones(1,3),'linewidth',1);
    end
    
end
c = colorbar('Position', [0.9 0.1 0.02 0.8]);
Y = ylabel(c,'Proportion of failed reintroductions','rotation',270,'fontsize',FS,'interpreter','latex');
set(Y,'Position',[4.5 0.0750 0])

% save figure
Make_TIFF(['Figure_6_LowRes.tiff'],[0 0 15 20]*1.3,'-r150')
Make_TIFF(['Figure_6.tiff'],[0 0 15 20]*1.3,'-r400')

