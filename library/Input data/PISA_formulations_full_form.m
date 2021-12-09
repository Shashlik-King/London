% Function that combines all PISA spring formulations for respective layers
% into one function to decrease QA time and chances of errors. 
%
% Units: kN, m, s, kPa
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Log of changes------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date            Initials        Change
%2020.03.25      FKMV            Programming
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [element]=PISA_formulations(PISA_param,pile,soil,element,scour,settings,data,i)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Upper clay 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(element.model_py(i),'PISA Upper clay')

% P-Y curves
PISA_param(i,1)  = 100; % Normalized ultimate lateral displacement
for j = 1:2 % run for top and bottom of elements
    PISA_param(i,1+j) = 10.52-5.29*exp(-0.93*(-element.level(i,j)/pile.diameter));   % Ultimate lateral load
    PISA_param(i,3+j) = max(-0.466*(-element.level(i,j)/pile.diameter)+4.13 , PISA_param(i,1+j)/PISA_param(i,1)); % Normalized initial stiffness
    if -element.level(i,j)/pile.diameter <= 14.9
        PISA_param(i,5+j) = -0.055*(-element.level(i,j)/pile.diameter)+0.822; % Curvature
    else
        PISA_param(i,5+j) = 0; % Curvature
    end       
end

% M-Theta curves
PISA_param(i,8)  = 30; % Normalized ultimate nodal rotation
for j = 1:2 % run for top and bottom of elements
    if -element.level(i,j)/pile.diameter < 3
        PISA_param(i,8+j) =  -0.026*(-element.level(i,j)/pile.diameter)+0.567; % Normalized initial stiffness
    elseif -element.level(i,j)/pile.diameter <= 5.05 && -element.level(i,j)/pile.diameter >= 3
        PISA_param(i,8+j) = -0.209*(-element.level(i,j)/pile.diameter)+1.116; % Normalized initial stiffness
    else
        PISA_param(i,8+j) = 0.06; % Normalized initial stiffness
    end
    PISA_param(i,10+j) = max(0.024+0.199*exp(-0.480*-element.level(i,j)/pile.diameter) , PISA_param(i,8+j)/PISA_param(i,8)); % Normalized initial stiffness
    if -element.level(i,j)/pile.diameter < 3.46
        PISA_param(i,12+j) = 0.117*-element.level(i,j)/pile.diameter; % Curvature
    elseif -element.level(i,j)/pile.diameter >= 3.46 && -element.level(i,j)/pile.diameter <= 6
        PISA_param(i,12+j) = -0.159*-element.level(i,j)/pile.diameter+0.954; % Curvature
    else 
        PISA_param(i,12+j) = 0; % Curvature
    end
end
     
           
% P-Y Toe curves
PISA_param(i,15)  = 13; % Normalized nodal displacement and rotation 
PISA_param(i,16) = -0.00016*-element.level(i,j)/pile.diameter+0.272; % Ultimate lateral load
PISA_param(i,17) = 0.0017*-element.level(i,j)/pile.diameter+0.038;   % Normalized initial stiffness for base shear
if -element.level(i,j)/pile.diameter <= 9.6
    PISA_param(i,18) = -0.05*-element.level(i,j)/pile.diameter+0.489;  % Curvature
else
    PISA_param(i,18) = 0;  % Curvature
end

% M-Theta Toe curves
PISA_param(i,19)  = 300; % Normalized ultimate nodal displacement and rotation
PISA_param(i,20) = 0.182; % Ultimate lateral load
PISA_param(i,21) = 0.003;  % Normalized initial stiffness for base moment
if -element.level(i,j)/pile.diameter <5.03
    PISA_param(i,22) = 0.999;
elseif -element.level(i,j)/pile.diameter >= 5.03 && -element.level(i,j)/pile.diameter <= 6.72
    PISA_param(i,22) = -0.592*-element.level(i,j)/pile.diameter+3.984;
else
    PISA_param(i,22) = 0;
end
            

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Glacial Till
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(element.model_py(i),'PISA Till')   

% P-Y curves
PISA_param(i,1)  = 100; % Normalized ultimate lateral displacement
for j = 1:2 % run for top and bottom of elements
    PISA_param(i,1+j) = 7.66-2.74*exp(-4.75*(-element.level(i,j)/pile.diameter));   % Ultimate lateral load
    PISA_param(i,3+j) = -0.41*(-element.level(i,j)/pile.diameter)+3.78; % Normalized initial stiffness
    PISA_param(i,5+j) = -0.079*(-element.level(i,j)/pile.diameter)+0.91; % Curvature
end
% M-Theta curves
PISA_param(i,8)  = 60; % Normalized ultimate nodal rotation
for j = 1:2 % run for top and bottom of elements
    PISA_param(i,8+j) = max(-0.12*(-element.level(i,j)/pile.diameter)+0.57, 0.03); % Ultimate lateral load
    PISA_param(i,10+j) = max(-0.007*-element.level(i,j)/pile.diameter+0.029, PISA_param(i,8+j)/PISA_param(i,8)); % Normalized initial stiffness
    PISA_param(i,12+j) = -0.04*(-element.level(i,j)/pile.diameter)+0.19; % Curvature
end

% P-Y Toe curves
PISA_param(i,15)  = 70; % Normalized nodal displacement and rotation 
PISA_param(i,16) = 0.27; % Ultimate lateral load
PISA_param(i,17) = 0.02;   % Normalized initial stiffness for base shear
PISA_param(i,18) = 0.49; % Curvature

% M-Theta Toe curves  
PISA_param(i,19) = 5000; % Normalized ultimate nodal displacement and rotation
PISA_param(i,20) = 0.21;  % Ultimate lateral load
PISA_param(i,21) = 0.001;  % Normalized initial stiffness for base moment
PISA_param(i,22) = 0.83; % Curvature

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Chalk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(element.model_py(i),'PISA Chalk')

% P-Y curves
PISA_param(i,1)  = 50; % Normalized ultimate lateral displacement
for j = 1:2 % run for top and bottom of elements
    PISA_param(i,1+j) = 0.5*(-element.level(i,j)/pile.diameter)+6.5;   % Ultimate lateral load
    PISA_param(i,3+j) = 0.3*(-element.level(i,j)/pile.diameter)+1.5; % Normalized initial stiffness
    PISA_param(i,5+j) = 0.73-0.66*exp(-4.24*(-element.level(i,j)/pile.diameter)); % Curvature
end

% M-Theta curves
PISA_param(i,8)  = 50; % Normalized ultimate nodal rotation
for j = 1:2 % run for top and bottom of elements
    PISA_param(i,8+j) =  -0.069*(-element.level(i,j)/pile.diameter)+0.57; % Ultimate lateral load
    PISA_param(i,10+j) = 0.032+0.0153*exp(-0.95*(-element.level(i,j)/pile.diameter)); % Normalized initial stiffness
    PISA_param(i,12+j) = -0.03*(-element.level(i,j)/pile.diameter)+0.4; % Curvature
end

% P-Y Toe curves
PISA_param(i,15)  = 20; % Normalized nodal displacement and rotation 
PISA_param(i,16) = 0.3; % Ultimate lateral load
PISA_param(i,17) = 0.036;   % Normalized initial stiffness for base shear
PISA_param(i,18) = 0.49; % Curvature

% M-Theta Toe curves
PISA_param(i,19)  = 2000; % Normalized ultimate nodal displacement and rotation
PISA_param(i,20) = 0.22; % Ultimate lateral load
PISA_param(i,21) = 0.0012;  % Normalized initial stiffness for base moment
PISA_param(i,22) = 0.91; % Curvature
      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Zero soil
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(element.model_py(i),'Zero soil')
    
PISA_param(i,1:22) = 0; 

else
    
end

element.PISA_param = PISA_param; % save whole matrix into element structure
end
