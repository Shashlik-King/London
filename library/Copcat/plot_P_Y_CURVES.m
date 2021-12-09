function plot_P_Y_CURVES(calibration,Global_Data_total,CallModels,object_layers,spring_type)
%% Preallocation
NumberofGeometry=size(CallModels,2);
Number_figure=0;
%% Folder creating for output saving
OutputFolder = 'output';   % Folder path name only
if exist(OutputFolder,'dir') == 0
    mkdir(OutputFolder);                          % Folder path for saving plots 
end

for Geo=1:NumberofGeometry
    
    OutputFolder = ['output\',CallModels{Geo}];   % Folder path name only
    if exist(OutputFolder,'dir') == 0
        mkdir(OutputFolder);                          % Folder path for saving plots 
    end

    saveFolder = ['output\',CallModels{Geo},'\reaction_curves'];   % Folder path name only
    if exist(saveFolder,'dir') == 0
        mkdir(saveFolder);                          % Folder path for saving plots 
    end
    
    if spring_type==0
        saveFolder = ['output\',CallModels{Geo},'\reaction_curves\p_y'];   % Folder path name only
        if exist(saveFolder,'dir') == 0
            mkdir(saveFolder);                          % Folder path for saving plots 
        end
    elseif spring_type==1
        saveFolder = ['output\',CallModels{Geo},'\reaction_curves\m_t'];   % Folder path name only
        if exist(saveFolder,'dir') == 0
            mkdir(saveFolder);                          % Folder path for saving plots 
        end
    elseif spring_type==2
        saveFolder = ['output\',CallModels{Geo},'\reaction_curves\Hb'];   % Folder path name only
        if exist(saveFolder,'dir') == 0
            mkdir(saveFolder);                          % Folder path for saving plots 
        end
    elseif spring_type==3
        saveFolder = ['output\',CallModels{Geo},'\reaction_curves\Mb'];   % Folder path name only
        if exist(saveFolder,'dir') == 0
            mkdir(saveFolder);                          % Folder path for saving plots 
        end
    end

%% Plotting
    for jj=1:size(calibration.level,2)
        Global_Data=Global_Data_total(Geo).(calibration.level{jj});
      
        for unit=1:size(object_layers,2)
            nameOfUnit=['soil',num2str(object_layers(unit))];
            if ~isempty(Global_Data.(nameOfUnit).Selected_index.Cospin_idx)
                Number_figure= Number_figure+1;
                figure(Number_figure)
                hold on
                text=['Geometry No. = ',char(CallModels(Geo)),'soil layer: ',nameOfUnit];
                title(text)
                n=size(Global_Data.(nameOfUnit).depthElem,1)+1;
                cm = jet (n);
                
                for iii=1:n-1
                    txt = ['depth  = ',num2str(-Global_Data.(nameOfUnit).depthElem(iii,1))];
                    plot(Global_Data.(nameOfUnit).SimulX(iii,:),Global_Data.(nameOfUnit).SimulY(iii,:),'color',cm(iii,:),'DisplayName',txt);
                    hold on
                    plot(Global_Data.(nameOfUnit).obserX(iii,:),Global_Data.(nameOfUnit).obserY(iii,:),'Marker','o','color',cm(iii,:),'DisplayName',txt);
                    hold on
                    % plot(Global_Data(unit).obserX(iii,:),Global_Data(unit).Asso_simul(iii,:),'Marker','d','color',cm(iii,:),'DisplayName',txt);
                    xlim([0 max(Global_Data.(nameOfUnit).obserX(iii,:))])
                end
                
                if spring_type==0
                    ylabel('P[kN]/m')
                    xlabel('y[m]')
                elseif spring_type==1
                    ylabel('distributed moment[kN.m]/m')
                    xlabel('Theta[m]')
                elseif spring_type==2
                    ylabel('Base Shear[kN]/m')
                    xlabel('y[m]')
                elseif spring_type==3
                    ylabel('Base Moment[kN]/m')
                    xlabel('y[m]')
                    
                end
                hold off
                legend show
                saveas(gcf,[saveFolder,'\Unit_',nameOfUnit,'_', calibration.level{jj},'.png'])
%                 close gcf
            end
        end
    end
end
end
