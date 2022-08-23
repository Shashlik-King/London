function get_spring_soil_params(folder1)

%% User Input
printflag=0;
dir1={fullfile(pwd, 'Plaxisfiles')};

lineStyles = {'-','--','-.',':','-','--','-.','-','--','-.',':','-','--','-.','-','--','-.',':','-','--','-.','-','--','-.',':','-','--','-.','-','--','-.',':','-','--','-.','-','--','-.',':','-','--','-.','-','--','-.',':','-','--','-.','-','--','-.',':','-','--','-.','-','--','-.',':','-','--','-.','-','--','-.',':','-','--','-.'};
lgndstr=replace(folder1,'_','-');
cmap=lines(250);

%% Initialize mat files

for jj=1:length(folder1)
    matfilename1 = fullfile(dir1{1},folder1{jj});
    dummy_var = 1;
    save(matfilename1,'dummy_var');
end

%% Base shear
filename1={'Base shear D_10.csv','Base shear D_200.csv'};

for ii=1:length(filename1)
    
    figure(1);
    subplot(1,2,ii); hold on;
    
    for jj=1:length(folder1)
        
        fullfilename=fullfile(dir1{1},folder1{jj},filename1{ii});
        inp=csvread(fullfilename);
%         disp_level=filename1{1}(end-7:end-4);
%         inp_HB.(disp_level)=inp;
        
        %lgndstr=[folder1{jj},' - ',filename1{ii}(1:end-4)]; lgndstr(lgndstr=='_')=' ';
        X = inp(2,:); Y=inp(1,:)*1;
        plot(X,Y,'DisplayName',lgndstr{jj});
        ylabel('Base shear [kN]'); xlabel('m');
        
        HB_max=max(abs(Y));
        %KB= max(abs(Y))/max(abs(X));
        KB= abs(Y(5)/X(5));
        matfilename1 = fullfile(dir1{1},folder1{jj});
        
        if contains(filename1{ii},'D_10')
            save(matfilename1,'HB_max','-append');
        elseif contains(filename1{ii},'D_200')
            K_HB_tan = KB;
            save(matfilename1,'K_HB_tan','-append');
        end
        
    end
    
    set(gca,'Xdir','reverse')
    leg=legend; set(leg,'Color','none','location','northeast');
    if printflag==1; printname='Base shear'; print(gcf, printname,'-dpng','-r150'); savefig(gcf,printname); end
end


%% Base moment
filename1={'Base moment D_10.csv','Base moment D_200.csv'};

for ii=1:length(filename1)
    
    figure(2);
    subplot(1,2,ii); hold on;
    
    for jj=1:length(folder1)
        
        fullfilename=fullfile(dir1{1},folder1{jj},filename1{ii});
        inp=csvread(fullfilename);
        
        %lgndstr=[folder1{jj},' - ',filename1{ii}(1:end-4)]; lgndstr(lgndstr=='_')=' ';
        
        X = inp(2,:); Y=inp(1,:)*1;
        plot(X,Y,'DisplayName',lgndstr{jj});
        ylabel('Base moment [kNm]'); xlabel('[rad]');
        
        MB_max=max(abs(Y));
        %KB= max(abs(Y))/max(abs(X));
        KB= abs(Y(5)/X(5));
        matfilename1 = fullfile(dir1{1},folder1{jj});
        
        if contains(filename1{ii},'D_10')
            save(matfilename1,'MB_max','-append')
        elseif contains(filename1{ii},'D_200')
            K_MB_tan = KB;
            save(matfilename1,'K_MB_tan','-append');
        end
        
    end
    
    set(gca,'Xdir','reverse')
    leg=legend; set(leg,'Color','none','location','northeast');
    if printflag==1; printname='Base moment'; print(gcf,printname ,'-dpng','-r150'); savefig(gcf,printname); end
    
end


%% depth profiles of soil reactions: M-theta curves
filename1={'M-thetaCurves D_10.csv','M-thetaCurves D_200.csv'};
filename2={'Base moment D_10.csv','Base moment D_200.csv'};

for ii=1:length(filename1)
    figure(ii+10); hold on;
    
    for jj=1:length(folder1)
        
        %Cstr='bkrg';
        
        fullfilename=fullfile(dir1{1},folder1{jj},filename1{ii});
        inp1=csvread(fullfilename); Counter=0;
        
        fullfilename=fullfile(dir1{1},folder1{jj},filename2{ii}); % Add Base Shear
        inp2=csvread(fullfilename); 
        
        inp=[zeros(1,size(inp2,2));inp2;inp1]; inp(1,1)=inp1(1,3);
        
        Mu = [];  Mu_depth=[];  theta_u50 = []; K_mt=[]; theta_u=[];
        
        for kk=1:1:size(inp,1)/3-1
            curveDepth=inp(1+(kk-1)*3,1);
            titleStr=[folder1{jj},' - ',filename1{ii}(1:end-4)]; titleStr(titleStr=='_')=' ';
            lgndstr1=[num2str(curveDepth)]; lgndstr1(lgndstr1=='_')=' '; %lgndstr(lgndstr=='D ')='D/';
            
            
            if curveDepth <=0 && curveDepth>=-100
                Counter=Counter+1;
                Theta=inp(3+(kk-1)*3,:); DistMoment=inp(2+(kk-1)*3,:)*1;
                plt1=plot(Theta,DistMoment,'Linestyle',lineStyles{jj},'DisplayName',lgndstr1);
                plt1.Color=cmap(Counter,:);
                plt1.LineWidth=1;
                
                X=abs(Theta); Y=abs(DistMoment); Y=cummax(Y);
                cond1 = [1, diff(Y)]> 0; % remove points with the same p value
                X=X(cond1); Y=Y(cond1); plt2=plot(X.*sign(Theta(cond1)),Y.*sign(DistMoment(cond1)),'Linestyle',lineStyles{jj},'DisplayName',lgndstr1); plt2.Color='b';
                Ymid=max(Y)/2;
                
                idx1 = find(Y==Y(end),1);
                if idx1==length(Y)
                    Y_step = max(abs(Y))/10; Y_stepwise = round(Y/Y_step,0)*Y_step;
                    idx1 = find(Y_stepwise==Y_stepwise(end),1);
                    plt1=plot(X.*sign(Theta(end)),Y_stepwise.*sign(DistMoment(end)),'Linestyle',lineStyles{jj},'DisplayName',lgndstr1); plt1.Color='b';
                end
                
                Mu(kk,1)=max(abs(DistMoment));
                Mu_depth(kk,1)=-curveDepth;
                theta_u50(kk,1)=interp1(Y,X, Ymid);
                %K_mt(kk,1) = max(abs(DistMoment))/max(abs(Theta));
                K_mt(kk,1) = abs(DistMoment(5)/Theta(5));
                theta_u(kk,1)= X(idx1);

                %plot(theta_u50(kk,jj)*sign(Theta(end)),Ymid*sign(DistMoment(end)),'o','Color', plt1.Color);
                plot([theta_u50(kk,1),theta_u(kk,1)]*sign(Theta(end)),[Ymid,Y(idx1)]*sign(DistMoment(end)),'o','Color', plt1.Color);

            end
            
        end
        
        matfilename1 = fullfile(dir1{1},folder1{jj});
        
        if contains(filename1{ii},'D_10')
            save(matfilename1,'Mu','Mu_depth','theta_u50','theta_u','-append')
        elseif contains(filename1{ii},'D_200')
            K_mt_tan = K_mt;
            save(matfilename1,'K_mt_tan','-append');
        end
        
    end
    
    leg=legend;%title(leg,legTitle,'FontWeight','normal');
    
    set(gca,'Xdir','reverse')
    
    ylabel('Moment kNm/m'); xlabel('[rad]');
    %xlim([0,xlim_ls(ii)]);
    
    titleStr=filename1{ii}(1:end-4);titleStr(titleStr=='_')=' '; title(titleStr)
    set(leg,'Color','none','location','best','box','off');
    if printflag==1; printname=filename1{ii}(1:end-4); print(gcf,printname,'-dpng','-r150'); savefig(gcf,printname); end
    
end

%% depth profiles of soil reactions: p-y curves
%figure(5);
filename1={'pYCurves D_10.csv','pYCurves D_200.csv'};
filename2={'Base shear D_10.csv','Base shear D_200.csv'};

for ii=1:length(filename1)
    hfig = figure(ii+20); hold on;
    hfig.Position = [680*.1 678*.1 560 420*1.5];
    
    for jj=1:length(folder1)
        
        %Cstr='bkrg';
        
        fullfilename=fullfile(dir1{1},folder1{jj},filename1{ii});
        inp1=csvread(fullfilename); Counter=0;
        
        fullfilename=fullfile(dir1{1},folder1{jj},filename2{ii}); % Add Base Shear
        inp2=csvread(fullfilename); 
        
        inp=[zeros(1,size(inp2,2));inp2;inp1]; inp(1,1)=inp1(1,3);
        
        pu =[]; pu_depth=[]; yu50=[]; K_py=[]; yu=[];
        
        for kk=1:1:size(inp,1)/3-1
            curveDepth=inp(1+(kk-1)*3,1);
            titleStr=[folder1{jj},' - ',filename1{ii}(1:end-4)]; titleStr(titleStr=='_')=' ';
            lgndstr1=[num2str(curveDepth)]; lgndstr1(lgndstr1=='_')=' '; %lgndstr(lgndstr=='D ')='D/';
            
            
            if curveDepth <=0 && curveDepth>=-100
                Counter=Counter+1;
                ylateral=inp(3+(kk-1)*3,:); plateral=inp(2+(kk-1)*3,:)*1;
                plt1=plot(ylateral,plateral,'Linestyle',lineStyles{jj},'DisplayName',lgndstr1);
                plt1.Color=cmap(Counter,:); plt1.LineWidth=1;
                
                
                X=abs(ylateral); Y=abs(plateral); Y=cummax(Y);
                cond1 = [1, diff(Y)]> 0; % remove points with the same p value
                X=X(cond1); Y=Y(cond1); %plt1=plot(X.*sign(ylateral(cond1)),Y.*sign(plateral(cond1)),'Linestyle',lineStyles{jj},'DisplayName',lgndstr1); plt1.Color='b';
                Ymid=max(Y)/2;
                
                idx1 = find(Y==max(Y),1);
                if idx1==length(Y)
                    Y_step = max(abs(Y))/10; Y_stepwise = round(Y/Y_step,0)*Y_step;
                    idx1 = find(Y_stepwise==Y_stepwise(end),1);
                    plt1=plot(X.*sign(ylateral(end)),Y_stepwise.*sign(plateral(end)),'Linestyle',lineStyles{jj},'DisplayName',lgndstr1); plt1.Color='b';
                end
                
                pu(kk,1)=max(abs(plateral));
                pu_depth(kk,1)=-curveDepth;
                yu50(kk,1)=interp1(Y, X, Ymid);
                yu(kk,1)= X(idx1);
                %K_py(kk,1) = max(abs(plateral))/max(abs(ylateral));
                K_py(kk,1) = abs(plateral(5)/ylateral(5));
                
                plot([yu50(kk,1),yu(kk,1)]*sign(ylateral(end)),[Ymid,Y(idx1)]*sign(plateral(end)),'o','Color', plt1.Color);

            end
            
        end
        
        
        matfilename1 = fullfile(dir1{1},folder1{jj});
        
        if contains(filename1{ii},'D_10')
            save(matfilename1,'pu','pu_depth','yu50','yu','-append')
        elseif contains(filename1{ii},'D_200')
            K_py_tan = K_py;
            save(matfilename1,'K_py_tan','-append');
        end
        
        
    end
    %     plt2=plot(nan(2,2),'k'); plt2(1).LineStyle=lineStyles{1}; plt2(2).LineStyle=lineStyles{2};
    %     lgndstr0=folder1; %lgndstr(lgndstr=='_')=' ';
    %     for mm=1:length(lgndstr0); lgndstr1=lgndstr0{mm}; lgndstr1(lgndstr1=='_')=' '; lgndstr2(mm)={lgndstr1}; end
    %     legend(plt2,lgndstr2);
    leg=legend;%title(leg,legTitle,'FontWeight','normal');
    title(titleStr);
    set(gca,'YaxisLocation','origin','XaxisLocation','origin')
    
    ylabel('Force kN/m'); xlabel('[m]');
    %xlim([0,xlim_ls(ii)]);
    titleStr=filename1{ii}(1:end-4);titleStr(titleStr=='_')=' '; title(titleStr,'Interpreter','none')
    set(leg,'Color','none','location','best','box','off');
    if printflag==1; printname=filename1{ii}(1:end-4); print(gcf, printname,'-dpng','-r150'); savefig(gcf,printname); end
    
end


%% Get soil profile properties when the material model is NGI-ADP

for jj=1:length(folder1)
    
    figure(100); hold on;
    
    filename1 = fullfile(dir1{1},folder1{jj},'Data_Base.csv');
    T10=table();
    T10=readtable(filename1);
    matfilename1=fullfile(dir1{1},folder1{jj});
    load(matfilename1); depth_q = pu_depth; % T10.depth_mid;
    
    %% Calcuate depths
    T10.depth_bot=cumsum(T10.t_i);
    T10.depth_top=[0; T10.depth_bot(1:end-1)];
    T10.depth_mid=0.5*(T10.depth_bot+T10.depth_top);
    T10 = movevars(T10,{'depth_top','depth_bot','depth_mid'},'After','t_i');
    
    depth1  = transpose([T10.depth_top, T10.depth_bot]); depth2=depth1(:);
    %% Calculate sig_v
    % x1=1:10; x2=movmean(x1,2); out1=[x1;x2]; % 1rst element is irrelevent in movmean !
    Gam_kN_m3_mean=T10.gamma;       % average of unit weight at the bottom and top of the layer
    layer_thickness=T10.t_i;
    sig_v_eff_layerBottom = layer_thickness.*(Gam_kN_m3_mean-10);
    T10.sigV_eff_bot = cumsum(sig_v_eff_layerBottom);
    T10.sig_v_eff_top = [0; T10.sigV_eff_bot(1:end-1)];
    T10.sig_v_eff_mid = (T10.sigV_eff_bot+T10.sig_v_eff_top)/2;
    % sig_h_eff = sig_v_eff.*T1.K0;
    % sig_m_eff = (sig_v_eff+2*sig_h_eff)/3;
    
    %% Interpolate Su G_su
    subplot(1,3,1);
    hold on; grid('on'); box('on');
    set(gca,'Ydir','reverse','xminorgrid','on','yminorgrid','on','Xaxislocation','top');
    
    var_name='su_A_ref'; % Gur_suA, su_A_ref
    var_top=T10.(var_name); var_bot=T10.(var_name);
    var1    = transpose([var_top, var_bot]); var2 = var1(:);
    h1= plot(var2,depth2,'-o');
    h1.DisplayName = 'From Plaxis DataBase';
    
    [var_q]=interp_var(depth2, var2, depth_q); su_A_ref = var_q;
    h2= plot(var_q,depth_q,'-o'); h2.DisplayName = replace(folder1{jj},'_','-');
    
    xlim([0,inf]);
    xlabel('su_A_ref','Interpreter','none');
    
    %%
    subplot(1,3,2);
    hold on; grid('on'); box('on');
    set(gca,'Ydir','reverse','xminorgrid','on','yminorgrid','on','Xaxislocation','top');
    
    var_name='Gur_suA';
    var_top=T10.(var_name); var_bot=T10.(var_name);
    var1    = transpose([var_top, var_bot]); var2 = var1(:);
    h1= plot(var2,depth2,'-o');
    h1.DisplayName = 'From Plaxis DataBase.xlsx';
    
    [var_q]=interp_var(depth2, var2, depth_q);  Gur_suA=var_q;
    h2= plot(var_q,depth_q,'-o'); h2.DisplayName = replace(folder1{jj},'_','-');
    
    xlim([0,inf]);
    xlabel('Gur_suA','Interpreter','none');
    
    %% Interpolate sig_v
    subplot(1,3,3);
    hold on; grid('on'); box('on');
    set(gca,'Ydir','reverse','xminorgrid','on','yminorgrid','on','Xaxislocation','top');
    
    var_top=T10.sig_v_eff_top; var_bot=T10.sigV_eff_bot;
    var1    = transpose([var_top, var_bot]); var2 = var1(:);
    h1= plot(var2,depth2,'-o');
    h1.DisplayName = 'From Plaxis DataBase.xlsx';
    
    [var_q]=interp_var(depth2, var2, depth_q); sig_v_eff=var_q;
    
    h2= plot(var_q,depth_q,'-o'); h2.DisplayName = replace(folder1{jj},'_','-');
    
    xlim([0,inf]);
    xlabel('sig_v_eff','Interpreter','none');
    
    %%
    Data_Base = T10;
    save(matfilename1,'Data_Base','sig_v_eff','Gur_suA','su_A_ref','-append');
    
end
end
