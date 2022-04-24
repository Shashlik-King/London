function [delta_gamma] = gamma_correction(CSR_old,CSR_new,CSR_N_axis,gamma_matrix)
%The correction to gamma is made by considering a cross section to the
%contour diagram for N=1. The values of gamma and csr for N=1 ar
%determined. Then, trough an interpolations of these data, the values of
%gamma, corresponding to CSR of the previous parcel and CSR of the current
%parcel are determined. The difference between these two values is
%"delta_gamma"

N=1;
gamma = gamma_matrix (3:end,1);
CSR = zeros(size(gamma,1),1);   % preallocation

for i = 1 : size (gamma,1)
    csr = retrive_CSR (gamma(i),N,CSR_N_axis,gamma_matrix);
    CSR (i,1) = csr;
end

gamma_old = interp1 (CSR,gamma,CSR_old);
gamma_new = interp1 (CSR,gamma,CSR_new);
delta_gamma = gamma_new - gamma_old;

end

