function [output] = plot_functions(element,pile,node,soil,plots,output,settings,toe_plot_u,L,i,Coord, loads, data, Es)
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
%--------------------------------------------------------------------------
%% Plots
%--------------------------------------------------------------------------

if plots.res_vs_pilelength == 1 && i == length(pile.length)
    figure
    plot(output.Rd(:,1),pile.length,'-o',output.Rd(:,2),pile.length,'-o')
    legend('Tension','Compression')
    set(gca,'YDir','rev')
    xlabel('Design bearing capacity [kN]')
    ylabel('Pile length [m]')
    saveas(gcf,[data.save_path,'\res_vs_pilelength_',data.location,'.png'])
end

if plots.pilehead_vs_length == 1 && i == length(pile.length);
    figure
    asym = min(output.pilehead_rotation(1,:));
    change = (output.pilehead_rotation-asym)/asym;
	criterion = 10; %percentage of relative rotation against unreasonably long pile
	[Critpilelength, output] = DeterCritPileLength(criterion,change,output,pile,node); %function to get interpolated critical pile length
    subplot(2,1,1)
    plot(pile.length,output.pilehead_rotation) 
    grid on
    xlabel('Pile length [m]')
    ylabel('Pile head rotation [{\circ}]')
    subplot(2,1,2)
    hold on
    plot(pile.length,change*100)
    plot(Critpilelength.value,criterion, 's','MarkerSize',4,'MarkerEdgeColor','b','MarkerFaceColor','b') 
	text(Critpilelength.text.x,Critpilelength.text.y,Critpilelength.text.value)
    grid on
    xlabel('Pile length [m]')
    ylabel('Relative pile head rotation [%]')
    hold off
    saveas(gcf,[data.save_path,'\pilehead_vs_length_',data.location,'.png'])
end

if plots.deflection_plot == 1
    figure
    plot(output.hor_defl(1:end-1,end),Coord(1:end-1,2))
    xlabel('Horisontal deflection [m]')
    ylabel('Level [m vref]')
    grid on
    saveas(gcf,[data.save_path,'\deflection_plot_',data.location,'.png'])
end

if plots.utilization_ratio == 1
    figure
    output.UR_plot = output.UR(output.plot_node(1:end-2),2); 
    plot(output.UR_plot,output.plot_level(2:end-1,1)-pile.head)   
    eval(['title(''Utilization plot, L = ' num2str(L) ' '');'])
    xlabel('Utilization ratio [-]')
    ylabel('Embedded length [m]')
    grid on
    saveas(gcf,[data.save_path,'\utilization_ratio_',data.location,'.png'])
end

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

if plots.permanent_rot_def == 1
    if settings.n_max < 10
        disp('To get proper results for the permanent rotation, settings.n_max should be at least 10')
    end
    deflections = output.deflections;
    for ii = 1:settings.n_max % putting a column of zero deflection in the first column of the deflection matrix. This is done to ensure that the rotation plot passes through origo.
        output.deflections(:,settings.n_max+2-ii) = deflections(:,settings.n_max+1-ii);
    end
    output.deflections(:,1) = zeros(size(output.deflections,1),1); % putting in zero displacement for zero load
    F = linspace(0,1,settings.n_max+1); % this is valid because the load is applied in equally sized steps - the magnitude of the load doesn't matter, only the fact that it is applied in equally sized steps
    perm_rot = output.deflections(3*plots.node_rot_def,end)-F(end)/output.elasticstiff; % the permanent rotation
    figure('visible','on')
    hold on
    scatter(perm_rot*180/pi,F(1),'ro')
    plot(output.deflections(3*plots.node_rot_def,:)*180/pi,F,'-bx')
    plot([perm_rot output.deflections(3*plots.node_rot_def,end)]*180/pi,[F(1) F(end)],'-r')
    grid on
    eval(['title(''Permanent rotation plot, L = ' num2str(L) ' '');'])
    eval(['xlabel(''Rotation of node ' num2str(plots.node_rot_def) ' [^o] '');'])
    ylabel('Load ratio [-]')
    eval(['legend(''Permanent rotation is ' num2str(perm_rot*180/pi,'%.3f') '^o '');'])
    saveas(gcf,[data.save_path,'\permanent_rot_def_',data.location,'.png'])
end

if plots.load_deflection == 1
    if settings.n_max < 50
        disp('To get proper results for the load-deflection curve, settings.n_max should be at least 50')
    end
    deflections = output.deflections;
    for ii = 1:settings.n_max % putting a column of zero deflection in the first column of the deflection matrix. This is done to ensure that the displacement plot passes through origo.
        output.deflections(:,settings.n_max+2-ii) = deflections(:,settings.n_max+1-ii);
    end
    output.deflections(:,1) = zeros(size(output.deflections,1),1); % putting in zero displacement for zero load
    F = linspace(0,settings.max_load_ratio,settings.n_max+1)*loads.H; % this is valid because the load is applied in equally sized steps - the magnitude of the load doesn't matter, only the fact that it is applied in equally sized steps
    figure('visible','on')
    hold on
    plot(output.deflections(1,1:min([settings.n_max output.n_possible])+1)*1000,F(1:min([settings.n_max output.n_possible])+1),'-bx')
    grid on
    eval(['title(''Pile head load-displacement curve plot, L = ' num2str(L) ' ' data.location ' '');'])
    xlim([0 2000])
    legend('1D Model','3D Model')
    ylabel('Pile head load ratio H [-]')
    xlabel('Pile head deflection [mm]')
    
    output.def_calibration = output.deflections(1,1:min([settings.n_max output.n_possible])+1)*1000;
    output.force_calibration = F(1:min([settings.n_max output.n_possible])+1);
    saveas(gcf,[data.save_path,'\load_deflection_',data.location,'.png'])

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

end

function [Critpilelength, output] = DeterCritPileLength(criterion,change,output,pile,node) %SPSO 01-02-2019 having a function in the bottom of such a file here is different than what we typically have done in COSPIN. Typically we have one file for each subroutine. Both of course works, but maybe to keep it uniform throughout we should make a seperate file for this subroutine?
%created 16/01/2019 by GMME as update to COSPIN
    if change(1,1) < 0.1
        disp('--------------------------------------')
        disp('Critical pile length due to 10% criterium can''t be determined.')   %SPSO: 01-02-2019 Changed to write 10% and not 1%
        error('Investigated minimum pile length is too large.')  					%SPSO: 01-02-2019 Do we want the program to report an error and stop? We could consider to just 1) exit function + 2) report that critical pile length cannot be determined due to too large minimum pile length + 3) make typical critical pile length plot but without the marker for the critical pile length 
        
    else
        for kl = 1:10    % loop over several percentage criterion (10% ... 1%)
            ij = 2;     % counter
            crit_percent(kl) = (10 - (kl-1))/100;   % determine the decimal fraction corresponding to percentage (0.1 0.09 ... 0.01) %SPSO 01-02-2019 Changed decimal fraction in the brackets of explanation
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

    kl = 10-(criterion-1); % 1%-> kl = 10; 10% -> kl = 1; 5% -> kl = 6
    Critpilelength.value = output.pile_length_deter.crit_length(kl);
    Critpilelength.text.x = output.pile_length_deter.crit_length(kl)+0.1;
    Critpilelength.text.y = 0.105*100;
    Critpilelength.text.value = [' (',num2str(round(crit_percent(kl)*100)),'% : L = ',num2str(ceil(output.pile_length_deter.crit_length(kl)*10)/10),' m)'];	
end