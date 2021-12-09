function [results] = PISA_rel_error_lat_disp(WeightOpt,Es,element,output,PLAX)

%% Load results from COSPIN and PLAXIS

if output.stop==0
    COSPIN_results(:,1) = element.level(:,1);
    COSPIN_results(:,2) = [Es{1,end}(:,1,1)];
    COSPIN_results(:,3) = [Es{1,end}(:,1,2)];
    COSPIN_results(:,4) = [Es{1,end}(:,1,3)];
    COSPIN_results(:,5) = output.hor_defl(1:end-1,:);
elseif output.stop==1 
    COSPIN_results(:,1) = element.level(:,1);
    COSPIN_results(:,2) = inf;
    COSPIN_results(:,3) = inf;
    COSPIN_results(:,4) = inf;
    COSPIN_results(:,5) = inf; 
end     

%% Shear
shear(:,1) = PLAX.Plax_V(4:end,1); % depth
shear(:,2) = PLAX.Plax_V(4:end,end); % Plaxis shear

% Add weight of model
weight = 1/(max(shear(:,2))*WeightOpt(1).Weight_moment); % weight 
shear(:,4) = weight*ones(length(shear),1); % assign same weight to all values

for i = 1:length(shear)
    shear(i,3) = interp1(COSPIN_results(:,1),COSPIN_results(:,3),shear(i,1)); % COSPIN shear
    shear(i,5) = (shear(i,3)-shear(i,2))^2; % calculate relative square error
end

%% Moment
moment(:,1) = PLAX.Plax_M(4:end,1); % depth
moment(:,2) = PLAX.Plax_M(4:end,end); % Plaxis moment

% Add weight of model

if strcmp(WeightOpt(1).weight_type,'Obs_NP') || strcmp(WeightOpt(1).weight_type,'Scalar_Obs_NP') 
    weight = 1/(max(moment(:,2))*WeightOpt(1).Weight_moment); % weight 
    moment(:,4) = weight*ones(length(moment),1); % assign same weight to all values
elseif strcmp(WeightOpt(1).weight_type,'SWR_Max') 
    weight =1/(max(moment(:,2))*WeightOpt(1).Weight_Def*sqrt(size(moment,1))); 
%     weight =1/WeightOpt(1).Weight_Def;
    moment(:,4) = weight*ones(length(moment),1); % assign same weight to all values    
end 

for i = 1:length(moment)
    moment(i,3) = interp1(COSPIN_results(:,1),COSPIN_results(:,4),moment(i,1)); % COSPIN moment
    moment(i,5) = ((moment(i,3)-moment(i,2))*moment(i,4))^2; % calculate relative square error
end

%% Displacement
displacement(:,1) = PLAX.Plax_Disp(4:end,1); % depth
displacement(:,2) = PLAX.Plax_Disp(4:end,end); % Plaxis displacement

% Add weight of model

if strcmp(WeightOpt(1).weight_type,'Obs_NP') || strcmp(WeightOpt(1).weight_type,'Scalar_Obs_NP') 
    displacement(:,4) = 1./(displacement(:,2)*WeightOpt(1).Weight_Def*sqrt(size(displacement,1))); % weight  equal to   1/ observation * Coeficient* N Data on the curve
elseif strcmp(WeightOpt(1).weight_type,'SWR_Max') 
    weight =1/(max(displacement(:,2))*WeightOpt(1).Weight_Def*sqrt(size(displacement,1)));  
    displacement(:,4) = weight*ones(length(displacement),1); % assign same weight to all values    
else 
    error('Wrong error type is assigned')
end 

%displacement(:,4) = weight*ones(length(displacement),1); % assign same weight to all values

for i = 1:length(displacement)
    displacement(i,3) = interp1(COSPIN_results(:,1),COSPIN_results(:,5),displacement(i,1)); % COSPIN displacement
    displacement(i,5) = (displacement(i,3)-displacement(i,2))^2; % calculate relative square error
end

results.shear = shear;
results.moment = moment;
results.displacement = displacement;

end