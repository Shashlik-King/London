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
%%%for hhhh=1: size(oobject_layers,2)
function [element]=PISA_formulations_inverse(pile,soil,element,scour,settings,data,i,variable,PYcreator_stiff)

% Formulations:
% 0 =Constant       = c1
% 1 = Linear        = c1 * L/D +c2
% 2 = Exponential   = c1 + c2 * exp( c3 * L/D )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Upper clay 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(element.model_py(i),'PISA Upper clay')
% if element.soil_layer(i) == object_layers || strcmp(element.model_py(i),'PISA Upper clay')
% P-Y curves


% Normalized ultimate lateral displacement
element.PISA_prelim_param.p_y(i,1)  = 0; % Formulation
element.PISA_prelim_param.p_y(i,2)  = 100; % Constant 1
element.PISA_prelim_param.p_y(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.p_y(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.p_y(i,5)  = 2; % Formulation
element.PISA_prelim_param.p_y(i,6)  = 10.52; % Constant 1
element.PISA_prelim_param.p_y(i,7)  = -5.29;   % Constant 2
element.PISA_prelim_param.p_y(i,8)  = -0.93;   % Constant 3

% if PYcreator_stiff
% Normalized initial stiffness
%     element.PISA_prelim_param.p_y(i,9)   = soil.ini_stiff(1); % Formulation
%     element.PISA_prelim_param.p_y(i,10)  = soil.ini_stiff(2);  % Constant 1
%     element.PISA_prelim_param.p_y(i,11)  = soil.ini_stiff(3);   % Constant 2
%     element.PISA_prelim_param.p_y(i,12)  = soil.ini_stiff(4);   % Constant 3
% else
    element.PISA_prelim_param.p_y(i,9)  = 1; % Formulation
    element.PISA_prelim_param.p_y(i,10)  = -0.466; % Constant 1 
    element.PISA_prelim_param.p_y(i,11)  = 4.13;   % Constant 2 
    element.PISA_prelim_param.p_y(i,12)  = 0;   % Constant 3
% end
% Curvature
if -element.level(i,1)/pile.diameter <= 14.9
    element.PISA_prelim_param.p_y(i,13)  = 1; % Formulation
    element.PISA_prelim_param.p_y(i,14)  = -0.055; % Constant 1  
    element.PISA_prelim_param.p_y(i,15)  = 0.822;   % Constant 2   
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
element.PISA_prelim_param.m_t(i,2)  = 30; % Constant 1   30
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
elseif strcmp(element.model_py(i),'PISA Till')   
% elseif element.soil_layer(i) < 11 || strcmp(element.model_py(i),'Zero soil') == 0
% elseif element.soil_layer(i) == object_layers || strcmp(element.model_py(i),'PISA Till')
% P-Y curves    

%Table=tableAssigne(model_py(i))



% Normalized ultimate lateral displacement
element.PISA_prelim_param.p_y(i,1)  = 0; % Formulation
element.PISA_prelim_param.p_y(i,2)  = 60; % Constant 1 
element.PISA_prelim_param.p_y(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.p_y(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.p_y(i,5)  = 2; % Formulation
element.PISA_prelim_param.p_y(i,6)  = 15.832; % Constant 1
element.PISA_prelim_param.p_y(i,7)  = -11.798;   % Constant 2
element.PISA_prelim_param.p_y(i,8)  = -0.161;   % Constant 3

% if PYcreator_stiff
% Normalized initial stiffness
    element.PISA_prelim_param.p_y(i,9)  = 1; % Formulation
    element.PISA_prelim_param.p_y(i,10)  = -0.275; % Constant 1
    element.PISA_prelim_param.p_y(i,11)  = 3.950;   % Constant 2
    element.PISA_prelim_param.p_y(i,12)  = 0;   % Constant 3
% end
% Curvature
element.PISA_prelim_param.p_y(i,13)  = 1; % Formulation
element.PISA_prelim_param.p_y(i,14)  = -0.034; % Constant 1
element.PISA_prelim_param.p_y(i,15)  = 0.955;   % Constant 2
element.PISA_prelim_param.p_y(i,16)  = 0;   % Constant 3


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M-T curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.m_t(i,1)  = 0; % Formulation
element.PISA_prelim_param.m_t(i,2)  = 30; % Constant 1
element.PISA_prelim_param.m_t(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.m_t(i,4)  = 0;   % Constant 3

% Ultimate lateral load
if -element.level(i,1)/pile.diameter <2.3
    element.PISA_prelim_param.m_t(i,5)  = 1; % Formulation
    element.PISA_prelim_param.m_t(i,6)  = 0.0000; % Constant 1
    element.PISA_prelim_param.m_t(i,7)  = 0.252;   % Constant 2
    element.PISA_prelim_param.m_t(i,8)  = 0;   % Constant 3
elseif -element.level(i,1)/pile.diameter >= 2.3 && -element.level(i,1)/pile.diameter <= 3.46
    element.PISA_prelim_param.m_t(i,5)  = 1; % Formulation
    element.PISA_prelim_param.m_t(i,6)  = -0.163; % Constant 1
    element.PISA_prelim_param.m_t(i,7)  = 0.625;   % Constant 2
    element.PISA_prelim_param.m_t(i,8)  = 0;   % Constant 3
else
    element.PISA_prelim_param.m_t(i,5)  = 0; % Formulation
    element.PISA_prelim_param.m_t(i,6)  = 0.062; % Constant 1
    element.PISA_prelim_param.m_t(i,7)  = 0;   % Constant 2
    element.PISA_prelim_param.m_t(i,8)  = 0;   % Constant 3
end
% Normalized initial stiffness
if -element.level(i,1)/pile.diameter <=3.9
    element.PISA_prelim_param.m_t(i,9)   = 1; % Formulation
    element.PISA_prelim_param.m_t(i,10)  = -0.019; % Constant 1
    element.PISA_prelim_param.m_t(i,11)  = 0.075;   % Constant 2
    element.PISA_prelim_param.m_t(i,12)  = 0;   % Constant 3
else
    element.PISA_prelim_param.m_t(i,9)   = 0; % Formulation
    element.PISA_prelim_param.m_t(i,10)  = 0.0044; % Constant 1
    element.PISA_prelim_param.m_t(i,11)  = 0;   % Constant 2
    element.PISA_prelim_param.m_t(i,12)  = 0;   % Constant 3
end

% Curvature
element.PISA_prelim_param.m_t(i,13)  = 1; % Formulation
element.PISA_prelim_param.m_t(i,14)  = 0.107; % Constant 1
element.PISA_prelim_param.m_t(i,15)  = 0.113;   % Constant 2
element.PISA_prelim_param.m_t(i,16)  = 0;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% P-Y Toe curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.Hb(i,1)  = 0; % Formulation
element.PISA_prelim_param.Hb(i,2)  = 35; % Constant 1
element.PISA_prelim_param.Hb(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.Hb(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.Hb(i,5)  = 1; % Formulation
element.PISA_prelim_param.Hb(i,6)  = 0.0556; % Constant 1
element.PISA_prelim_param.Hb(i,7)  = -0.0258;   % Constant 2
element.PISA_prelim_param.Hb(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.Hb(i,9)   = 1; % Formulation
element.PISA_prelim_param.Hb(i,10)  = 0.024; % Constant 1
element.PISA_prelim_param.Hb(i,11)  = -0.0004;   % Constant 2
element.PISA_prelim_param.Hb(i,12)  = 0;   % Constant 3

% Curvature
element.PISA_prelim_param.Hb(i,13)  = 1; % Formulation
element.PISA_prelim_param.Hb(i,14)  = -0.1456; % Constant 1
element.PISA_prelim_param.Hb(i,15)  = 0.774;   % Constant 2
element.PISA_prelim_param.Hb(i,16)  = 0;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M-Theta Toe curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.Mb(i,1)  = 0; % Formulation
element.PISA_prelim_param.Mb(i,2)  = 1000; % Constant 1
element.PISA_prelim_param.Mb(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.Mb(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.Mb(i,5)  = 0; % Formulation
element.PISA_prelim_param.Mb(i,6)  = 0.091; % Constant 1
element.PISA_prelim_param.Mb(i,7)  = 0;   % Constant 2
element.PISA_prelim_param.Mb(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.Mb(i,9)   = 0; % Formulation
element.PISA_prelim_param.Mb(i,10)  = 0.00025; % Constant 1
element.PISA_prelim_param.Mb(i,11)  = 0;   % Constant 2
element.PISA_prelim_param.Mb(i,12)  = 0;   % Constant 3

element.PISA_prelim_param.Mb(i,13)  = 0; % Formulation
element.PISA_prelim_param.Mb(i,14)  = 0.832; % Constant 1
element.PISA_prelim_param.Mb(i,15)  = 0;   % Constant 2
element.PISA_prelim_param.Mb(i,16)  = 0;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Chalk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(element.model_py(i),'PISA Chalk') 
% elseif element.soil_layer(i) == object_layers || strcmp(element.model_py(i),'PISA Chalk')
% elseif element.soil_layer(i) < 20 || strcmp(element.model_py(i),'Zero soil') == 0
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
%% Bothkennar clay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(element.model_py(i),'PISA Bothkennar clay') 
% elseif element.soil_layer(i) == object_layers || strcmp(element.model_py(i),'PISA Chalk')
% elseif element.soil_layer(i) < 20 || strcmp(element.model_py(i),'Zero soil') == 0
% P-Y curves    

% Normalized ultimate lateral displacement
element.PISA_prelim_param.p_y(i,1)  = 0; % Formulation
element.PISA_prelim_param.p_y(i,2)  = 200; % Constant 1
element.PISA_prelim_param.p_y(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.p_y(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.p_y(i,5)  = 2; % Formulation
element.PISA_prelim_param.p_y(i,6)  = 10.7; % Constant 1
element.PISA_prelim_param.p_y(i,7)  = -6.33;   % Constant 2
element.PISA_prelim_param.p_y(i,8)  = -1.12;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.p_y(i,9)   = 1; % Formulation
element.PISA_prelim_param.p_y(i,10)  = -1.01; % Constant 1
element.PISA_prelim_param.p_y(i,11)  = 10.51;   % Constant 2
element.PISA_prelim_param.p_y(i,12)  = 0;   % Constant 3

% Curvature
element.PISA_prelim_param.p_y(i,13)  = 1; % Formulation
element.PISA_prelim_param.p_y(i,14)  = -0.009; % Constant 1
element.PISA_prelim_param.p_y(i,15)  = 0.73;   % Constant 2
element.PISA_prelim_param.p_y(i,16)  = 0;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M-T curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.m_t(i,1)  = 0; % Formulation
element.PISA_prelim_param.m_t(i,2)  = 10; % Constant 1
element.PISA_prelim_param.m_t(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.m_t(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.m_t(i,5)  = 1; % Formulation
element.PISA_prelim_param.m_t(i,6)  = -0.04; % Constant 1
element.PISA_prelim_param.m_t(i,7)  = 0.58;   % Constant 2
element.PISA_prelim_param.m_t(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.m_t(i,9)   = 1; % Formulation
element.PISA_prelim_param.m_t(i,10)  = -0.2; % Constant 1
element.PISA_prelim_param.m_t(i,11)  = 1.25;   % Constant 2
element.PISA_prelim_param.m_t(i,12)  = 0;   % Constant 3

% Curvature
element.PISA_prelim_param.m_t(i,13)  = 0; % Formulation
element.PISA_prelim_param.m_t(i,14)  = 0; % Constant 1
element.PISA_prelim_param.m_t(i,15)  = 0;   % Constant 2
element.PISA_prelim_param.m_t(i,16)  = 0;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% P-Y Toe curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.Hb(i,1)  = 0; % Formulation
element.PISA_prelim_param.Hb(i,2)  = 300; % Constant 1
element.PISA_prelim_param.Hb(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.Hb(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.Hb(i,5)  = 1; % Formulation
element.PISA_prelim_param.Hb(i,6)  = -0.002; % Constant 1
element.PISA_prelim_param.Hb(i,7)  = 0.26;   % Constant 2
element.PISA_prelim_param.Hb(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.Hb(i,9)   = 1; % Formulation
element.PISA_prelim_param.Hb(i,10)  = -0.26; % Constant 1
element.PISA_prelim_param.Hb(i,11)  = 2.77;   % Constant 2
element.PISA_prelim_param.Hb(i,12)  = 0;   % Constant 3

% Curvature
element.PISA_prelim_param.Hb(i,13)  = 1; % Formulation
element.PISA_prelim_param.Hb(i,14)  = -0.03; % Constant 1
element.PISA_prelim_param.Hb(i,15)  = 0.40;   % Constant 2
element.PISA_prelim_param.Hb(i,16)  = 0;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M-Theta Toe curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.Mb(i,1)  = 0; % Formulation
element.PISA_prelim_param.Mb(i,2)  = 200; % Constant 1
element.PISA_prelim_param.Mb(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.Mb(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.Mb(i,5)  = 0; % Formulation
element.PISA_prelim_param.Mb(i,6)  = 0.21; % Constant 1
element.PISA_prelim_param.Mb(i,7)  = 0;   % Constant 2
element.PISA_prelim_param.Mb(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.Mb(i,9)   = 1; % Formulation
element.PISA_prelim_param.Mb(i,10)  = -0.02; % Constant 1
element.PISA_prelim_param.Mb(i,11)  = 0.26;   % Constant 2
element.PISA_prelim_param.Mb(i,12)  = 0;   % Constant 3

element.PISA_prelim_param.Mb(i,13)  = 1; % Formulation
element.PISA_prelim_param.Mb(i,14)  = -0.12; % Constant 1
element.PISA_prelim_param.Mb(i,15)  = 0.83;   % Constant 2
element.PISA_prelim_param.Mb(i,16)  = 0;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Cowden clay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(element.model_py(i),'PISA Cowden clay') 
% elseif element.soil_layer(i) == object_layers || strcmp(element.model_py(i),'PISA Chalk')
% elseif element.soil_layer(i) < 20 || strcmp(element.model_py(i),'Zero soil') == 0
% P-Y curves    

% Normalized ultimate lateral displacement
element.PISA_prelim_param.p_y(i,1)  = 0; % Formulation
element.PISA_prelim_param.p_y(i,2)  = 200; % Constant 1
element.PISA_prelim_param.p_y(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.p_y(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.p_y(i,5)  = 2; % Formulation
element.PISA_prelim_param.p_y(i,6)  = 10.21; % Constant 1
element.PISA_prelim_param.p_y(i,7)  = -7.22;   % Constant 2
element.PISA_prelim_param.p_y(i,8)  = -0.33;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.p_y(i,9)   = 1; % Formulation
element.PISA_prelim_param.p_y(i,10)  = -1.10; % Constant 1
element.PISA_prelim_param.p_y(i,11)  = 8.12;   % Constant 2
element.PISA_prelim_param.p_y(i,12)  = 0;   % Constant 3

% Curvature
element.PISA_prelim_param.p_y(i,13)  = 1; % Formulation
element.PISA_prelim_param.p_y(i,14)  = -0.05; % Constant 1
element.PISA_prelim_param.p_y(i,15)  = 0.92;   % Constant 2
element.PISA_prelim_param.p_y(i,16)  = 0;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M-T curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.m_t(i,1)  = 0; % Formulation
element.PISA_prelim_param.m_t(i,2)  = 10; % Constant 1
element.PISA_prelim_param.m_t(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.m_t(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.m_t(i,5)  = 1; % Formulation
element.PISA_prelim_param.m_t(i,6)  = -0.04; % Constant 1
element.PISA_prelim_param.m_t(i,7)  = 0.38;   % Constant 2
element.PISA_prelim_param.m_t(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.m_t(i,9)   = 1; % Formulation
element.PISA_prelim_param.m_t(i,10)  = -0.11; % Constant 1
element.PISA_prelim_param.m_t(i,11)  = 0.97;   % Constant 2
element.PISA_prelim_param.m_t(i,12)  = 0;   % Constant 3

% Curvature
element.PISA_prelim_param.m_t(i,13)  = 0; % Formulation
element.PISA_prelim_param.m_t(i,14)  = 0; % Constant 1
element.PISA_prelim_param.m_t(i,15)  = 0;   % Constant 2
element.PISA_prelim_param.m_t(i,16)  = 0;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% P-Y Toe curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.Hb(i,1)  = 0; % Formulation
element.PISA_prelim_param.Hb(i,2)  = 300; % Constant 1
element.PISA_prelim_param.Hb(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.Hb(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.Hb(i,5)  = 1; % Formulation
element.PISA_prelim_param.Hb(i,6)  = 0.07; % Constant 1
element.PISA_prelim_param.Hb(i,7)  = 0.60;   % Constant 2
element.PISA_prelim_param.Hb(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.Hb(i,9)   = 1; % Formulation
element.PISA_prelim_param.Hb(i,10)  = -0.32; % Constant 1
element.PISA_prelim_param.Hb(i,11)  = 2.56;   % Constant 2
element.PISA_prelim_param.Hb(i,12)  = 0;   % Constant 3

% Curvature
element.PISA_prelim_param.Hb(i,13)  = 1; % Formulation
element.PISA_prelim_param.Hb(i,14)  = -0.03; % Constant 1
element.PISA_prelim_param.Hb(i,15)  = 0.74;   % Constant 2
element.PISA_prelim_param.Hb(i,16)  = 0;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M-Theta Toe curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.Mb(i,1)  = 0; % Formulation
element.PISA_prelim_param.Mb(i,2)  = 200; % Constant 1
element.PISA_prelim_param.Mb(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.Mb(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.Mb(i,5)  = 1; % Formulation
element.PISA_prelim_param.Mb(i,6)  = -0.08; % Constant 1
element.PISA_prelim_param.Mb(i,7)  = 0.65;   % Constant 2
element.PISA_prelim_param.Mb(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.Mb(i,9)   = 1; % Formulation
element.PISA_prelim_param.Mb(i,10)  = -0.003; % Constant 1
element.PISA_prelim_param.Mb(i,11)  = 0.20;   % Constant 2
element.PISA_prelim_param.Mb(i,12)  = 0;   % Constant 3

element.PISA_prelim_param.Mb(i,13)  = 1; % Formulation
element.PISA_prelim_param.Mb(i,14)  = -0.16; % Constant 1
element.PISA_prelim_param.Mb(i,15)  = 1.01;   % Constant 2
element.PISA_prelim_param.Mb(i,16)  = 0;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PISA Sand Dr = 75%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(element.model_py(i),'PISA sand Dr75') 
% elseif element.soil_layer(i) == object_layers || strcmp(element.model_py(i),'PISA Chalk')
% elseif element.soil_layer(i) < 20 || strcmp(element.model_py(i),'Zero soil') == 0
% P-Y curves    

% Normalized ultimate lateral displacement
element.PISA_prelim_param.p_y(i,1)  = 0; % Formulation
element.PISA_prelim_param.p_y(i,2)  = 53.1; % Constant 1
element.PISA_prelim_param.p_y(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.p_y(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.p_y(i,5)  = 1; % Formulation
element.PISA_prelim_param.p_y(i,6)  = -10.18; % Constant 1
element.PISA_prelim_param.p_y(i,7)  = 21.61;   % Constant 2
element.PISA_prelim_param.p_y(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.p_y(i,9)   = 1; % Formulation
element.PISA_prelim_param.p_y(i,10)  = -0.85; % Constant 1
element.PISA_prelim_param.p_y(i,11)  = 7.46;   % Constant 2
element.PISA_prelim_param.p_y(i,12)  = 0;   % Constant 3

% Curvature
element.PISA_prelim_param.p_y(i,13)  = 0; % Formulation
element.PISA_prelim_param.p_y(i,14)  = 0.944; % Constant 1
element.PISA_prelim_param.p_y(i,15)  = 0;   % Constant 2
element.PISA_prelim_param.p_y(i,16)  = 0;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M-T curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.m_t(i,1)  = 0; % Formulation
element.PISA_prelim_param.m_t(i,2)  = 20; % Constant 1
element.PISA_prelim_param.m_t(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.m_t(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.m_t(i,5)  = 1; % Formulation
element.PISA_prelim_param.m_t(i,6)  = -0.05; % Constant 1
element.PISA_prelim_param.m_t(i,7)  = 0.21;   % Constant 2
element.PISA_prelim_param.m_t(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.m_t(i,9)   = 0; % Formulation
element.PISA_prelim_param.m_t(i,10)  = 20; % Constant 1
element.PISA_prelim_param.m_t(i,11)  = 0;   % Constant 2
element.PISA_prelim_param.m_t(i,12)  = 0;   % Constant 3

% Curvature
element.PISA_prelim_param.m_t(i,13)  = 0; % Formulation
element.PISA_prelim_param.m_t(i,14)  = 0; % Constant 1
element.PISA_prelim_param.m_t(i,15)  = 0;   % Constant 2
element.PISA_prelim_param.m_t(i,16)  = 0;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% P-Y Toe curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.Hb(i,1)  = 1; % Formulation
element.PISA_prelim_param.Hb(i,2)  = -0.29; % Constant 1
element.PISA_prelim_param.Hb(i,3)  = 2.31;   % Constant 2
element.PISA_prelim_param.Hb(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.Hb(i,5)  = 1; % Formulation
element.PISA_prelim_param.Hb(i,6)  = -0.07; % Constant 1
element.PISA_prelim_param.Hb(i,7)  = 0.62;   % Constant 2
element.PISA_prelim_param.Hb(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.Hb(i,9)   = 1; % Formulation
element.PISA_prelim_param.Hb(i,10)  = -0.38; % Constant 1
element.PISA_prelim_param.Hb(i,11)  = 3.02;   % Constant 2
element.PISA_prelim_param.Hb(i,12)  = 0;   % Constant 3

% Curvature
element.PISA_prelim_param.Hb(i,13)  = 1; % Formulation
element.PISA_prelim_param.Hb(i,14)  = -0.05; % Constant 1
element.PISA_prelim_param.Hb(i,15)  = 0.94;   % Constant 2
element.PISA_prelim_param.Hb(i,16)  = 0;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M-Theta Toe curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.Mb(i,1)  = 0; % Formulation
element.PISA_prelim_param.Mb(i,2)  = 50; % Constant 1
element.PISA_prelim_param.Mb(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.Mb(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.Mb(i,5)  = 1; % Formulation
element.PISA_prelim_param.Mb(i,6)  = -0.05; % Constant 1
element.PISA_prelim_param.Mb(i,7)  = 0.38;   % Constant 2
element.PISA_prelim_param.Mb(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.Mb(i,9)   = 0; % Formulation
element.PISA_prelim_param.Mb(i,10)  = 0.29; % Constant 1
element.PISA_prelim_param.Mb(i,11)  = 0;   % Constant 2
element.PISA_prelim_param.Mb(i,12)  = 0;   % Constant 3

% Curvature
element.PISA_prelim_param.Mb(i,13)  = 0; % Formulation
element.PISA_prelim_param.Mb(i,14)  = 0.89; % Constant 1
element.PISA_prelim_param.Mb(i,15)  = 0;   % Constant 2
element.PISA_prelim_param.Mb(i,16)  = 0;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PISA Sand Dr = 45%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(element.model_py(i),'PISA sand Dr45') 
% elseif element.soil_layer(i) == object_layers || strcmp(element.model_py(i),'PISA Chalk')
% elseif element.soil_layer(i) < 20 || strcmp(element.model_py(i),'Zero soil') == 0
% P-Y curves    

% Normalized ultimate lateral displacement
element.PISA_prelim_param.p_y(i,1)  = 0; % Formulation
element.PISA_prelim_param.p_y(i,2)  = 102.4; % Constant 1
element.PISA_prelim_param.p_y(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.p_y(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.p_y(i,5)  = 1; % Formulation
element.PISA_prelim_param.p_y(i,6)  = -6.87; % Constant 1
element.PISA_prelim_param.p_y(i,7)  = 14.16;   % Constant 2
element.PISA_prelim_param.p_y(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.p_y(i,9)   = 1; % Formulation
element.PISA_prelim_param.p_y(i,10)  = -0.82; % Constant 1
element.PISA_prelim_param.p_y(i,11)  = 7.34;   % Constant 2
element.PISA_prelim_param.p_y(i,12)  = 0;   % Constant 3

% Curvature
element.PISA_prelim_param.p_y(i,13)  = 0; % Formulation
element.PISA_prelim_param.p_y(i,14)  = 0.940; % Constant 1
element.PISA_prelim_param.p_y(i,15)  = 0;   % Constant 2
element.PISA_prelim_param.p_y(i,16)  = 0;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M-T curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.m_t(i,1)  = 0; % Formulation
element.PISA_prelim_param.m_t(i,2)  = 20; % Constant 1
element.PISA_prelim_param.m_t(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.m_t(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.m_t(i,5)  = 1; % Formulation
element.PISA_prelim_param.m_t(i,6)  = -0.10; % Constant 1
element.PISA_prelim_param.m_t(i,7)  = 0.19;   % Constant 2
element.PISA_prelim_param.m_t(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.m_t(i,9)   = 0; % Formulation
element.PISA_prelim_param.m_t(i,10)  = 20; % Constant 1
element.PISA_prelim_param.m_t(i,11)  = 0;   % Constant 2
element.PISA_prelim_param.m_t(i,12)  = 0;   % Constant 3

% Curvature
element.PISA_prelim_param.m_t(i,13)  = 0; % Formulation
element.PISA_prelim_param.m_t(i,14)  = 0; % Constant 1
element.PISA_prelim_param.m_t(i,15)  = 0;   % Constant 2
element.PISA_prelim_param.m_t(i,16)  = 0;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% P-Y Toe curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.Hb(i,1)  = 1; % Formulation
element.PISA_prelim_param.Hb(i,2)  = -0.20; % Constant 1
element.PISA_prelim_param.Hb(i,3)  = 2.17;   % Constant 2
element.PISA_prelim_param.Hb(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.Hb(i,5)  = 1; % Formulation
element.PISA_prelim_param.Hb(i,6)  = -0.07; % Constant 1
element.PISA_prelim_param.Hb(i,7)  = 0.62;   % Constant 2
element.PISA_prelim_param.Hb(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.Hb(i,9)   = 1; % Formulation
element.PISA_prelim_param.Hb(i,10)  = -0.37; % Constant 1
element.PISA_prelim_param.Hb(i,11)  = 3.07;   % Constant 2
element.PISA_prelim_param.Hb(i,12)  = 0;   % Constant 3

% Curvature
element.PISA_prelim_param.Hb(i,13)  = 1; % Formulation
element.PISA_prelim_param.Hb(i,14)  = -0.04; % Constant 1
element.PISA_prelim_param.Hb(i,15)  = 0.90;   % Constant 2
element.PISA_prelim_param.Hb(i,16)  = 0;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M-Theta Toe curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.Mb(i,1)  = 0; % Formulation
element.PISA_prelim_param.Mb(i,2)  = 50; % Constant 1
element.PISA_prelim_param.Mb(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.Mb(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.Mb(i,5)  = 1; % Formulation
element.PISA_prelim_param.Mb(i,6)  = -0.04; % Constant 1
element.PISA_prelim_param.Mb(i,7)  = 0.26;   % Constant 2
element.PISA_prelim_param.Mb(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.Mb(i,9)   = 0; % Formulation
element.PISA_prelim_param.Mb(i,10)  = 0.28; % Constant 1
element.PISA_prelim_param.Mb(i,11)  = 0;   % Constant 2
element.PISA_prelim_param.Mb(i,12)  = 0;   % Constant 3

% Curvature
element.PISA_prelim_param.Mb(i,13)  = 0; % Formulation
element.PISA_prelim_param.Mb(i,14)  = 0.87; % Constant 1
element.PISA_prelim_param.Mb(i,15)  = 0;   % Constant 2
element.PISA_prelim_param.Mb(i,16)  = 0;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PISA Sand Dr = 60%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(element.model_py(i),'PISA sand Dr60') 
% elseif element.soil_layer(i) == object_layers || strcmp(element.model_py(i),'PISA Chalk')
% elseif element.soil_layer(i) < 20 || strcmp(element.model_py(i),'Zero soil') == 0
% P-Y curves    

% Normalized ultimate lateral displacement
element.PISA_prelim_param.p_y(i,1)  = 0; % Formulation
element.PISA_prelim_param.p_y(i,2)  = 75.8; % Constant 1
element.PISA_prelim_param.p_y(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.p_y(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.p_y(i,5)  = 1; % Formulation
element.PISA_prelim_param.p_y(i,6)  = -5.77; % Constant 1
element.PISA_prelim_param.p_y(i,7)  = 17.04;   % Constant 2
element.PISA_prelim_param.p_y(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.p_y(i,9)   = 1; % Formulation
element.PISA_prelim_param.p_y(i,10)  = -0.82; % Constant 1
element.PISA_prelim_param.p_y(i,11)  = 7.42;   % Constant 2
element.PISA_prelim_param.p_y(i,12)  = 0;   % Constant 3

% Curvature
element.PISA_prelim_param.p_y(i,13)  = 0; % Formulation
element.PISA_prelim_param.p_y(i,14)  = 0.950; % Constant 1
element.PISA_prelim_param.p_y(i,15)  = 0;   % Constant 2
element.PISA_prelim_param.p_y(i,16)  = 0;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M-T curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.m_t(i,1)  = 0; % Formulation
element.PISA_prelim_param.m_t(i,2)  = 20; % Constant 1
element.PISA_prelim_param.m_t(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.m_t(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.m_t(i,5)  = 1; % Formulation
element.PISA_prelim_param.m_t(i,6)  = -0.08; % Constant 1
element.PISA_prelim_param.m_t(i,7)  = 0.20;   % Constant 2
element.PISA_prelim_param.m_t(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.m_t(i,9)   = 0; % Formulation
element.PISA_prelim_param.m_t(i,10)  = 20; % Constant 1
element.PISA_prelim_param.m_t(i,11)  = 0;   % Constant 2
element.PISA_prelim_param.m_t(i,12)  = 0;   % Constant 3

% Curvature
element.PISA_prelim_param.m_t(i,13)  = 0; % Formulation
element.PISA_prelim_param.m_t(i,14)  = 0; % Constant 1
element.PISA_prelim_param.m_t(i,15)  = 0;   % Constant 2
element.PISA_prelim_param.m_t(i,16)  = 0;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% P-Y Toe curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.Hb(i,1)  = 1; % Formulation
element.PISA_prelim_param.Hb(i,2)  = -0.20; % Constant 1
element.PISA_prelim_param.Hb(i,3)  = 2.07;   % Constant 2
element.PISA_prelim_param.Hb(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.Hb(i,5)  = 1; % Formulation
element.PISA_prelim_param.Hb(i,6)  = -0.05; % Constant 1
element.PISA_prelim_param.Hb(i,7)  = 0.52;   % Constant 2
element.PISA_prelim_param.Hb(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.Hb(i,9)   = 1; % Formulation
element.PISA_prelim_param.Hb(i,10)  = -0.37; % Constant 1
element.PISA_prelim_param.Hb(i,11)  = 3.05;   % Constant 2
element.PISA_prelim_param.Hb(i,12)  = 0;   % Constant 3

% Curvature
element.PISA_prelim_param.Hb(i,13)  = 1; % Formulation
element.PISA_prelim_param.Hb(i,14)  = -0.06; % Constant 1
element.PISA_prelim_param.Hb(i,15)  = 0.94;   % Constant 2
element.PISA_prelim_param.Hb(i,16)  = 0;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M-Theta Toe curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.Mb(i,1)  = 0; % Formulation
element.PISA_prelim_param.Mb(i,2)  = 50; % Constant 1
element.PISA_prelim_param.Mb(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.Mb(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.Mb(i,5)  = 1; % Formulation
element.PISA_prelim_param.Mb(i,6)  = -0.04; % Constant 1
element.PISA_prelim_param.Mb(i,7)  = 0.29;   % Constant 2
element.PISA_prelim_param.Mb(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.Mb(i,9)   = 0; % Formulation
element.PISA_prelim_param.Mb(i,10)  = 0.29; % Constant 1
element.PISA_prelim_param.Mb(i,11)  = 0;   % Constant 2
element.PISA_prelim_param.Mb(i,12)  = 0;   % Constant 3

% Curvature
element.PISA_prelim_param.Mb(i,13)  = 0; % Formulation
element.PISA_prelim_param.Mb(i,14)  = 0.86; % Constant 1
element.PISA_prelim_param.Mb(i,15)  = 0;   % Constant 2
element.PISA_prelim_param.Mb(i,16)  = 0;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PISA Sand Dr = 90%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(element.model_py(i),'PISA sand Dr90') 
% elseif element.soil_layer(i) == object_layers || strcmp(element.model_py(i),'PISA Chalk')
% elseif element.soil_layer(i) < 20 || strcmp(element.model_py(i),'Zero soil') == 0
% P-Y curves    

% Normalized ultimate lateral displacement
element.PISA_prelim_param.p_y(i,1)  = 0; % Formulation
element.PISA_prelim_param.p_y(i,2)  = 58.93; % Constant 1
element.PISA_prelim_param.p_y(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.p_y(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.p_y(i,5)  = 1; % Formulation
element.PISA_prelim_param.p_y(i,6)  = -9.49; % Constant 1
element.PISA_prelim_param.p_y(i,7)  = 25.61;   % Constant 2
element.PISA_prelim_param.p_y(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.p_y(i,9)   = 1; % Formulation
element.PISA_prelim_param.p_y(i,10)  = -0.83; % Constant 1
element.PISA_prelim_param.p_y(i,11)  = 7.31;   % Constant 2
element.PISA_prelim_param.p_y(i,12)  = 0;   % Constant 3

% Curvature
element.PISA_prelim_param.p_y(i,13)  = 0; % Formulation
element.PISA_prelim_param.p_y(i,14)  = 0.962; % Constant 1
element.PISA_prelim_param.p_y(i,15)  = 0;   % Constant 2
element.PISA_prelim_param.p_y(i,16)  = 0;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M-T curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.m_t(i,1)  = 0; % Formulation
element.PISA_prelim_param.m_t(i,2)  = 20; % Constant 1
element.PISA_prelim_param.m_t(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.m_t(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.m_t(i,5)  = 1; % Formulation
element.PISA_prelim_param.m_t(i,6)  = -0.02; % Constant 1
element.PISA_prelim_param.m_t(i,7)  = 0.21;   % Constant 2
element.PISA_prelim_param.m_t(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.m_t(i,9)   = 0; % Formulation
element.PISA_prelim_param.m_t(i,10)  = 20; % Constant 1
element.PISA_prelim_param.m_t(i,11)  = 0;   % Constant 2
element.PISA_prelim_param.m_t(i,12)  = 0;   % Constant 3

% Curvature
element.PISA_prelim_param.m_t(i,13)  = 0; % Formulation
element.PISA_prelim_param.m_t(i,14)  = 0; % Constant 1
element.PISA_prelim_param.m_t(i,15)  = 0;   % Constant 2
element.PISA_prelim_param.m_t(i,16)  = 0;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% P-Y Toe curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.Hb(i,1)  = 1; % Formulation
element.PISA_prelim_param.Hb(i,2)  = -0.48; % Constant 1
element.PISA_prelim_param.Hb(i,3)  = 3.33;   % Constant 2
element.PISA_prelim_param.Hb(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.Hb(i,5)  = 1; % Formulation
element.PISA_prelim_param.Hb(i,6)  = -0.09; % Constant 1
element.PISA_prelim_param.Hb(i,7)  = 0.72;   % Constant 2
element.PISA_prelim_param.Hb(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.Hb(i,9)   = 1; % Formulation
element.PISA_prelim_param.Hb(i,10)  = -0.38; % Constant 1
element.PISA_prelim_param.Hb(i,11)  = 3.02;   % Constant 2
element.PISA_prelim_param.Hb(i,12)  = 0;   % Constant 3

% Curvature
element.PISA_prelim_param.Hb(i,13)  = 1; % Formulation
element.PISA_prelim_param.Hb(i,14)  = -0.06; % Constant 1
element.PISA_prelim_param.Hb(i,15)  = 0.95;   % Constant 2
element.PISA_prelim_param.Hb(i,16)  = 0;   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M-Theta Toe curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.Mb(i,1)  = 0; % Formulation
element.PISA_prelim_param.Mb(i,2)  = 50; % Constant 1
element.PISA_prelim_param.Mb(i,3)  = 0;   % Constant 2
element.PISA_prelim_param.Mb(i,4)  = 0;   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.Mb(i,5)  = 1; % Formulation
element.PISA_prelim_param.Mb(i,6)  = -0.06; % Constant 1
element.PISA_prelim_param.Mb(i,7)  = 0.40;   % Constant 2
element.PISA_prelim_param.Mb(i,8)  = 0;   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.Mb(i,9)   = 0; % Formulation
element.PISA_prelim_param.Mb(i,10)  = 0.29; % Constant 1
element.PISA_prelim_param.Mb(i,11)  = 0;   % Constant 2
element.PISA_prelim_param.Mb(i,12)  = 0;   % Constant 3

% Curvature
element.PISA_prelim_param.Mb(i,13)  = 0; % Formulation
element.PISA_prelim_param.Mb(i,14)  = 0.88; % Constant 1
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
