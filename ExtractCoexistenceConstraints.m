% This script reads in the coexistence constraints and formats them into a
% matrix
[D,T] = xlsread('Data\Coexistence_constraints_CS_SC.xlsx');
D(isnan(D)) = 0;

for d = 1:size(D,1)
    Subset{d,1} = find(D(d,:)>0);
end

save Data\Coexistence_constraints_list
