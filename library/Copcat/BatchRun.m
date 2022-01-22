function General_error = BatchRun(variable,loadcase,object_layers,PYcreator,CallModels,Weight,PLAX,calibration,scour,soil,pile,loads,settings,PlotSwitch,PYcreator_stiff,var_name,focus,constant,con_name,spring_type,Stratigraphy,Database,Apply_Direct_springs,txt_file_output,Input)
[variable,constant] = Homo_Layered_Var(variable,constant,object_layers,Stratigraphy);
Nrun_forward        = 0;
NumberofGeometry    = size(CallModels,2);
Residual            = [];
for Geo = 1:size(CallModels,2)    % Run over the number of plaxis model
    for level = 1:size(calibration.level,2)   % Run over the  load level of each models  
        if PYcreator == 1       % SSI Creator  only  
            [ResidualSingle,Global_Data(Geo).(calibration.level{level}),DB_output,output_COPCAT] = P_Y_Creator_function(CallModels{Geo},Weight,PLAX.(CallModels{Geo}).(calibration.level{level}),PYcreator,variable,loadcase.(CallModels{Geo}).(calibration.level{level}),object_layers,scour.(CallModels{Geo}), soil.(CallModels{Geo}), pile.(CallModels{Geo}), loads.(CallModels{Geo}), settings.(CallModels{Geo}),PYcreator_stiff,PlotSwitch,var_name,constant,con_name,spring_type,Database,Apply_Direct_springs,txt_file_output);
             Residual = [Residual;ResidualSingle];
        end
        if PYcreator == 0  % Pile response analysis 
            if strcmp(calibration.involvment,'def') || strcmp(calibration.involvment,'mom') || strcmp(calibration.involvment,'def_mom')  || strcmp(calibration.involvment,'def_mom')  || strcmp(calibration.involvment,'def_mom_defmud')  || strcmp(calibration.involvment,'def_defmud')
                Nrun_forward            = Nrun_forward+1;
                [results,DB_output,output_COPCAT.(calibration.level{level}).output]     = run_COSPIN_deflection_excel(CallModels{Geo},Weight,PLAX.(CallModels{Geo}).(calibration.level{level}),PYcreator,variable,loadcase.(CallModels{Geo}).(calibration.level{level}),object_layers,scour.(CallModels{Geo}), soil.(CallModels{Geo}), pile.(CallModels{Geo}), loads.(CallModels{Geo}), settings.(CallModels{Geo}),PYcreator_stiff,var_name,constant,con_name,Database,Apply_Direct_springs,txt_file_output);
            else
                results.shear           = 0;
                results.moment          = 0;
                results.displacement    = 0;
                output_COPCAT           = [];
            end
            if contains(calibration.involvment,'defmud')
                switch calibration.level{level}
                    case 'D_200'
                        NStepMultiplier = 250;
                    case 'D_10'
                        NStepMultiplier = 25;
                end
                Nrun_forward= Nrun_forward+1;
                [load_dips_curve,DB_output,output_COPCAT.(calibration.level{level}).load_def] = run_COSPIN_load_def_final(CallModels{Geo},Weight,PLAX.(CallModels{Geo}).(calibration.level{level}),PYcreator,variable,loadcase.(CallModels{Geo}).(calibration.level{level}),object_layers,scour.(CallModels{Geo}), soil.(CallModels{Geo}), pile.(CallModels{Geo}), loads.(CallModels{Geo}), settings.(CallModels{Geo}),PYcreator_stiff,NStepMultiplier,var_name,constant,con_name,Database,Apply_Direct_springs,txt_file_output,output_COPCAT);
            else
                load_dips_curve.load_displacement = 0;
            end
            model(Geo).result(level).load_displacement  = load_dips_curve.load_displacement;
            model(Geo).result(level).shear              = results.shear;
            model(Geo).result(level).moment             = results.moment;
            model(Geo).result(level).displacement       = results.displacement;
        end
    end
end

if  PYcreator == 0
    General_error = Assemble_Error(NumberofGeometry,calibration,model);
elseif PYcreator == 1
    General_error = Residual;
end

%% POSTPROCESSING
%Plotting
if PlotSwitch && PYcreator == 0
    plot_results(calibration,model,CallModels); 
elseif PlotSwitch && PYcreator==1
    close all
    plot_P_Y_CURVES(calibration,Global_Data,CallModels,object_layers,spring_type);  
end

% MySQL DB Output
if PlotSwitch && Input.Database_update{1,2}
    DB_write(DB_output,Input,spring_type);
else
    disp('No update of the Database chosen.')
end

% Text Output
if PlotSwitch && txt_file_output
    txt_file_output_fun(CallModels,Geo,output_COPCAT,calibration,txt_file_output,PYcreator)
else
    disp('No update of the Database chosen.')
end

% Log files
if PlotSwitch && txt_file_output
    txt_file_output_fun(CallModels,Geo,output_COPCAT,calibration,txt_file_output,PYcreator)
else
    disp('No update of the Database chosen.')
end

%% Text Output
if txt_file_output 
    OutputFolder = ['output\',CallModels{Geo},'\data'];   % Folder path name only
    if exist(OutputFolder,'dir') == 0
        mkdir(OutputFolder);                          % Folder path for saving plots 
    end
    if PYcreator && Input.Calibration{1,2} == 0% Write all springs to the text files
        
        OutputFolder = ['output\',CallModels{Geo},'\data\reaction_curves'];   % Folder path name only
        if exist(OutputFolder,'dir') == 0
            mkdir(OutputFolder);                          % Folder path for saving plots 
        end
    
        writematrix(output_COPCAT.p.top,['output\',CallModels{Geo},'\data\reaction_curves\','p.txt'],'Delimiter','tab')
        writematrix(output_COPCAT.y.top,['output\',CallModels{Geo},'\data\reaction_curves\','y.txt'],'Delimiter','tab')
        writematrix([output_COPCAT.m.top{1,1},output_COPCAT.m.top{1,2},output_COPCAT.m.top{1,3},output_COPCAT.m.top{1,4},output_COPCAT.m.top{1,5},output_COPCAT.m.top{1,6},output_COPCAT.m.top{1,7}],['output\',CallModels{Geo},'\data\reaction_curves\','m.txt'],'Delimiter','tab')
        writematrix(output_COPCAT.teta.top{1,1},['output\',CallModels{Geo},'\data\reaction_curves\','teta.txt'],'Delimiter','tab')
        writematrix(output_COPCAT.p_toe.bottom,['output\',CallModels{Geo},'\data\reaction_curves\','p_toe.txt'],'Delimiter','tab')
        writematrix(output_COPCAT.y_toe.bottom,['output\',CallModels{Geo},'\data\reaction_curves\','y_toe.txt'],'Delimiter','tab')
        writematrix(output_COPCAT.m_toe.bottom,['output\',CallModels{Geo},'\data\reaction_curves\','m_toe.txt'],'Delimiter','tab')
        writematrix(output_COPCAT.teta_toe.bottom,['output\',CallModels{Geo},'\data\reaction_curves\','teta_toe.txt'],'Delimiter','tab')
    elseif PYcreator == 0 && Input.Calibration{1,2} == 0% write all pile response output to a text file
        
        OutputFolder = ['output\',CallModels{Geo},'\data\pile_response'];   % Folder path name only
        if exist(OutputFolder,'dir') == 0
            mkdir(OutputFolder);                          % Folder path for saving plots 
        end
        
                OutputFolder = ['output\',CallModels{Geo},'\data\pile_response\D_10'];   % Folder path name only
        if exist(OutputFolder,'dir') == 0
            mkdir(OutputFolder);                          % Folder path for saving plots 
        end
        
                OutputFolder = ['output\',CallModels{Geo},'\data\pile_response\D_200'];   % Folder path name only
        if exist(OutputFolder,'dir') == 0
            mkdir(OutputFolder);                          % Folder path for saving plots 
        end
        if strcmp(calibration.involvment,'def') || strcmp(calibration.involvment,'mom') || strcmp(calibration.involvment,'def_mom')  || strcmp(calibration.involvment,'def_mom')  || strcmp(calibration.involvment,'def_mom_defmud')  || strcmp(calibration.involvment,'def_defmud')
            writematrix(output_COPCAT.D_10.output.output.hor_defl,['output\',CallModels{Geo},'\data\pile_response\','deflection_along_pile_D_10.txt'],'Delimiter','tab')
            writematrix(output_COPCAT.D_200.output.output.hor_defl,['output\',CallModels{Geo},'\data\pile_response\','deflection_along_pile_D_200.txt'],'Delimiter','tab')
            writematrix(output_COPCAT.D_10.output.Es{1,1}(:,:,3),['output\',CallModels{Geo},'\data\pile_response\','moment_D_10.txt'],'Delimiter','tab')
            writematrix(output_COPCAT.D_200.output.Es{1,1}(:,:,3),['output\',CallModels{Geo},'\data\pile_response\','moment_D_200.txt'],'Delimiter','tab')
            writematrix(output_COPCAT.D_10.output.Es{1,1}(:,:,2),['output\',CallModels{Geo},'\data\pile_response\','shear_D_10.txt'],'Delimiter','tab')
            writematrix(output_COPCAT.D_200.output.Es{1,1}(:,:,2),['output\',CallModels{Geo},'\data\pile_response\','shear_D_200.txt'],'Delimiter','tab')
        end
        if contains(calibration.involvment,'defmud')
            writematrix(output_COPCAT.D_10.load_def.output.load_def.force_calibration,['output\',CallModels{Geo},'\data\pile_response\','load_applied_at_mudline_D_10.txt'],'Delimiter','tab')
            writematrix(output_COPCAT.D_10.load_def.output.load_def.def_calibration,['output\',CallModels{Geo},'\data\pile_response\','displacement_at_mudline_D_10.txt'],'Delimiter','tab')
            writematrix(output_COPCAT.D_200.load_def.output.load_def.force_calibration,['output\',CallModels{Geo},'\data\pile_response\','load_applied_at_mudline_D_200.txt'],'Delimiter','tab')
            writematrix(output_COPCAT.D_200.load_def.output.load_def.def_calibration,['output\',CallModels{Geo},'\data\pile_response\','displacement_at_mudline_D_200.txt'],'Delimiter','tab')
        end
    end
end