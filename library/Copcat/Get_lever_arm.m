function [Lever_arm,scour_Depth]=Get_lever_arm(file_name_orsted)
sheet           = 'Summary';                                 % define excel sheet name
data            = xlsread(file_name_orsted,sheet,'H20:H24'); % read excel
scour_Depth     = data(1)-data(5);                           % calulate scour depth
le_arm_af_Scour = data(3);                                   % arm length without scour
Lever_arm       = le_arm_af_Scour-scour_Depth;               % arm length with scour
end 
