function [utilisation] = cyclic_degradation_run_Zhang(variable,loadcase,object_layers,PYcreator,CallModels,Weight,PLAX,calibration,scour,soil,pile,loads,settings,~,PYcreator_stiff,var_name,~,constant,con_name,~,Stratigraphy,Database,Apply_Direct_springs,Cyclic_concept,Markov,Input)

%% Input definitions
[variable,constant]=Homo_Layered_Var(variable,constant,object_layers,Stratigraphy);
% interest_node = Cyclic_concept.interest_nodes;

%% Main loop
for Geo=1:size(CallModels,2)    % Run over the number of plaxis model
    %% Load all batches
    %find all batches used in the models
    batch_names = unique(soil.(CallModels{1,1}).degradation.batch);
    for i = 1:size(batch_names,1) % run for loop to load all batches
        CSR_N_axis_all{i,1}     = load(['Plaxisfiles\Batches\CSR_N_axis_',batch_names{i,1},'.mat']);
        gamma_matrix_all{i,1}   = load(['Plaxisfiles\Batches\gamma_matrix_',batch_names{i,1},'.mat']);
        multipliers_all{i,1}    = load(['Plaxisfiles\Batches\multipliers_',batch_names{i,1},'.mat']);
    end

    %% Change markov matrix
    markow.num=Markov.(CallModels{Geo}).num;
%     unique_markow = unique([markow.num(:,1) , markow.num(:,3)],'rows'); % Make unique Markov matrix
    unique_markow = unique(markow.num(:,1),'rows'); % Make unique Markov matrix
    for ii = 1:size(unique_markow(:,1),1)
%         unique_markow(ii,3) = sum(markow.num((unique_markow(ii,1) == markow.num(:,1) & unique_markow(ii,2) == markow.num(:,3)),5));% accumulate count
        unique_markow(ii,3) = sum(markow.num((unique_markow(ii,1) == markow.num(:,1) ),5));% accumulate count
        unique_markow(ii,2) = max(markow.num((unique_markow(ii,1) == markow.num(:,1) ),3));% accumulate count
    end
    markow.num = [unique_markow(:,1), zeros(size(unique_markow(:,1),1),1) , unique_markow(:,2), zeros(size(unique_markow(:,1),1),1) , unique_markow(:,3)];
    
    %% Initialise
    loadcase.H = markow.num(1,3)/2;
    loadcase.M = -markow.num(1,1)/2;
    multiplier_init  = ones(10000,2);
    [initialise_data] = run_COSPIN_utilisation_Zhang(CallModels{Geo},Weight,PLAX.(CallModels{Geo}).(calibration.level{1}),PYcreator,variable,loadcase,object_layers,scour.(CallModels{Geo}), soil.(CallModels{Geo}), pile.(CallModels{Geo}), loads.(CallModels{Geo}), settings.(CallModels{Geo}),PYcreator_stiff,var_name,constant,con_name,Database,Apply_Direct_springs,Input,multiplier_init);
    utilisation(1:size(markow.num,1),3) = {ones(size(initialise_data.utilisation,1),1)};
    multiplier(1:size(markow.num,1),1)  = {ones(size(initialise_data.utilisation,1),6)};
    N_eq(1:size(markow.num,1),1)        = {ones(size(initialise_data.utilisation,1),3)};
%     N_eq{1,1}(:,1)                      =  markow.num(1,5); %MDGI: initalization of Neq for the first parcel itr 0
    N_eq_new(1:size(markow.num,1),1)    = {ones(size(initialise_data.utilisation,1),3)};
    gamma(1:size(markow.num,1),1)       = {ones(size(initialise_data.utilisation,1),3)};
    utilisation_counter                 = zeros(size(initialise_data.utilisation,1),1);
    
    %% Markov run
    if Cyclic_concept.Markov_switch==1
        for level=1:size(markow.num,1)   % Run over the  load level of each models 
            if level == 1
                %% First parcel
                % 0th iteration
                loadcase.H = markow.num(level,3)/2;
                loadcase.M = -markow.num(level,1)/2;
                [results] = run_COSPIN_utilisation_Zhang(CallModels{Geo},Weight,PLAX.(CallModels{Geo}).(calibration.level{1}),PYcreator,variable,loadcase,object_layers,scour.(CallModels{Geo}), soil.(CallModels{Geo}), pile.(CallModels{Geo}), loads.(CallModels{Geo}), settings.(CallModels{Geo}),PYcreator_stiff,var_name,constant,con_name,Database,Apply_Direct_springs,Input,multiplier{level,1}(:,1:2));
                disp(strcat('Calculation for parcel no.' , num2str(level)))
                utilisation{level,1} = results.utilisation;
                for jj = 1:size(results.utilisation,1)
                    CSR_N_axis          = CSR_N_axis_all{strcmp(results.element.batch(jj),batch_names),1}.CSR_N_axis ;
                    gamma_matrix        = gamma_matrix_all{strcmp(results.element.batch(jj),batch_names),1}.gamma_matrix;
                    multipliers_graph   = multipliers_all{strcmp(results.element.batch(jj),batch_names),1}.batch;                    
                    if utilisation{level,1}(jj,3) > results.element.min_CSR(jj)
                        if utilisation_counter(jj) == 0
                            [gamma{level,1}(jj,2)]  = retrive_gamma(markow.num(level,5),utilisation{level,1}(jj,3),CSR_N_axis,gamma_matrix);
                            utilisation_counter(jj) = 1;
                        else
                        [gamma{level,1}(jj,1)] = retrive_gamma(markow.num(level,5),utilisation{level,1}(jj,3),CSR_N_axis,gamma_matrix);
                        [multiplier{level,1}(jj,1), multiplier{level,1}(jj,2)] = springs_modifier(multipliers_graph, 1, 1, N_eq{level,1}(jj,1));
                        end
                    end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % 1st iteration
                loadcase.H = markow.num(level,3)/2;
                loadcase.M = -markow.num(level,1)/2;
                [results] = run_COSPIN_utilisation_Zhang(CallModels{Geo},Weight,PLAX.(CallModels{Geo}).(calibration.level{1}),PYcreator,variable,loadcase,object_layers,scour.(CallModels{Geo}), soil.(CallModels{Geo}), pile.(CallModels{Geo}), loads.(CallModels{Geo}), settings.(CallModels{Geo}),PYcreator_stiff,var_name,constant,con_name,Database,Apply_Direct_springs,Input,multiplier{level,1}(:,3:4));
                disp(strcat('Calculation for parcel no.' , num2str(level)))
                utilisation{level,2} = results.utilisation;
                for jj = 1:size(results.utilisation,1)
                    CSR_N_axis     = CSR_N_axis_all{strcmp(results.element.batch(jj),batch_names),1}.CSR_N_axis ;
                    gamma_matrix   = gamma_matrix_all{strcmp(results.element.batch(jj),batch_names),1}.gamma_matrix;
                    multipliers_graph   = multipliers_all{strcmp(results.element.batch(jj),batch_names),1}.batch;   
                    if utilisation{level,2}(jj,3) > results.element.min_CSR(jj)
                        if utilisation_counter(jj) == 0
                            [gamma{level,1}(jj,2)]  = retrive_gamma(markow.num(level,5),utilisation{level,2}(jj,3),CSR_N_axis,gamma_matrix);
                            utilisation_counter(jj) = 1;
                        else
                            [N_eq_new{level,1}(jj,1),gamma{level,1}(jj,2),N_eq{level,1}(jj,1)]  = N_eq_calc(0,gamma{level,1}(jj,1),utilisation{level,1}(jj,3),markow.num(level,5),CSR_N_axis,gamma_matrix);
                            [multiplier{level,1}(jj,3), multiplier{level,1}(jj,4)] = springs_modifier(multipliers_graph, N_eq{level,1}(jj,1));
                        end
                    end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % 2nd iteration
                loadcase.H = markow.num(level,3)/2;
                loadcase.M = -markow.num(level,1)/2;
                [results] = run_COSPIN_utilisation_Zhang(CallModels{Geo},Weight,PLAX.(CallModels{Geo}).(calibration.level{1}),PYcreator,variable,loadcase,object_layers,scour.(CallModels{Geo}), soil.(CallModels{Geo}), pile.(CallModels{Geo}), loads.(CallModels{Geo}), settings.(CallModels{Geo}),PYcreator_stiff,var_name,constant,con_name,Database,Apply_Direct_springs,Input,multiplier{level,1}(:,5:6));
                disp(strcat('Calculation for parcel no.' , num2str(level)))
                utilisation{level,3} = results.utilisation;
                for jj = 1:size(results.utilisation,1)
                    CSR_N_axis     = CSR_N_axis_all{strcmp(results.element.batch(jj),batch_names),1}.CSR_N_axis ;
                    gamma_matrix   = gamma_matrix_all{strcmp(results.element.batch(jj),batch_names),1}.gamma_matrix;      
                    multipliers_graph   = multipliers_all{strcmp(results.element.batch(jj),batch_names),1}.batch;   
                    if utilisation{level,3}(jj,3) > results.element.min_CSR(jj)
                        if utilisation_counter(jj) == 0
                            [gamma{level,1}(jj,2)]  = retrive_gamma(markow.num(level,5),utilisation{level,3}(jj,3),CSR_N_axis,gamma_matrix);
                            utilisation_counter(jj) = 1;
                        else                        
                        [N_eq_new{level,1}(jj,1),gamma{level,1}(jj,3),N_eq{level,1}(jj,1)]  = N_eq_calc(0,gamma{level,1}(jj,2),utilisation{level,1}(jj,3),markow.num(level,5),CSR_N_axis,gamma_matrix);
                        [multiplier{level,1}(jj,5), multiplier{level,1}(jj,6)] = springs_modifier(multipliers_graph, N_eq{level,1}(jj,1));
                        end
                    end
                end
            else
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % 2nd parcel and beyond
                % 0th iteration
                loadcase.H = markow.num(level,3)/2;
                loadcase.M = -markow.num(level,1)/2;
                [results] = run_COSPIN_utilisation_Zhang(CallModels{Geo},Weight,PLAX.(CallModels{Geo}).(calibration.level{1}),PYcreator,variable,loadcase,object_layers,scour.(CallModels{Geo}), soil.(CallModels{Geo}), pile.(CallModels{Geo}), loads.(CallModels{Geo}), settings.(CallModels{Geo}),PYcreator_stiff,var_name,constant,con_name,Database,Apply_Direct_springs,Input,multiplier{level-1,1}(:,5:6));
                disp(strcat('Calculation for parcel no.' , num2str(level)))
                utilisation{level,1} = results.utilisation;
                for jj = 1:size(results.utilisation,1)
                    CSR_N_axis          = CSR_N_axis_all{strcmp(results.element.batch(jj),batch_names),1}.CSR_N_axis ;
                    gamma_matrix        = gamma_matrix_all{strcmp(results.element.batch(jj),batch_names),1}.gamma_matrix;
                    multipliers_graph   = multipliers_all{strcmp(results.element.batch(jj),batch_names),1}.batch;                   
                    if utilisation{level,1}(jj,3) > results.element.min_CSR(jj)
                        if utilisation_counter(jj) == 0
                            [gamma{level,1}(jj,1)]  = retrive_gamma(markow.num(level,5),utilisation{level,1}(jj,3),CSR_N_axis,gamma_matrix);
                            utilisation_counter(jj) = 1;
                        else                        
                        [N_eq_new{level,1}(jj,1),gamma{level,1}(jj,1),N_eq{level,1}(jj,1)]  = N_eq_calc(utilisation{level - 1,1}(jj,3),gamma{level-1,1}(jj,3),utilisation{level,1}(jj,3),markow.num(level,5),CSR_N_axis,gamma_matrix); 
                        [multiplier{level,1}(jj,1), multiplier{level,1}(jj,2)] = springs_modifier(multipliers_graph, N_eq{level,1}(jj,1));
                        end
                    end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
                % 1st iteration
                loadcase.H = markow.num(level,3)/2;
                loadcase.M = -markow.num(level,1)/2;
                [results] = run_COSPIN_utilisation_Zhang(CallModels{Geo},Weight,PLAX.(CallModels{Geo}).(calibration.level{1}),PYcreator,variable,loadcase,object_layers,scour.(CallModels{Geo}), soil.(CallModels{Geo}), pile.(CallModels{Geo}), loads.(CallModels{Geo}), settings.(CallModels{Geo}),PYcreator_stiff,var_name,constant,con_name,Database,Apply_Direct_springs,Input,multiplier{level,1}(:,1:2));
                disp(strcat('Calculation for parcel no.' , num2str(level)))
                utilisation{level,2} = results.utilisation;
                for jj = 1:size(results.utilisation,1)
                    CSR_N_axis     = CSR_N_axis_all{strcmp(results.element.batch(jj),batch_names),1}.CSR_N_axis ;
                    gamma_matrix   = gamma_matrix_all{strcmp(results.element.batch(jj),batch_names),1}.gamma_matrix; 
                    multipliers_graph   = multipliers_all{strcmp(results.element.batch(jj),batch_names),1}.batch;                                           
                    if utilisation{level,2}(jj,3) > results.element.min_CSR(jj)
                        if utilisation_counter(jj) == 0
                            [gamma{level,1}(jj,2)]  = retrive_gamma(markow.num(level,5),utilisation{level,2}(jj,3),CSR_N_axis,gamma_matrix);
                            utilisation_counter(jj) = 1;
                        else
                        [N_eq_new{level,1}(jj,2),gamma{level,1}(jj,2),N_eq{level,1}(jj,2)]  = N_eq_calc(utilisation{level - 1,1}(jj,3),gamma{level,1}(jj,1),utilisation{level,1}(jj,3),markow.num(level,5),CSR_N_axis,gamma_matrix);
                        [multiplier{level,1}(jj,3), multiplier{level,1}(jj,4)] = springs_modifier(multipliers_graph, N_eq{level,1}(jj,2));
                        end
                    end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
                % 2nd iteration
                loadcase.H = markow.num(level,3)/2;
                loadcase.M = -markow.num(level,1)/2;
                [results] = run_COSPIN_utilisation_Zhang(CallModels{Geo},Weight,PLAX.(CallModels{Geo}).(calibration.level{1}),PYcreator,variable,loadcase,object_layers,scour.(CallModels{Geo}), soil.(CallModels{Geo}), pile.(CallModels{Geo}), loads.(CallModels{Geo}), settings.(CallModels{Geo}),PYcreator_stiff,var_name,constant,con_name,Database,Apply_Direct_springs,Input,multiplier{level,1}(:,3:4));
                disp(strcat('Calculation for parcel no.' , num2str(level)))
                utilisation{level,3} = results.utilisation;
                for jj = 1:size(results.utilisation,1)
                    CSR_N_axis     = CSR_N_axis_all{strcmp(results.element.batch(jj),batch_names),1}.CSR_N_axis ;
                    gamma_matrix   = gamma_matrix_all{strcmp(results.element.batch(jj),batch_names),1}.gamma_matrix;   
                    multipliers_graph   = multipliers_all{strcmp(results.element.batch(jj),batch_names),1}.batch;                        
                    if utilisation{level,3}(jj,3) > results.element.min_CSR(jj)
                        if utilisation_counter(jj) == 0
                            [gamma{level,1}(jj,3)]  = retrive_gamma(markow.num(level,5),utilisation{level,3}(jj,3),CSR_N_axis,gamma_matrix);
                            utilisation_counter(jj) = 1;
                        else                        
                        [N_eq_new{level,1}(jj,3),gamma{level,1}(jj,3),N_eq{level,1}(jj,3)]  = N_eq_calc(utilisation{level - 1,1}(jj,3),gamma{level,1}(jj,2),utilisation{level,1}(jj,3),markow.num(level,5),CSR_N_axis,gamma_matrix);
                        [multiplier{level,1}(jj,5), multiplier{level,1}(jj,6)] = springs_modifier(multipliers_graph, N_eq{level,1}(jj,3));
                        end
                    end
                end
            end
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        main_folder = strcat('output\',CallModels{Geo});
        location_folder = strcat('output\',CallModels{Geo},'\markov_matrix');
        mat_folder = strcat('output\',CallModels{Geo},'\markov_matrix\mat_files');
        plot_folder = strcat('output\',CallModels{Geo},'\markov_matrix\plots');
        node_folder = strcat('output\',CallModels{Geo},'\markov_matrix\markov_matrix_per_node');
        
        if not(isfolder(main_folder))
            mkdir(main_folder)
        end
        if not(isfolder(location_folder))
            mkdir(location_folder)
        end
        if not(isfolder(mat_folder))
            mkdir(mat_folder)
        end
        if not(isfolder(plot_folder))
            mkdir(plot_folder)
        end
        if not(isfolder(node_folder))
            mkdir(node_folder)
        end
        
        save(strcat('output\',CallModels{Geo},'\markov_matrix\mat_files\utilisation.mat'), 'utilisation')
        save(strcat('output\',CallModels{Geo},'\markov_matrix\mat_files\soil_type.mat'), 'soil_type')       

%         save(strcat('output\markov_matrix\',CallModels{Geo},'\mat_files\utilisation.mat'), 'utilisation')
%         save(strcat('output\markov_matrix\',CallModels{Geo},'\mat_files\soil_type.mat'), 'soil_type')
    end
    addpath (genpath('output'));
    load(strcat('output\',CallModels{Geo},'\markov_matrix\mat_files\utilisation.mat'));
    load(strcat('output\',CallModels{Geo},'\markov_matrix\mat_files\soil_type.mat'));
    %% Final table creation per node

%     for level=1:size(utilisation,1)   % Run over the  load level of each models
%         for min_max = 1:4 % run for mean + range & mean - range
%             for node_num = 1:size(utilisation{level,min_max},1)
%                 % node number
%                 final_table{node_num,1}(level,1) = node_num;
%                 % elevation
%                 final_table{node_num,1}(level,27:29) = [soil_type{node_num,2:4}]; % should be shifted
%                 % deflection
%                 final_table{node_num,1}(level,2) = utilisation{level,1}(node_num,1);
%                 final_table{node_num,1}(level,3) = utilisation{level,2}(node_num,1);
%                 final_table{node_num,1}(level,4) = utilisation{level,3}(node_num,1);
%                 final_table{node_num,1}(level,5) = utilisation{level,4}(node_num,1);
%                 % sign
%                 final_table{node_num,1}(level,6) = utilisation{level,1}(node_num,6);
%                 final_table{node_num,1}(level,7) = utilisation{level,2}(node_num,6);
%                 final_table{node_num,1}(level,8) = utilisation{level,3}(node_num,6);
%                 final_table{node_num,1}(level,9) = utilisation{level,4}(node_num,6);
%                 % p mn max
%                 final_table{node_num,1}(level,10) = utilisation{level,1}(node_num,2);
%                 final_table{node_num,1}(level,11) = utilisation{level,2}(node_num,2);
%                 final_table{node_num,1}(level,12) = utilisation{level,3}(node_num,2);
%                 final_table{node_num,1}(level,13) = utilisation{level,4}(node_num,2);
%                 % pu
%                 final_table{node_num,1}(level,14) = utilisation{level,4}(node_num,5);
%                 % sigma v
%                 final_table{node_num,1}(level,15) = utilisation{level,4}(node_num,4);
%                 % utilisation
%                 if strcmp(soil_type(node_num) , 'Clay')
%                     final_table{node_num,1}(level,16) = final_table{node_num,1}(level,10) / final_table{node_num,1}(level,14);
%                     final_table{node_num,1}(level,17) = final_table{node_num,1}(level,11) / final_table{node_num,1}(level,14);
%                     final_table{node_num,1}(level,18) = final_table{node_num,1}(level,12) / final_table{node_num,1}(level,14);
%                     final_table{node_num,1}(level,19) = final_table{node_num,1}(level,13) / final_table{node_num,1}(level,14);
%                 elseif strcmp(soil_type(node_num)  , 'Sand') && strcmp(Cyclic_concept.Sand_CSR  , 'Dash')
%                     final_table{node_num,1}(level,16) = final_table{node_num,1}(level,10) / (final_table{node_num,1}(level,15) * pile.(CallModels{1,1}).diameter * Cyclic_concept.Ns) ;
%                     final_table{node_num,1}(level,17) = final_table{node_num,1}(level,11) / (final_table{node_num,1}(level,15) * pile.(CallModels{1,1}).diameter * Cyclic_concept.Ns) ;
%                     final_table{node_num,1}(level,18) = final_table{node_num,1}(level,12) / (final_table{node_num,1}(level,15) * pile.(CallModels{1,1}).diameter * Cyclic_concept.Ns) ;
%                     final_table{node_num,1}(level,19) = final_table{node_num,1}(level,13) / (final_table{node_num,1}(level,15) * pile.(CallModels{1,1}).diameter * Cyclic_concept.Ns) ;
%                 elseif strcmp(soil_type(node_num)  , 'Sand') && strcmp(Cyclic_concept.Sand_CSR  , 'NGI')
%                     final_table{node_num,1}(level,16) = final_table{node_num,1}(level,10) / final_table{node_num,1}(level,14);
%                     final_table{node_num,1}(level,17) = final_table{node_num,1}(level,11) / final_table{node_num,1}(level,14);
%                     final_table{node_num,1}(level,18) = final_table{node_num,1}(level,12) / final_table{node_num,1}(level,14);
%                     final_table{node_num,1}(level,19) = final_table{node_num,1}(level,13) / final_table{node_num,1}(level,14);
%                 end
%                 % markov matrix of utilisation 
%                 [final_table{node_num,1}(level,20) , final_table{node_num,1}(level,21) ]  = max([final_table{node_num,1}(level,16) , final_table{node_num,1}(level,17) , final_table{node_num,1}(level,18) , final_table{node_num,1}(level,19)]) ;% max
%                 [final_table{node_num,1}(level,22) , final_table{node_num,1}(level,23) ] = min([final_table{node_num,1}(level,16) , final_table{node_num,1}(level,17) , final_table{node_num,1}(level,18) , final_table{node_num,1}(level,19)]) ;%min
%                 final_table{node_num,1}(level,24) = mean([final_table{node_num,1}(level,20) , final_table{node_num,1}(level,22) ]); % mean
%                 final_table{node_num,1}(level,25) = final_table{node_num,1}(level,20) - final_table{node_num,1}(level,22); % range
%                 % count
%                 final_table{node_num,1}(level,26) = markow.num(level,5);
%             end
%         end
%     end

%     save(strcat('output\',CallModels{Geo},'\markov_matrix\mat_files\final_table.mat'), 'final_table')
%     load(strcat('output\',CallModels{Geo},'\markov_matrix\mat_files\final_table.mat'));
%     for ii = 1:size(final_table,1)
%         Table_data = final_table{ii,1};
%         Table_name = strcat('output\',CallModels{Geo},'\markov_matrix\markov_matrix_per_node\Final_table_node_',num2str(ii),'.csv');
%         Table_headings = {'Node number','Deflection 1 - sM','Deflection 2 - Sm','Deflection 3 - sm','Deflection 4 - SM','Deflection direction sign - sM','Deflection direction sign - Sm','Deflection direction sign - sm','Deflection direction sign - SM','p 1 - sM','p 1 - Sm','p 1 - sm','p 1 - SM','p_ult','sigma_v','Utilisation 1','Utilisation 2','Utilisation 3','Utilisation 4','Max utilisation','Max utilisation index','Min utilisation','Min utilisation index','Mean utilisation','Utilisation range','Number of cycles','Top elevation','Bottom elevation','Start of layer'};
%         xlswrite(Table_name,Table_headings,'Sheet1','A1');
%         xlswrite(Table_name,Table_data,'Sheet1','A2');
%     end
    
    %% Plotting of markow matrix of utilisation
%     for index=1:size(interest_node,1)
%         [~, node_number] = min(abs(( + str2double(interest_node{index}) + [soil_type{:,2}])));
%         markow.min_range = min(final_table{node_number,1}(:,25)); % range
%         markow.max_range = max(final_table{node_number,1}(:,25)); % range
%         markow.min_mean = min(final_table{node_number,1}(:,24)); % mean
%         markow.max_mean = max(final_table{node_number,1}(:,24)); % mean
%         markow.num_node=[final_table{node_number,1}(:,24), final_table{node_number,1}(:,25),final_table{node_num,1}(:,26)];
% 
% 
%         number_unique_1=str2double(Cyclic_concept.markov_plot_size(1,1)); %64
%         number_unique_2=str2double(Cyclic_concept.markov_plot_size(2,1)); %64
% 
%         xBin = linspace(markow.min_range,markow.max_range,number_unique_1); % range
%         yBin = linspace(markow.min_mean,markow.max_mean,number_unique_2); % mean
%         dx = abs(xBin(2)-xBin(1))/2; % range
%         dy = abs(yBin(2)-yBin(1))/2; % mean
% 
%         for x =1:length(xBin)
%             for y=1:length(yBin)
%                 selectx = markow.num_node(:,2)>xBin(x)-dx &markow.num_node(:,2)<=xBin(x)+dx; % range
%                 selecty = markow.num_node(:,1)>yBin(y)-dy & markow.num_node(:,1)<=yBin(y)+dy; % mean
%                 select = selectx & selecty;
%                 Z(y,x) = sum(markow.num(select,5));      %%#ok<SAGROW>
%             end
%         end
%         [X,Y] = meshgrid(xBin,yBin);
%         figure
%         scatterbar3(X,Y,Z,dy)
%         colormap(hsv)
%         xlabel('Utilisation ratio_{rng} [-]')
%         ylabel('Utilisation ratio_{avg} [-]')
%         zlabel('Number of cycles [-]')
%         grid on
%         print(gcf,'-dpng',strcat('output\',CallModels{Geo},'\markov_matrix\plots\','Node_number_',num2str(node_number),'_',num2str(soil_type{node_number,2}),'_MarkovMTRX.png'),'-r250') 
%     %     saveas(gcf,['output\','Node_number_',num2str(node_number),'_MarkovMTRX.png'])
%     end

    %% Plotting of markow matrix of load
%     for index=1:2 % for shear and for moment
%         if index == 1 % moment
%             markow.min_range = min(markow.num(:,1)); % range
%             markow.max_range = max(markow.num(:,1)); % range
%             markow.min_mean = min(markow.num(:,2)); % mean
%             markow.max_mean = max(markow.num(:,2)); % mean
%             markow.num_node=[markow.num(:,1), markow.num(:,2),markow.num(:,5)];
%             number_unique_1=unique(markow.num(:,1)); %64
%             number_unique_2=unique(markow.num(:,2)); %64
%         elseif index == 2 % shear
%             markow.min_range = min(markow.num(:,3)); % range
%             markow.max_range = max(markow.num(:,3)); % range
%             markow.min_mean = min(markow.num(:,4)); % mean
%             markow.max_mean = max(markow.num(:,4)); % mean
%             markow.num_node=[markow.num(:,3), markow.num(:,4),markow.num(:,5)];
%             number_unique_1=unique(markow.num(:,3)); %20
%             number_unique_2=unique(markow.num(:,4)); %10
%         end
% 
%         xBin = linspace(markow.min_range,markow.max_range,number_unique_1); % range
%         yBin = linspace(markow.min_mean,markow.max_mean,number_unique_2); % mean
%         dx = abs(xBin(2)-xBin(1))/2; % range
%         dy = abs(yBin(2)-yBin(1))/2; % mean
% 
%         for x =1:length(xBin)
%             for y=1:length(yBin)
%                 selectx = markow.num_node(:,2)>xBin(x)-dx &markow.num_node(:,2)<=xBin(x)+dx; % range
%                 selecty = markow.num_node(:,1)>yBin(y)-dy & markow.num_node(:,1)<=yBin(y)+dy; % mean
%                 select = selectx & selecty;
%                 Z(y,x) = sum(markow.num(select,5));      %%#ok<SAGROW>
%             end
%         end
%         [X,Y] = meshgrid(xBin,yBin);
%         figure
%         scatterbar3(X,Y,Z,dy)
%         colormap(hsv)
%         if index == 1
%             xlabel('Moment_range [-]')
%             ylabel('Moment mean [-]')
%         elseif index ==2
%             xlabel('Shear range [-]')
%             ylabel('Shear mean [-]')  
%         end
%         zlabel('Number of cycles [-]')
%         grid on
%         if index == 1
%             print(gcf,'-dpng',strcat('output\',CallModels{Geo},'\markov_matrix\plots\','Moment_MarkovMTRX.png'),'-r250') 
%         elseif index == 2
%             print(gcf,'-dpng',strcat('output\',CallModels{Geo},'\markov_matrix\plots\','Shear_MarkovMTRX.png'),'-r250') 
%         end
%     end
end
end