function [ptop]=fitting_function_pisa(Coeff,Xtop)

	K_AKt=Coeff(1);
	n_AKt=Coeff(2);
	Yu_AKt=Coeff(3);
	Pu_AKt=Coeff(4);

	for i =1:size(Xtop,2)
		a_top = 1-2*n_AKt;
		b_top_n = 2*n_AKt*(Xtop(i)/Yu_AKt)-(1-n_AKt)*(1+(Xtop(i).*K_AKt./Pu_AKt));
		c_top_n = (Xtop(i).*K_AKt./Pu_AKt)*(1-n_AKt)-n_AKt*(Xtop(i)/Yu_AKt)^2;
	% -------- Pile resistance -------------------------------------------------
		if Xtop(i) <= Yu_AKt
			ptop(1,i) = Pu_AKt.*((2*c_top_n)./(-b_top_n+sqrt(b_top_n.^2-4*a_top*c_top_n))); %Normalized pile resistance 
		else
			ptop(1,i) = Pu_AKt; %Normalized ultimate pile resistance 
		end
	end 
end 