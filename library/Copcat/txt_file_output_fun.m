function txt_file_output_fun(CallModels,Geo,output_COPCAT,calibration,txt_file_output,PYcreator)
%% Text file writing function to run benchmark of the code i.e. unit test

if txt_file_output 
    OutputFolder = ['output\',CallModels{Geo},'\data'];   % Folder path name only
    if exist(OutputFolder,'dir') == 0
        mkdir(OutputFolder);                          % Folder path for saving plots 
    end
    if PYcreator % Write all springs to the text files
        
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
    else % write all pile response output to a text file
        
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
            if any(strcmp(calibration.level,'D_10'))
            writematrix(output_COPCAT.D_10.output.output.hor_defl,['output\',CallModels{Geo},'\data\pile_response\','deflection_along_pile_D_10.txt'],'Delimiter','tab')
            writematrix(output_COPCAT.D_10.output.Es{1,1}(:,:,3),['output\',CallModels{Geo},'\data\pile_response\','moment_D_10.txt'],'Delimiter','tab')
            writematrix(output_COPCAT.D_10.output.Es{1,1}(:,:,2),['output\',CallModels{Geo},'\data\pile_response\','shear_D_10.txt'],'Delimiter','tab')
            end
            if any(strcmp(calibration.level,'D_200')) 
            writematrix(output_COPCAT.D_200.output.output.hor_defl,['output\',CallModels{Geo},'\data\pile_response\','deflection_along_pile_D_200.txt'],'Delimiter','tab')
            writematrix(output_COPCAT.D_200.output.Es{1,1}(:,:,3),['output\',CallModels{Geo},'\data\pile_response\','moment_D_200.txt'],'Delimiter','tab')
            writematrix(output_COPCAT.D_200.output.Es{1,1}(:,:,2),['output\',CallModels{Geo},'\data\pile_response\','shear_D_200.txt'],'Delimiter','tab')   
            end
        end
        if contains(calibration.involvment,'defmud')
            if any(strcmp(calibration.level,'D_10'))
            writematrix(output_COPCAT.D_10.load_def.output.load_def.force_calibration,['output\',CallModels{Geo},'\data\pile_response\','load_applied_at_mudline_D_10.txt'],'Delimiter','tab')
            writematrix(output_COPCAT.D_10.load_def.output.load_def.def_calibration,['output\',CallModels{Geo},'\data\pile_response\','displacement_at_mudline_D_10.txt'],'Delimiter','tab')
            end
            if any(strcmp(calibration.level,'D_200'))   
            writematrix(output_COPCAT.D_200.load_def.output.load_def.force_calibration,['output\',CallModels{Geo},'\data\pile_response\','load_applied_at_mudline_D_200.txt'],'Delimiter','tab')
            writematrix(output_COPCAT.D_200.load_def.output.load_def.def_calibration,['output\',CallModels{Geo},'\data\pile_response\','displacement_at_mudline_D_200.txt'],'Delimiter','tab')
            end
        end
    end
end