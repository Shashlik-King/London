
model.project_name={'GEGE_D_Char_PISA_Test(BE)'};
% model.project_name={'C11'}; test

model.pileL=44.8;

model.loadcase={'LC5P'};

CallModels = {'C11'};

soil_unit=[1];

visual=1

PYcreator=1
PYcreator_stiff = 1; % calculate initial stiffness based on curves, 0 = no, 1 = yes

%% FKMV Inpup
addpath (genpath('excel')); % make sure all the excel input is available
addpath (genpath('library')); % make sure all the functions are available
settings.model_name = CallModels{1,1};
settings.lateralmultipliers = 1;
[scour, soil, pile, loads, settings] = manual_data_input_excel(settings); % load soil and pile information from Exce-file



index_rotation=[];
file_name_plaxis='C11_PY_D_10.csv';
[PLAX.depth,PLAX.X_curve,PLAX.Y_curve,PLAX.index_rotation]=read_Reaction_Plaxis(file_name_plaxis,index_rotation);
file_name_plaxis='C11_PY_D_200.csv';
[PLAX.depth_stiff,PLAX.X_curve_stiff,PLAX.Y_curve_stiff,PLAX.index_rotation_stiff]=read_Reaction_Plaxis(file_name_plaxis,PLAX,index_rotation);


variable=[-0.275	3.950	-0.034	0.955	60];

[Residual]=P_Y_Creator_function(soil_unit,variable,model,visual,PLAX,PYcreator,scour, soil, pile, loads, settings,PYcreator_stiff);

Residual