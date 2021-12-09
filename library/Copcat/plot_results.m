function plot_results(calibration,model,CallModels)

NumberofGeometry = size(CallModels,2);
Number_figure    = 0;
OutputFolder     = 'output';   % Folder path name only
if exist(OutputFolder,'dir') == 0
    mkdir(OutputFolder);                          % Folder path for saving plots 
end

for i = 1:NumberofGeometry
    OutputFolder = ['output\',CallModels{i}];   % Folder path name only
    if exist(OutputFolder,'dir') == 0
        mkdir(OutputFolder);                          % Folder path for saving plots 
    end

    saveFolder = ['output\',CallModels{i},'\pile_response'];   % Folder path name only
    if exist(saveFolder,'dir') == 0
        mkdir(saveFolder);                          % Folder path for saving plots 
    end
    
    for ii=1:size(calibration.level,2)
        
        if strcmp(calibration.involvment,'def') || strcmp(calibration.involvment,'mom') || strcmp(calibration.involvment,'def_mom')  || strcmp(calibration.involvment,'def_mom')  || strcmp(calibration.involvment,'def_mom_defmud')  ||  strcmp(calibration.involvment,'def_defmud')
            Number_figure=Number_figure+1;
            figure(Number_figure)
            
            hold on
            text=['Geometry No. = ',char(CallModels(i)),'under load',calibration.level{ii}];
            subplot(1,2,1)
            title(text)
            hold on
            plot(model(i).result(ii).moment(:,3),model(i).result(ii).moment(:,1),'-KX')
            plot(model(i).result(ii).moment(:,2),model(i).result(ii).moment(:,1), '-rx')
            ylabel('Depth [m]')
            xlabel('Moment [kNm]')
            grid on
            legend('COPCAT - 1D', 'PLAXIS - 3D','Location','southeast')
            
            subplot(1,2,2)
            hold on
            plot(model(i).result(ii).displacement(:,3),model(i).result(ii).displacement(:,1),'-KX')
            plot(model(i).result(ii).displacement(:,2),model(i).result(ii).displacement(:,1), '-rx')
            ylabel('Depth [m]')
            xlabel('Displacement m')
            grid on
            legend('COPCAT - 1D', 'PLAXIS - 3D','Location','northeast')
            hold off
            saveas(gcf,[saveFolder,'\def_mom_plot_', calibration.level{ii},'.png'])
        end
        
        if contains(calibration.involvment,'defmud')
            
            Number_figure=Number_figure+10;
            figure(Number_figure)
            text=['Geometry No. = ',char(CallModels(i)),'under load',calibration.level{ii}];
            plot(model(i).result(ii).load_displacement(:,1),(model(i).result(ii).load_displacement(:,3))/1000,'-KX')
            hold on
            plot(model(i).result(ii).load_displacement(:,1),(model(i).result(ii).load_displacement(:,2))/1000,'-rx')
            hold on
            
            simul_1=(model(i).result(ii).load_displacement(:,3))./1000;
            simul_2=simul_1(~isnan(simul_1));
            Asimul=trapz(simul_2);
            ref_1=model(i).result(ii).load_displacement(1:size(simul_2,1),2)/1000;
            ref_2=ref_1(~isnan(ref_1));
            Aref=trapz(ref_2);
            
            Adif=Aref-Asimul;
            Nehtha_1=(Aref-Adif)/Aref;
            
            title([text,' and Pisa Error = ',num2str(Nehtha_1)]) 
            ylabel('Force [MN]')
            xlabel('Displacement m')
            legend('COPCAT - 1D', 'PLAXIS - 3D','Location','northeast')
            hold off
            saveas(gcf,[saveFolder,'\load_disp_plot_', calibration.level{ii},'.png'])
        end
    end  
end
end