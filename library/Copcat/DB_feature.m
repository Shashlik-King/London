function [settings] = DB_feature
%% MySQL Database settings
% Log-in information for the main MySQL Database used for development branch
settings.db_server          = 'DKLYCOPILOD1';       % Databse server
settings.db_user         	= 'owdb_user';          % Database user
settings.db_pass            = 'ituotdowdb';         % Database pass
settings.db_name            = 'owdb';               % Database name
settings.db_table           = 'COPCAT_Data_Base';   % Database table name
end