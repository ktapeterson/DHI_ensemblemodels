

clear all

% How many alternatives are there?
ALTNAME = 'AlternativeNames_23';
[D,TXT] = xlsread(['Data/' ALTNAME '.xlsx']);
NumInt = length(TXT);
NumSpp = 19;

PLOT_bars = 0;
PLOT_checker_SameSpp = 0;
PLOT_checker_SameAlt = 0;
PLOT_checker_SameMat = 1;

[d,Names_S] = xlsread('Data/DHINames_short.xlsx');
[d,Names_M] = xlsread('Data/DHINames_medium.xlsx');
FS = 14;

%% =====================================================================================================
%% ============ Creates a figure that compares the same alternative with different matrices ============
%% =====================================================================================================
if PLOT_checker_SameAlt == 1 | PLOT_checker_SameMat == 1 | PLOT_checker_SameSpp == 1
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
end
save OUTCOMES_BLOCK
%% =================================================================
%% ============ Checkerboard figure for a single matrix ============
%% =================================================================

if PLOT_checker_SameMat == 1
    % Now plot how different alternatives work for the same interaction matrix
    figure(1), clf, hold on, box on
    InteractionMatrix = 7;
    
%     II = imagesc(log(squeeze(OutcomesBlock(end:-1:1,:,InteractionMatrix))), 'AlphaData', .78);
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
        ppp = plot(XX(i),YY(i),'kx'); set(ppp,'markersize',16,'linewidth',2)
    end

    
    for i = 1:13
        line([i i]+0.5, 0.5+[0 NumInt], 'Color',0.2.*ones(1,3),'linewidth',1);
    end
    for i = 1:NumInt
        line([0 13]+0.5, 0.5+i+[0 0], 'Color',0.3.*ones(1,3),'linewidth',1);
    end
    
    yticks([1:NumInt]);
    xticks([1:13]);
    TranslocationAlternativesNames
    if mod(InteractionMatrix,2) == 1
        yticklabels(T_alt(end:-1:1));
        ylabel('Reintroduction alternative','fontsize',FS,'interpreter','latex');
    else
        yticklabels([]);
    end
    
    if InteractionMatrix >=5; xticklabels(Names_M);
    else; xticklabels(Names_S);
    end
    xtickangle(45)
    axis tight
%     caxis([-5.5 -1.85])
    caxis([0 0.15])
    colorbar
    xlim([0.5 13.5])
    title(Interaction_Matrix_Name{InteractionMatrix},'fontsize',FS,'interpreter','latex')
    
    Make_TIFF(['NewFigures/Checkerboard_Mat' num2str(InteractionMatrix) '.tiff'],[0 0 42 45]*0.5,'-r300')
end

if PLOT_checker_SameAlt == 1
    % Now plot how each alternative works for different interaction matrices
    figure(1), clf
    ha = tight_subplot(5,5,0.04,0.02,0.02);%,1);
    for alt_num = 1:NumInt
        %         figure(alt_num), clf, hold on, box on
        axes(ha(alt_num)), cla, hold on, box on
        
        II = imagesc(log(squeeze(OutcomesBlock(alt_num,:,end:-1:1))'), 'AlphaData', .78);
        
        % When we're not translocating boodies, show results as white
        if alt_num == 6
            for m = 1:7 %%
                ppp = patch([9 10 10 9]+0.5,[0 0 1 1]+m-0.5,'w'); set(ppp,'edgecolor','none')
            end
        end
        if alt_num == 7
            for m = 1:7 %%
                ppp = patch([9 10 10 9]-0.5,[0 0 1 1]+m-0.5,'w'); set(ppp,'edgecolor','none')
            end
        end
        if alt_num == 20 | alt_num == 21 | alt_num == 22
            for m = 1:7 %%
                ppp = patch(3+[9 10 10 9]-0.5,[0 0 1 1]+m-0.5,'w'); set(ppp,'edgecolor','none')
            end
            if alt_num == 21
                for m = 1:7 %%
                    ppp = patch([9 10 10 9]-0.5,[0 0 1 1]+m-0.5,'w'); set(ppp,'edgecolor','none')
                end
            end
        end
        
        for i = 1:13
            line([i i]+0.5, 0.5+[0 7], 'Color',0.2.*ones(1,3),'linewidth',1); %%
        end
        for i = 1:7 %%
            line([0 13]+0.5, 0.5+i+[0 0], 'Color',0.3.*ones(1,3),'linewidth',1);
        end
        
        yticks([1:7]); xticks([1:13]); %%
        xticklabels(Names_S);
        TranslocationAlternativesNames
        yticklabels(Interaction_Matrix_Name_S(end:-1:1));
        xtickangle(45)
        %         h = colorbar;
        %         G = get(h,'ticks');
        %         ylabel(h, 'Frequency of failure','fontsize',FS,'interpreter','latex','Rotation',270.0)
        %         set(h,'ticks',G([1 end]),'ticklabels',{'Low','High'},'fontsize',FS);
        axis tight
        colormap(parula)
        caxis([-5.5 -1.85])
        xlim([0.5 13.5])
        title(T_alt{alt_num},'fontsize',FS,'interpreter','latex')
    end
    
    Make_TIFF(['NewFigures/Checkerboard_SameAlt.tiff'],[0 0 65 50],'-r300')
end


if PLOT_checker_SameSpp == 1
    
    % Now plot how each alternative works for different interaction matrices
    figure(1), clf
    ha = tight_subplot(3,5,0.04,0.02,0.02,1);
    for spp_num = 1:13
        
        axes(ha(spp_num)), cla, hold on, box on
        II = imagesc(log(squeeze(OutcomesBlock(:,spp_num,:))), 'AlphaData', .78);
        
        if spp_num == 10 % Boodies
            ppp = patch([0 7 7 0],6+[0 0 1 1]-0.5,'w'); set(ppp,'edgecolor','none') % Intervention 6
        end
        if spp_num == 12 % Desert mouse
            ppp = patch([0 7 7 0],20+[0 0 3 3]-0.5,'w'); set(ppp,'edgecolor','none') % Intervention 6
        end
        if spp_num == 9 % Mulgara
            ppp = patch([0 7 7 0],21+[0 0 1 1]-0.5,'w'); set(ppp,'edgecolor','none') % Intervention 6
            ppp = patch([0 7 7 0],07+[0 0 1 1]-0.5,'w'); set(ppp,'edgecolor','none') % Intervention 6
        end
        TranslocationAlternativesNames
        
        yticks([1:length(T_alt)]); xticks([1:13]);
        xticklabels(Names_S);
        xticklabels(Interaction_Matrix_Name_S);
        xtickangle(45)
        %         h = colorbar;
        %         G = get(h,'ticks');
        %         ylabel(h, 'Frequency of failure','fontsize',FS,'interpreter','latex','Rotation',270.0)
        %         set(h,'ticks',G([1 end]),'ticklabels',{'Low','High'},'fontsize',FS);
        axis tight
        colormap(parula)
        caxis([-5.5 -1.85])
        ylim([0.5 length(T_alt)+0.5])
        xlim([0.5 7.5])
        title(Names_M{spp_num},'fontsize',FS,'interpreter','latex')
        
        
        for i = 1:7 %%
            line([i i]+0.5, 0.5+[0 length(T_alt)], 'Color',0.7.*ones(1,3),'linewidth',1);
        end
        for i = 1:length(T_alt)
            line([0 13]+0.5, 0.5+i+[0 0], 'Color',0.7.*ones(1,3),'linewidth',1);
        end
        
    end
    
    axes(ha(14)), axis off; axes(ha(15)), axis off
    Make_TIFF(['NewFigures/Checkerboard_SameSpp.tiff'],[0 0 40 70]*0.8,'-r300')
end




if PLOT_bars == 1
    figure(4), clf, hold on; axis off;
    ax = tight_subplot(7,1,[0.05],[0.07 0.05],[0.07 0.02],1); %%
    
    for InteractionMatrix = 1:7 %%
        
        % Load the species names
        if InteractionMatrix < 7 %%
            Names = Names_S;
        else
            Names = Names_M;
        end
        
        load(['MAT files/OutcomesSetBIGIM' num2str(InteractionMatrix)],'*Failures')
        NumMod = size(WhichFailures,1);
        
        TranslocationAlternativesNames
        NumInt = length(T_alt);
        Fails = zeros(NumSpp,NumInt); MeaningfulMod = 0;
        for nm = 1:NumMod
            
            AllSame = 1;
            for i = 1:NumInt-1
                % Is the ith set the same as the (i+1)th set?
                if isequal(WhichFailures{nm,i},WhichFailures{nm,i+1}) == 0
                    AllSame = 0;
                end
            end
            %         if sum(NumberFailures(nm,:)) > 0
            %             AllSame = 0;
            %         end
            
            
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
        
        if PLOT_bars == 1
            axes(ax(InteractionMatrix)); hold on
            Fails = Fails(1:13,:)./MeaningfulMod;
            MY = 1.1*max(Fails(:));
            
            % Introduce some background shading
            for i = 1:13
                if mod(i,2) == 0
                    pp = patch(i+0.5.*[-1 1 1 -1],[0 0 1 1],'k');
                    set(pp,'edgecolor','none','facealpha',0.2)
                end
            end
            
            % Draw the bars
            B = bar(Fails);
            dc = parula(NumInt);
            for i = 1:NumInt
                set(B(i),'facecolor',dc(i,:));
            end
            
            if InteractionMatrix == 7 %%
                set(gca,'xtick',[1 2 3 4 5 6 7 8 9 10 11 12 13],'xticklabels',Names,'fontsize',FS);
            else
                set(gca,'xtick',[1 2 3 4 5 6 7 8 9 10 11 12 13],'xticklabels',Names,'fontsize',FS-2);
            end
            xtickangle(45);
            
            if InteractionMatrix == 2 | InteractionMatrix == 5
                ylabel('Frequency of reintroduction failure','fontsize',FS+1,'interpreter','latex');
            end
            ylim([0 0.25])
            box on
            TranslocationAlternativesNames
            title(Interaction_Matrix_Name{InteractionMatrix},'fontsize',FS,'interpreter','latex')
            if InteractionMatrix == 7 %%
                Make_TIFF(['NewFigures/Species_outcomes_bars.tiff'],[0 0 40 45])
            end
        end
        %
        %         if PLOT_checker_SameMat_DiffAlt == 1
        %             figure(1), clf, hold on, box on
        %             II = imagesc(log(Fails(:,end:-1:1)'), 'AlphaData', .78);
        %             for i = 1:13
        %                 line([i i]+0.5, 0.5+[0 NumInt], 'Color',0.2.*ones(1,3),'linewidth',1);
        %             end
        %             for i = 1:NumInt
        %                 line([0 13]+0.5, 0.5+i+[0 0], 'Color',0.3.*ones(1,3),'linewidth',1);
        %             end
        %
        %             yticks([1:NumInt]);
        %             xticks([1:13]);
        %             xticklabels(Names_M);
        %             TranslocationAlternativesNames
        %             yticklabels(T_alt(end:-1:1));
        %             xtickangle(45)
        %             colorbar
        %             axis tight
        %             colormap(parula)
        %             xlim([0.5 13.5])
        %             ylabel('Reintroduction alternative','fontsize',FS,'interpreter','latex');
        %             title(Interaction_Matrix_Name{InteractionMatrix},'fontsize',FS+5,'interpreter','latex')
        % %             Make_TIFF(['Figures/Species_outcomes_checkerboard_M' num2str(InteractionMatrix) '.tiff'],[0 0 30 20])
        %         end
        %
        clearvars -except InteractionMatrix FS ax Names* NumSpp PLOT_bars PLOT_checker_SameMat_DiffAlt
    end
    Make_TIFF(['NewFigures/Species_outcomes_checkerboard_M' num2str(InteractionMatrix) '.tiff'],[0 0 30 20])
end