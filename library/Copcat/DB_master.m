function [settings] = DB_master
%% MySQL Database settings
% Log-in information for the main MySQL Database used for all master versions and releases
settings.db_server          = 'DKLYCOPILOD1';       % Databse server
settings.db_user         	= 'owdb_user';          % Database user
settings.db_pass            = 'ituotdowdb';         % Database pass
settings.db_name            = 'owdb';               % Database name
settings.db_table           = 'COPCAT_Data_Base';   % Database table name
end