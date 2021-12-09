%% Inverse analysis run 
clc; clear all; close all;

%% Input

PYcreator = 0; % Always off for this forward model (1 = py curves, 0 = pile response)

calibration.method='nlinearlqr';
calibration.Costfunction='Vector';
Weight.weight_type='Obs_NP';

CallModels={'C11'};
NumberofGeometry=size(CallModels,2);

calibration.level={'200', '10'};


Weight.Weight_moment=0.01;
Weight.Weight_Def=0.01;
Weight.Weight_Load_disp=0.01;
Weight.Weight_moment=0.01;
Weight.Weight_Def=0.01;
Weight.Weight_Load_disp=0.01;


%% FKMV Inpup
addpath (genpath('excel')); % make sure all the excel input is available
addpath (genpath('library')); % make sure all the functions are available


for Geo=1:size(CallModels,2)

settings.(CallModels{Geo}).model_name = CallModels{Geo};
settings.(CallModels{Geo}).lateralmultipliers = 1;
[scour.(CallModels{Geo}), soil.(CallModels{Geo}), pile.(CallModels{Geo}), loads.(CallModels{Geo}), settings.(CallModels{Geo})] = manual_data_input_excel(settings.(CallModels{Geo})); % load soil and pile information from Exce-file

for level=1:size(calibration.level,2)
    PlaxisFilenames.(CallModels{Geo}).Stract{level,1}=[CallModels{Geo},'_D_',calibration.level{level}];
    PlaxisFilenames.(CallModels{Geo}).PYCurve{level,1}=[CallModels{Geo},'_PY_D_',calibration.level{level}];
    PlaxisFilenames.(CallModels{Geo}).MthehtaCurve{level,1}=[CallModels{Geo},'_M_thetaCurves_D_',calibration.level{level}];
    PlaxisFilenames.(CallModels{Geo}).BaseShear{level,1}=[CallModels{Geo},'_Base_shear_D_',calibration.level{level}];    
    PlaxisFilenames.(CallModels{Geo}).BaseMoment{level,1}=[CallModels{Geo},'_Base_moment_D_',calibration.level{level}];    

end 

end 


object_layers=[1];

           % KP1   KP2     n1       n2   Y 
variable=[-0.275 3.950   -0.034  0.955  60];

calibration.involvment='defmud'; % 'def' or 'mom' or 'defmud' or 'def_mom' or 'def_mom-defmud
calibration.type = 'sqpso'; % either 'sqpso' or 'lsqnonlin'


%% Calculations





Nrun_forward=0;
for Geo=1:size(CallModels,2)    % Run over the number of plaxis model
    
    for level=1:size(calibration.level,2)   % Run over the  load level of each models
        
        Nrun_forward= Nrun_forward+1 
        

        
        Plaxis_model = PlaxisFilenames.(CallModels{Geo}).Stract{level,1}; % path to do to be changed
        [PLAX.Plax_N] = xlsread(Plaxis_model,['N']); % normal force
        [PLAX.Plax_V] = xlsread(Plaxis_model,['V']); % shear force
        [PLAX.Plax_M] = xlsread(Plaxis_model,['M']); % moment
        [PLAX.Plax_Disp] = xlsread(Plaxis_model,['Pile Displacement']);

        loadcase.H=PLAX.Plax_V(1,end);        
        loadcase.M=-PLAX.Plax_M(4,end);
        
        
        [results] = run_COSPIN_deflection_excel(CallModels{Geo},Weight,PLAX,PYcreator,variable,loadcase,object_layers,scour.(CallModels{Geo}), soil.(CallModels{Geo}), pile.(CallModels{Geo}), loads.(CallModels{Geo}), settings.(CallModels{Geo}),PYcreator); 
        model(Geo).result(level) = results;

    end
    
    
%         [GlobalError] = Assemble_Error(NumberofGeometry,calibration,model);
        
%         model(Geo).result(Pres_level)=results; 
    
        if contains(calibration.involvment,'defmud')
            
%             plaxis_file_name=[plaxisfilename{Geo},'_','10','.xlsx'];
            Plaxis_model = PlaxisFilenames.(CallModels{Geo}).Stract{2,1}; % path to do to be changed
            [PLAX.Plax_N] = xlsread(Plaxis_model,['N']); % normal force
            [PLAX.Plax_V] = xlsread(Plaxis_model,['V']); % shear force
            [PLAX.Plax_M] = xlsread(Plaxis_model,['M']); % moment
            [PLAX.Plax_Disp] = xlsread(Plaxis_model,['Pile Displacement']);
            model(Geo).loaddef = run_COSPIN_load_def_final(CallModels{Geo},Weight,PLAX,PYcreator,variable,loadcase,object_layers,scour.(CallModels{Geo}), soil.(CallModels{Geo}), pile.(CallModels{Geo}), loads.(CallModels{Geo}), settings.(CallModels{Geo})); 
        else
            model(Geo).loaddef=0;
        end
            
end 

       plot_results(calibration,model,NumberofGeometry);        
       General_error=Assemble_Error(NumberofGeometry,calibration,model);
       
       
     


% % % Result.def= Matrix (nX4)
% % % result.moment=Matrix (nX4)