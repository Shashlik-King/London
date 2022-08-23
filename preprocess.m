% Preprocess script
% author - MUJI

clc; clear; close all; printflag=0;
addpath (genpath('library'));  
addpath (genpath('excel'));
%% Input
[settings] = initialise_preprocess();

%% Read & Write mat files
get_spring_soil_params(settings.folder_name);

%% Plot springs
plot_spring_params(settings.copcat_input_name, settings.vars)

%% Plot curve pairs
plot_curve_pairs(settings.num_depths)