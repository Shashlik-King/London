function  overwriteingPisaParam(variable,object_layers,VarName,pile,element,i)

    
if element.element.soil_layer(i) == object_layers
    
    for Var=1:size(VarName)
        if Varname(Var,1)==1
            element.PISA_prelim_param.p_y(i,VarName(Var))= variable(Var);
            
        elseif Varname(Var,1)==2
            element.PISA_prelim_param.m_t(i,VarName(Var))= variable(Var);
            
        elseif Varname(Var,1)==3
            element.PISA_prelim_param.Hb(i,VarName(Var))= variable(Var);
            
        elseif Varname(Var,1)==4
            element.PISA_prelim_param.Mb(i,VarName(Var))= variable(Var);
            
        end
    end
    
end 


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
%     element.PISA_prelim_param.p_y(i,10)  = soil.ini_stiff(2);  % Constant 1   -0.466
%     element.PISA_prelim_param.p_y(i,11)  = soil.ini_stiff(3);   % Constant 2    4.13
%     element.PISA_prelim_param.p_y(i,12)  = soil.ini_stiff(4);   % Constant 3
% else
    element.PISA_prelim_param.p_y(i,9)  = 1; % Formulation
    element.PISA_prelim_param.p_y(i,10)  = variable(1); % Constant 1   -0.466
    element.PISA_prelim_param.p_y(i,11)  = variable(2);   % Constant 2    4.13
    element.PISA_prelim_param.p_y(i,12)  = 0;   % Constant 3
% end
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
            


end 