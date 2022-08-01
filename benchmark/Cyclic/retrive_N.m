function [N] = retrive_N (gamma,CSR,CSR_N_axis,gamma_matrix)
%RetriveN function takes as input the value of gamma and cyclic stress ratio
%(gamma,CSR) and gives back the corrisponding number of cycle N.

n               = CSR_N_axis(:,1);
csr             = CSR_N_axis(:,2);
N                = [];
[~,CSR_index]   = min(abs(csr-CSR));
g_prelim        = gamma_matrix(CSR_index,:);   
g               = g_prelim(~isnan(g_prelim));         %Column of gamma_matrix, corresponding to cyclice stress ratio "CSR" given as input

if max(g) >= gamma && min(g) <= gamma   %If "gamma" given as input is lower or bigger than the first or the last value of the vector "g" containing the values of gamma,    
    
    [~,gamma_index]  = min(abs(g-gamma));    
    N                = n(gamma_index);
    
else
%     N                = 1;
    if g(end) < gamma
        disp('gamma is too big');
    elseif g(1) > gamma 
        disp('gamma too small');
    end
end
end
