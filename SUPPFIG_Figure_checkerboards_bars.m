% This script creates all checkerboard figures that are shown in
% Supplementary Information 4

clear all
% How many alternatives are there?
ALTNAME = 'AlternativeNames_23';
[D,TXT] = xlsread(['Data/' ALTNAME '.xlsx']);
NumInt = length(TXT);
NumSpp = 19;

% set desired figures to be 1, and set to 0 if not desired
PLOT_checker_SameSpp = 1; % checkerboard with same species for each figure
PLOT_checker_SameAlt = 0; % checkerboard with same alternative for each figure
PLOT_checker_SameMat = 0; % checkerboard with same Transition matrix for each figure

[d,Names_S] = xlsread('Data/DHINames_short.xlsx');
[d,Names_M] = xlsread('Data/DHINames_medium.xlsx');
[d,Names_L] = xlsread('Data/DHINames.xlsx');
FS = 14;

%% Creates a figure that compares the same alternative with different matrices
if PLOT_checker_SameAlt == 1 | PLOT_checker_SameMat == 1 | PLOT_checker_SameSpp == 1
    OutcomesBlock = zeros(NumInt,13,7);
    for InteractionMatrix = 1:7
        
        % Load the outcomes for this matrix
        load(['Data/OutcomesSetBIGIM' num2str(InteractionMatrix)],'*Failures')
        NumMod = size(WhichFailures,1); % This is the number of models we considered
        
        Fails = zeros(NumSpp,NumInt); MeaningfulMod = 0;
        for nm = 1:NumMod % Go through the models one-by-one
            AllSame = 1; % Check if they're all the same outcome (in which case we don't really care)
            for i = 1:NumInt-1
                % Is the ith set the same as the (i+1)th set?
                if isequal(WhichFailures{nm,i},WhichFailures{nm,i+1}) == 0
                    AllSame = 0;
                end
            end
            
            %             % If anyone went extinct in any alternative, we'll consider the model for the summary statistics
            %             if sum(NumberFailures(nm,:)) > 0
            %                 AllSame = 0;
            %             end
            
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
end

if PLOT_checker_SameSpp == 1
    % Now plot how each alternative works for different interaction matrices
    figure(1), clf
    ha = tight_subplot(3,5,[0.07 0.03],[0.04 0.04],[0.06 0.02],1);
    axes(ha(14)); axis off
    axes(ha(15)); axis off
    for spp_num = 1:13
        axes(ha(spp_num)), cla, hold on, box on
        II = imagesc((squeeze(OutcomesBlock(end:-1:1,spp_num,:))), 'AlphaData', .78);
        
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
                if spp_num == 12 % Desert mouse
                    if j == 20 | j == 21 | j == 22
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
        xticklabels(Interaction_Mat_Name_anon);
        xtickangle(45)
        axis tight
        colorbar
        colormap(parula)
        caxis([0 0.15])
        ylim([0.5 length(T_alt)+0.5])
        xlim([0.5 7.5])
        title(Names_L{spp_num},'fontsize',FS-1,'interpreter','latex')
        
        if spp_num == 1 | spp_num == 6 | spp_num == 11
            ylabel('Reintroduction strategy','fontsize',FS-1,'interpreter','latex');
        end
        
        for i = 1:7
            line([i i]+0.5, 0.5+[0 length(T_alt)], 'Color',0.7.*ones(1,3),'linewidth',1);
        end
        for i = 1:length(T_alt)
            line([0 13]+0.5, 0.5+i+[0 0], 'Color',0.7.*ones(1,3),'linewidth',1);
        end
        
    end
    Make_TIFF(['SuppFig_MatrixAlternativeChecquerboard.tiff'],[0 0 35 40]*1.1)
end

if PLOT_checker_SameAlt == 1
    % Now plot how different alternatives work for the same interaction matrix
    figure(1), clf
    ha = tight_subplot(8,3,[0.03 0.04],[0.04 0.04],[0.05 0.05],0);
    axes(ha(24)); axis off
    
    for alt_num = 1:NumInt
        
        axes(ha(alt_num)), cla, hold on, box on
        II = imagesc((squeeze(OutcomesBlock(alt_num,:,end:-1:1))'), 'AlphaData', .78);
        
        % Grey out sections with no negative consequences
        for i = 1:13
            for j = 1:7
                if OutcomesBlock(alt_num,i,end-j+1) < 0.01
                    ppp = patch(i+[0 1 1 0]-0.5,j+[0 0 1 1]-0.5,'w'); set(ppp,'edgecolor','none','facecolor',0.9.*ones(1,3))
                end
            end
        end
        
        
        % When we're not translocating boodies, show results as white
        if alt_num == 6
            for m = 1:7
                ppp = patch([9 10 10 9]+0.5,[0 0 1 1]+m-0.5,'w'); set(ppp,'edgecolor','none')
                ppp = plot(10,m,'kx'); set(ppp,'markersize',14,'linewidth',2)
            end
        end
        if alt_num == 7
            for m = 1:7
                ppp = patch([9 10 10 9]-0.5,[0 0 1 1]+m-0.5,'w'); set(ppp,'edgecolor','none')
                ppp = plot(9,m,'kx'); set(ppp,'markersize',14,'linewidth',2)
            end
        end
        if alt_num == 20 | alt_num == 21 | alt_num == 22
            for m = 1:7
                ppp = patch(3+[9 10 10 9]-0.5,[0 0 1 1]+m-0.5,'w'); set(ppp,'edgecolor','none')
                ppp = plot(12,m,'kx'); set(ppp,'markersize',14,'linewidth',2)
            end
            if alt_num == 21
                for m = 1:7
                    ppp = patch([9 10 10 9]-0.5,[0 0 1 1]+m-0.5,'w'); set(ppp,'edgecolor','none')
                    ppp = plot(9,m,'kx'); set(ppp,'markersize',14,'linewidth',2)
                end
            end
        end
        
        for i = 1:13
            line([i i]+0.5, 0.5+[0 7], 'Color',0.7.*ones(1,3),'linewidth',1);
        end
        for i = 1:7
            line([0 13]+0.5, 0.5+i+[0 0], 'Color',0.7.*ones(1,3),'linewidth',1);
        end
        
        yticks([1:7]); xticks([1:13]);
        xticklabels(Names_S);
        TranslocationAlternativesNames
        yticklabels(Interaction_Mat_Name_anon(end:-1:1));
        xtickangle(45)
        
        axis tight
        caxis([0 0.15])
        colorbar
        xlim([0.5 13.5])
        title(['Reintroduction strategy ' num2str(alt_num)],'fontsize',FS,'interpreter','latex')
        set(gca, 'Layer', 'top')
    end
    Make_TIFF(['SuppFig_MatrixSpeciesChecquerboard.tiff'],[0 0 40 60])
end

if PLOT_checker_SameMat == 1
    % Now plot how different alternatives work for the same interaction matrix
    figure(1), clf
    ha = tight_subplot(3,3,[0.06 0.08],[0.06 0.04],[0.1 0.05],0);
    for InteractionMatrix = 1:7
        axes(ha(InteractionMatrix)); hold on
        if     InteractionMatrix == 7
            axes(ha(7)); axis off
            axes(ha(9)); axis off
            axes(ha(8)); hold on
        end
        
        II = imagesc((squeeze(OutcomesBlock(end:-1:1,:,InteractionMatrix))), 'AlphaData', .78);
        
        % Grey out sections with no negative consequences
        for i = 1:13
            for j = 1:NumInt
                if OutcomesBlock(end-j+1,i,InteractionMatrix) < 0.01
                    ppp = patch(i+[0 1 1 0]-0.5,j+[0 0 1 1]-0.5,'w'); set(ppp,'edgecolor','none','facecolor',0.9.*ones(1,3))
                end
            end
        end
        
        % Cross out alternatives that exclude certain species
        XX = [9 10 12 12 12 9];
        YY = [17 18 4  3  2 3];
        for i = 1:length(XX)
            ppp = patch(XX(i)+[0 1 1 0]-0.5,YY(i)+[0 0 1 1]-0.5,'w'); set(ppp,'edgecolor','none')
            ppp = plot(XX(i),YY(i),'kx'); set(ppp,'markersize',10,'linewidth',1.5)
        end
        
        
        for i = 1:13
            line([i i]+0.5, 0.5+[0 NumInt], 'Color',0.7.*ones(1,3),'linewidth',1);
        end
        for i = 1:NumInt
            line([0 13]+0.5, 0.5+i+[0 0], 'Color',0.7.*ones(1,3),'linewidth',1);
        end
        
        
        yticks([1:NumInt]);
        xticks([1:13]);
        TranslocationAlternativesNames
        yticklabels(T_num_reverse);
        if mod(InteractionMatrix,3) == 1
            ylabel('Reintroduction strategy','fontsize',FS,'interpreter','latex');
        end
        
        if InteractionMatrix >=5; xticklabels(Names_M);
        else; xticklabels(Names_S);
        end
        xtickangle(45)
        axis tight
        caxis([0 0.15])
        colorbar
        xlim([0.5 13.5])
        if InteractionMatrix == 7
            title(['Consensus matrix'],'fontsize',FS,'interpreter','latex')
        else
            title([Interaction_Mat_Name_anon_L{InteractionMatrix}],'fontsize',FS,'interpreter','latex')
        end
        set(gca, 'Layer', 'top')
    end
    Make_TIFF(['SuppFig_AlternativeSpeciesChecquerboard.tiff'],[0 0 27 30]*1.2)
end
