function [settings] = initialise_preprocess()
% Read excel file
[~, ~, raw]             = xlsread('COPCAT_input.xlsm','Pre-process Exchange','B3:C8');
[~, ~, raw2]             = xlsread('COPCAT_input.xlsm','Pre-process_locations','A2:C2000');
% Allocate variables
settings.folder_name        = raw2{:,2}();
settings.copcat_input_name  = raw{2,2};
% settings.folder_sand        = raw{3,2};
% settings.folder_clay        = raw{4,2};
settings.vars               = raw{5,2};
settings.num_depths         = raw{6,2};

% Make string variables into cell arrays
settings.folder_name = textscan(settings.folder_name,'%s','Delimiter',',');
settings.folder_name = settings.folder_name{1};
% settings.folder_sand = textscan(settings.folder_sand,'%s','Delimiter',',')';
% settings.folder_sand = settings.folder_sand{1};
% settings.folder_clay = textscan(settings.folder_clay,'%s','Delimiter',',')';
% settings.folder_clay = settings.folder_clay{1};
settings.vars = textscan(settings.vars,'%s','Delimiter',',')';
settings.vars = settings.vars{1};

end