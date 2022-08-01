function [CSR] = retrive_CSR(gamma,N,CSR_N_axis,gamma_matrix)
%RetriveCSR function takes as imput the value of gamma and number of
%cycles (gamma,N) and gives back the corresponding cyclic stress ratio CSR

n           = CSR_N_axis(:,1);
csr         = CSR_N_axis(:,2);
CSR         = [];
[~,N_index] = min(abs(n-N));
g_prelim    = gamma_matrix(:,N_index);
g           = g_prelim(~isnan(g_prelim));  

if g(end) >= gamma && g(2) <= gamma     %If "gamma" given as input is lower or bigger than the first or the last value of the vector "g" containing the values of gamma, 
    
    [~,gamma_index]  = min(abs(g-gamma));   
    CSR              = csr(gamma_index);
    
else
    if g(end) < gamma
        disp ('gamma is too big');
    elseif g(1) > gamma 
        disp ('gamma too small');
    end
end
end
