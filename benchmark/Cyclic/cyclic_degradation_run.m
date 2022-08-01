function [utilisation] = cyclic_degradation_run(variable,loadcase,object_layers,PYcreator,CallModels,Weight,PLAX,calibration,scour,soil,pile,loads,settings,~,PYcreator_stiff,var_name,~,constant,con_name,~,Stratigraphy,Database,Apply_Direct_springs,Cyclic_concept,Markov,Input)

%% Input definitions
[variable,constant]=Homo_Layered_Var(variable,constant,object_layers,Stratigraphy);
% Nrun_forward=0;
% NumberofGeometry=size(CallModels,2);
% Residual=[];
interest_node = Cyclic_concept.interest_nodes;


%% Run of COSPIN for all load combinations
% matrix for each load level is created

for Geo=1:size(CallModels,2)    % Run over the number of plaxis model
    markow.num=Markov.(CallModels{Geo}).num;

    if Cyclic_concept.Markov_switch==1
        for level=1:size(markow.num,1)   % Run over the  load level of each models 
            %% Normal cyclic run
            for min_max = 1:4 % run for mean + range & mean - range
                if min_max == 1 % min
                    loadcase.H = markow.num(level,4) - markow.num(level,3)/2;
                    loadcase.M = -markow.num(level,2) - markow.num(level,1)/2;
                elseif min_max == 2 % max
                    loadcase.H = markow.num(level,4) + markow.num(level,3)/2;
                    loadcase.M = -markow.num(level,2) + markow.num(level,1)/2;
                elseif min_max == 3 % max
                    loadcase.H = markow.num(level,4) - markow.num(level,3)/2;
                    loadcase.M = -markow.num(level,2) + markow.num(level,1)/2;
                elseif min_max == 4 % max
                    loadcase.H = markow.num(level,4) + markow.num(level,3)/2;
                    loadcase.M = -markow.num(level,2) - markow.num(level,1)/2;
                end

                [results] = run_COSPIN_utilisation(CallModels{Geo},Weight,PLAX.(CallModels{Geo}).(calibration.level{1}),PYcreator,variable,loadcase,object_layers,scour.(CallModels{Geo}), soil.(CallModels{Geo}), pile.(CallModels{Geo}), loads.(CallModels{Geo}), settings.(CallModels{Geo}),PYcreator_stiff,var_name,constant,con_name,Database,Apply_Direct_springs);
                disp(strcat('Calculation for index_' , num2str(level),'_', num2str(min_max)))
                utilisation{level,min_max} = results.utilisation;

                if Geo == 1 && level == 1 && min_max == 1
                    soil_type = results.soil_type;
                end
                clear results    
            end
        end
        
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

    for level=1:size(utilisation,1)   % Run over the  load level of each models
        for min_max = 1:4 % run for mean + range & mean - range
            for node_num = 1:size(utilisation{level,min_max},1)
                % node number
                final_table{node_num,1}(level,1) = node_num;
                % elevation
                final_table{node_num,1}(level,27:29) = [soil_type{node_num,2:4}]; % should be shifted
                % deflection
                final_table{node_num,1}(level,2) = utilisation{level,1}(node_num,1);
                final_table{node_num,1}(level,3) = utilisation{level,2}(node_num,1);
                final_table{node_num,1}(level,4) = utilisation{level,3}(node_num,1);
                final_table{node_num,1}(level,5) = utilisation{level,4}(node_num,1);
                % sign
                final_table{node_num,1}(level,6) = utilisation{level,1}(node_num,6);
                final_table{node_num,1}(level,7) = utilisation{level,2}(node_num,6);
                final_table{node_num,1}(level,8) = utilisation{level,3}(node_num,6);
                final_table{node_num,1}(level,9) = utilisation{level,4}(node_num,6);
                % p mn max
                final_table{node_num,1}(level,10) = utilisation{level,1}(node_num,2);
                final_table{node_num,1}(level,11) = utilisation{level,2}(node_num,2);
                final_table{node_num,1}(level,12) = utilisation{level,3}(node_num,2);
                final_table{node_num,1}(level,13) = utilisation{level,4}(node_num,2);
                % pu
                final_table{node_num,1}(level,14) = utilisation{level,4}(node_num,5);
                % sigma v
                final_table{node_num,1}(level,15) = utilisation{level,4}(node_num,4);
                % utilisation
                if strcmp(soil_type(node_num) , 'Clay')
                    final_table{node_num,1}(level,16) = final_table{node_num,1}(level,10) / final_table{node_num,1}(level,14);
                    final_table{node_num,1}(level,17) = final_table{node_num,1}(level,11) / final_table{node_num,1}(level,14);
                    final_table{node_num,1}(level,18) = final_table{node_num,1}(level,12) / final_table{node_num,1}(level,14);
                    final_table{node_num,1}(level,19) = final_table{node_num,1}(level,13) / final_table{node_num,1}(level,14);
                elseif strcmp(soil_type(node_num)  , 'Sand') && strcmp(Cyclic_concept.Sand_CSR  , 'Dash')
                    final_table{node_num,1}(level,16) = final_table{node_num,1}(level,10) / (final_table{node_num,1}(level,15) * pile.(CallModels{1,1}).diameter * Cyclic_concept.Ns) ;
                    final_table{node_num,1}(level,17) = final_table{node_num,1}(level,11) / (final_table{node_num,1}(level,15) * pile.(CallModels{1,1}).diameter * Cyclic_concept.Ns) ;
                    final_table{node_num,1}(level,18) = final_table{node_num,1}(level,12) / (final_table{node_num,1}(level,15) * pile.(CallModels{1,1}).diameter * Cyclic_concept.Ns) ;
                    final_table{node_num,1}(level,19) = final_table{node_num,1}(level,13) / (final_table{node_num,1}(level,15) * pile.(CallModels{1,1}).diameter * Cyclic_concept.Ns) ;
                elseif strcmp(soil_type(node_num)  , 'Sand') && strcmp(Cyclic_concept.Sand_CSR  , 'NGI')
                    final_table{node_num,1}(level,16) = final_table{node_num,1}(level,10) / final_table{node_num,1}(level,14);
                    final_table{node_num,1}(level,17) = final_table{node_num,1}(level,11) / final_table{node_num,1}(level,14);
                    final_table{node_num,1}(level,18) = final_table{node_num,1}(level,12) / final_table{node_num,1}(level,14);
                    final_table{node_num,1}(level,19) = final_table{node_num,1}(level,13) / final_table{node_num,1}(level,14);
                end
                % markov matrix of utilisation 
                [final_table{node_num,1}(level,20) , final_table{node_num,1}(level,21) ]  = max([final_table{node_num,1}(level,16) , final_table{node_num,1}(level,17) , final_table{node_num,1}(level,18) , final_table{node_num,1}(level,19)]) ;% max
                [final_table{node_num,1}(level,22) , final_table{node_num,1}(level,23) ] = min([final_table{node_num,1}(level,16) , final_table{node_num,1}(level,17) , final_table{node_num,1}(level,18) , final_table{node_num,1}(level,19)]) ;%min
                final_table{node_num,1}(level,24) = mean([final_table{node_num,1}(level,20) , final_table{node_num,1}(level,22) ]); % mean
                final_table{node_num,1}(level,25) = final_table{node_num,1}(level,20) - final_table{node_num,1}(level,22); % range
                % count
                final_table{node_num,1}(level,26) = markow.num(level,5);
            end
        end
    end

    save(strcat('output\',CallModels{Geo},'\markov_matrix\mat_files\final_table.mat'), 'final_table')
%     load(strcat('output\',CallModels{Geo},'\markov_matrix\mat_files\final_table.mat'));
    
%     load('C:\Users\FKMV\Desktop\New folder\output\markov_matrix\OSSC\mat_files\final_table.mat')
    for ii = 1:size(final_table,1)
        Table_data = final_table{ii,1};
        Table_name = strcat('output\',CallModels{Geo},'\markov_matrix\markov_matrix_per_node\Final_table_node_',num2str(ii),'.csv');
        Table_headings = {'Node number','Deflection 1 - sM','Deflection 2 - Sm','Deflection 3 - sm','Deflection 4 - SM','Deflection direction sign - sM','Deflection direction sign - Sm','Deflection direction sign - sm','Deflection direction sign - SM','p 1 - sM','p 1 - Sm','p 1 - sm','p 1 - SM','p_ult','sigma_v','Utilisation 1','Utilisation 2','Utilisation 3','Utilisation 4','Max utilisation','Max utilisation index','Min utilisation','Min utilisation index','Mean utilisation','Utilisation range','Number of cycles','Top elevation','Bottom elevation','Start of layer'};
        xlswrite(Table_name,Table_headings,'Sheet1','A1');
        xlswrite(Table_name,Table_data,'Sheet1','A2');
    end
    
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