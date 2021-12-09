function [WSR,Asso_simul]=errorPYcalcu(obserX,obserY,SimulY,SimulX,Stressofcurve)
Asso_simul = interp1(SimulX,SimulY,obserX);         % interpolation
residual   = Asso_simul-obserY;                     % difference calculation
% SR         =((residual).^2)/((0.01*max(obserY))^2); % sum residual calculation
SR         = ((residual).^2)/((Stressofcurve)^2);   % sum residual calculation
WSR        = sum(SR);                               % weighted sum residual calculation
end 


