function [N_eq_new,gamma_new,N_eq] = N_eq_calc(CSR_old,gamma_old,CSR_new,N_new,CSR_N_axis,gamma_matrix)
%Function to determine the new equivalent number of cycle. Starting from a
%point in the contour diagram, where the cyclic stress ratio "CSR_old" and
%gamma "gamma_old" are known, first the number of cycle corresponding to
%the new csr "CSR_new" and the old gamma "gamma_old" is determined; then
%the gamma value is corrected, obtaining a "gamma_corr", and a number of
%cycle "N_eq_corr", for "gamma_corrected" and "CSR_new" is determined. Eventually, the
%number of cycle of the next parcel is added to  "N_eq_corr", to obtain the
%value of gamma of the final point.

N_eq         = retrive_N(gamma_old,CSR_new,CSR_N_axis,gamma_matrix);

delta_gamma  = gamma_correction(CSR_old,CSR_new,CSR_N_axis,gamma_matrix);

gamma_corr   = gamma_old + delta_gamma;

N_eq_corr    = retrive_N(gamma_corr,CSR_new,CSR_N_axis,gamma_matrix);

N_eq_new     = N_eq_corr + N_new;

gamma_new    = retrive_gamma(N_eq_new,CSR_new,CSR_N_axis,gamma_matrix);

end

