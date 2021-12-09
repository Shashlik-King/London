function [results] = PISA_rel_error_load_disp(weightOpt,Es,element,output,PLAX)

%% Load results from COSPIN and PLAXIS

if output.stop==0
    COSPIN_results(:,1)    = output.def_calibration'; % displacement
    COSPIN_results(:,2)    = output.force_calibration'; % force
elseif output.stop==1 
    COSPIN_results(:,1)    = linspace(0,50,50);
    COSPIN_results(:,2)    = ones(length(COSPIN_results(:,1)))*10000000;
end     

%% Load displacement
load_displacement(:,1)     = unique(PLAX.Plax_Disp(4,[2:end]))'; % Plaxis displacement
load_displacement(:,2)     = 2*(unique(PLAX.Plax_Disp(1,[2:end]))'); % load    2 times of the load applied by plaxis 

% Add weight of model
weight                     = 1/(max(load_displacement(:,2))*weightOpt(1).Weight_Load_disp); % weight 
load_displacement(:,4)     = weight*ones(length(load_displacement),1);

for i = 1:length(load_displacement)
    load_displacement(i,3) = interp1(COSPIN_results(:,1)/1000, COSPIN_results(:,2), load_displacement(i,1)); % COSPIN displacement
    load_displacement(i,5) = (load_displacement(i,3)-load_displacement(i,2))^2; % calculate relative square error
end
results.load_displacement  = load_displacement;
end