function [results,DB_output,output_COPCAT] = run_COSPIN_deflection_excel(Location,Weight,PLAX,PYcreator,variable,loadcase,object_layers,scour,soil,pile,loads,settings,PYcreator_stiff,var_name,constant,con_name,Database,Apply_Direct_springs,txt_file_output)
addpath (genpath('library')); % make sure all the functions are available
%% For All Locations
ID = Location;				 
for loc = 1:size(ID,1)
    clearvars -except loc ID model pile_length_LC pile_length_end load_case object_layers variable PLAX PYcreator loadcase scour soil pile loads settings Weight PYcreator_stiff var_name constant con_name Database Apply_Direct_springs txt_file_output																		
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
    settings.interface              = 'FAC'; % FLS: FLS loads are applied, ULS: factored ULS loads are applied, 
                                             % GEO: factored/unfactored loads are applied depending on the check
                                             % that are carried out
    loads.MF.effective=1;
    loads.MF.Total=1;
    %--------------------------------------------------------------------------
    %% General calculation settings
    %--------------------------------------------------------------------------
    settings.nelem_factor           = 2;        % [m-1] minimum number of pile beam elements per meter 2.2
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
    output = [];  % end
    loads.H = loadcase.H;        
    loads.M = loadcase.M;
    cases = 1:length(pile.length);
    iter_global = 0;
    %%
    for i = cases
        iter_global = iter_global+1;
        pile.L = pile.length(i); % Selecting pile length
        disp(['Pile length: ',num2str(pile.L),' m'])
        pile.toe = pile.head - pile.L; % pile toe level
        [element,node,pile] = elem_node_data(pile,soil,scour,settings,data,variable,object_layers,PLAX,PYcreator,var_name,constant,con_name,0,Database); % assign properties to elements and nodes
        Rd=0;
    end
    %--------------------------------------------------------------------------
    %% Lateral calculation / p-y curves / lateral UR
    %--------------------------------------------------------------------------
    if strcmp(soil.type_su,'DEGRADED')
        element.cu = element.cu*soil.su_degradation;
    end
    element.tillheqv               = 0;
    if settings.lateral_loading
        disp('Lateral calculation initiated')
        [element Ndof Coord Mmax Es u ustep output] = winkler(element,node,pile,loads,settings,output,plots,data); % calcutation routine for lateral loading
        for j = 1:element.nelem+1
            output.hor_defl(j,i) = u(j*3-2,1); % save horisontal pile deflection at final loading increment for each pile length
            output.rot(j,i) = u(j*3,1)*180/pi;
        end
        output.pilehead_rotation(1,i) = -u(3,1)/pi*180; % save pile head rotation
        disp('Lateral calculation completed')
        output.Coord = Coord;
    end
    %--------------------------------------------------------------------------
    %% Plots and other output
    %--------------------------------------------------------------------------
    [output] = plot_functions(element,pile,node,soil,plots,output,settings,i, loads, data,SF);
    disp('--------------------------------------')
    if settings.rel_error == 1 && plots.deflection_plot == 1
        [results] = PISA_rel_error_lat_disp(Weight,Es,element,output,PLAX);
    elseif settings.rel_error == 1 && plots.load_deflection == 1
        [results] = PISA_rel_error_load_disp(Weight,Es,element,output);
    end
    
    for iii = 1:size(unique(element.soil_layer),1)
        index_param = find(element.soil_layer == iii);
        DB_output(iii,:) = [element.PISA_prelim_param.p_y(index_param(1,:),:) , element.PISA_prelim_param.m_t(index_param(1,:),:) , element.PISA_prelim_param.Hb(index_param(1,:),:) , element.PISA_prelim_param.Mb(index_param(1,:),:)];    
    end
    
    if txt_file_output
        output_COPCAT.pile = pile;
        output_COPCAT.loads = loads;
        output_COPCAT.soil = soil;
        output_COPCAT.scour = scour;
        output_COPCAT.output = output;
        output_COPCAT.Es = Es;
        output_COPCAT.element = element;
    else
        output_COPCAT = [];
    end
end
end