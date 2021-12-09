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

function [element]=PISA_formulations_inverse(pile,soil,element,scour,settings,data,i,variable,object_layers)

% Formulations:
% 0 =Constant
% 1 = Linear 
% 2 = Exponential
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Upper clay 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if strcmp(element.model_py(i),'PISA Upper clay')
if element.soil_layer(i) < 9 || strcmp(element.model_py(i),'Zero soil') == 0
% P-Y curves


% Normalized ultimate lateral displacement
element.PISA_prelim_param.p_y(i,1)  = 1; % Formulation
element.PISA_prelim_param.p_y(i,2)  = 100; % Constant 1
element.PISA_prelim_param.p_y(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.p_y(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.p_y(i,5)  = 2; % Formulation
element.PISA_prelim_param.p_y(i,6)  = 10.52; % Constant 1
element.PISA_prelim_param.p_y(i,7)  = -5.29;   % Constant 2
element.PISA_prelim_param.p_y(i,8)  = -0.93;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.p_y(i,9)  = 1; % Formulation
element.PISA_prelim_param.p_y(i,10)  = variable(1); % Constant 1   -0.466
element.PISA_prelim_param.p_y(i,11)  = variable(2);   % Constant 2    4.13
element.PISA_prelim_param.p_y(i,12)  = 0;   % Constant 3

% Curvature
if -element.level(i,1)/pile.diameter <= 14.9
    element.PISA_prelim_param.p_y(i,13)  = 1; % Formulation
    element.PISA_prelim_param.p_y(i,14)  = variable(3); % Constant 1    -0.055
    element.PISA_prelim_param.p_y(i,15)  = variable(4);   % Constant 2    0.822
    element.PISA_prelim_param.p_y(i,16)  = 0;   % Constant 3
else
    element.PISA_prelim_param.p_y(i,13)  = 0; % Formulation
    element.PISA_prelim_param.p_y(i,14)  = 0; % Constant 1
    element.PISA_prelim_param.p_y(i,15)  = 0;   % Constant 2
    element.PISA_prelim_param.p_y(i,16)  = 0;   % Constant 3
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M-T curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.m_t(i,1)  = 0; % Formulation
element.PISA_prelim_param.m_t(i,2)  = variable(5); % Constant 1   30
element.PISA_prelim_param.m_t(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.m_t(i,4)  = 0;   % Constant 3

% Ultimate lateral load
if -element.level(i,1)/pile.diameter < 3
    element.PISA_prelim_param.m_t(i,5)  = 1; % Formulation
    element.PISA_prelim_param.m_t(i,6)  = -0.026; % Constant 1
    element.PISA_prelim_param.m_t(i,7)  = 0.567;   % Constant 2
    element.PISA_prelim_param.m_t(i,8)  = 0;   % Constant 3
elseif -element.level(i,1)/pile.diameter <= 5.05 && -element.level(i,1)/pile.diameter >= 3
    element.PISA_prelim_param.m_t(i,5)  = 1; % Formulation
    element.PISA_prelim_param.m_t(i,6)  = -0.209; % Constant 1
    element.PISA_prelim_param.m_t(i,7)  = 1.116;   % Constant 2
    element.PISA_prelim_param.m_t(i,8)  = 0;   % Constant 3
else
    element.PISA_prelim_param.m_t(i,5)  = 0; % Formulation
    element.PISA_prelim_param.m_t(i,6)  = 0.06; % Constant 1
    element.PISA_prelim_param.m_t(i,7)  = 0;   % Constant 2
    element.PISA_prelim_param.m_t(i,8)  = 0;   % Constant 3
end

% Normalized initial stiffness
element.PISA_prelim_param.m_t(i,9)  = 2; % Formulation
element.PISA_prelim_param.m_t(i,10)  = 0.024; % Constant 1
element.PISA_prelim_param.m_t(i,11)  = 0.199;   % Constant 2
element.PISA_prelim_param.m_t(i,12)  = -0.480;   % Constant 3

% Curvature
if -element.level(i,1)/pile.diameter < 3.46
    element.PISA_prelim_param.m_t(i,13)  = 1; % Formulation
    element.PISA_prelim_param.m_t(i,14)  = 0.117; % Constant 1
    element.PISA_prelim_param.m_t(i,15)  = 0;   % Constant 2
    element.PISA_prelim_param.m_t(i,16)  = 0;   % Constant 3
elseif -element.level(i,1)/pile.diameter >= 3.46 && -element.level(i,1)/pile.diameter <= 6
    element.PISA_prelim_param.m_t(i,13)  = 1; % Formulation
    element.PISA_prelim_param.m_t(i,14)  = -0.159; % Constant 1
    element.PISA_prelim_param.m_t(i,15)  = 0.954;   % Constant 2
    element.PISA_prelim_param.m_t(i,16)  = 0;   % Constant 3
else 
    element.PISA_prelim_param(i,12+1) = 0; % Curvature
    element.PISA_prelim_param.m_t(i,13)  = 0; % Formulation
    element.PISA_prelim_param.m_t(i,14)  = 0; % Constant 1
    element.PISA_prelim_param.m_t(i,15)  = 0;   % Constant 2
    element.PISA_prelim_param.m_t(i,16)  = 0;   % Constant 3
end  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          
% P-Y Toe curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.Hb(i,1)  = 0; % Formulation
element.PISA_prelim_param.Hb(i,2)  = 13; % Constant 1
element.PISA_prelim_param.Hb(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.Hb(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.Hb(i,5)  = 1; % Formulation
element.PISA_prelim_param.Hb(i,6)  = -0.00016; % Constant 1
element.PISA_prelim_param.Hb(i,7)  = 0.272;   % Constant 2
element.PISA_prelim_param.Hb(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.Hb(i,9)  = 1; % Formulation
element.PISA_prelim_param.Hb(i,10)  = 0.0017; % Constant 1
element.PISA_prelim_param.Hb(i,11)  = 0.038;   % Constant 2
element.PISA_prelim_param.Hb(i,12)  = 0;   % Constant 3

% Curvature
if -element.level(i,1)/pile.diameter <= 9.6
    element.PISA_prelim_param.Hb(i,13)  = 1; % Formulation
    element.PISA_prelim_param.Hb(i,14)  = -0.05; % Constant 1
    element.PISA_prelim_param.Hb(i,15)  = 0.489;   % Constant 2
    element.PISA_prelim_param.Hb(i,16)  = 0;   % Constant 3
else
    element.PISA_prelim_param(i,18) = 0;  % Curvature
    element.PISA_prelim_param.Hb(i,13)  = 0; % Formulation
    element.PISA_prelim_param.Hb(i,14)  = 0; % Constant 1
    element.PISA_prelim_param.Hb(i,15)  = 0;   % Constant 2
    element.PISA_prelim_param.Hb(i,16)  = 0;   % Constant 3
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M-Theta Toe curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.Mb(i,1)  = 0; % Formulation
element.PISA_prelim_param.Mb(i,2)  = 300; % Constant 1
element.PISA_prelim_param.Mb(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.Mb(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.Mb(i,5)  = 0; % Formulation
element.PISA_prelim_param.Mb(i,6)  = 0.182; % Constant 1
element.PISA_prelim_param.Mb(i,7)  = 0;   % Constant 2
element.PISA_prelim_param.Mb(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.Mb(i,9)   = 0; % Formulation
element.PISA_prelim_param.Mb(i,10)  = 0.003; % Constant 1
element.PISA_prelim_param.Mb(i,11)  = 0;   % Constant 2
element.PISA_prelim_param.Mb(i,12)  = 0;   % Constant 3

if -element.level(i,1)/pile.diameter <5.03
    element.PISA_prelim_param.Mb(i,13)  = 0; % Formulation
    element.PISA_prelim_param.Mb(i,14)  = 0.999; % Constant 1
    element.PISA_prelim_param.Mb(i,15)  = 0;   % Constant 2
    element.PISA_prelim_param.Mb(i,16)  = 0;   % Constant 3
elseif -element.level(i,1)/pile.diameter >= 5.03 && -element.level(i,1)/pile.diameter <= 6.72
    element.PISA_prelim_param.Mb(i,13)  = 1; % Formulation
    element.PISA_prelim_param.Mb(i,14)  = -0.592; % Constant 1
    element.PISA_prelim_param.Mb(i,15)  = 3.984;   % Constant 2
    element.PISA_prelim_param.Mb(i,16)  = 0;   % Constant 3
else
    element.PISA_prelim_param.Mb(i,13)  = 0; % Formulation
    element.PISA_prelim_param.Mb(i,14)  = 0; % Constant 1
    element.PISA_prelim_param.Mb(i,15)  = 0;   % Constant 2
    element.PISA_prelim_param.Mb(i,16)  = 0;   % Constant 3
end
            

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Glacial Till
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% elseif strcmp(element.model_py(i),'PISA Till')   
elseif element.soil_layer(i) < 11 || strcmp(element.model_py(i),'Zero soil') == 0
% P-Y curves    

%Table=tableAssigne(model_py(i))



% Normalized ultimate lateral displacement
element.PISA_prelim_param.p_y(i,1)  = 1; % Formulation
element.PISA_prelim_param.p_y(i,2)  = 100; % Constant 1
element.PISA_prelim_param.p_y(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.p_y(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.p_y(i,5)  = 2; % Formulation
element.PISA_prelim_param.p_y(i,6)  = 7.66; % Constant 1
element.PISA_prelim_param.p_y(i,7)  = -2.74;   % Constant 2
element.PISA_prelim_param.p_y(i,8)  = -4.75;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.p_y(i,9)  = 1; % Formulation
element.PISA_prelim_param.p_y(i,10)  = -0.41; % Constant 1
element.PISA_prelim_param.p_y(i,11)  = 3.78;   % Constant 2
element.PISA_prelim_param.p_y(i,12)  = 0;   % Constant 3

% Curvature
element.PISA_prelim_param.p_y(i,13)  = 1; % Formulation
element.PISA_prelim_param.p_y(i,14)  = -0.079; % Constant 1
element.PISA_prelim_param.p_y(i,15)  = 0.91;   % Constant 2
element.PISA_prelim_param.p_y(i,16)  = 0;   % Constant 3


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M-T curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.m_t(i,1)  = 0; % Formulation
element.PISA_prelim_param.m_t(i,2)  = 60; % Constant 1
element.PISA_prelim_param.m_t(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.m_t(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.m_t(i,5)  = 1; % Formulation
element.PISA_prelim_param.m_t(i,6)  = -0.12; % Constant 1
element.PISA_prelim_param.m_t(i,7)  = 0.57;   % Constant 2
element.PISA_prelim_param.m_t(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.m_t(i,9)   = 1; % Formulation
element.PISA_prelim_param.m_t(i,10)  = -0.007; % Constant 1
element.PISA_prelim_param.m_t(i,11)  = 0.029;   % Constant 2
element.PISA_prelim_param.m_t(i,12)  = 0;   % Constant 3

% Curvature
element.PISA_prelim_param.m_t(i,13)  = 1; % Formulation
element.PISA_prelim_param.m_t(i,14)  = -0.04; % Constant 1
element.PISA_prelim_param.m_t(i,15)  = 0.19;   % Constant 2
element.PISA_prelim_param.m_t(i,16)  = 0;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% P-Y Toe curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.Hb(i,1)  = 0; % Formulation
element.PISA_prelim_param.Hb(i,2)  = 70; % Constant 1
element.PISA_prelim_param.Hb(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.Hb(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.Hb(i,5)  = 0; % Formulation
element.PISA_prelim_param.Hb(i,6)  = 0.27; % Constant 1
element.PISA_prelim_param.Hb(i,7)  = 0;   % Constant 2
element.PISA_prelim_param.Hb(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.Hb(i,9)   = 0; % Formulation
element.PISA_prelim_param.Hb(i,10)  = 0.02; % Constant 1
element.PISA_prelim_param.Hb(i,11)  = 0;   % Constant 2
element.PISA_prelim_param.Hb(i,12)  = 0;   % Constant 3

% Curvature
element.PISA_prelim_param.Hb(i,13)  = 0; % Formulation
element.PISA_prelim_param.Hb(i,14)  = 0.49; % Constant 1
element.PISA_prelim_param.Hb(i,15)  = 0;   % Constant 2
element.PISA_prelim_param.Hb(i,16)  = 0;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M-Theta Toe curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.Mb(i,1)  = 0; % Formulation
element.PISA_prelim_param.Mb(i,2)  = 5000; % Constant 1
element.PISA_prelim_param.Mb(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.Mb(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.Mb(i,5)  = 0; % Formulation
element.PISA_prelim_param.Mb(i,6)  = 0.21; % Constant 1
element.PISA_prelim_param.Mb(i,7)  = 0;   % Constant 2
element.PISA_prelim_param.Mb(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.Mb(i,9)   = 0; % Formulation
element.PISA_prelim_param.Mb(i,10)  = 0.001; % Constant 1
element.PISA_prelim_param.Mb(i,11)  = 0;   % Constant 2
element.PISA_prelim_param.Mb(i,12)  = 0;   % Constant 3

element.PISA_prelim_param.Mb(i,13)  = 0; % Formulation
element.PISA_prelim_param.Mb(i,14)  = 0.83; % Constant 1
element.PISA_prelim_param.Mb(i,15)  = 0;   % Constant 2
element.PISA_prelim_param.Mb(i,16)  = 0;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Chalk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% elseif strcmp(element.model_py(i),'PISA Chalk') 
elseif element.soil_layer(i) < 20 || strcmp(element.model_py(i),'Zero soil') == 0
% P-Y curves    

% Normalized ultimate lateral displacement
element.PISA_prelim_param.p_y(i,1)  = 1; % Formulation
element.PISA_prelim_param.p_y(i,2)  = 50; % Constant 1
element.PISA_prelim_param.p_y(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.p_y(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.p_y(i,5)  = 1; % Formulation
element.PISA_prelim_param.p_y(i,6)  = 0.5; % Constant 1
element.PISA_prelim_param.p_y(i,7)  = 6.5;   % Constant 2
element.PISA_prelim_param.p_y(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.p_y(i,9)   = 1; % Formulation
element.PISA_prelim_param.p_y(i,10)  = 0.3; % Constant 1
element.PISA_prelim_param.p_y(i,11)  = 1.5;   % Constant 2
element.PISA_prelim_param.p_y(i,12)  = 0;   % Constant 3

% Curvature
element.PISA_prelim_param.p_y(i,13)  = 2; % Formulation
element.PISA_prelim_param.p_y(i,14)  = 0.73; % Constant 1
element.PISA_prelim_param.p_y(i,15)  = -0.66;   % Constant 2
element.PISA_prelim_param.p_y(i,16)  = -4.24;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M-T curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.m_t(i,1)  = 0; % Formulation
element.PISA_prelim_param.m_t(i,2)  = 50; % Constant 1
element.PISA_prelim_param.m_t(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.m_t(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.m_t(i,5)  = 1; % Formulation
element.PISA_prelim_param.m_t(i,6)  = -0.069; % Constant 1
element.PISA_prelim_param.m_t(i,7)  = 0.57;   % Constant 2
element.PISA_prelim_param.m_t(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.m_t(i,9)   = 2; % Formulation
element.PISA_prelim_param.m_t(i,10)  = 0.032; % Constant 1
element.PISA_prelim_param.m_t(i,11)  = 0.0153;   % Constant 2
element.PISA_prelim_param.m_t(i,12)  = -0.95;   % Constant 3

% Curvature
element.PISA_prelim_param.m_t(i,13)  = 1; % Formulation
element.PISA_prelim_param.m_t(i,14)  = -0.03; % Constant 1
element.PISA_prelim_param.m_t(i,15)  = 0.4;   % Constant 2
element.PISA_prelim_param.m_t(i,16)  = 0;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% P-Y Toe curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.Hb(i,1)  = 0; % Formulation
element.PISA_prelim_param.Hb(i,2)  = 20; % Constant 1
element.PISA_prelim_param.Hb(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.Hb(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.Hb(i,5)  = 0; % Formulation
element.PISA_prelim_param.Hb(i,6)  = 0.3; % Constant 1
element.PISA_prelim_param.Hb(i,7)  = 0;   % Constant 2
element.PISA_prelim_param.Hb(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.Hb(i,9)   = 0; % Formulation
element.PISA_prelim_param.Hb(i,10)  = 0.036; % Constant 1
element.PISA_prelim_param.Hb(i,11)  = 0;   % Constant 2
element.PISA_prelim_param.Hb(i,12)  = 0;   % Constant 3

% Curvature
element.PISA_prelim_param.Hb(i,13)  = 0; % Formulation
element.PISA_prelim_param.Hb(i,14)  = 0.49; % Constant 1
element.PISA_prelim_param.Hb(i,15)  = 0;   % Constant 2
element.PISA_prelim_param.Hb(i,16)  = 0;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M-Theta Toe curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.Mb(i,1)  = 0; % Formulation
element.PISA_prelim_param.Mb(i,2)  = 2000; % Constant 1
element.PISA_prelim_param.Mb(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.Mb(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.Mb(i,5)  = 0; % Formulation
element.PISA_prelim_param.Mb(i,6)  = 0.22; % Constant 1
element.PISA_prelim_param.Mb(i,7)  = 0;   % Constant 2
element.PISA_prelim_param.Mb(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.Mb(i,9)   = 0; % Formulation
element.PISA_prelim_param.Mb(i,10)  = 0.0012; % Constant 1
element.PISA_prelim_param.Mb(i,11)  = 0;   % Constant 2
element.PISA_prelim_param.Mb(i,12)  = 0;   % Constant 3

element.PISA_prelim_param.Mb(i,13)  = 0; % Formulation
element.PISA_prelim_param.Mb(i,14)  = 0.91; % Constant 1
element.PISA_prelim_param.Mb(i,15)  = 0;   % Constant 2
element.PISA_prelim_param.Mb(i,16)  = 0;   % Constant 3
      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Zero soil
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(element.model_py(i),'Zero soil')
    
element.PISA_prelim_param.p_y(i,1:16) = 0; 
element.PISA_prelim_param.m_t(i,1:16) = 0; 
element.PISA_prelim_param.Hb(i,1:16)  = 0; 
element.PISA_prelim_param.Mb(i,1:16)  = 0; 

else
    
end

% element.element.PISA_prelim_param = element.PISA_prelim_param; % save whole matrix into element structure
end
