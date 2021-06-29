clear all

%% This function produces an overall bar chart for the different translocation options.

% How many alternatives are there?
ALTNAME = 'AlternativeNames_23';
[D,TXT] = xlsread(['Data/' ALTNAME '.xlsx']);
NumInt = length(TXT);
NumSpp = 19;
Fails = zeros(NumInt,14); MeaningfulMod = 0;

for InteractionMatrix = 7
    
    
    load(['Data/OutcomesSetBIGIM' num2str(InteractionMatrix)],'*Failures')
    NumMod = size(WhichFailures,1);
    
    for nm = 1:NumMod
        
        % We only care about this model if the results aren't the same for every intervention
        AllSame = 1;
        %         for i = 1:NumInt-1
        %             % Is the ith set the same as the (i+1)th set?
        %             if isequal(WhichFailures{nm,i},WhichFailures{nm,i+1}) == 0
        %                 AllSame = 0;
        %             end
        %         end
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
end
Fails = Fails./MeaningfulMod;


% Load the species names
[d,Names] = xlsread('Data/DHINames.xlsx');

figure(2), clf
subplot('position',[0.08 0.15 0.3 0.8]); hold on;
CL = parula(NumInt); FS = 14; VisMin = 0.05;
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

set(gca,'xtick',[0:14],'ytick',[1:NumInt],'fontsize',FS-3,'yticklabel',T_num_reverse)
ylim([0 NumInt+1])
xlim([0 5])
box on
X = xlabel('Number of failed reintroductions','fontsize',FS+2,'interpreter','latex');

ylabel('Reintroduction strategy','fontsize',FS+2,'interpreter','latex');
set(gca,'TickLabelInterpreter','latex')
%% =================================================================
%% ============ Checkerboard figure for a single matrix ============
%% =================================================================
subplot('position',[0.5 0.15 0.45 0.8]); hold on; box on
load Data/OUTCOMES_BLOCK OutcomesBlock Names*

% Now plot how different alternatives work for the same interaction matrix
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
    line([i i]+0.5, 0.5+[0 NumInt], 'Color',0.5.*ones(1,3),'linewidth',1);
end
for i = 1:NumInt
    line([0 13]+0.5, 0.5+i+[0 0], 'Color',0.5.*ones(1,3),'linewidth',1);
end
set(gca,'xtick',[1:13],'ytick',[1:NumInt],'fontsize',FS-4,'yticklabel',T_num_reverse)

if InteractionMatrix >=5; xticklabels(Names_M);
else; xticklabels(Names_S);
end
xtickangle(45)
axis tight
caxis([0 0.15])
c = colorbar;
Y = ylabel(c,'Proportion of failed reintroductions','rotation',270,'fontsize',FS+2,'interpreter','latex');
set(Y,'Position',[3.9 0.0750 0])
xlim([0.5 13.5])
set(gca,'TickLabelInterpreter','latex')

set(X,'position',[2.5000 -3 -1])

X = xlabel('Species whose reintroduction failed','fontsize',FS+2,'interpreter','latex');
set(X,'position',[7.0000   -2.4   -1.0000])

text(-15.25,23,'(a)','fontsize',FS+5,'interpreter','latex')
text(-1.75,23,'(b)','fontsize',FS+5,'interpreter','latex')

Make_TIFF(['Figure_4_LowRes.tiff'],[0 0 25 20]*1.15,'-r150')
Make_TIFF(['Figure_4.tiff'],[0 0 25 20]*1.15,'-r400')


