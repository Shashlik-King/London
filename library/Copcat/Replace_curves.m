function [XCorrected,Y_Corrected, coeef]=Replace_curves(X,Y,mmmm,Refined_depth,type_of_curve,model_name)

x0(1)       = (Y(5)-Y(1))/(X(5)-X(1));
x0(2)       = 0.5;
x0(3)       = 0.2;
x0(4)       = max(Y);

XCorrected  = linspace(min(X(:)),X(end),size(X,2)); % establishavector of X
fun         = @(coeff,X)fitting_function_pisa(coeff,X); 
coeef       = lsqcurvefit(fun,x0,X,Y); % curve fitting using LSQ

if ~isreal(coeef)  
    error 
end 

% Plotting of replaced curves
figure(mmmm)
plot(X,Y,'ko',X,fun(coeef,X),'b-')
title(['Reaction curve at depth of ',num2str(Refined_depth)]);
filename     = fullfile('output',['fitted_Curve_',model_name,'_',type_of_curve,num2str(Refined_depth),'.png']);
saveas(gcf,filename)

Y_Corrected  = fun(coeef,XCorrected);

end 

