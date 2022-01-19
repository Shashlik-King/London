function DB_write(DB_output,Input,spring_type)
% Read and write excel database

%% MySQL dDatabase settings
settings.db_server          = 'DKLYCOPILOD1';       % Databse server
settings.db_user         	= 'owdb_user';          % Database user
settings.db_pass            = 'ituotdowdb';         % Database pass
settings.db_name            = 'owdb';               % Database name
table                       = 'COPCAT_Data_Base';   % Database table name

%% Opening MySQL Database


mysqlstr_ini        = ['INSERT INTO ',table,' (name,project,rev,notes,soil_type,'...
    'y_u_F,y_u_1,y_u_2,y_u_3,P_u_F,P_u_1,P_u_2,P_u_3,k_p_F,k_p_1,k_p_2,k_p_3,'...
    'n_p_F,n_p_1,n_p_2,n_p_3,tetam_u_F,tetam_u_1,tetam_u_2,tetam_u_3,m_u_F,'...
    'm_u_1,m_u_2,m_u_3,k_m_F,k_m_1,k_m_2,k_m_3,n_m_F,n_m_1,n_m_2,n_m_3,yB_u_F,'...
    'yB_u_1,yB_u_2,yB_u_3,HB_u_F,HB_u_1,HB_u_2,HB_u_3,k_H_F,k_H_1,k_H_2,k_H_3,'...
    'n_H_F,n_H_1,n_H_2,n_H_3,tetaMb_u_F,tetaMb_u_1,tetaMb_u_2,tetaMb_u_3,MB_u_F,'...
    'MB_u_1,MB_u_2,MB_u_3,k_Mb_F,k_Mb_1,k_Mb_2,k_Mb_3,n_Mb_F,n_Mb_1,n_Mb_2,n_Mb_3) VALUES ('];
    
%% New data assignment

    mysql('open',settings.db_server,settings.db_user,settings.db_pass); % ('open','server','username','password')
    mysql(['use ',settings.db_name]); % name of database

    New.revision = Input.revision{1,2};
    disp('Writing parameters into Database starting. Please wait.')
    for i = 1:size(Input.Layered_Data,2)
        New.name{i} = Input.Layered_Data{i,4}; % specifies the soil layer name
        New.project{i} = Input.Project_name{1,2}; % specifies the project name
        if Input.PYCreator{1,2}==1 && spring_type == 0
            New.notes{i} = 'Reaction curves - p-y'; % specifies calibration type used
        elseif Input.PYCreator{1,2}==1 && spring_type == 1
            New.notes{i} = 'Reaction curves - m-t'; % specifies calibration type used
        elseif Input.PYCreator{1,2}==1 && spring_type == 2
            New.notes{i} = 'Reaction curves - H-b'; % specifies calibration type used
        elseif Input.PYCreator{1,2}==1 && spring_type == 3
            New.notes{i} = 'Reaction curves - M-b'; % specifies calibration type used
        elseif Input.PYCreator{1,2}==0
            New.notes{i} = 'Pile_response'; % specifies calibration type used
        end
        New.soil_type{i} = Input.SoilType{i,1};
        database_str = [mysqlstr_ini,'''',New.name{i},''',''',New.project{i},''',''',num2str(New.revision),''',''',New.notes{i},''',''',New.soil_type{i},''''];
        for ii = 1:size(DB_output(i,:),2)
            database_str = [database_str,',',num2str(DB_output(i,ii))]; % Initialisation fo the string to be sent to the MySQL Database
        end
        database_str = [database_str,');'];
        mysql(database_str)
    end
    disp('Writing into Database finished.')
    mysql('close')
    disp('Finished exporting py-curves')
 
disp('---------------------------------------------------------------------')

%% Constitutive model Database
% Possibility to add FE model input to the DB


end
