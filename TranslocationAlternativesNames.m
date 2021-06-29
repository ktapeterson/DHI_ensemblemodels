
% This figure generates the names of the transition matrices

[D,Text] = xlsread(['Data/' ALTNAME '.xlsx']);

for i = 1:length(D)
    T_alt{i ,1} = Text{i};
    T_num{i} = ['(' num2str(i) ')'];
    T_num_reverse{i} = ['(' num2str(24-i) ')'];
end

Interaction_Matrix_Name{1} = '  First Saul matrix';
Interaction_Matrix_Name{2} = '  Second Saul matrix';
Interaction_Matrix_Name{3} = '  Third Saul matrix';
Interaction_Matrix_Name{4} = '  First Lesley matrix';
Interaction_Matrix_Name{5} = '  Second Lesley matrix';
Interaction_Matrix_Name{6} = '  Colleen matrix';
Interaction_Matrix_Name{7} = '  Consensus matrix';

Interaction_Matrix_Name_S{1} = 'E1-1';
Interaction_Matrix_Name_S{2} = 'E1-2';
Interaction_Matrix_Name_S{3} = 'E1-3';
Interaction_Matrix_Name_S{4} = 'E2-1';
Interaction_Matrix_Name_S{5} = 'E2-2';
Interaction_Matrix_Name_S{6} = 'E3-1';
Interaction_Matrix_Name_S{7} = 'C';

Interaction_Mat_Name_anon{1} = 'E1-1';
Interaction_Mat_Name_anon{2} = 'E1-2';
Interaction_Mat_Name_anon{3} = 'E1-3';
Interaction_Mat_Name_anon{4} = 'E2-1';
Interaction_Mat_Name_anon{5} = 'E2-2';
Interaction_Mat_Name_anon{6} = 'E3-1';
Interaction_Mat_Name_anon{7} = 'C';

Interaction_Mat_Name_anon_L{1} = 'Expert matrix E1-1';
Interaction_Mat_Name_anon_L{2} = 'Expert matrix E1-2';
Interaction_Mat_Name_anon_L{3} = 'Expert matrix E1-3';
Interaction_Mat_Name_anon_L{4} = 'Expert matrix E2-1';
Interaction_Mat_Name_anon_L{5} = 'Expert matrix E2-2';
Interaction_Mat_Name_anon_L{6} = 'Expert matrix E3-1';
Interaction_Mat_Name_anon_L{7} = 'Expert matrix C';



