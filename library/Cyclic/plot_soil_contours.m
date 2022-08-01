function plot_soil_contours(CSR, gamma,batch_name,location)

           figure 
           [X,Y] = meshgrid(CSR(:,1),CSR(:,2));
            contour(X,Y,gamma ,[0.1, 0.5 , 2 , 5, 10, 15], 'ShowText','on');

           set(gca,'XScale', 'log')
           xlabel('N')
           ylabel('CSR')
           title(batch_name)
             saveFolder = ['output\',location,'\Soil_Contours'];   % Folder path name only
            if exist(saveFolder,'dir') == 0
                mkdir(saveFolder);                          % Folder path for saving plots 
            end
            saveas(gcf,[saveFolder,'\' ,batch_name,'.png'])
end