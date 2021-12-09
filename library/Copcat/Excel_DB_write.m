function Excel_DB_write(DB_output,Input)
% Read and write excel database


%% Opening & Reading Excel
filename='excel\COPCAT_Data_Base.xlsx'; % This file should be inside the working directory/Complete path Name
sheet='Soil';
[~, text]=xlsread(filename,sheet); % read numerical data 
New.row = size(text(:,1),1) +1;
Param.columns = {'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'AA', 'AB', 'AC', 'AD', 'AE', 'AF', 'AG', 'AH', 'AI', 'AJ', 'AK', 'AL', 'AM', 'AN', 'AO', 'AP', 'AQ', 'AR', 'AS', 'AT', 'AU', 'AV', 'AW', 'AX', 'AY', 'AZ', 'BA', 'BB', 'BC', 'BD', 'BE', 'BF', 'BG', 'BH', 'BI', 'BJ', 'BK', 'BL', 'BM', 'BN', 'BO', 'BP', 'BQ'};

prompt = 'Do you want to upload the parameters to the database?  [y/n] ';
IsWrite = input(prompt,'s');
if strcmp(IsWrite,'y')
    disp(['Parameter revision used for calibration is ', num2str(Input.SoilInfo{1,2})])
    New.revision = {input('Enter revision under which to save the parameters:','s')};
    disp('Writing parameters into Database starting. Please wait.')
    for i = 1:size(variable,1)
        New.name{i} = {Input.BaseSoil{i}}; % specifies the soil layer name
        New.project{i} = {Input.SoilInfo{i,1}}; % specifies the project name
        if PYcreator==1 && Input.SpringType == 0
            New.notes{i} = {'Reaction curves - p-y'}; % specifies calibration type used
        elseif PYcreator==1 && Input.SpringType == 1
            New.notes{i} = {'Reaction curves - m-t'}; % specifies calibration type used
        elseif PYcreator==1 && Input.SpringType == 2
            New.notes{i} = {'Reaction curves - H-b'}; % specifies calibration type used
        elseif PYcreator==1 && Input.SpringType == 3
            New.notes{i} = {'Reaction curves - M-b'}; % specifies calibration type used
        elseif PYcreator==0
            New.notes{i} = {'Pile response'}; % specifies calibration type used
        end
        New.soil_type{i} = {'Sand'}; % to be changed FKMV
        
        xlswrite(filename,New.name{i},sheet,strcat('A',num2str(New.row))) % write New.name
        xlswrite(filename,New.project{i},sheet,strcat('B',num2str(New.row))) % write New.project
        xlswrite(filename,New.revision{i},sheet,strcat('C',num2str(New.row))) % write New.notes
        xlswrite(filename,New.notes{i},sheet,strcat('D',num2str(New.row))) % write New.soil_type
        xlswrite(filename,New.soil_type{i},sheet,strcat('E',num2str(New.row))) % write New.soil_type

        % Write parameters
        for ii = 1:size(Param.columns,2) % PISA_constants
            xlswrite(filename,DB_output(ii),sheet,strcat(num2str(Param.columns{ii}),num2str(New.row))) % write Parameter constants
        end
        
        
    end
    disp('Writing into Database finished.')
else
    disp('No update of the Database chosen.')
end  
disp('---------------------------------------------------------------------')

%% Parameter Database
% Write Information section


%% MySQL write
database_str = []; % Initialisation fo the string to be sent to the MySQL Database
mysql(mysqlstr)
%% Constitutive model Database
% Possibility to add FE model input to the DB

end
