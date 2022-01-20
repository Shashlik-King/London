%% Inverse analysis run
% description of the function is found in the Function manual
clc; clear all; close all; delete(gcp('nocreate'))

%%Version number is automatically updated by release pipeline
CopcatVersion           = 'DevelopmentVersion'

%% Input
addpath (genpath('library'));                                               % make sure all the functions are available
addpath (genpath('excel'));                                                 % make sure all the excel input is available
[Input]                                  = Initialize();                    % reads all input from excel user interface
[Database.num,Database.txt,Database.raw] = xlsread('COPCAT_Input.xlsm','Table Output','A1:BT100'); % reads COPCAT database with PISA parameters
Database.txt                             = Database.txt(2:end,:);           % filters the text part of the database only
scour_Depth 							 = 0; 								% sets scour to 0
		
Layered_wise_calibration = cell2mat(Input.Layered_wise_calibration(1,2));   % Assign switch - layered calibration 1 = on, 0 = off
Inversemode              = cell2mat(Input.Calibration(1,2));                % Assign switch - run calibration 1 = on, 0 = off
PYcreator                = cell2mat(Input.PYCreator(1,2));                  % Assign switch - 1 = py curves, 0 = pile response																				 
PYcreator_stiff          = 0;
calibration.method       = Input.CalibMethod{1,2};                          % Assign switch - calibration method. Types: 'nlinearlqr','Other'
calibration.Costfunction = Input.Costfunctiontype{1,2};                     % Assign switch - Cost function type. Options are: 'Vector','Scalar','PISAMethod'
Weight.weight_type       = Input.weightType{1,2};                           % Assign switch - Weight type. Options are:'SWR_Max','Obs_NP','Other'
CallModels               = Input.ModelsSpil;                                % Assign switch - model name
calibration.level        = Input.Loads_lev_Spil;                            % Assign switch - load level. Options are: 'D_10,'D_200','D_10,D_200'
spring_type              = cell2mat(Input.Springtype(1,2));                 % Assign switch - spring type. Options are: 0 = p-y, 1 = m-t, 2 = Hb, 3 = Mb
txt_file_output          = cell2mat(Input.Text_file_output(1,2));           % Assign switch - text file output

Weight.Weight_moment     = cell2mat(Input.MomentWeight(1,2));               % Moment plot weight - see manual for explanation
Weight.Weight_Def        = cell2mat(Input.DispWeight(1,2));                 % Deflection plot weight - see manual for explanation
Weight.Weight_Load_disp  = cell2mat(Input.Loaddisp(1,2));                   % Load displacement plot weight - see manual for explanation

focus.moment             = cellfun(@str2num,Input.MomentFocus);             % Focus on individual moment curves for different models - see manual for explanation
focus.def                = cellfun(@str2num,Input.DispFocus);               % Focus on individual displacement curves for different models - see manual for explanation
focus.load_disp          = cellfun(@str2num,Input.Load_Disp_Focus);         % Focus on individual load-disp curves for different models - see manual for explanation
focus.load_level         = cellfun(@str2num,Input.Load_Level_Focus);        % Focus on different load levels - see manual for explanation
focus.model              = cellfun(@str2num,Input.Model_Focus);             % Focus on different models - see manual for explanation

object_layers            = Input.objective_layer';                          % Layers to be considered in plotting and/or calibration
Stratigraphy             = Input.Stratigraphy{1,2};                         % Stratigraphy assignment
Apply_Direct_springs     = Input.Direct_Soil_Springs{1,2};                  % Assign switch - use of direct soil springs. See manual for info
Ommit_Bad_Curves         = Input.Ommit_Bad_Curves{1,2};                     % Assign switch - ommit bad curves for direct soil spring method. See manual for info

%% Parameters Assginment

var_name  = Input.CalibParam;                                                % defines names of variables used for calibration
start     = cell2mat(Input.Starting_Value);                                  % defines the starting variables for calibration
con_name  = Input.Constant_name;                                             % defines the names of the constants to be used in calculations but not calibrated
constant  = cell2mat(Input.Constant_value);                                  % defines the constants to be used in calculations but not calibrated
LB        = Input.LB;                                                        % defines LB values for all of the parameters to be calibrated
UB        = Input.UB;                                                        % defines UB values for all of the parameters to be calibrated
base_soil = Input.BaseSoil;                                                 % defines base case names needed for writing to DB
%%  Calibrations options
calibration.involvment  = Input.Involvment{1,2};                            % 'def' or 'mom' or 'defmud' or 'def_mom' or 'def_mom-defmud'  'def_defmud'
calibration.type        = 'sqpso';                                          % either 'sqpso' or 'lsqnonlin'

%% PLAXIS file reading
for Geo=1:size(CallModels,2)
    
    settings.(CallModels{Geo}).model_name 		  = CallModels{Geo};
    settings.(CallModels{Geo}).lateralmultipliers = 0;
    [scour.(CallModels{Geo}), soil.(CallModels{Geo}), pile.(CallModels{Geo}), loads.(CallModels{Geo}), settings.(CallModels{Geo})] = manual_data_input_excel(settings.(CallModels{Geo})); % load soil and pile information from Exce-file
    
    soil.(CallModels{Geo}).function_types_name 	 = Input.Function_Type_Name; 		 % defines names of the function types
    soil.(CallModels{Geo}).function_types 		 = cell2mat(Input.Function_Type); 	 % defines the function types
    pile.(CallModels{Geo}).Reduction_ult_sand.PU = Input.reduction_factor_PU_D{1,2}; % reduction of pu for sand
    pile.(CallModels{Geo}).Reduction_ult_sand.MU = Input.reduction_factor_MU_D{1,2}; % reduction of mu for sand
    pile.(CallModels{Geo}).Reduction_ult_clay.PU = Input.reduction_factor_PU_U{1,2}; % reduction of pu for clay
    pile.(CallModels{Geo}).Reduction_ult_clay.MU = Input.reduction_factor_MU_U{1,2}; % reduction of mu for clay
    
    for level=1:size(calibration.level,2)
        
        Plaxis_model 													= [pwd,'\Plaxisfiles\',CallModels{Geo},'\Structural Forces ',(calibration.level{level}),'.xlsx']; 	% defines name and path of the structural forces excel to be read
        PlaxisFilenames.(CallModels{Geo}).Stract{level,1} 				= Plaxis_model; 																					% redefines the name  
        [PLAX.(CallModels{Geo}).(calibration.level{level}).Plax_N] 		= xlsread(Plaxis_model,['N']); 																		% reads normal force along the pile
        [PLAX.(CallModels{Geo}).(calibration.level{level}).Plax_V] 		= xlsread(Plaxis_model,['V']); 																		% reads shear force along the pile
        [PLAX.(CallModels{Geo}).(calibration.level{level}).Plax_M] 		= xlsread(Plaxis_model,['M']); 																		% reads moment along the pile
        [PLAX.(CallModels{Geo}).(calibration.level{level}).Plax_Disp] 	= xlsread(Plaxis_model,['Pile Displacement']);  													% reads displacement along the pile
        loadcase.(CallModels{Geo}).(calibration.level{level}).H 		= 2*PLAX.(CallModels{Geo}).(calibration.level{level}).Plax_V(1,end); 	 							% reads moment force applied to the top of the pile
        loadcase.(CallModels{Geo}).(calibration.level{level}).M 		= -abs(PLAX.(CallModels{Geo}).(calibration.level{level}).Plax_M(4,end)); 							% reads shear force applied to the top of the pile

        if PYcreator||Apply_Direct_springs
            
            index_rotation=[];
            plaxisfile.main=[pwd,'\Plaxisfiles\',CallModels{Geo},'\FE_Orsted.xlsx'];
            plaxisfile.sheet='Shear';
            [PLAX.(CallModels{Geo}).(calibration.level{level}).PYCurves]        = read_Reaction_Plaxis(plaxisfile,index_rotation,spring_type,Ommit_Bad_Curves,scour_Depth,CallModels{Geo});
            
            plaxisfile.sheet='Moment';
            [PLAX.(CallModels{Geo}).(calibration.level{level}).MTheta]          = read_Reaction_Plaxis_mt(plaxisfile,index_rotation,spring_type,PLAX.(CallModels{Geo}).(calibration.level{level}).PYCurves,Ommit_Bad_Curves,scour_Depth,CallModels{Geo});
            
            plaxisfile.sheet='Shear';
            [PLAX.(CallModels{Geo}).(calibration.level{level}).BaseShear]       = read_Base_Reaction_Plaxis(plaxisfile,index_rotation,scour_Depth);
            PLAX.(CallModels{Geo}).(calibration.level{level}).BaseShear.depth   = pile.(CallModels{Geo}).length;
            
            plaxisfile.sheet='Moment';
            [PLAX.(CallModels{Geo}).(calibration.level{level}).BaseMoment]      = read_Base_Reaction_Plaxis(plaxisfile,index_rotation,scour_Depth);
            PLAX.(CallModels{Geo}).(calibration.level{level}).BaseMoment.depth  = pile.(CallModels{Geo}).length;
        end
    end
end

LB = cell2mat(LB);
UB = cell2mat(UB);
    
%% Calculations
[variable]      = Ucode2014(Inversemode,loadcase,object_layers,PYcreator,CallModels,Weight,PLAX,calibration,scour,soil,pile,loads,settings,PYcreator_stiff,var_name,focus,constant,con_name,spring_type,Stratigraphy,Database,start,LB,UB,Layered_wise_calibration,Apply_Direct_springs,Input);
General_error   = BatchRun(variable,loadcase,object_layers,PYcreator,CallModels,Weight,PLAX,calibration,scour,soil,pile,loads,settings,1,PYcreator_stiff,var_name,focus,constant,con_name,spring_type,Stratigraphy,Database,Apply_Direct_springs,txt_file_output,Input);
