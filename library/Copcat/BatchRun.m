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
            end
            if contains(calibration.involvment,'defmud')
                switch calibration.level{level}
                    case 'D_200'
                        NStepMultiplier = 250;
                    case 'D_10'
                        NStepMultiplier = 25;
                end
                Nrun_forward= Nrun_forward+1;
                [load_dips_curve,DB_output,output_COPCAT.(calibration.level{level}).load_def] = run_COSPIN_load_def_final(CallModels{Geo},Weight,PLAX.(CallModels{Geo}).(calibration.level{level}),PYcreator,variable,loadcase.(CallModels{Geo}).(calibration.level{level}),object_layers,scour.(CallModels{Geo}), soil.(CallModels{Geo}), pile.(CallModels{Geo}), loads.(CallModels{Geo}), settings.(CallModels{Geo}),PYcreator_stiff,NStepMultiplier,var_name,constant,con_name,Database,Apply_Direct_springs,txt_file_output);
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

if PlotSwitch && PYcreator == 0
    plot_results(calibration,model,CallModels); 
elseif PlotSwitch && PYcreator==1
    close all
    plot_P_Y_CURVES(calibration,Global_Data,CallModels,object_layers,spring_type);  
end

DB_write(DB_output,Input,output_COPCAT,calibration.level{level});

if  PYcreator == 0
    General_error = Assemble_Error(NumberofGeometry,calibration,model);
elseif PYcreator == 1
    General_error = Residual;
end

%% Text Output
txt_file_output_fun(CallModels,Geo,output_COPCAT,calibration,txt_file_output,PYcreator)

end