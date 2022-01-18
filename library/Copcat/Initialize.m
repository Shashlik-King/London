function [Input] = Initialize()
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
'Models' 'B17:C17'
'LoadLevels' 'B18:C18'
'Springtype' 'B19:C19'
'Stratigraphy' 'B20:C20'
'SoilType' 'B21:C21'
'MomentWeight' 'B42:C42'
'DispWeight' 'B43:C43'
'Loaddisp' 'B44:C44'
'MomentFocus' 'B45:C45'
'DispFocus' 'B46:C46'
'Load_Disp_Focus' 'B47:C47'
'Load_Level_Focus' 'B48:C48'
'Model_Focus' 'B49:C49'
'Layered_wise_calibration' 'B12:C12'
'Direct_Soil_Springs' 'B13:C13'
'Ommit_Bad_Curves' 'B14:C14'
'Text_file_output' 'B52:C52'
'Database_update' 'B53:C53'
'Project_name' 'B54:C54'
'revision' 'B55:C55'
'reduction_factor_PU_D' 'B24:C24'
'reduction_factor_MU_D' 'B25:C25'
'reduction_factor_PU_U' 'B28:C28'
'reduction_factor_MU_U' 'B29:C29'
'Layered_Data' 'E5:I33'
'CalibParam' 'J4:S4'
'Starting_Value' 'J5:S33'
'LB' 'J38:S67'
'UB' 'J73:S101'
'Function_Type_Name' 'U4:AJ4'
'Function_Type' 'U5:AJ34'
'Constant_name' 'AL4:AU4'
'Constant_value' 'AL5:AU34'
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

Input.objective_layer    = cell2mat(Input.Layered_Data(:,5));
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

end 


