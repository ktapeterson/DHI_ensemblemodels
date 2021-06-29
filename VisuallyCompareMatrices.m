function CompareMatrices()
% This function creates visual comparisons of the transition matrices 
clc

% read in data
[D,T] = xlsread('Data/DHINames_short.xlsx');
[d,Names_S] = xlsread('Data/DHINames_short.xlsx');
[d,Names_M] = xlsread('Data/DHINames_medium.xlsx');

[D1,T1] = xlsread('Data/IM1.xlsx');
[D2,T2] = xlsread('Data/IM2.xlsx');
[D3,T3] = xlsread('Data/IM3.xlsx');
[D4,T4] = xlsread('Data/IM4.xlsx');
[D5,T5] = xlsread('Data/IM5.xlsx');
[D6,T6] = xlsread('Data/IM6.xlsx');
[D7,T7] = xlsread('Data/IM7.xlsx');
NumSpp = length(D1);

% figure(3), clf; set(gcf,'color','w'); MS = 25; FS = 17;
% subplot('position',[0.1 0.1 0.7 0.7]), hold on; axis square, box on
% Agree = zeros(size(D1));
% for i = 1:19
%     for j = 1:19
%         vec = [];
%         for k = [3 5]%1:6
%             eval(['DD = D' num2str(k) ';'])
%             if isnan(DD(i,j)) == 0
%                 vec = [vec DD(i,j)];
%             else
% %                 vec = [vec 2];
%             end
%         end
%         
%         if length(unique(vec)) == 1
%             Agree(i,j) = 1;
%             if unique(vec) == 0 | i == j
%                 plot(i,20-j,'.','color',[0 0.5 0],'markersize',MS-10)
%             else
%                 plot(i,20-j,'.','color',[0 0.5 0],'markersize',MS+5)
%             end
%         else
%             plot(i,20-j,'x','color',[0.5 0 0],'markersize',MS-20,'linewidth',1)
%         end
%     end
% end
% text(21,12,[num2str(round(100*sum(Agree(:)==1)./19^2)) '% agreement'],'fontsize',FS,'color',[0 0.3 0])
% set(gca,'xtick',[1:19],'xticklabel',Names_M,'ytick',[1:19],'yticklabel',Names_M(end:-1:1))
% xtickangle(90); set(gca,'XAxisLocation','Top');

% Make_TIFF('Matrices_agreement.tiff',[0 0 25 20])

% This figure colours the entries of the transition matrices based on their
% sign
figure(2), clf; FS = 18;
set(gcf,'color','w'); MS = 30;

for i = 1:6 % loop over transition matrices
    if i < 4
        subplot(2,3,i), hold on, box on, axis square
    elseif i < 7
        subplot(2,3,i), hold on, box on, axis square
    elseif i == 7
        subplot(1,4,4), hold on, box on, axis square
    end
    eval(['Mat = D' num2str(i) ';'])
    for i = 1:19
        for j = 1:19
            if Mat(i,j) == 1
                plot(i,20-j,'.','color',[0 0.5 0],'markersize',MS)
            elseif Mat(i,j) == -1
                plot(i,20-j,'.','color',[0.5 0 0],'markersize',MS)
            elseif isnan(Mat(i,j)) == 1
                plot(i,20-j,'.','color',[0.75 0.75 0.75],'markersize',MS)
            end
        end
    end
    set(gca,'xtick',[1:19],'xticklabel',Names_S,'ytick',[1:19],'yticklabel',Names_S(end:-1:1))
    xtickangle(90)
    set(gca,'XAxisLocation','Top');
    
end
return
% Make_TIFF('Figures/All_interaction_matrices_MATFORM.tiff',[0 0 50 25])
% 
% figure(1), clf; FS = 18
% axes('position',[0.15 0.05 0.8 0.8]); hold on, box on, axis square
% set(gcf,'color','w'); MS = 35;
% 
% for i = 7
%     eval(['Mat = D' num2str(i) ';'])
%     for i = 1:19
%         for j = 1:19
%             if Mat(i,j) == 1
%                 plot(i,20-j,'.','color',[0 0.5 0],'markersize',MS)
%             elseif Mat(i,j) == -1
%                 plot(i,20-j,'.','color',[0.5 0 0],'markersize',MS)
%             elseif isnan(Mat(i,j)) == 1
%                 plot(i,20-j,'.','color',[0.75 0 0.75],'markersize',MS)
%             end
%         end
%     end
%     set(gca,'xtick',[1:19],'xticklabel',Names_M,'ytick',[1:19],'yticklabel',Names_M(end:-1:1))
%     xtickangle(90)
%     set(gca,'XAxisLocation','Top');
%     
% end
% 
% Make_TIFF('Figures/Consensus_interaction_matrix_MATFORM.tiff',[0 0 20 20]*0.75)

figure(1), clf; FS = 18;
set(gcf,'color','w');

XL = -1.4;
YL = 1.41;

AX = tight_subplot(3,2,0,0,0)

%% REPLACE THE CONSENSUS MATRIX
D6 = D7;
for X = 1:6
    axes(AX(X)); hold on
    eval(['PlotCircle(D' num2str(X) ',T)'])
end


% Make_TIFF('Figures/All_interaction_matrices.tiff',[0 0 30 30])

function PlotCircle(SppIntMat,T)
NumSpp = length(T);

% ===== PLOT JOINS BETWEEN SPECIES =====

R = 1; R2 = 1.01; R3 = 1.1;
Theta = linspace(0,2*pi,NumSpp+1);

d = 0.0;
LW = 1;
FS = 10;
for i = 1:NumSpp
    for j = 1:NumSpp
        if SppIntMat(i,j) < 0
            xx = [R*cos(Theta(i)+d) R*cos(Theta(j)+d)];
            yy = [R*sin(Theta(i)+d) R*sin(Theta(j)+d)];
            
            p = plot(xx,yy,'r--','linewidth',LW);
        end
        
        if SppIntMat(i,j) > 0
            xx = [R*cos(Theta(i)) R*cos(Theta(j))];
            yy = [R*sin(Theta(i)) R*sin(Theta(j))];
            
            p = plot(xx,yy,'b','linewidth',1*LW);
            
        end
    end
    plot(R2*cos(Theta(i)),R2*sin(Theta(i)),'k.','markersize',6)
    tt = text(R3*cos(Theta(i)),R3*sin(Theta(i)),T{i});
    set(tt,'rotation',360.*Theta(i)./2./pi,'fontsize',FS);
end

xlim([-1.5 1.5])
ylim([-1.5 1.5])
axis square off
box on
