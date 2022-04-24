function [gamma_final,N_eq] = Neq_calc(csr,n,CSR_N_axis,gamma_matrix)
% Neq_calc(Neq_old,N_new,CSR_old,CSR_new,CSR_N_axis,gamma_matrix)
% Determination of equivalen number of cycle, knowing the  previous Neq,
% Number of cycle of the new load parcel, CSR of the previous parcel and CSR of the new parcel 

N_eq(1,3) = n(1);
% Neq       = 1;
for i = 1:size(csr,1)
    gamma = retrive_gamma(N_eq(i,3),csr(i),CSR_N_axis,gamma_matrix);
    
    if gamma >= 15
        fprintf('Failure reached at load level %d \n',i+1);
        break
    end
    
    Neq       = retrive_N(gamma,csr(i+1),CSR_N_axis,gamma_matrix);
    N_eq(i+1,1) = Neq;
    
    if i < size(csr,1) && Neq > 1        
        parcel_old      = csr(i);
        parcel_new      = csr(i+1);
        delta_gamma     = gamma_correction(parcel_old,parcel_new,CSR_N_axis,gamma_matrix);
        gamma_corrected = gamma+delta_gamma;
        Neq             = retrive_N(gamma_corrected,csr(i+1),CSR_N_axis,gamma_matrix);
        N_eq(i+1,2)     = Neq;
        
        if gamma_corrected >= 15
            fprintf('Failure reached at load level %d \n',i+1);
            break
        end
        
    elseif Neq <= 1
        Neq         = 1;
        N_eq(i+1)   = Neq;
        N_eq(i+1,2) = Neq;
    end
    N_eq(i+1,3) = N_eq(i+1,2) + n(i+1);
end
gamma_final = retrive_gamma(N_eq(i,3),csr(i),CSR_N_axis,gamma_matrix);
          
end

