function [Input, Database] = Initialize()
% Loads settings and starting values, LB, UB values as well as constants necessary for calibration and plotting

%% Sheet and excel definition
Sheets = {'Exchange'};
Files  = {'COPCAT_input.xlsm'};

%% Main settings and switches
Range = {'Calibration' 'B3:C3'
'PYCreator' 'B4:C4'
'CalibMethod' 'B5:C5'
'Costfunctiontype' 'B6:C6'
'Involvment' 'B7:C7'
'OptAlgorithm' 'B8:C8'
'weightType' 'B9:C9'
'Models' 'B15:C15'
'LoadLevels' 'B16:C16'
'Springtype' 'B17:C17'
'Stratigraphy' 'B18:C18'
% 'SoilType' 'B21:C21'
'MomentWeight' 'B31:C31'
'DispWeight' 'B32:C32'
'Loaddisp' 'B33:C33'
'MomentFocus' 'B34:C34'
'DispFocus' 'B35:C35'
'Load_Disp_Focus' 'B36:C36'
'Load_Level_Focus' 'B37:C37'
'Model_Focus' 'B38:C38'
'Layered_wise_calibration' 'B11:C11'
'Direct_Soil_Springs' 'B12:C12'
'Ommit_Bad_Curves' 'B13:C13'
'Text_file_output' 'B20:C20'
'Database_update' 'B21:C21'
'Project_name' 'B22:C22'
'Location_name' 'B23:C23'
'revision' 'B24:C24'
'preparer' 'B25:C25'
'reduction_factor_PU_D' 'B40:C40'
'reduction_factor_MU_D' 'B41:C41'
'reduction_factor_PU_U' 'B42:C42'
'reduction_factor_MU_U' 'B43:C43'
'Layered_Data' 'F5:K33'
'CalibParam' 'L4:U4'
'Starting_Value' 'L5:U33'
'LB' 'L38:U67'
'UB' 'L73:U101'
'Function_Type_Name' 'W4:AL4'
'Function_Type' 'W5:AL34'
'Constant_name' 'AN4:AW4'
'Constant_value' 'AN5:AW34'
};

[~,~,Input_raw] = xlsread(Files{1,1},Sheets{1,1});
for i = 1:size(Range,1)
    range_values        = split(Range{i,2},":")';
    row_num_1           = str2double(regexp(range_values{1,1},'[\d.]+','match'));
    row_num_2           = str2double(regexp(range_values{1,2},'[\d.]+','match'));
    col_char_1          = erase(range_values{1,1} , num2str(row_num_1));
    col_char_2          = erase(range_values{1,2} , num2str(row_num_2));
    col_num_1           = xlsColStr2Num( {col_char_1} );
    col_num_2           = xlsColStr2Num( {col_char_2} );
    for ii = 1:row_num_2-row_num_1+1
        for iii = 1:col_num_2-col_num_1+1
            Input.(Range{i,1}){ii,iii} = Input_raw{row_num_1+ii-1,col_num_1+iii-1};
        end
    end
end

%% Cut away unnecessary parts at the end
on_layers_rows          = ~any(cellfun(@isempty, Input.Layered_Data), 2);  %find them
on_layers_cols          = ~any(cellfun(@isempty, Input.Starting_Value(on_layers_rows,:)), 1);  %find them
Input.Starting_Value    = Input.Starting_Value(on_layers_rows,on_layers_cols);
Input.Layered_Data      = Input.Layered_Data(on_layers_rows,:);
Input.LB                = Input.LB(on_layers_rows,on_layers_cols);
Input.UB                = Input.UB(on_layers_rows,on_layers_cols);
Input.Function_Type     = Input.Function_Type(on_layers_rows,:);   %delete them

on_layers_cols_con      = ~any(cellfun(@isempty, Input.Constant_value(on_layers_rows,:)), 1);  %find them
Input.Constant_value    =  Input.Constant_value(on_layers_rows,on_layers_cols_con);

%% Reassignment of parameters

Input.objective_layer    = cell2mat(Input.Layered_Data(:,6));
Input.BaseSoil           = Input.Layered_Data(:,1);
Input.SoilInfo           = Input.Layered_Data(:,2:end-1);
Input.CalibParam         = Input.CalibParam(1,on_layers_cols);
Input.Function_Type_Name = Input.Function_Type_Name;
Input.Function_Type      = Input.Function_Type;
Input.Constant_name      = Input.Constant_name(1,on_layers_cols_con);

if strcmp(Input.Stratigraphy{1,2}, 'homogeneous')    % When the soil is homogious, but various layeres has been defined in cospin input 
    Input.Starting_Value = Input.Starting_Value(1,:); 
    Input.LB             = Input.LB(1,:);
    Input.UB             = Input.UB(1,:);
else   
    Input.Starting_Value = Input.Starting_Value; 
    Input.LB             = Input.LB;
    Input.UB             = Input.UB;
end

Input.ModelsSpil         = split(Input.Models{1,2},",")';
Input.Loads_lev_Spil     = split(Input.LoadLevels{1,2},",")';
Input.MomentFocus        = split(Input.MomentFocus{1,2},"&")';
Input.DispFocus          = split(Input.DispFocus{1,2},"&")';
Input.Load_Disp_Focus    = split(Input.Load_Disp_Focus{1,2},"&")';
Input.Load_Level_Focus   = split(Input.Load_Level_Focus{1,2},"&")';
Input.Model_Focus        = split(Input.Model_Focus{1,2},"&")';

%% Import DB from excel
[Database.num,Database.txt,Database.raw] = xlsread('COPCAT_Input.xlsm','Table Output','A1:BQ100000'); % reads COPCAT database with PISA parameters
Database.txt                             = Database.txt(2:end,:);           % filters the text part of the database only


for ii = 1:size(Input.objective_layer,1)
    index = find(strcmp(Input.BaseSoil{ii}, Database.txt(:,1)));
    Input.SoilType(ii,1) = Database.txt(index,5);
end

end 


