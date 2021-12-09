function [output, Ger_output] = plot_functions(element,pile,node,soil,plots,output,settings,i, loads, data,SF,Rd,nn,loc,Ger_output)
%% PLOTTING FUNCTION
% RECEIVES INPUT FROM MAIN.M TO MAKE PLOTS
%--------------------------------------------------------------------------
% CHANGE LOG
% 02.08.2013    MUOE - OPTIMIZING PLOT, SINCE CERTAIN DATA IS REDUNDANT
%--------------------------------------------------------------------------
%% Initial
%--------------------------------------------------------------------------
output.plot_node  = node.level<=soil.toplevel(1,1); % Determines which nodes are below seabed (embedded)
output.plot_level = node.level(output.plot_node);   % Sorts out the nodes below seabed
plots.node_rot_def= 1;                              % number of node to plot permanent rotations for, 1 = node at pile head

for k = 1:6
    save_name2{k}     = '0';                     % initialise filenames of plots, temporary plot to be inserted into database
end

pathname2 = [pwd,'\library\Output\Temporary_plots']; % temporary folder for plot to be loaded into database by perl, can be specified arbitrarily
filename = [data.location,'_',Ger_output.LC{nn},'_',soil.type,'_']; % general part of each filename

%% write documentation of revision settings for each position
% by use of the revision no. the applied loads, geometry and soil
% parameters can be backtracked within the MySQL database
% F = fopen([pathname,data.location,'_AppliedRevisions_',date,'.dat'],'wt');
% fprintf(F,'**********************************************************************************************************************************************\n');
% fprintf(F,'**************************************** Revisions applied for all checks at position %5s **************************************************\n',data.location);
% fprintf(F,'************************************************************* %s ******************************************************************\n',date);
%     fprintf(F,'   \n');
%     fprintf(F,'Global revision: %2d\n',data.revision.global);
%     fprintf(F,'   \n');
%     fprintf(F,'Soil revision: %2d\n',data.revision.soil);
%     fprintf(F,'   \n');
%     fprintf(F,'Structural revision: %2d\n',data.revision.structure);
%     fprintf(F,'   \n');
%     fprintf(F,'Load revision: %2d\n',data.revision.loads);
%     fprintf(F,'   \n');
% fprintf(F,'**********************************************************************************************************************************************\n');
% fclose(F);

%--------------------------------------------------------------------------
%% Plots
%--------------------------------------------------------------------------

if plots.res_vs_pilelength == 1 && i == length(pile.length) && soil.psf==0
    figure(1)
    subplot(1,2,1)
    hold on
    plot(Rd.cumulative_comp(:)/1000,-element.level(1:end-1,1))%,'-o',output.Rd(:,2),pile.length,'-o')
    plot([loads.Vc/1000 loads.Vc/1000],[-element.level(1,1) -element.level(end-1,1)], '--k')
    plot([0 Rd.cumulative_comp(pile.axial_elem)/1000],[pile.L-pile.extra_L pile.L-pile.extra_L], '--r')
    hold off
    legend('Axial capacity', 'Factored axial load', 'Selected emb. length')
    set(gca,'YDir','rev')
    xlabel('Axial Compression Capacity [MN]')
    ylabel('Depth below mudline [m]')
    xlim([0 100])
    ylim([0 70])
    xticks([0 25 50 75 100])
    subplot(1,2,2)
    Rd.cumulative_comp(find(Rd.cumulative_comp<0))=0;
    plot(loads.Vc./Rd.cumulative_comp, -element.level(1:end-1,1))
    hold on
    plot([0 loads.Vc./Rd.cumulative_comp(pile.axial_elem)],[pile.L-pile.extra_L pile.L-pile.extra_L], '--r')
    set(gca,'YDir','rev')
    xlabel('Axial utilisation ratio')
    ylabel('Depth below mudline [m]')
    xlim([0.2 1])
    ylim([0 70])
    xticks([0.2 0.4 0.6 0.8 1])
     legend('Axial utilisation ratio','Selected emb. length')
    saveas(gcf,[data.save_path,'\axial_capacity_',data.location,'.png'])
	save_name2{1} = [pathname2,'\Axial_capacity\',filename,'axial_capacity.png']; % temporary file for plot to be loaded into database by perl
    print(figure(1),save_name2{1}, '-r300','-dpng'); % temporary file for plot to be loaded into database by perl
    %close(1)
end

if plots.pilehead_vs_length == 1 && i == length(pile.length) && soil.psf==0
    figure(2)
    clf;
    asym = min(output.pilehead_rotation(1,:));
    change = (output.pilehead_rotation-asym)/asym;
	criterion = 20; %percentage of relative rotation against unreasonably long pile
	[Critpilelength, output] = DeterCritPileLength(criterion,change,output,pile,node); %function to get interpolated critical pile length
    
    Ger_output.CriticalPile(nn)=Critpilelength.value;
    
    subplot(2,1,1)
    hold on
    plot(pile.length,output.pilehead_rotation) 
    

    grid on
    xlabel('Pile length [m]')
    ylabel('Pile head rotation [{\circ}]')
    hold off
    subplot(2,1,2)
    hold on
    plot(pile.length,change*100)
    plot(Critpilelength.text.x,Critpilelength.text.y, 's','MarkerSize',4,'MarkerEdgeColor','b','MarkerFaceColor','b'); 
    text(Critpilelength.text.x,Critpilelength.text.y+0.01,Critpilelength.text.value);
    
    grid on
    xlabel('Pile length [m]')
    ylabel('Relative pile head rotation [%]')
    hold off
    saveas(gcf,[data.save_path,'\pilehead_vs_length_',data.location,'.png'])
	save_name2{2} = [pathname2,'\pilehead_vs_length\',filename,'pilehead_vs_length.png'];
	print(figure(2),'-dpng',save_name2{2}, '-r300')
    %close(2)
end

if plots.deflection_plot == 1  %%% && soil.psf==0
    Coord = output.Coord;
    figure(3)
    plot(output.hor_defl(1:end-1,end),Coord(1:end-1,2))
    xlabel('Horizontal deflection [m]')
    ylabel('Level [m vref]')
    grid on
    saveas(gcf,[data.save_path,'\deflection_plot_',data.location,'.png'])
	save_name2{3} = [pathname2,'\Deflection\',filename,'deflection.png'];
	print(figure(3),save_name2{3}, '-r300','-dpng');
    
    Ger_output.Deflection(nn)=max(output.hor_defl(1:end-1,end));
    
    %close(3)
end

% if plots.utilization_ratio == 1 && soil.psf==1
%     figure(4)
%     output.UR_plot = output.UR(output.plot_node(1:end-2),2); 
%     plot(output.UR_plot,output.plot_level(2:end-1,1)-pile.head)   
%     eval(['title(''Utilization plot, L = ' num2str(pile.L) ' '');'])
%     xlabel('Utilization ratio [-]')
%     ylabel('Embedded length [m]')
%     grid on
%     saveas(gcf,[data.save_path,'\utilization_ratio_',data.location,'.png'])
% 	save_name2{4} = [pathname2,'\Utilization_ratio\',filename,'utilization_ratio.png'];
% 	print(figure(4),'-dpng',save_name2{4}, '-r300')
%     %close(4)
% end



if plots.deflection_bundle == 1
    figure(100)
    hold all
    grid on
    plot(output.hor_defl(:,i),output.plot_level(:,1)-pile.head,'k')
    title('Deflection plot, bundle')
    xlabel('Deflection [m]')
    ylabel('Depth below pile head [m]')
end

if settings.toe_shear == 1
    if plots.toe_shear_graph == 1
        toe_plot_u = output.toe_plot_u;
        figure
       % ts = toe_shear(element,node,pile,abs(output.hor_defl(end)),length(element.model_py));
       [kHb_top kHb_bot] = secHBstiff(element,pile,[abs(output.hor_defl(end)) abs(output.hor_defl(end))],length(element.model_py)); 
       ts = kHb_bot*abs(output.hor_defl(end))*(element.level(end,1)-element.level(end,2)); 
        hold all
        grid on
        plot(toe_plot_u*1000,output.ts,'b-')
       plot(abs(output.hor_defl(end))*1000,ts,'ro')
        ylabel('Toe shear force [kN]')
        xlabel('Toe kick [mm]')
    end
end

if plots.permanent_rot_def == 1 && soil.psf==0
    if settings.n_max < 10
        disp('To get proper results for the permanent rotation, settings.n_max should be at least 10')
    end
    deflections = output.deflections;
    for ii = 1:settings.n_max % putting a column of zero deflection in the first column of the deflection matrix. This is done to ensure that the rotation plot passes through origo.
        output.deflections(:,settings.n_max+2-ii) = deflections(:,settings.n_max+1-ii);
    end
    output.deflections(:,1) = zeros(size(output.deflections,1),1); % putting in zero displacement for zero load
    F = linspace(0,1,settings.n_max+1); % this is valid because the load is applied in equally sized steps - the magnitude of the load doesn't matter, only the fact that it is applied in equally sized steps
    output.perm_rot = output.deflections(3*plots.node_rot_def,end)-F(end)/output.elasticstiff; % the permanent rotation
    figure(5)
    clf;
    hold on
    scatter(output.perm_rot*180/pi,F(1),'ro')
    plot(output.deflections(3*plots.node_rot_def,:)*180/pi,F,'-bx')
    plot([output.perm_rot output.deflections(3*plots.node_rot_def,end)]*180/pi,[F(1) F(end)],'-r')
    grid on
    eval(['title(''Permanent rotation plot, L = ' num2str(pile.L) ' '');'])
    eval(['xlabel(''Rotation of node ' num2str(plots.node_rot_def) ' [^o] '');'])
    ylabel('Load ratio [-]')
    eval(['legend(''Permanent rotation is ' num2str(output.perm_rot*180/pi,'%.3f') '^o '');'])
    
    Ger_output.Permanent_rot(nn)=output.perm_rot*180/pi;
    
    saveas(gcf,[data.save_path,'\permanent_rot_def_',data.location,'.png'])
	save_name2{5} = [pathname2,'\Perm_rot\',filename,'perm_rotation.png'];
	print(figure(5),'-dpng',save_name2{5}, '-r300');
    %close(5)
end

if plots.load_deflection == 1  && strcmp(settings.interface,'FAC')
    if settings.n_max < 50
        disp('To get proper results for the load-deflection and UR curve, settings.n_max should be at least 50; this is AO1 project specific')
    end
    deflections = output.deflections;
    for ii = 1:settings.n_max % putting a column of zero deflection in the first column of the deflection matrix. This is done to ensure that the displacement plot passes through origo.
        output.deflections(:,settings.n_max+2-ii) = deflections(:,settings.n_max+1-ii);
    end
    
 output.deflections(:,1) = zeros(size(output.deflections,1),1); % putting in zero displacement for zero load

 % this is valid because the load is applied in equally sized steps - the magnitude of the load doesn't matter, only the fact that it is applied in equally sized steps

 if soil.psf==1
 F = linspace(0,settings.max_load_ratio,settings.n_max+1)*loads.H; % DNV calc, material factors are applied
 elseif soil.psf==0
 F = linspace(0,settings.max_load_ratio,settings.n_max+1)*loads.H/SF.R_ult;  % bsh calc, resistance factor is applied
 end
 
 output.defl_plot=output.deflections(1,1:min([settings.n_max output.n_possible])+1)*1000;
 output.load_interp=F(1:min([settings.n_max output.n_possible])+1); 
 
%%%% finding horizontal load that that corresponds to displacement=10%D 
value=find(abs(output.defl_plot-pile.diameter*100)==(min(abs(output.defl_plot-pile.diameter*100))));

if length(value)==2
    value=value(1);
end

if output.defl_plot(value)<=pile.diameter*100
value1=value;
value2=value+1;
elseif output.defl_plot(value)>pile.diameter*100
value1=value-1;
value2=value;   
end

valuex=interp1([output.defl_plot(value1) output.defl_plot(value2)],[output.load_interp(value1) output.load_interp(value2)],pile.diameter*100);
FF_interp = F/loads.H; % factor multiplied to horizontal load for load-deflection plot
H_load_10_ratio=interp1([output.load_interp(value1) output.load_interp(value2)],[FF_interp(value1) FF_interp(value2)],valuex);
H_load_10 = H_load_10_ratio*loads.H; % load that corresponds to displacement=10%D
% matrix_name=['H_load_10_pos_',data.location,'.mat'];
% save(['output\rev0.1\mat_files/',matrix_name], 'H_load_10');
    
%interpolation to find the displacement that corresponds to loads.H UR
 load_10=find(abs(output.load_interp-loads.H)==(min(abs(output.load_interp-loads.H))));
if length(load_10)==2
    load_10=load_10(1);
end

if output.load_interp(load_10)<=loads.H
load1=load_10;
load2=load1+1;
elseif output.load_interp(load_10)>loads.H
load1=load_10-1;
load2=load_10;   
end

disp_10=interp1([output.load_interp(load1) output.load_interp(load2)],[output.defl_plot(load1) output.defl_plot(load2)],loads.H); 

%%%% plots

  if soil.psf==1
    
    figure(4)
    clf;
  output.H_load_10_dnv=H_load_10;
  output.UR_lat_dnv=loads.H/output.H_load_10_dnv;

x1=[0 pile.diameter*100];
y1=[output.H_load_10_dnv/1000 output.H_load_10_dnv/1000];
x2=[pile.diameter*100 pile.diameter*100];
y2=[0 output.H_load_10_dnv/1000];

 plot(pile.diameter*100,output.H_load_10_dnv/1000,'or')
 hold on
 plot(disp_10,loads.H/1000,'og')
 plot(output.deflections(1,1:min([settings.n_max output.n_possible])+1)*1000,F(1:min([settings.n_max output.n_possible])+1)/1000,'-kx')
 plot(x1,y1,':r')
 plot(x2,y2,':r')
 grid on
 eval(['title(''Pile head load-displacement curve, UR_D_N_V_G_L = ' num2str(output.UR_lat_dnv,'%0.2f') ' '');'])
 xlim([0 2000])
 legend('Lateral Capacity','ULS Factored Load','Location','SouthEast')
 ylabel('Horizontal load at mudline [MN]')
 xlabel('Pile head deflection [mm]')
 output.def_calibration = output.deflections(1,1:min([settings.n_max output.n_possible])+1)*1000;
 output.force_calibration = F(1:min([settings.n_max output.n_possible])+1);
 saveas(gcf,[data.save_path,'\utilization_ratio_',data.location,'_DNV.png'])
 save_name2{4} = [pathname2,'\Utilization_ratio\',filename,'utilization_ratio_DNV.png'];
 print(figure(4),'-dpng',save_name2{4}, '-r300'); 
  
    
 elseif soil.psf==0
      
 figure(4)
 clf;
 output.H_load_10_bsh=H_load_10;
 output.UR_lat_bsh=loads.H/output.H_load_10_bsh;

 x1=[0 pile.diameter*100];
 y1=[output.H_load_10_bsh/1000 output.H_load_10_bsh/1000];
x2=[pile.diameter*100 pile.diameter*100];
y2=[0 output.H_load_10_bsh/1000];

 plot(pile.diameter*100,output.H_load_10_bsh/1000,'or')
 hold on
 plot(disp_10,loads.H/1000,'og')
 plot(output.deflections(1,1:min([settings.n_max output.n_possible])+1)*1000,F(1:min([settings.n_max output.n_possible])+1)/1000,'-kx')
 plot(x1,y1,':r')
 plot(x2,y2,':r')
 grid on
 eval(['title(''Pile head load-displacement curve, UR_B_S_H = ' num2str(output.UR_lat_bsh,'%0.2f') ' '');'])
 xlim([0 2000])
 legend('Lateral Capacity','ULS Factored Load','Location','SouthEast')
 ylabel('Horizontal load at mudline [MN]')
 xlabel('Pile head deflection [mm]')
 output.def_calibration = output.deflections(1,1:min([settings.n_max output.n_possible])+1)*1000;
 output.force_calibration = F(1:min([settings.n_max output.n_possible])+1);
 saveas(gcf,[data.save_path,'\utilization_ratio_',data.location,'_BSH.png'])
 save_name2{4} = [pathname2,'\Utilization_ratio\',filename,'utilization_ratio_BSH.png'];
 print(figure(4),'-dpng',save_name2{4}, '-r300'); 
  
 end


%%%%%
    

% if plots.load_deflection == 1 
%     if settings.n_max < 50
%         disp('To get proper results for the load-deflection curve, settings.n_max should be at least 50')
%     end
%     deflections = output.deflections;
%     for ii = 1:settings.n_max % putting a column of zero deflection in the first column of the deflection matrix. This is done to ensure that the displacement plot passes through origo.
%         output.deflections(:,settings.n_max+2-ii) = deflections(:,settings.n_max+1-ii);
%     end
%     output.deflections(:,1) = zeros(size(output.deflections,1),1); % putting in zero displacement for zero load
%     F = linspace(0,settings.max_load_ratio,settings.n_max+1)*loads.H; % this is valid because the load is applied in equally sized steps - the magnitude of the load doesn't matter, only the fact that it is applied in equally sized steps
%     figure('visible','on')
%     hold on
%     plot(output.deflections(1,1:min([settings.n_max output.n_possible])+1)*1000,F(1:min([settings.n_max output.n_possible])+1),'-bx')
%     grid on
%     eval(['title(''Pile head load-displacement curve plot, L = ' num2str(pile.L) ' ' data.location ' '');'])
%     xlim([0 2000])
%     legend('1D Model','3D Model')
%     ylabel('Pile head load ratio H [-]')
%     xlabel('Pile head deflection [mm]')
%     
%     output.def_calibration = output.deflections(1,1:min([settings.n_max output.n_possible])+1)*1000;
%     output.force_calibration = F(1:min([settings.n_max output.n_possible])+1);
%     saveas(gcf,[data.save_path,'\load_deflection_',data.location,'.png'])
% 	save_name2{6} = [pathname2,'\load_deflection\',filename,'load_deflection.png'];
% 	print(figure(6),'-dpng',save_name2{6}, '-r300');
% 
% end


end

% if plots.moment_distribution == 1
%     figure('visible','on', 'Position', [10 10 900 600])
%     subplot(1,3,1)
%     plot(Es{1,1}(:,1,3),element.level(:,1)) %FKMV
% %     plot(soil.Mxy*1000, soil.levelPLAX, '-rx')
%     ylabel('Depth [m]')
%     xlabel('Moment [kNm]')
%     grid on
%     subplot(1,3,2)
%     plot(Es{1,1}(:,1,2),element.level(:,1)) %FKMV
% %     plot(soil.Mxy*1000, soil.levelPLAX, '-rx')
%     ylabel('Depth [m]')
%     xlabel('Shear [kNm]')
%     grid on
%     subplot(1,3,3)
%     plot(output.hor_defl(1:end-1,end),element.level(:,1)) %FKMV
% %     plot(soil.Mxy*1000, soil.levelPLAX, '-rx')
%     ylabel('Depth [m]')
%     xlabel('Displacement [kNm]')
%     grid on
% end
    if settings.update_db, database_write(output,settings,loads,data,plots,save_name2,pile,i,soil); end
    
end

function [Critpilelength, output] = DeterCritPileLength(criterion,change,output,pile,node) %SPSO 01-02-2019 having a function in the bottom of such a file here is different than what we typically have done in COSPIN. Typically we have one file for each subroutine. Both of course works, but maybe to keep it uniform throughout we should make a seperate file for this subroutine?
%created 16/01/2019 by GMME as update to COSPIN
    if change(1,1) < 0.1   % PNGI The correct Value is 0.1
        disp('--------------------------------------')
        disp('Critical pile length due to 10% criterium can''t be determined.')   %SPSO: 01-02-2019 Changed to write 10% and not 1%
        error('Investigated minimum pile length is too large.')  					%SPSO: 01-02-2019 Do we want the program to report an error and stop? We could consider to just 1) exit function + 2) report that critical pile length cannot be determined due to too large minimum pile length + 3) make typical critical pile length plot but without the marker for the critical pile length 
        
    else
        for kl = 1:criterion    % loop over several percentage criterion (10% ... 1%)
            ij = 2;     % counter
            crit_percent(kl) = (criterion - (kl-1))/100;  % criterion=10 % determine the decimal fraction corresponding to percentage (0.1 0.09 ... 0.01) %SPSO 01-02-2019 Changed decimal fraction in the brackets of explanation
            while change(1,ij) > crit_percent(kl)   % look for pile length until %-criterium is reached
                ij = ij + 1;
            end
            % interpolate critical pile length 
            output.pile_length_deter.crit_length(kl) = pile.length(ij-1) + (pile.length(ij) - pile.length(ij-1))...
                / (change(1,ij) - change (1,ij-1)) * (crit_percent(kl) - change(1,ij-1));
            % interpolate pile head deflection 
            output.pile_length_deter.pile_head_defl(kl) = output.hor_defl(1,ij-1) + (output.hor_defl(1,ij) - output.hor_defl(1,ij-1))...
                / (change(1,ij) - change (1,ij-1)) * (crit_percent(kl) - change(1,ij-1));
            % interpolate pile toe deflection 
            m = 1; % counter
            while -node.level(m) < pile.length(ij-1)
                m = m+1;
            end
            n = 1; % counter
            while -node.level(n) < pile.length(ij)
                n = n+1;
            end
            output.pile_length_deter.pile_toe_defl(kl) = output.hor_defl(m,ij-1) + (output.hor_defl(n,ij) - output.hor_defl(m,ij-1))...
                / (change(1,ij) - change (1,ij-1)) * (crit_percent(kl) - change(1,ij-1));
        end
    end

    kl = criterion-(criterion-1); % 1%-> kl = 10; 10% -> kl = 1; 5% -> kl = 6
    Critpilelength.value = output.pile_length_deter.crit_length(kl);
    Critpilelength.text.x = output.pile_length_deter.crit_length(kl)+0.1;
    Critpilelength.text.y = 0.105*100;
    Critpilelength.text.value = [' (',num2str(round(crit_percent(kl)*100)),'% : L = ',num2str(ceil(output.pile_length_deter.crit_length(kl)*10)/10),' m)'];	
end

	