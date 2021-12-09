
%%%%%%inverse analysis run 



function [General_error]=forward_model_Function(X)


% plaxisfilename={'model1','model2'};
plaxisfilename={'model1'};

NumberofGeometry=size(plaxisfilename,2);

PYcreator = 0; % Always off for this forward model (1 = py curves, 0 = pile response)

calibration.method='nlinearlqr'

%  calibration.level= {'200','10'} %200 Refers to the stiffness   10 Refers to ultimate

  calibration.level= {'200'} %200 Refers to the stiffness   10 Refers to ultimate



% loadcase={'LC6P','LC5P'}
 loadcase={'LC6P'}

model(1).project_name = {'GEGE_D_Char_PISA_H1(BE)'}; % needed to read excel manual input

model(1).appload=[200, 20545];
model(1).appmoment=[1000, 100000];
model(1).pile_length=44.89;
model(1).diameter=10.2;
model(1).tickness=0.085;
model(1).Weight_moment=0.01;
model(1).Weight_Def=0.01;
model(1).Weight_Load_disp=0.01;

model(2).appload=[200, 20545];
model(2).appmoment=[1000, 100000];
model(2).pile_length=40;
model(2).diameter=10.2;

% plaxis_file_name={'Structural_Forces_D_200.xlsx' , 'Structural_Forces_D_10.xlsx'};

 plaxis_file_name={'Structural_Forces_D_200.xlsx'};

% [PLAX.depth_stiff,PLAX.X_curve_stiff,PLAX.Y_curve_stiff] = read_Reaction_Plaxis_def_mom(file_name_plaxis);

object_layers=[1];
% variable=[105.936	1.65814	0.752558	0.777427	13.7046	-3.30867];
variable=[300	0.65814	0.752558	0.814845	14.1517	-1.95423];

variable(2)=X(1);    % only stiffness
variable(3)=X(2);   %only stiffness


calibration.involvment='def' % 'def' or 'mom' or 'defmud' or 'def_mom' or 'def_mom-defmud
calibration.type = 'sqpso'; % either 'sqpso' or 'lsqnonlin'

Nrun_forward=0
for Geo =1:NumberofGeometry    % Run over the number of plaxis model
    
    for Pres_level=1:size(calibration.level,2)   % Run over the  load level of each models
        
        Nrun_forward= Nrun_forward+1 
        
%         plaxis_file_name = [plaxisfilename{Geo},'_',calibration.level,'.xlsx'];
        
        Plaxis_model = plaxis_file_name{Geo,Pres_level}; % path to do to be changed
        [PLAX.Plax_N] = xlsread(Plaxis_model,['N']); % normal force
        [PLAX.Plax_V] = xlsread(Plaxis_model,['V']); % shear force
        [PLAX.Plax_M] = xlsread(Plaxis_model,['M']); % moment
        [PLAX.Plax_Disp] = xlsread(Plaxis_model,['Pile Displacement']);

    
%         [results] = run_COSPIN_deflection(Pisa_param,plaxis_file_name,model(Geo));
          [results] = run_COSPIN_deflection(plaxis_file_name,model(Geo),calibration,PLAX,PYcreator,variable,loadcase{Pres_level},object_layers);
          
        model(Geo).result(Pres_level) = results;

        
             
    end
    
    
        [GlobalError] = Assemble_Error(NumberofGeometry,calibration,model);
        
%         model(Geo).result(Pres_level)=results; 
    
        if contains(calibration.involvment,'defmud')
            
            plaxis_file_name=[plaxisfilename{Geo},'_','10','.xlsx']
            model(geo).loaddef=Run_cospin_deflection_mudline(Pisa_param,plaxis_file_name,model(Geo),calibration); 
        else
            
            model(Geo).loaddef=0;
        end 
            
end 


       General_error=Assemble_Error(NumberofGeometry,calibration,model);
       
end 


% % % Result.def= Matrix (nX4)
% % % result.moment=Matrix (nX4)