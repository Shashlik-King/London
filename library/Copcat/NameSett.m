function [Input] = NameSett(Sett,Input)
% Name Settings imported from Excel

Input.objective_layer    = cell2mat(Sett.Layered_Data(:,4));
Input.BaseSoil           = Sett.Layered_Data(:,1);
Input.SoilInfo           = Sett.Layered_Data(:,2:end-1);
Input.CalibParam         = Sett.CalibParam;
Input.Function_Type_Name = cell2mat(Sett.Function_Type_Name);
Input.Function_Type      = Sett.Function_Type;
Input.Constant_name      = Sett.Constant_name(1,2:end);
Input.Constant_value     = Sett.Constant_value(:,2:end);

if strcmp(Input.Stratigraphy{1,2}, 'homogeneous')    % When the soil is homogious, but various layeres has been defined in cospin input 
    Input.Starting_Value = Sett.Starting_Value(1,:); 
    Input.LB             = Sett.LB(1,:);
    Input.UB             = Sett.UB(1,:);
else   
    Input.Starting_Value = Sett.Starting_Value; 
    Input.LB             = Sett.LB;
    Input.UB             = Sett.UB;
end

Input.ModelsSpil         = split(Input.Models{1,2},",")';
Input.Loads_lev_Spil     = split(Input.LoadLevels{1,2},",")';
Input.MomentFocus        = split(Input.MomentFocus{1,2},"&")';
Input.DispFocus          = split(Input.DispFocus{1,2},"&")';
Input.Load_Disp_Focus    = split(Input.Load_Disp_Focus{1,2},"&")';
Input.Load_Level_Focus   = split(Input.Load_Level_Focus{1,2},"&")';
Input.Model_Focus        = split(Input.Model_Focus{1,2},"&")';

end 
















