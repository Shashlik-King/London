function [gamma] = retrive_gamma(N,CSR,CSR_N_axis,gamma_matrix)
%RetriveGamma function takes as imput the number of cycles and cyclic 
%stress ratio (N,CSR) and retrive the corresponding shear strain (gamma) 
n               = CSR_N_axis(:,1);
csr             = CSR_N_axis(:,2);
[~,N_index]     = min(abs(n-N));
[~,CSR_index]   = min(abs(csr-CSR));
gamma           = gamma_matrix(CSR_index , N_index);
end