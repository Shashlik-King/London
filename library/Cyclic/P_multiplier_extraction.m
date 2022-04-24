function [multipliers_p , multipliers_y] =  P_multiplier_extraction ( CSR_N_axis, gamma_matrix)

N_taregt = [1 10 100 1000 10000];

    CSR=[];
    for i=1:size(N_taregt,2)
               [CSR_failure] = retrive_CSR(15,N_taregt(i),CSR_N_axis,gamma_matrix);
               CSR = [ CSR , CSR_failure ] ; 
    end
        multipliers_p     = [ CSR ; N_taregt ];
        multipliers_y     = [ ones(1,size(N_taregt,2)) ; N_taregt];
end