function [WeightedResidual,Global_Data,DB_output,output_COPCAT]=P_Y_Creator_function(Location,weight,PLAX,PYcreator,variable,loadcase,object_layers,scour,soil,pile,loads,settings,PYcreator_stiff,PlotSwitch,var_name,constant,con_name,spring_type,Database,Apply_Direct_springs,txt_file_output)
addpath (genpath('library')); %make sure all the functions are available
%% For All Locations
ID = Location;
for loc = 1:size(ID,1)   
%% Project data
%--------------------------------------------------------------------------
data.project                    = 'GEGE_D_Char_PISA(BE)';   % 'Project name'
data.A_number                   = 'A127858';   % 'Project number'
data.location                   = ID;   % 'Project location'
data.db_location                = strcat('OC',ID);
data.db_location_geo            = strcat('OC',ID); %'Database location to read data
data.prepared_by                = 'PNGI';   %  Initials of preparer
data.id                         = strcat('OC',ID); % Id to store into the database   
data.revision.global            = -1;   % global revision no. for selected location to be used,
                                        %1000 detects corresponding soil, structure and load revision no. automatically
                                        %-1 reads the settings below 
%--------------------------------------------------------------------------
%% Soil and pile input
%--------------------------------------------------------------------------
settings.database               = 'Manual'; % if 'Database' the database module is activated. If 'Manual' input is taken from manual_data_input.xlsx
settings.PISA_database          = 1;
% interim settings rev 01
settings.interimloads           = 0;
settings.interimgeometry        = 0;
soil.type_su                    = ''; % 'DEGRADED' to use the factor below for lateral calculation only,'' to not use
soil.su_degradation             = 1; % factor to be applied on the su before lateral calculation

%below only if reading from database is set
loads.type                      = 'SLS';    % Loads to be used (ULS or FLS)maybe also GEO
soil.psf                        = 0; % Partial Safety Factors 0 reads the _geo columns from the load table in the database 
soil.type                       = 'BE';
data.table_springs               = 'char' ;% 'char', 'LB', 'UB'
% WARNING: ONLY FOR SPECIAL USE (only applied if data.revision.global = -1):
data.revision.soil          = 4;  % revision no. of soil parameters to be used (1000 = latest revision)
data.revision.structure     = 0;  % revision no. of structure to be used (1000 = latest revision)
data.revision.loads         = 0;  % revision no. of ULS loads to be used (1000 = latest revision)
data.revision.output        = 98;  % revision no. for storing results into the database  
settings.interface              = 'UNFAC'; % FLS: FLS loads are applied, ULS: factored ULS loads are applied,
                                         % UNFAC , Char loads, FAC % Design load 
                                         % GEO: factored/unfactored loads are applied depending on the check
                                         % that are carried out
settings.db_server          ='DKLYCOPILOD1';  %  Databse server
settings.db_user          ='yhdb_user';    %   Database user
settings.db_pass          ='ituotdyhdb';    % Database pass
settings.db_name          ='yhdb';    % Database name
                                         
%--------------------------------------------------------------------------
%% General calculation settings
%--------------------------------------------------------------------------
settings.nelem_factor           = 2;        % [m-1] minimum number of pile beam elements per meter 2.2
settings.j_max                  = 100;      % max. no. of iterations in a load step (lateral only)
settings.TOL                    = 1e-4;     % relative tolerance (lateral only)
settings.n_max                  = 10;       % number of load steps (lateral only)
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
loads.static_cyclic             = 'static'; % 'cyclic' or 'static' in accordance with DNV OS-J101
loads.n_cycles                  = 100;      % Number of cycles, relevant for Stiff clay w/o water only!
loads.A                         = 'API';    % use API or TUHH (Dührkop) approach for determination of A, relevant for API/Kirsch sand

plots.pilehead_vs_length        = 0;        % 1 = yes, 0 = no
plots.deflection_plot           = 1;        % 1 = yes, 0 = no
plots.utilization_ratio         = 0;        % 1 = yes, 0 = no, settings.toe_shear = 0 if only p-y UR is of interest
plots.deflection_bundle         = 0;        % 1 = yes, 0 = no
plots.toe_shear_graph           = 0;        % 1 = yes, 0 = no
plots.permanent_rot_def         = 0;        % 1 = yes (minimum 10 load steps is recommended), 0 = no -- cannot be used together with other analyses
plots.load_deflection			= 0;		% 1 = yes (should not be combined with other plots; minimum 50 load steps us recommended), 0 = no
plots.moment_distribution		= 1;		% 1 = yes, 0 = no

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

settings.Apply_Direct_springs =Apply_Direct_springs;
settings.Plaxis_data =PLAX;
%--------------------------------------------------------------------------
%% Output files
%--------------------------------------------------------------------------
settings.PSI                    = 0;        % Create PSI file? 1 = yes, 0 = no
settings.ANSYS                  = 0;        % Create ANSYS ASAS file? 1 = yes, 0 = no
settings.appendix               = 0;        % Create appendix for report (calculation log)? 1 = yes, 0 = no
data.save_path                  = 'output\';      % Saves files in defined working folder, for current 'pwd'
settings.SSI2db                 = 1;        % Save SSI-curves in database? 1 = yes, 0 = no
settings.update_db              = 0; % update the results in MySQL database (1 = yes, 0 = no)
%--------------------------------------------------------------------------
%% Collecting input data from source
%--------------------------------------------------------------------------
disp(['Position ',data.location,' at ',data.project])
[SF reduction] = factors(loads);
output = [];
loads.H = loadcase.H;                          
loads.M = loadcase.M;                          
cases = 1:length(pile.length); 
iter_global = 0;
for i = cases
    iter_global = iter_global+1;
    pile.L = pile.length(i); % Selecting pile length
    disp(['Pile length: ',num2str(pile.L),' m'])
    pile.toe = pile.head - pile.L; % pile toe level
%     PYcreator;
    [element,node,pile] = elem_node_data(pile,soil,scour,settings,data,variable,object_layers,PLAX,PYcreator,var_name,constant,con_name,PYcreator_stiff,Database); % assign properties to elements and nodes
    if settings.rotationalmultipliers
        [element,soil] = interimRotationalMultipliers (element,soil);
    end
    Rd=0;
end
%--------------------------------------------------------------------------
%% Lateral calculation / p-y curves / lateral UR
%--------------------------------------------------------------------------
if strcmp(soil.type_su,'DEGRADED')
    element.cu = element.cu*soil.su_degradation;
end
element.tillheqv               = 0;
    [element] = layer(element,node,pile,settings);
    [p y y_tot output toe_plot_u] = p_y(node,pile,element,loads,output,settings); % calculation of p-y curves for soil layers
    p_av=p.top;
    depth_av=abs((element.level(:,1)+element.level(:,2))/2);
    depth_av(end)=[];

    if settings.mteta
        [m teta output toe_plot_teta] = m_teta(node,pile,element,loads,output,settings);
        m_av=m.top{1,1};     
    end
    if settings.toe_shear
        [p_toe,y_toe] = p_y_toe(node,pile,element,loads,output,settings);
        [m_toe,teta_toe] = m_teta_toe(node,pile,element,loads,output,settings);
    end
 
    % p-y comparison
    if spring_type == 0
        PLAXIS=PLAX.PYCurves;        
        A = repmat(depth_av,[1 length(PLAXIS.depth)]);
        [minValue,closestIndex] = min(abs(A-PLAXIS.depth'));
        closestValue = depth_av(closestIndex);
        [Residual,NumSpring,Global_Data,PureErrorTotal,PureWeightTotal,Selected_index.PY]=comparingSprings(closestValue,closestIndex,PLAXIS.depth,PLAXIS.X_curve,PLAXIS.Y_curve,depth_av,p_av,y.top,object_layers,element,soil,pile);
    elseif spring_type == 1
        % m-t comparison
        PLAXIS=PLAX.MTheta;
        PLAXIS_P_Y=PLAX.PYCurves;
        A = repmat(depth_av,[1 length(PLAXIS.depth)]);
        [minValue,closestIndex] = min(abs(A-PLAXIS.depth'));
        closestValue = depth_av(closestIndex);
        [Residual,NumSpring,Global_Data,PureErrorTotal,PureWeightTotal,Selected_index.MT]=comparingSprings_m_t(settings,closestValue,closestIndex,PLAXIS.depth,PLAXIS.X_curve,PLAXIS.Y_curve,depth_av,m_av,teta.top{1,1},object_layers,element,soil,pile,PLAXIS_P_Y,p_av,y.top,loads);
    elseif spring_type == 2
        % Hb comparison
        PLAXIS=PLAX.BaseShear;
        depth_av=abs(element.level(end,2));  % Only it is 1 spring at the end 
        PLAXIS.depth=depth_av;    % only last spring is considered 
        A = repmat(depth_av,[1 length(PLAXIS.depth)]);
        [minValue,closestIndex] = min(abs(A-PLAXIS.depth'));
        closestValue = depth_av(closestIndex);
        [Residual,NumSpring,Global_Data,PureErrorTotal,PureWeightTotal]=comparingSprings_base(closestValue,closestIndex,PLAXIS.depth,PLAXIS.X_curve,PLAXIS.Y_curve,depth_av,p_toe.top(end,:),y_toe.top(end,:),object_layers,element,soil,pile);
    elseif spring_type == 3
        % Mb comparison
        PLAXIS=PLAX.BaseMoment;
        PLAXIS_P_Y=PLAX.BaseShear;        
        depth_av=abs(element.level(end,2));
        PLAXIS.depth=depth_av;        
        A = repmat(depth_av,[1 length(PLAXIS.depth)]);
        [minValue,closestIndex] = min(abs(A-PLAXIS.depth'));
        closestValue = depth_av(closestIndex);
        [Residual,NumSpring,Global_Data,PureErrorTotal,PureWeightTotal,Selected_index.MT]=comparingSprings_Base_M_T(closestValue,closestIndex,PLAXIS.depth,PLAXIS.X_curve,PLAXIS.Y_curve,depth_av,m_toe.top(end,:),teta_toe.top(end,:),object_layers,element,soil,pile,PLAXIS_P_Y,p_av,y.top,loads);
    end
    
    for iii = 1:size(unique(element.soil_layer),1)
        index_param = find(element.soil_layer == iii);
        DB_output(iii,:) = [element.PISA_prelim_param.p_y(index_param(1,:),:) , element.PISA_prelim_param.m_t(index_param(1,:),:) , element.PISA_prelim_param.Hb(index_param(1,:),:) , element.PISA_prelim_param.Mb(index_param(1,:),:)];    
    end

    WeightedResidual=PureErrorTotal.*PureWeightTotal;
    if txt_file_output
        output_COPCAT.p = p;
        output_COPCAT.y = y;
        output_COPCAT.m = m;
        output_COPCAT.teta = teta;
        output_COPCAT.p_toe = p_toe;
        output_COPCAT.y_toe = y_toe;
        output_COPCAT.m_toe = m_toe;
        output_COPCAT.teta_toe = teta_toe;
        output_COPCAT.pile = pile;
        output_COPCAT.loads = loads;
        output_COPCAT.soil = soil;
        output_COPCAT.scour = scour;
        output_COPCAT.output = output;
        output_COPCAT.element = element;
    else
        output_COPCAT = [];        
    end
end
end 