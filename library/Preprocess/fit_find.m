function [x] = fit_find(xdata,ydata,wdata, condition1, depth_norm_length, fit_type, lb,ub,x0)

%xdata_fit=linspace(0.5,max(xdata),200);
try
    xdata = xdata(condition1);
    ydata = ydata(condition1);
    wdata = wdata(condition1);
catch
    warning('The desired Condition1 can not be met! All curves are considered!')
end


ydata =ydata(~isnan(ydata));
xdata =xdata(~isnan(ydata));
wdata = wdata(~isnan(ydata));


C = depth_norm_length;

if strcmp(fit_type,'exp')
    if ~exist('lb','var') || any(isnan([lb, x0, ub])) % if lb, x0, ub are not defined or are nan
        warning('Boundaries and initial conditions were assumed. Check them!')
        lb=[-inf, -inf, -inf];
        ub=[inf, inf, inf];
        x0=5*[1,1,-.1];
    end
    
    
    options=optimset('MaxFunEvals',10*200*3);
    fun1 = @(x) sum((wdata.*(ydata-(x(1)+x(2)*exp(x(3)*xdata/C)))).^2);
    
    
    
    
    %x = fminsearch(fun1,5*[1,-1,-.1],options); x= round(x,3,'significant');
    % x = fmincon(fun,x0,A,b,Aeq,beq,lb,ub)
    
    
    
    x = minimize(fun1,x0, [],[], [],[], lb, ub); x= round(x,3,'significant');
    
    % p1 - is the final constant value with increasing depth
    % p2 > 0 - curve value increases with depth before reaching a constant value
    % p2 < 0 - curve vlaue decreases with depth before reaching a constant value
    % p3     - asymptotic curve value
    %     ydata_fit = (x(1)+x(2)*exp(x(3)*xdata_fit/depth_norm_length));
    
elseif strcmp(fit_type,'lin')
    
    x = polyfit(xdata/C,ydata,1);
    %     ydata_fit = x(1)*xdata_fit+x(2);
    
else
    
    error('The fit type has not been defined!')
    
end

x = [xdata(1),xdata(end),x];


% h3 = plot(ax1, ydata_fit,xdata_fit,':'); h3.LineWidth=1.2;
%
% hlines = findobj(gca,'Type','Line'); hlines=flipud(hlines); h3.Color=hlines(end-1).Color;
% str1 = strcat('; ',cellstr(num2str(x','%.3g'))); str2 = [str1{:}]; h3.DisplayName=str2;


