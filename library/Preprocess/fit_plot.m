function [] = fit_plot(fit_params,xdata,depth_norm_length,ax1,properties)

C= depth_norm_length;

for ii=1:size(fit_params,1)
    
    x=fit_params(ii,3:end);
    
    if ~isempty(x)
        
        cond1=xdata>=fit_params(ii,1) & xdata<=fit_params(ii,2);
        xlb=max(xdata(cond1));
        xub=min(xdata(cond1));
        xdata_fit=linspace(xlb,xub,200);
        
        if size(x,2)==3
            
            ydata_fit = (x(1)+x(2)*exp(x(3)*xdata_fit/C));
            
        elseif size(x,2)==2
            
            ydata_fit = x(1)*xdata_fit/C + x(2);
            
        elseif size(x,2)==1
            
            ydata_fit = 0* xdata_fit/C + x;
            
        end
        
        h100 = plot(ax1, ydata_fit,xdata_fit,'--'); h100.LineWidth=1.1;
        
        hlines = findobj(ax1,'Type','Line'); hlines=flipud(hlines); 
        str1 = strcat('; ',cellstr(num2str(x','%.3g'))); str2 = [str1{:}]; 
        str2 = replace(str2,' ',''); str2 = replace(str2,';','; ');
        str2(1:2)=[];

        
        if ~exist('properties','var')
            h100.Color=hlines(end-1).Color;
        else
            h100.Color=properties.Color;
            h100.LineStyle=properties.LineStyle;
            Label=replace(properties.Time{ii}(6:end),'_','-');
            str2 = [Label, '\newline', str2]; 
        end
        
        h100.DisplayName=str2;

        
    else
        
        warning('No parameters were found in the copcat out.xlsx');
        
    end
    
end






