function [scour, soil, pile, loads, settings] = manual_data_input_excel(settings , Input)
%% MODULE TO IMPORT MANUAL INPUT DATA FROM EXCEL
% FILE ENABLING THE USER TO INPUT DATA FROM EXCEL TO GET A BETTER OVERVIEW
% OF THE DATA INSTEAD OF USING THE MATLAB-FILE, MANUAL_INPUT_DATA.M
%--------------------------------------------------------------------------
% CHANGE LOG
% 28.10.2013    MUOE - PROGRAMMING
%--------------------------------------------------------------------------
%% Data import
%--------------------------------------------------------------------------
[num,txt] = xlsread('COPCAT_input.xlsm',settings.model_name);
n_layers = num(1,2);
n_sections = num(2,2);
% n_disp = num(3,2);
location = txt(1,1);
if strcmp(settings.model_name,location)
    disp('Match between chosen location and Excel-sheet headline')
else
    disp('The Excel-sheet headline does not match the chosen location')
end
%--------------------------------------------------------------------------
%% Load data
%--------------------------------------------------------------------------
loads.H = num(5,7); % [kN] horisontal load at pile head
loads.M = num(6,7); % [kNm] overturning moment at pile head
loads.Vc = num(7,7); % [kN] compressive axial force at pile head
loads.Vt = num(8,7); % [kN] tensile axial force at pile head
loads.Mz = num(9,7); % [kN] torsional moment
%--------------------------------------------------------------------------
%% Scour data
%--------------------------------------------------------------------------
scour.local = num(1,7);%num(1,7); % [m] local scour
disp('scour depth defined in run_COSPIN.m')
scour.ORD = num(2,7); % [m] overburden reduction depth
scour.water_depth = num(3,7); % [m] water depth
%--------------------------------------------------------------------------
%% Pile data
%--------------------------------------------------------------------------
pile.head                       = num(5,2); % [m] 
pile.length_start               = num(6,2); % [m] embedment length, may be a vector
pile.length_end                 = num(7,2); % [m]
pile.length_inc                 = num(8,2); % [m]
pile.diameter                   = num(9,2); %num(9,2); % [m] outer diameter of the pile
disp('pile outer diameter defined in run_COSPIN.m')
pile.density                    = num(10,2); % [kN/m^3] density of pile material (steel)
pile.sigma_y                    = num(11,2); % [kPa] characteristic steel yield strength 
pile.E                          = num(12,2); % [kPa] Young's modulus of steel 
pile.G                          = num(13,2); % [kPa] Shear modulus  
pile.ksf                        = num(14,2); % [-] Shear correction factor for Timoshenko beam theory
pile.cross_section.toplevel     = num(17:17+n_sections-1,2); % [m VREF]
pile.cross_section.thickness    = num(17:17+n_sections-1,3); % [m]

pile.length                     = (pile.length_start:pile.length_inc:pile.length_end); % [m] creates a vector for rotation vs. embedment if needed

pile.stick_up                   = abs(pile.head-num(3,11))+scour.local; % [m] calculate pile stick-up

settings.pile_type              = cell2mat(txt(14,7)); % [text]
if strcmp(settings.pile_type,'open')
    pile.cross_section.endarea  = pi*((pile.diameter/2)^2-(pile.diameter/2-pile.cross_section.thickness(end))^2); % [m^2] end bearing area
%     pile.cross_section.K        = 0.8;
elseif strcmp(settings.pile_type,'closed')
    pile.cross_section.endarea  = pi*(pile.diameter/2)^2;
%     pile.cross_section.K        = 1.0;
    msgbox('Pile is closed-ended. For correct axial capacity calculation please set reducion.skin_inner = 0.0 in the file reduction_factors.m as this will exclude internal shaft friction')
end    
%--------------------------------------------------------------------------
%% Soil data
%--------------------------------------------------------------------------
soil.layer                  = num(3:3+n_layers-1,10);													 
soil.toplevel               = -abs(num(3:3+n_layers-1,11)); % [m VREF]
soil.model_py               = txt(6:6+n_layers-1,12); % [text]
soil.model_axial            = txt(6:6+n_layers-1,13); % [text]
soil.gamma_eff              = num(3:3+n_layers-1,14); % [kN/m^3]
soil.cu                     = num(3:3+n_layers-1,15); % [kPa]
soil.delta_cu               = num(3:3+n_layers-1,16); % [kPa/m]
soil.phi                    = num(3:3+n_layers-1,17); % [degrees]
soil.delta_eff              = num(3:3+n_layers-1,18); % [degrees]
soil.c_eff                  = num(3:3+n_layers-1,20); % [kPa]
soil.K0                     = num(3:3+n_layers-1,19); % [kPa]
soil.epsilon50              = num(3:3+n_layers-1,21); % [-]
soil.delta_epsilon50        = num(3:3+n_layers-1,22); % [1/m]
soil.J                      = num(3:3+n_layers-1,23); % [-]
soil.Es                     = num(3:3+n_layers-1,24); % [kPa]
soil.delta_Es 				= num(3:3+n_layers-1,25); % [kPa/m]
soil.limit_skin             = num(3:3+n_layers-1,26); % [kPa]
soil.limit_alpha            = num(3:3+n_layers-1,27); % [-]
soil.limit_tip              = num(3:3+n_layers-1,28); % [kPa]
soil.G0                     = num(3:3+n_layers-1,29); % [kPa]
soil.delta_G0               = num(3:3+n_layers-1,30); % [kPa/m]
soil.poisson                = num(3:3+n_layers-1,31); % [-]
soil.q_ur                   = num(3:3+n_layers-1,32); % [kPa]
soil.delta_q_ur             = num(3:3+n_layers-1,33); % [kPa/m]
soil.k_rm                   = num(3:3+n_layers-1,34); % [-]
soil.RQD                    = num(3:3+n_layers-1,35); % [-]
soil.Nq                     = num(3:3+n_layers-1,36); % [-]
soil.degradation.value_tz_t = num(3:3+n_layers-1,37); % [m]
soil.degradation.value_tz_z = num(3:3+n_layers-1,38); % [m]

%%%%%%%%Fake   PNGI 

soil.Dr=soil.G0;
soil.Dr(:)=0.1;

% [num,txt] = xlsread('manual_data_input.xlsx','Control Panel', 'C21'); % FKMV
% soil.soiltype = txt; % FKMV

for i = 1:length(soil.degradation.value_tz_z)
    if soil.degradation.value_tz_z(i) ~= 1.0
        disp('z-multiplier is only applied to t-z curves - not Q-z curves')
    end
end

if settings.lateralmultipliers
	soil.degradation.value_py_p = num(3:3+n_layers-1,39); % [m]
	soil.degradation.value_py_y = num(3:3+n_layers-1,40); % [m]
else
	soil.degradation.value_py_p = ones(length(soil.model_py),1); % [m]
	soil.degradation.value_py_y = ones(length(soil.model_py),1); % [m]
end

if strcmp(Input.Cyclic_style{1,2} , 'Zhang') && Input.Cyclic_run{1,2} == 1 && Input.Markov_run{1,2} == 1
	soil.degradation.batch  = txt(6:6+n_layers-1,46); % [m]
	soil.degradation.Ns     = num(3:3+n_layers-1,47); % [m]
    soil.degradation.min_CSR= num(3:3+n_layers-1,48); % [m]
else
	soil.degradation.batch  = ones(length(soil.model_py),1); % [m]
	soil.degradation.Ns     = ones(length(soil.model_py),1); % [m]
    soil.degradation.min_CSR= ones(length(soil.model_py),1); % [m]
end
