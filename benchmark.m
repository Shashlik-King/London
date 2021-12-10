%% BENCHMARKING 
% Script comparing the benchmark model of the original version to the checked out version from the repo
clc; close all; clear all;
cprintf('black','Benchmarking initiated \n');
cprintf('black','---------------------------------------------------------------------- \n');
%% Run Inverse model of new version
% system('taskkill /F /IM EXCEL.EXE');
copyfile('excel\COPCAT_input.xlsm', 'excel\temp','f') % move COPCAT input to a temporary folder
copyfile('benchmark\COPCAT_input_benchmark_reac_curv.xlsm', 'excel\COPCAT_input.xlsm','f')
Inverse_Model % run Inverse model
copyfile('benchmark\COPCAT_input_benchmark_pile_resp.xlsm', 'excel\COPCAT_input.xlsm','f')
Inverse_Model % run Inverse model
copyfile('excel\temp\COPCAT_input.xlsm', 'excel','f')

%% test 2
%% Pile response benchmarking
path_benchmark_ref  = 'benchmark\';                         % path for the reference datasets
path_benchmark_new  = 'output\benchmark\data\pile_response\';             % path for the newly ran datasets
files = {'deflection_along_pile_D_10','deflection_along_pile_D_200','moment_D_10','moment_D_200','shear_D_10','shear_D_200','load_applied_at_mudline_D_10','displacement_at_mudline_D_10','load_applied_at_mudline_D_200','displacement_at_mudline_D_200'}; % list fo files used for comparison
for i = 1:size(files,2)
    %% Read benchmark model and new model
    file_name_ref   = [path_benchmark_ref,files{i},'.txt']; % total path for reference dataset
    file_name_new   = [path_benchmark_new,files{i},'.txt']; % total path for new dataset
    reference       = importdata(file_name_ref);            % import of reference dataset
    new             = importdata(file_name_new);            % import of new dataset
    
    %% Calculate error
    error.response{i,1}       = (new - reference) ./ reference; % calculate error for each discretised element/value
    error.response{i,1}(isnan(error.response{i,1}))=0;
    total_error.response{i,1} = sum(sum(error.response{i,1}));  % calculate total error for file analysed
    cprintf('black',['Total error results for ',files{i}, ' are:']);
    if total_error.response{i,1} == 0
        cprintf('green', 'Acceptable. \n');
    else
        cprintf('red', 'Not acceptable. \n');
    end
end

global_error.response = sum([total_error.response{1:end,1}]);
cprintf('black','Benchmarking test results for pile response are:');
if global_error.response == 0
    cprintf('green', 'Acceptable.  \n');
else
    cprintf('red', 'Not acceptable.  \n');
end
cprintf('black','Benchmarking for pile response is complete \n');
cprintf('black','---------------------------------------------------------------------- \n');


%% Reaction curve benchmarking
files = {'p','p_toe','m','m_toe','y','y_toe','teta','teta_toe'}; % list fo files used for comparison
path_benchmark_new  = 'output\benchmark\data\reaction_curves\';             % path for the newly ran datasets
for i = 1:size(files,2)
    %% Read benchmark model and new model
    file_name_ref   = [path_benchmark_ref,files{i},'.txt'];   % total path for reference dataset
    file_name_new   = [path_benchmark_new,files{i},'.txt']; % total path for new dataset
    reference       = importdata(file_name_ref);            % import of reference dataset
    new             = importdata(file_name_new);            % import of new dataset
    
    %% Calculate error
    error.reaction{i,1}       = (new - reference) ./ reference; % calculate error for each discretised element/value
    error.reaction{i,1}(isnan(error.reaction{i,1}))=0;
    total_error.reaction{i,1} = sum(sum(error.reaction{i,1})); % calculate total error for file analysed
    cprintf('black',['Total error results for ',files{i}, ' are:']);
    if total_error.reaction{i,1} == 0
        cprintf('green', 'Acceptable. \n');
    else
        cprintf('red', 'Not acceptable. \n');
    end
end

global_error.reaction = sum([total_error.reaction{1:end,1}]);
cprintf('black','Benchmarking test results for reaction curves are:');
if global_error.reaction == 0
    cprintf('green', 'Acceptable.  \n');
else
    cprintf('red', 'Not acceptable.  \n');
end
cprintf('black','Benchmarking for reaction curves is complete \n');
cprintf('black','---------------------------------------------------------------------- \n');
%% Save benchmark results 
writematrix([total_error.response{1:end,1}],'total_error_response.txt','Delimiter','tab')
writematrix([total_error.reaction{1:end,1}],'total_error_reaction.txt','Delimiter','tab')