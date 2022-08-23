function plot_spring_params(copcat_input_name, vars)
%%
Color1=prism(256);
Color2=lines(256);
[~,~,raw1] = xlsread(copcat_input_name);
datestr1_ls={'2022_07_15_22_55_08'};
try
    datestr1_ls = unique(raw1(:,2)); datestr1_ls(end)=[];
catch
    error('This is totally stupid error! For some reason, you need to restart matlab!');
end

dir1={fullfile(pwd, 'Plaxisfiles')};

%% User Input : Choose locations to plot - Put similar piles with different length after one another
folder1={'NGI_ADP_PC1_77_36m_1','NGI_ADP_PC1_77_44m_1'}; % Put similar piles with different length after one another

%% User Input : Use a set of parameters to plot
params_toe_multi_depth=table();

for jj=1:length(folder1)
    
    fig_name = replace(folder1{jj},{'NGI_ADP_','_short','_long','-compare'},'');
    matfilename1 = fullfile(dir1{1},[folder1{jj},'.mat']);
    S1 = load(matfilename1);
    D  = S1.Data_Base.Diameter(1);
    L  = S1.Data_Base.buriedLength(1);
    
    S2 = rmfield(S1,{'Data_Base','HB_max','K_HB_tan','MB_max','K_MB_tan','dummy_var'});
    T0 = struct2table(S2); T0=sortrows(T0,{'pu_depth'});
    
    G0 = T0.Gur_suA.*T0.su_A_ref; T0.G0=G0;
    su = T0.su_A_ref;
    
    % Actual values
    %         pu_depth  = T0.pu_depth;
    %         pu        = T0.pu;
    %         yu50      = T0.yu50;
    %         yu        = T0.yu;
    %         Mu        = T0.Mu;
    %         Mu_depth  = T0.Mu_depth;
    %         theta_u50 = T0.theta_u50;
    %         K_py_tan  = T0.K_py_tan;
    %         K_mt_tan  = T0.K_mt_tan;
    %         theta_u   = T0.theta_u;
    %         K_py_tan  = T0.K_py_tan;
    %         K_mt_tan  = T0.K_mt_tan;
    
    % Normalized values
    T1=table();
    T1.depth     = T0.pu_depth;
    T1.pu        = T0.pu./(su*D);
    T1.yu50      = T0.yu50.*G0./(D*su);
    T1.yu        = T0.yu.*G0./(D*su);
    T1.Mu        = T0.Mu./(su*D^2);
    T1.Mu_depth  = T0.Mu_depth;
    T1.theta_u50 = T0.theta_u50.*(G0./su);
    T1.theta_u   = T0.theta_u.*(G0./su);
    T1.K_py_tan  = T0.K_py_tan./G0;
    T1.K_mt_tan  = T0.K_mt_tan./(G0*D^2);
    
    T1.Mu(end) = T1.Mu(end)/D; % Additional base Moment normalization
    T1.pu(end) = T1.pu(end)/D; % Additional base shear normalization
    
    T1.K_py_50 = 0.5*T1.pu./T1.yu50;
    T1.K_mt_50 = 0.5*T1.Mu./T1.theta_u50;
    
    A = (0.5-(T1.yu50)./(T1.yu)).^2;
    B = (0.5-(T1.K_py_tan)./(T1.K_py_50))*(0.5-1);
    T1.n_py = B./(A+B);
    
    A = (0.5-T1.theta_u50./T1.theta_u).^2;
    B = (0.5-T1.K_mt_tan./T1.K_mt_50)*(0.5-1);
    T1.n_mt = B./(A+B);
    
    %% User Input: Remove undesirable points for fitting by setting them to nan
    cond1 = abs(T1.K_py_tan)>4*mean(abs(T1.K_py_tan)); T1.K_py_tan(cond1)=nan;
    cond1 = abs(T1.K_mt_tan)>8*mean((abs(T1.K_mt_tan))); T1.K_mt_tan(cond1)=nan;
    T1.n_py(abs(T1.n_py)>1)=nan; T1.n_py(T1.n_py<0)=nan;
    T1.n_mt(abs(T1.n_mt)>1)=nan; T1.n_mt(T1.n_mt<0)=nan;
    %%
    % Extract the toe springs
    params_toe=T1(end,:);
    T1(end,:)=[];
    if rem(jj,2)==1
        params_toe_multi_depth=table(); % For every odd folder number, reset the table.
    end
    
    params_toe_multi_depth(folder1(jj),:)=params_toe;
    % params.depth(:)={params.value{'depth'}}
    %params.depth{'n_m'}(end+1)=10
    
    %% User Input: filter points based on curve depth
    condition1=(T1.depth<30) & (T1.depth>0);
    
    depth_filtered = T1.depth(condition1);
    [~,idx_rotation_point]=min(abs(T1.depth-0.70*L)); % rotation point at 70% of pile length below ground surface
    
    nPoint=1; % Set some end points of the variables to nan, 
    T1(end-nPoint:end,2:end)={nan}; % First columnn is depth and shall never be nan
    
    %%
    params=table();
    params.name={'y_u';'y_u50';'p_u';'k_p';'k_p50';'n_p';...
        'tetam_u';'tetam_u50';'m_u';'k_m';'k_m50';'n_m';...
        'yB_u';'yB_u50';'HB_u';'k_H';'k_H50';'n_H';...
        'tetaMb_u';'tetaMb_u50';'MB_u';'k_Mb';'k_Mb50';'n_Mb'};
    
    %% py spring parameters
    params.Properties.RowNames=params.name;
    %params.value{'depth'} = T1.depth; % the same as Mu_depth
    params.value{'y_u'} = T1.yu;
    params.value{'y_u50'} = T1.yu50;
    params.value{'p_u'} = T1.pu;
    params.value{'k_p'} = T1.K_py_tan;
    params.value{'k_p50'} = T1.K_py_50;
    params.value{'n_p'} = T1.n_py;
    params.depth(:)={T1.depth};
    params({'y_u';'y_u50';'p_u';'k_p';'k_p50';'n_p'},'fit_type')={'lin';'exp';'exp';'lin';'lin';'lin'};
    params({'y_u';'y_u50';'p_u';'k_p';'k_p50';'n_p'},'curve_type') = {'py'};
    params({'y_u';'y_u50';'p_u';'k_p';'k_p50';'n_p'},{'lb','ub','x0'})={{nan}};
    
    %     lb=[-inf, -inf, -inf]; ub=-lb; x0=[1 1 1];
    %     params{'y_u',{'lb','ub','x0'}}  = {[0,-inf,-inf], [inf, 0, 0], [1,-1,-1]};       %params.xlabel{'y_u'}='y_{u,50}';
    %     params('y_u50',{'fit_type','lb','ub','x0'})= {'exp',lb, ub, x0};       %params.xlabel{'y_u'}='y_{u,50}';
    %     params('p_u',{'fit_type','lb','ub','x0'})  = {'exp',lb, ub, x0};       %params.xlabel{'y_u'}='y_{u,50}';
    %     params('k_p',{'fit_type','lb','ub','x0'})  = {'lin',lb, ub, x0};       %params.xlabel{'y_u'}='y_{u,50}';
    %     params('k_p50',{'fit_type','lb','ub','x0'})= {'lin',lb, ub, x0};       %params.xlabel{'y_u'}='y_{u,50}';
    %     params('n_p',{'fit_type','lb','ub','x0'})  = {'lin',lb, ub, x0};       %params.xlabel{'y_u'}='y_{u,50}';
    %% mt spring parameters
    params.value{'tetam_u'}   = T1.theta_u;
    params.value{'tetam_u50'} = T1.theta_u50;
    params.value{'m_u'}   = T1.Mu;
    params.value{'k_m'}   = T1.K_mt_tan;
    params.value{'k_m50'} = T1.K_mt_50;
    params.value{'n_m'} = T1.n_mt;
    params({'tetam_u';'tetam_u50';'m_u';'k_m';'k_m50';'n_m'},'fit_type')={'exp';'lin';'lin';'lin';'lin';'lin'};
    params({'tetam_u';'tetam_u50';'m_u';'k_m';'k_m50';'n_m'},'curve_type')={'mt'};
    params({'tetam_u';'tetam_u50';'m_u';'k_m';'k_m50';'n_m'},{'lb','ub','x0'})={{nan}};
    
    %% Hb spring parameters
    params.value{'yB_u'}   = params_toe_multi_depth.yu;
    params.value{'yB_u50'} = params_toe_multi_depth.yu50;
    params.value{'HB_u'}   = params_toe_multi_depth.pu;
    params.value{'k_H'}   =  params_toe_multi_depth.K_py_tan;
    params.value{'k_H50'} =  params_toe_multi_depth.K_py_50;
    params.value{'n_H'} = params_toe_multi_depth.n_py;
    params({'yB_u';'yB_u50';'HB_u';'k_H';'k_H50';'n_H'},'depth')={{params_toe_multi_depth.depth}};
    params({'yB_u';'yB_u50';'HB_u';'k_H';'k_H50';'n_H'},'fit_type')={'lin';'lin';'lin';'lin';'lin';'lin'};
    params({'yB_u';'yB_u50';'HB_u';'k_H';'k_H50';'n_H'},'curve_type')={'HB'};
    params({'yB_u';'yB_u50';'HB_u';'k_H';'k_H50';'n_H'},{'lb','ub','x0'})={{nan}};
    
    %% Mb spring parameters
    params.value{'tetaMb_u'}   = params_toe_multi_depth.theta_u;
    params.value{'tetaMb_u50'} = params_toe_multi_depth.theta_u50;
    params.value{'MB_u'}   = params_toe_multi_depth.Mu;
    params.value{'k_Mb'}   =  params_toe_multi_depth.K_mt_tan;
    params.value{'k_Mb50'} =  params_toe_multi_depth.K_mt_50;
    params.value{'n_Mb'} = params_toe_multi_depth.n_mt;
    params({'tetaMb_u';'tetaMb_u50';'MB_u';'k_Mb';'k_Mb50';'n_Mb'},'depth')={{params_toe_multi_depth.depth}};
    params({'tetaMb_u';'tetaMb_u50';'MB_u';'k_Mb';'k_Mb50';'n_Mb'},'fit_type')={'lin';'lin';'lin';'lin';'lin';'lin'};
    params({'tetaMb_u';'tetaMb_u50';'MB_u';'k_Mb';'k_Mb50';'n_Mb'},'curve_type')={'MB'};
    params({'tetaMb_u';'tetaMb_u50';'MB_u';'k_Mb';'k_Mb50';'n_Mb'},{'lb','ub','x0'})={{nan}};
    
    
    n_sp = length(vars);
    fig_num=1; % ceil(jj/2);
    hfig = figure(fig_num); hold on;
    hfig.Position = [680/5 678/5 560*2.5 420*1.5];
    hfig.Name = folder1{jj};
    DisplayName = replace(folder1{jj},{'NGI_ADP_'},''); DisplayName = replace(DisplayName,'_','-');

    for kk=1:length(vars)
        
        subplot(1,n_sp,kk); hold on;
        
        var1=vars{kk}; disp([var1, ' will be plotted !'])
        var_type=strsplit(var1,'_'); var_type=[var_type{1},'_',var_type{2}];
        xlabel(var_type,'Interpreter','none');
        
        curve_type = params.curve_type{var1}; % py, mt, HB, MB
        
        xdata=params.depth{var1};  % vertical axis
        ydata=params.value{var1};  % horizontal axis
        
        if length(xdata)>1 % For HB and MB, at least two points are needed
    
            h1 = plot(ydata, xdata); h1.Marker='.'; h1.Color=Color2(jj,:);
            h1.DisplayName = DisplayName;
            
            if kk==1
                %ylabel(['Fit was done over',num2str(depth_filtered(1)),'m to ',num2str(depth_filtered(end)),' m with z/D']);
            end
            
            fit_type  = params.fit_type{var1};
            lb=   params.lb{var1};
            ub=   params.ub{var1};
            x0=   params.x0{var1};
            
            normalization_length=D; % There is a mistake in copcat manual
            wdata=ones(length(xdata),1);
            x = fit_find(xdata,ydata,wdata, condition1, normalization_length, fit_type,lb,ub,x0);
            fit_plot(x, xdata, normalization_length, gca);
        end
        
        %% Plot the fits from copcat;

        if rem(jj,2)==0 || length(folder1)==1
            idx1 = []; iter=0;
            for mm=1:length(datestr1_ls)
                datestr1=datestr1_ls{mm};
                rows=1:size(raw1,1);
                cond1=strcmp(raw1(:,2),datestr1); idx1=rows(cond1); idx1=[idx1(1)-1, idx1]; % idx1(1)-1 is the row with variable names
                raw2 = raw1(idx1,:);
                cond2=cellfun(@(x) max(~isnan(x)),raw2(1,:)); raw2=raw2(:,cond2); VariableNames=raw2(1,:); VariableNames{1}='is_run';
                T5=cell2table(raw2(2:end,:),'VariableNames',VariableNames);
                
                N_layers=max(T5.layer_id);
                T5=T5(1:N_layers,:);
                %
                if all(T5.is_run)
                    iter=iter+1;
                    cond10 = startsWith(VariableNames,{'depth_top','depth_bot',var_type}); % p_u, k_p, n_p, y_u, ...
                    cond20 = ~endsWith(VariableNames,{'_F'}); % p_u, k_p, n_p, y_u, ...
                    cond1 = cond10 & cond20;
                    properties.Color=Color1(iter,:);
                    properties.LineStyle='-';
                    properties.Time=T5{:,'Time'};
                    x = T5{:,cond1}; fit_plot(x, xdata,normalization_length,gca, properties);
                end
            end
        end
        
        
    end
    
    if rem(jj,2)==0 || jj==length(folder1) % Only save after plotting the second pile length too
        
        hAxes=findobj(gcf,'Type','Axes');
        for nn=1:length(hAxes)
            set(hAxes(nn),'xminorgrid','on','yminorgrid','on'); grid(gca,'on');
            set(hAxes(nn),'XAxisLocation','Top','Ydir','reverse');
            hlines=findobj(hAxes(nn),'Type','Line');
            if ~isempty(hlines)
                XData=[hlines(1:1:end).XData]; YData=[hlines(1:1:end).YData];
                if isempty(XData); XData=inf; end
                if isempty(YData); YData=inf; end
                %xlim(hAxes(nn),[min(XData), max(XData)]);
                xlim(hAxes(nn),[0, max(XData)]);
                ylim(hAxes(nn),[0, max(YData)]);
            end
            
            if length(hlines)<15
                leg=legend(hAxes(nn));
                set(leg,'color','none','Location','southoutside');
            end
        end
        
        full_fig_name = fullfile(dir1{1},[curve_type,fig_name]);
        %         savefig(full_fig_name);
        %         print(gcf,full_fig_name,'-dpng','-r150');
    end
    
    
end