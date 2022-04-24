function [N_eq_new,gamma_new,N_eq] = N_eq_calc(CSR_old,gamma_old,CSR_new,N_new,CSR_N_axis,gamma_matrix)
%Function to determine the new equivalent number of cycle. Starting from a
%point in the contour diagram, where the cyclic stress ratio "CSR_old" and
%gamma "gamma_old" are known, first the number of cycle corresponding to
%the new csr "CSR_new" and the old gamma "gamma_old" is determined; then
%the gamma value is corrected, obtaining a "gamma_corr", and a number of
%cycle "N_eq_corr", for "gamma_corrected" and "CSR_new" is determined. Eventually, the
%number of cycle of the next parcel is added to  "N_eq_corr", to obtain the
%value of gamma of the final point.
% g               = g_prelim(~isnan(g_prelim));   
if gamma_old==0
    N_eq=1; % MDGI: If gamma=0 means that last load level was small and had to effect on this load level
    delta_gamma = 0; gamma_corr=0;
    N_eq_corr    = 1;
    N_eq         =   N_eq_corr; % MDGI to make sure that the load level change is included in output N_eq
    N_eq_new     =  N_new;
    
    if N_eq_new>=10000; N_eq_new=10000; end  % N shall be capped on 10000 cycles

else
    N_eq         = retrive_N(gamma_old,CSR_new,CSR_N_axis,gamma_matrix);
    delta_gamma  = gamma_correction(CSR_old,CSR_new,CSR_N_axis,gamma_matrix);
    gamma_corr   = gamma_old + delta_gamma;
    N_eq_corr    = retrive_N(gamma_corr,CSR_new,CSR_N_axis,gamma_matrix);
%     N_eq         =   N_eq_corr; % MDGI to make sure that the load level change is included in output N_eq
    N_eq_new     = N_eq_corr + N_new;
    
    if N_eq_new>=10000; N_eq_new=10000; end  % N shall be capped on 10000 cycles
end

gamma_new    = retrive_gamma(N_eq_new,CSR_new,CSR_N_axis,gamma_matrix);

end

