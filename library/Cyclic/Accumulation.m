function [N,CSR] = Accumulation(batch)
% close all
% clear ll
% clc

% batch = {'Drammen_Clay_4'};
% addpath (genpath('Library'));
% addpath (genpath('Batches'));
% load(['CSR_N_axis_',batch{1},'.mat']);
% load(['gamma_matrix_',batch{1},'.mat']);
%% Load data
CSR_N_axis = load(['CSR_N_axis_',batch,'.mat']);
gamma_matrix = load(['gamma_matrix_',batch,'.mat']);

%% Preallocation
loads       = xlsread('Markov_Matrix_node.xlsx');  %read loads
csr         = loads(:,1);
n           = loads(:,2);
Neq_plot(1) = 1;
Neq_plot(2) = 800;    %should be n(1) instead of 100....
csr_plot(1) = csr(1);
csr_plot(2) = csr(1);

%% Loop over loads
for i = 1:size(csr,1)  %cycle over the number of loads
    
    if i == 1
        gamma_old = retrive_gamma(100,csr(i),CSR_N_axis,gamma_matrix);    %should be n(i) instead of 100....
    else
        [N_eq_new,gamma_new,N_eq]  = N_eq_calc(csr(i-1),gamma_old,csr(i),n(i),CSR_N_axis,gamma_matrix);
        idx1                       = 1+(i-1)*2;
        idx2                       = 2+(i-1)*2;
        Neq_plot(idx1:idx2)        = [N_eq,N_eq_new];
        csr_plot(idx1:idx2)        = [csr(i),csr(i)];
        gamma_old                  = gamma_new;
    end
    
    if gamma_old == 15
        fprintf('Failure reached at load level %d \n',i+1);
        break
    end
    fprintf('Load level calculated: %d \n',i);
       
end

N        = CSR_N_axis (:,1);
CSR      = CSR_N_axis (:,2);
[N,CSR]  = meshgrid (N,CSR);

%% Plotting
contour (N,CSR,gamma_matrix);
grid on
grid minor
set(gca,'XScale','log')
xlabel ('Number of cycles [-]','FontSize',14);
ylabel ('CSR [-]','FontSize',14);
hold on
plot(Neq_plot,csr_plot,'.-r','MarkerSize',10);
legend (batch,'Accumulation Procedure','FontSize',14);

end

