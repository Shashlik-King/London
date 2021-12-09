function [kstop ksbot] = Direct_Sec(PLAXIS,element,pile,y_topbottom,i)
%--------------------------------------------------------------------------
% PURPOSE
% Compute the secant spring stiffness [kN/m/m] and pile resistance p 
% in the top and the bottom of each pile segment by applying p-v curves 
% according to PISA sand model. 
% 
% INPUT:  
%         putop_n       : Normalized ultimate resistance [-] in top of element, determined in PISAlayer.m
%         pubot_n       : Normalized ultimate resistance [-] in bot of element, determined in PISAlayer.m
%         heqv          : Depth from the seabed [m]
%         u             : Global displacement vector
%         i             : Counter referring to element number  
%
% OUTPUT: kstop   : Soil stiffness at the top of the element [kN/m/m]
%         ksbot   : Soil stiffness at the bottom of the element [kN/m/m]
%
% Log: 
% EVVA    09.08.2016  Programming
% FKMV    17.08.2020  Update to use database
%--------------------------------------------------------------------------
% -------- Initializing pile and soil parameters --------------------------




ytop    = abs(y_topbottom(1));      % Horizontal disp. at the top of the
                                    % pile segment [m]

ybot    = abs(y_topbottom(2));      % Horizontal disp. at the bottom of the
                                    % pile segment [m]

xtop    = element.heqv(i,1);        % Distance from the seabed to the top
                                    % of the considered pile segment [m].
xbot    = element.heqv(i,2);        % Distance from the seabed to the bottom
                                    % of the considered pile segment [m].                                                                       

D       = pile.diameter;            % Outer diameter [m]
G_top   = element.G0(i,1);             % Shear modulus at the top of the element [kPa]
G_bot   = element.G0(i,2);             % Shear modulus at the bottom of the element [kPa]
putop_n   = element.pu(i,1);        % Normalized ultimate resistance [-] in top
pubot_n   = element.pu(i,2);        % and bottom of pile element, determined in PISAlayer.m
sigma_v_top = element.sigma_v_eff(i,1);           % Effective vertical stress at the element top [kPa]
sigma_v_bot = element.sigma_v_eff(i,2);           % Effective vertical stress at the element bottom [kPa]


x_ave=(xtop+xbot)/2;


[kstop,ksbot]=DirectLookUP_Sec(x_ave,ytop,ybot,PLAXIS);


end 



