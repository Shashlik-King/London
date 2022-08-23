function plot_curve_pairs(num_depths)
%% User Input
fig_name='figure-1'; % fig name
datestr1='2022_07_20_21_24_17'; % folder name in which the fig file is saved
num_depths=2; % how many depths to compare

%%
%dir1='C:\Users\Butterfly\Documents\copcat_out';
dir1={fullfile('C:\Users',getenv('username'),'Documents','copcat_out',datestr1)};


hfig = openfig(fullfile(dir1{1},fig_name));
hlines=findobj(gcf,'Type', 'Line');
hlines = flipud(hlines);


YData_all=[hlines(1:end-6).YData];
XData_all=[hlines(2:2:end-6).XData];

if isempty(YData_all)
    YData_all=[hlines(2:end).YData];
    XData_all=[hlines(2:end).XData];
end

Ylim = [0, max(YData_all)*1.1];
Xlim = [0, max(XData_all)*1.3];


MarkerTypes={'o','none'};
Color(1:2:256*2,:)=lines(256);
Color(2:2:256*2,:)=lines(256);
%Color=lines(256);

iter = 1;
idx1=[];

for ii=1:length(hlines)
    
    XData = hlines(ii).XData;
    YData = hlines(ii).YData;
    DisplayName = replace(hlines(ii).DisplayName,{'depth = '},'');
    
    MarkerType=MarkerTypes{rem(ii,2)+1};
    
    idx1(ii) = ceil(ii/(num_depths*2)); % plots some depths together
    hfig = figure(idx1(ii)+100); hold on;
    hfig.Position = [680/10 678/10 560*1 420*1.5];
    
    set(gca,'xminorgrid','on','yminorgrid','on'); grid(gca,'on'); box(gca,'on');
    
    if ii>1
        if idx1(ii)==idx1(ii-1)
            iter=iter+1;
        else
            iter=1;
        end
    end
    
    h1 = plot(XData,YData);
    h1.DisplayName = DisplayName;
    h1.LineWidth = 1;
    h1.Marker = MarkerType; h1.MarkerSize=4;
    h1.Color = Color(iter,:);
    leg = legend(); set(leg,'Location','South','Color','None','NumColumns',2);
    title(leg,'depth [m]')
    
    xlim(Xlim);
    ylim(Ylim);
    %     xlabel('y [m]')
    %     ylabel('p [kN/m]');
    
    
    if ii>1 && iter==1
        fullname1 = fullfile(dir1{1},[fig_name, '-',num2str( idx1(ii-1),'%03d')]);
        print(figure(idx1(ii-1)+100),fullname1,'-dpng','-r100')
    end
    
end


fullname1 = fullfile(dir1{1},[fig_name, '-',num2str( idx1(end),'%03d')]);
print(figure(idx1(end)+100),fullname1,'-dpng','-r100')
