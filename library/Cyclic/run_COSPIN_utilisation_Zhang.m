
%% CALCULATION ROUTINE FOR AXIALLY AND LATERALLY LOADED PILES
% RUN FILE FOR CMAT CALCULATION TOOL
% CAN PERFORM AXIAL AND LATERAL BEARING CAPACITY CALCULATIONS
% % % % % function [results] =
function [results] = run_COSPIN_utilisation_Zhang(Location,Weight,PLAX,PYcreator,variable,loadcase,object_layers,scour,soil,pile,loads,settings,PYcreator_stiff,var_name,constant,con_name,Database,Apply_Direct_springs,Input,multiplier) %PNGI
% clear
% close all
% clc
%--------------------------------------------------------------------------
% Units: kN, m, s, kPa
%--------------------------------------------------------------------------
% CHANGE LOG
% YYYY.MM.DD    USER    Task
% 2010.11.04    MMOL    Programming
% 2011.0X.XX    JALY    Streamlining code
% 2013.07.XX    MUOE    Cleaning and streamlining
%                       Adding t-z curves and SACS PSI-input module
%                       Adding weak rock p-y module
% 2013.10.16    MUOE    Adding print-out of
%                       documentation/assumptions during calculation
% 2014.07.15    MMOL    Cleaning and streamlining
% 2018.04.04	DATY	On/Off switch for Georgiadis approach
% 2019.10.25    ASSV    Changed the folder structure, creating a library,
%                       cleaning, add database input/output modules from SNA
%                       and corresponding commands in the main, removed the
%                       p-y saving on excel
%2019.11.20		ASSV	Corrected the pile length used in the PISA base elements functions
%                       Winkler solver modified to enhance convergence with
%                       base moment springs
%2019.11.22     ASSV    Database interaction fully working, all the inputs 
%                       can be read from mysql and PISA springs saved
%--------------------------------------------------------------------------
addpath (genpath('library')); % make sure all the functions are available
%% For All Locations
ID = Location;


% load_case = loadcase;				 
%%
for loc = 1:size(ID,1)
clearvars -except loc ID model pile_length_LC pile_length_end load_case object_layers variable PLAX PYcreator loadcase scour soil pile loads settings Weight PYcreator_stiff var_name constant con_name Database Apply_Direct_springs Input multiplier
%data.load_case=	load_case;																		
%% Project data
%--------------------------------------------------------------------------
data.project                    = 'GEGE_D_Char_PISA(BE)';   % 'Project name'
data.A_number                   = 'A127858';   % 'Project number'
data.location                   = ID(loc);   % 'Project location'
data.db_location                = strcat('L1',ID(loc));
data.db_location_geo            = strcat('L',ID(loc)); %'Database location to read data
data.prepared_by                = 'GINI';   %  Initials of preparer
data.id                         = strcat('L1',ID(loc)); % Id to store into the database   
data.revision.global            = -1;   % global revision no. for selected location to be used,
                                        %1000 detects corresponding soil, structure and load revision no. automatically
                                        %-1 reads the settings below 
%--------------------------------------------------------------------------
%% Soil and pile input
%--------------------------------------------------------------------------
% settings.database               = 'Manual'; % if 'Database' the database module is activated. If 'Manual' input is taken from manual_data_input.xlsx
settings.PISA_database = 1;
% interim settings rev 01
settings.interimloads           = 1;
settings.interimgeometry        = 0;
soil.type_su                    = ''; % 'DEGRADED' to use the factor below for lateral calculation only,'' to not use
soil.su_degradation             = 0.72; % factor to be applied on the su before lateral calculation

%below only if reading from database is set
loads.type                      = 'ULS';    % Loads to be used (ULS or FLS)maybe also GEO
soil.psf                        = 0; % Partial Safety Factors 0 reads the _geo columns from the load table in the database 
soil.type                       = 'BE';
data.table_springs               = 'char' ;% 'char', 'LB', 'UB'
% WARNING: ONLY FOR SPECIAL USE (only applied if data.revision.global = -1):
% data.revision.soil          = 4;  % revision no. of soil parameters to be used (1000 = latest revision)
% data.revision.structure     = 2;  % revision no. of structure to be used (1000 = latest revision)
% data.revision.loads         = 0;  % revision no. of ULS loads to be used (1000 = latest revision)
% data.revision.output        = 89;  % revision no. for storing results into the database  
settings.interface              = 'FAC'; % FLS: FLS loads are applied, ULS: factored ULS loads are applied, 
                                         % GEO: factored/unfactored loads are applied depending on the check
                                         % that are carried out
loads.MF.effective=1;
loads.MF.Total=1;
                                                                      
% settings.db_server          ='DKLYCOPILOD1';  %  Databse server
% settings.db_user          ='ao1db_user';    %   Database user
% settings.db_pass          ='ituotdao1db';    % Database pass
% settings.db_name          ='ao1db';    % Database name
                                         
%--------------------------------------------------------------------------
%% General calculation settings
%--------------------------------------------------------------------------
settings.nelem_factor           = 1;        % [m-1] minimum number of pile beam elements per meter 2.2
settings.j_max                  = 100;      % max. no. of iterations in a load step (lateral only)
settings.TOL                    = 1e-4;     % relative tolerance (lateral only)
settings.n_max                  = 1;       % number of load steps (lateral only)
%--------------------------------------------------------------------------
%% Calculation settings (axial)
%--------------------------------------------------------------------------
settings.axial_loading          = 0;        % calculate capacity for axial loading? 1 = yes, 0 = no
settings.clay_type              = 'alpha';  % 'alpha' or 'beta' for way to calculate skin friction in API clay
pile.plug_unplug.tens           = 0;        % plug/unplug control in tension - 0 = auto, 1 = plugged, 2 = unplugged
pile.plug_unplug.comp           = 0;        % plug/unplug control in compression - 0 = auto, 1 = plugged, 2 = unplugged
plots.res_vs_pilelength         = 0;        % 1 = yes, 0 = no
%--------------------------------------------------------------------------
%% Calculation settings (torsional)
%--------------------------------------------------------------------------
settings.torsion                = 0;        % calculate torsional stiffness? 1 = yes, 0 = no. settings.axial_loading must also be set to 1
%--------------------------------------------------------------------------
%% Calculation settings (lateral)
%--------------------------------------------------------------------------
loads.static_cyclic             = 'cyclic'; % 'cyclic' or 'static' in accordance with DNV OS-J101
loads.n_cycles                  = 100;      % Number of cycles, relevant for Stiff clay w/o water only!
loads.A                         = 'API';    % use API or TUHH (Dührkop) approach for determination of A, relevant for API/Kirsch sand

plots.pilehead_vs_length        = 0;        % 1 = yes, 0 = no
plots.deflection_plot           = 1;        % 1 = yes, 0 = no
plots.utilization_ratio         = 0;        % 1 = yes, 0 = no, settings.toe_shear = 0 if only p-y UR is of interest
plots.deflection_bundle         = 0;        % 1 = yes, 0 = no
plots.toe_shear_graph           = 0;        % 1 = yes, 0 = no
plots.permanent_rot_def         = 0;        % 1 = yes (minimum 10 load steps is recommended), 0 = no -- cannot be used together with other analyses
plots.load_deflection			= 0;		% 1 = yes (should not be combined with other plots; minimum 50 load steps us recommended), 0 = no
plots.moment_distribution		= 0;		% 1 = yes, 0 = no
plots.Inverse                   = 1;

settings.lateral_loading        = 1;        % calculate capacity for lateral loading? 1 = yes, 0 = no
settings.beam_theory            = 1;        % 1 = Timoshenko, 0 = Euler-Bernoulli
settings.toe_shear              = 1;        % include base shear and moment? 1 = yes, 0 = no  
settings.mteta	                = 1;        % include uniformly distributed moment? 1 = yes, 0 = no 
settings.Georgiadis				= 0;		% apply Georgiadis approach? 1 = yes, 0 = no
settings.lateralmultipliers 	= 0; 		% account for p and y multipliers: 0-> not accounted 1-> accounted
settings.rotationalmultipliers  = 0;        % account for m and theta multipliers: 0-> not accounted 1-> accounted
settings.ULS                    = 0;        % 1 = Integration of mobilisable soil resistance in accordance with EA-Phähle approach is plotted, 0 = no plot
settings.tillheqv               = 0;        % ONLY VALID FOR CHALK AND TILL SPRINGS! 1 = Use heqv from start of till/chalk layer, 0 = Use heqv from seabed
settings.lat_cap_10_crit        = 0;
settings.PISA_cal_save          = 0;        % Saving moment, shear, etc. for PISA SSI spring calibration
settings.rel_error              = 1;        % Combines output of COSPIN and PLAXIS to calculate relative error and optimise PISA curves

% if  plots.permanent_rot_def == 1
% 	settings.elasticstiffness 	= 'cyclic'; % acceptable input: 'static' or 'cyclic' -- determination of initial stiffness based on static of cyclic curves
% 	settings.elasticmultipliers = 0; % input details: 0-> lateral multipliers of 1 accounted in elastic stiffness, 1-> multipliers accounted in elastic stiffness.
% end
if plots.load_deflection == 1 
	settings.max_load_ratio     = 10;        % attempts to apply a load equal to the one imported from Excel/database multiplied by this factor
end
%--------------------------------------------------------------------------
%% Output files
%--------------------------------------------------------------------------
settings.PSI                    = 0;        % Create PSI file? 1 = yes, 0 = no
settings.ANSYS                  = 0;        % Create ANSYS ASAS file? 1 = yes, 0 = no
settings.appendix               = 0;        % Create appendix for report (calculation log)? 1 = yes, 0 = no
data.save_path                  = 'output\';      % Saves files in defined working folder, for current 'pwd'
settings.SSI2db                 = 0;        % Save SSI-curves in database? 1 = yes, 0 = no
settings.update_db              = 0; % update the results in MySQL database (1 = yes, 0 = no)
settings.save_plots             = 0; % save plots in output folder (1 = yes, 0 =no)
settings.multi_toe_levels       = 0; % upload to DB toe springs for more than one level (1 = yes, 0 = no)
settings.damping 				= 0; % uploads needed input for soil damping to excel (1 = yes, 0 = no)

%----------------------------------------------------------------------------------------------------
settings.Apply_Direct_springs =Apply_Direct_springs;
settings.Plaxis_data =PLAX;


%--------------------------------------------------------------------------
%% Collecting input data from source
%--------------------------------------------------------------------------
disp(['Position ',data.location,' at ',data.project])
[SF reduction] = factors(loads); %#ok<*NCOMMA>
% if strcmp(settings.database,'Database')
%     [scour soil pile loads data settings] = database_input(pile,soil,data,...
%         loads,settings,plots); % load soil and pile information from database (SNA module)
%     soil.q_ur                = soil.q_ur_py; % [kPa]
%     soil.delta_q_ur = zeros(length(soil.q_ur_py));
%     if settings.interimloads 
%     [loads] = interimLoads (plots,ID{loc},soil,loads,settings);
%     disp('loads inserted manually in run_COSPIN - correct when loads are available in database')
%     end
%     if settings.interimgeometry 
%     [pile] = interimGeometry (plots,ID{loc},soil,loads,settings,pile,scour);
%     disp('MP geometry inserted manually in run_COSPIN - correct when MP geometry is available in database')
%     end
%      scour.local = 2;
% elseif strcmp(settings.database,'Manual')
%     [scour soil pile loads settings] = manual_data_input_excel(pile,data,soil,...
%         loads,settings); % load soil and pile information from Exce-file
% end

% if settings.axial_loading == 0

%%%% indicator of crash in the code %%%%%%%
output = [];  % end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % over load the loads from those of plaxis 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    loads.H = loadcase.H;        
    loads.M = loadcase.M;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


cases = 1:length(pile.length); % Looping over all pile lengths...
                                   %(no reloading path to be determined for this kind of calculation)
% end
% pile.diameter=9.2
% pile.length=pile.length-4	
iter_global = 0;
%%
 for i = cases
 iter_global = iter_global+1;

% if plots.permanent_rot_def == 1 && iter_global == 1
%     if settings.elasticmultipliers > settings.lateralmultipliers 
%         error(['Permanent rotation calculation: Multipliers below 1 only used',...
%         'for unloading stiffness - check variable:',...
%         ' settings.lateralmultipliers.']) % safeguard if multipliers are 'on' 
%                                           %for unloading stiffness and 'off' for loading stiffness
%     end 
%     fprintf('\nCalculation to evaluate initial stiffness for unloading part of permanent rotation check.\n\n');
% 	store1 							= loads.static_cyclic;
% 	store2 							= settings.lateralmultipliers;
% 	loads.static_cyclic 			= settings.elasticstiffness;
% 	settings.lateralmultipliers 	= settings.elasticmultipliers;
%     
% elseif plots.permanent_rot_def == 1 && iter_global == 2
%     fprintf('\nCalculation to evaluate loading path of permanent rotation at pile head check.\n\n'); 
% 	loads.static_cyclic 			= store1;
% 	settings.lateralmultipliers 	= store2;
% end

pile.L = pile.length(i); % Selecting pile length
% pile.L = pile.L-4; % Selecting pile length
disp(['Pile length: ',num2str(pile.L),' m'])
pile.toe = pile.head - pile.L; % pile toe level

[element,node,pile] = elem_node_data(pile,soil,scour,settings,data,variable,object_layers,PLAX,PYcreator,var_name,constant,con_name,0,Database); % assign properties to elements and nodes
% if settings.rotationalmultipliers
%     [element,soil] = interimRotationalMultipliers (element,soil);
% end
if strcmp(Input.Cyclic_style{1,2} , 'Zhang')
    [element] = cyclic_Zhang_multi(element,multiplier);
end
%--------------------------------------------------------------------------
%% Axial calculation / t-z curves / Q-z curves
%--------------------------------------------------------------------------
% if settings.axial_loading    
%     disp('Axial calculation initiated')
%     [fs qp A G] = skin_tip(element,reduction,pile,settings,loads); % Skin friction and tip resistance calculation
%     [Rd Rbd Rsd Rbk Rsk plug_unplug G] = axial_uls(A,G,fs,qp,element,pile,SF,reduction); % Calculation of total pile resistance
%     output.Rd(i,1:2) = [Rd.tens Rd.comp]; % Save for plotting
%     output.Rbd(i,1:2) = [Rbd.tens Rbd.comp]; % Save for plotting
%     output.Rsd(i,1:2) = [Rsd.tens Rsd.comp]; % Save for plotting
%     [t z] = t_z(fs,pile,element,reduction,plug_unplug,A,G); % calculation of t-z curves for soil layers according to API
%     [Q zQ] = Q_z(qp,pile,element); % calculation of Q-z curves for soil layers according to API
%     disp('Axial calculation completed')
% else 
Rd=0;
%--------------------------------------------------------------------------
%% Torsional stiffness
%--------------------------------------------------------------------------
if settings.torsion
    data.torsion = torsion_stiffness(pile,element,t);
end
end
%--------------------------------------------------------------------------
%% Lateral calculation / p-y curves / lateral UR
%--------------------------------------------------------------------------
%% interim rev 0.1
if strcmp(soil.type_su,'DEGRADED')
    element.cu = element.cu*soil.su_degradation;
end
element.tillheqv               = 0;
%%
if settings.lateral_loading
    disp('Lateral calculation initiated')
    [element Ndof Coord Mmax Es u ustep output] = winkler(element,node,pile,loads,settings,output,plots,data); % calcutation routine for lateral loading
    for j = 1:element.nelem+1
        output.hor_defl(j,i) = u(j*3-2,1); % save horisontal pile deflection at final loading increment for each pile length
        output.rot(j,i) = u(j*3,1)*180/pi;
    end

    output.pilehead_rotation(1,i) = -u(3,1)/pi*180; % save pile head rotation
   [p y y_tot output toe_plot_u] = p_y(node,pile,element,loads,output,settings); % calculation of p-y curves for soil layers
    if settings.mteta
       [m teta output toe_plot_teta] = m_teta(node,pile,element,loads,output,settings);
    end
%     if settings.toe_shear
%         [p_toe,y_toe] = p_y_toe(node,pile,element,loads,output,settings);
%         [m_toe,teta_toe] = m_teta_toe(node,pile,element,loads,output,settings);
%     end
%     if plots.load_deflection == 0
% 		[output] = UR_v2(element,settings,pile,loads,data,plots,ustep,y_tot,output,node);
%     end
    disp('Lateral calculation completed')
    output.Coord = Coord;
%    output.toe_plot_u = toe_plot_u;
end
%--------------------------------------------------------------------------
%% Plots and other output
%--------------------------------------------------------------------------
% if plots.permanent_rot_def == 1 && iter_global == 1
% 	plots.node_rot_def= 1;                              % number of node to plot permanent rotations for, 1 = node at pile head
% 	F = linspace(0,1,settings.n_max+1); % this is valid because the load is applied in equally sized steps - the magnitude of the load doesn't matter, only the fact that it is applied in equally sized steps
%     output.elasticstiff = (F(2)-F(1))/(output.deflections(3*plots.node_rot_def,2)-output.deflections(3*plots.node_rot_def,1)); % the unloading/reloading stiffness is calculated as the initial stiffness
% else
	[output] = plot_functions(element,pile,node,soil,plots,output,settings,i, loads, data,SF);
% end


% if settings.PSI
%     disp('Printing to SACS PSI-file')
%     PSI(pile,data,element,scour,settings,t,z,p,y,Q,zQ,plug_unplug,i)
%     disp('Finished printing to SACS PSI-file')
% end
% if settings.ANSYS
%     disp('Printing to ANSYS ASAS-file')
% 	[p_TDA t_TDA level_TDA]   = TDA(node,p,t,data,scour,pile,y,z,settings);
%     %ANSYS_ASAS(p,t,node,y,z,scour,pile,data,i)
% 	ANSYS_ASAS_TDA(p_TDA,t_TDA,level_TDA,y,z,scour,pile,data,i,Q,zQ,plug_unplug,element);
%     disp('Finished printing to ANSYS ASAS-file')
% end    

% if settings.SSI2db
%     if settings.lateral_loading
%         database_write_springs(settings,element,loads,data,p,y,...
%         strcat('soil_py_curves_',data.table_springs),'py'); % write py-curves into database
%     end
%     if settings.axial_loading
%         database_write_springs(settings,element,loads,data,t,z,...
%         strcat('soil_tz_curves_',data.table_springs),'tz'); % write tz-curves into database
%     end
%     if settings.mteta    
%         database_write_Mtsprings(settings,element,loads,data,m,teta,...
%             strcat('soil_Mt_curves_',data.table_springs),'Mt'); % write Mt-curves into database
%     end
%     if settings.toe_shear
%         if settings.multi_toe_levels
%             database_write_toesprings_multi(settings,element,loads,data,pile,soil,plots,output,i,p_toe,y_toe,m_toe,teta_toe) % writes toe springs for same revision for different depths
%         else
%             database_write_toesprings(settings,element,loads,data,p_toe,y_toe,...
%                 strcat('soil_py_toe_curves_',data.table_springs),'py'); % write py-curves into database
%             database_write_toesprings(settings,element,loads,data,m_toe,teta_toe,...
%                 strcat('soil_Mt_toe_curves_',data.table_springs),'Mt'); % write Mt-curves into database
%         end
%     end
% end
			 
% if settings.appendix
%     disp('Writing appendix to Word-file')
%     
%     disp('Finished writing appendix to Word-file')
% end
    disp('--------------------------------------')
% end
% auto_documentation(data,settings, soil, plots, loads);
%F = linspace(0,loads.H,settings.n_max+1)/1000; % This is for Hv plots in PISA (temporal)
% if settings.damping
% 	soil_damping_input_write(data,Coord,output,loads)
% end

% if settings.PISA_cal_save
%     save_results_PISA_calibration(data,element,output,plots,Es) % FKMV addition
% %     PISA_calibration_plots(data, plots)
% end



if settings.rel_error == 1 && plots.deflection_plot == 1
    [results] = PISA_rel_error_lat_disp(Weight,Es,element,output,PLAX);
elseif settings.rel_error == 1 && plots.load_deflection == 1
    [results] = PISA_rel_error_load_disp(Weight,Es,element,output);
end

DB_output = [element.PISA_prelim_param.p_y(1,:) , element.PISA_prelim_param.m_t(1,:) , element.PISA_prelim_param.Hb(1,:) , element.PISA_prelim_param.Mb(1,:)];

for iii = 1:size(output.hor_defl,1)-2
    
    results.utilisation(iii,1) = output.hor_defl(iii);
    results.utilisation(iii,2) = (abs(output.hor_defl(iii))/output.hor_defl(iii))*interp1(y.top(iii,:) , p.top(iii,:) , abs(output.hor_defl(iii)));
    if strcmp(element.type{iii,1} , 'Clay')
        results.utilisation(iii,3) =  results.utilisation(iii,2) / max(p.top(iii,:));
    elseif strcmp(element.type{iii,1} , 'Sand')
        sigma_ref = 100*(element.sigma_v_eff(iii)/100)^0.9;
        results.utilisation(iii,3) =  results.utilisation(iii,2) / (9.2 * pile.diameter * sigma_ref);
    else
        disp('wrong soil type identified!')
    end
    results.utilisation(iii,4) = element.sigma_v_eff(iii);
    results.utilisation(iii,5) = max(p.top(iii,:));
    results.utilisation(iii,6) = sign(results.utilisation(iii,1));
    results.soil_type{iii,1}   = element.type{iii,1};
    results.soil_type{iii,2} = element.level(iii,1);
    results.soil_type{iii,3} = element.level(iii,2);
    results.soil_type{iii,4} = element.level(iii,3);
    results.batch{iii+1,4}   = element.batch(iii,1);
end
    results.utilisation(iii+1,1) = output.hor_defl(iii+1);
    results.utilisation(iii+1,1) = (abs(output.hor_defl(iii))/output.hor_defl(iii))*interp1(y.bottom(iii,:) , p.bottom(iii,:) , abs(output.hor_defl(iii+1)));
    results.utilisation(iii+1,1) =  results.utilisation(iii+1,2) / max(p.bottom(iii,:));
    results.utilisation(iii+1,4) = element.sigma_v_eff(iii+1);
    results.utilisation(iii+1,5) = max(p.bottom(iii,:));
    results.utilisation(iii+1,6) = sign(results.utilisation(iii+1,1));
    results.utilisation(iii+1,7) = element.level(iii+1,1);
    results.soil_type{iii+1,1}   = element.type{iii+1,1};
    results.soil_type{iii+1,2} = element.level(iii+1,1);
    results.soil_type{iii+1,3} = element.level(iii+1,2);
    results.soil_type{iii+1,4} = element.level(iii+1,3);
    results.batch{iii+1,4}      = element.batch(iii+1,1);
    
end

results.element = element;
end
% % % % % % end