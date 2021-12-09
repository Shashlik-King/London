function [GlobalError]=Assemble_Error(NumberofGeometry,calibration,model,focus)

if contains(calibration.Costfunction,'PISAMethod')
    GlobalError = []; % Initialisation of global error
    for geo = 1:NumberofGeometry
        Nehtha_Level = [];
        for Pres_level = 1:size(calibration.level,2)
            Asimul = trapz(model(geo).result(Pres_level).load_displacement(:,3)); % simulated value from COSPIN
            Aref   = trapz(model(geo).result(Pres_level).load_displacement(:,2)); % reference value 
            Adif   = trapz(abs((model(geo).result(Pres_level).load_displacement(:,2)-model(geo).result(Pres_level).load_displacement(:,3))));
            if strcmp(calibration.method,'ga')
                Nehtha_1 = (Adif)/Aref;
            elseif strcmp(calibration.method,'goalattain')
                Nehtha_1 = (Aref-Adif)/Aref;
            end
            Nehtha_Level = [Nehtha_Level,Nehtha_1];
        end
        GlobalError = [GlobalError;Nehtha_Level];
    end
else
    
    Involvment          = calibration.involvment; 	% Involvement specification
    total_error_def     = []; 					    % Initialisation of total error for deflection
    total_weight_def    = [];                       % Initialisation of total error weight for deflection
    total_error_mom     = [];                       % Initialisation of total error for moment
    total_weight_mom    = [];                       % Initialisation of total error weight for moment
    total_error_defmud  = [];                       % Initialisation of total error for deflection at mudline
    total_weight_defmud = [];                       % Initialisation of total error weight for deflection at mudline

    for geo = 1:NumberofGeometry
        
        P_error_def_l  = []; % Initialisation of pure error for deflection
        P_weight_def_1 = []; % Initialisation of pure error weight for deflection
        P_error_mom_l  = []; % Initialisation of pure error for moment
        P_weight_mom_1 = []; % Initialisation of pure error weight for moment
        
        for Pres_level=1:size(calibration.level,2)
            if strcmp(calibration.involvment,'def') || strcmp(calibration.involvment,'mom') || strcmp(calibration.involvment,'def_mom')  || strcmp(calibration.involvment,'def_mom')  || strcmp(calibration.involvment,'def_mom_defmud') || strcmp(calibration.involvment,'def_defmud')
                %% Deflection
                P_error_def= (model(geo).result(Pres_level).displacement(:,3)-model(geo).result(Pres_level).displacement(:,2)); % extraction of pure error for one model for def analysis
                P_weight_def=(model(geo).result(Pres_level).displacement(:,4)); 												% extraction of pure error weight for one model for def analysis
                P_error_def_l=[P_error_def_l;P_error_def]; 																		% assemblleing the error of deflection between all of load levels
                P_weight_def_1=[P_weight_def_1;P_weight_def]; 																	% assemblleing the weight of deflection between all of load levels
                %% Moment
                P_error_mom=(model(geo).result(Pres_level).moment(:,3)-model(geo).result(Pres_level).moment(:,2)); 				% extraction of pure error for one model for moment analysis
                P_weight_mom=(model(geo).result(Pres_level).moment(:,4)); 														% extraction of pure error weight for one model for moment analysis
                P_error_mom_l=[P_error_mom_l;P_error_mom]; 																		% assembleling the error of moment between all of load levels
                P_weight_mom_1=[P_weight_mom_1;P_weight_mom]; 																	% assembleling the weight of moment between all of load levels
            end
			% Total error assembly
            total_error_def=[total_error_def;P_error_def_l]; 	% Total error assembly
            total_weight_def=[total_weight_def;P_weight_def_1]; % Total error assembly
            total_error_mom=[total_error_mom;P_error_mom_l]; 	% Total error assembly
            total_weight_mom=[total_weight_mom;P_weight_mom_1]; % Total error assembly

            if contains (Involvment,'defmud')
                
                P_error_defmud=(model(geo).result(Pres_level).load_displacement(:,2)-model(geo).result(Pres_level).load_displacement(:,3)); % Pure error for deflection at mudline of 1 single model in single load level
                P_weight_defmud=(model(geo).result(Pres_level).load_displacement(:,4)); 													% Pure error for deflection at mudline of 1 single model in single load level
                total_error_defmud=[total_error_defmud;P_error_defmud]; 																	% Total error assembly
                total_weight_defmud=[total_weight_defmud;P_weight_defmud]; 																	% Total error assembly
                
            end
        end
    end

    switch Involvment
        case 'def'
            Global_error_vector= total_error_def; 											% Global error assembly
            Global_weight_vector=total_weight_def; 											% Global error weight assembly
        case 'mom'
            Global_error_vector= total_error_mom; 											% Global error assembly
            Global_weight_vector=total_weight_mom; 											% Global error weight assembly
        case 'defmud'
            Global_error_vector= total_error_defmud; 										% Global error assembly
            Global_weight_vector=total_weight_defmud; 										% Global error weight assembly
        case 'def_mom'
            Global_error_vector = [total_error_def;total_error_mom]; 						% Global error assembly
            Global_weight_vector= [total_weight_def;total_weight_mom] ; 					% Global error weight assembly
        case 'def_mom_defmud'
            Global_error_vector = [total_error_def;total_error_mom;total_error_defmud]; 	% Global error assembly
            Global_weight_vector= [total_weight_def;total_weight_mom;total_weight_defmud];  % Global error weight assembly
        case 'def_defmud'
            Global_error_vector = [total_error_def;total_error_defmud]; 					% Global error assembly
            Global_weight_vector= [total_weight_def;total_weight_defmud]; 					% Global error weight assembly
    end

    ErrorVector  =(Global_error_vector) ;  % reassignment
    WeightVector = (Global_weight_vector); % reassignment
    [n,m]        = size(WeightVector);
    WeightMatrix = eye(n);
    
    for ii=1:n
        WeightMatrix(ii,ii) = WeightVector(ii,1); % reassignment
    end

    if contains(calibration.Costfunction,'Scalar')
        GlobalError = ErrorVector'*(WeightMatrix^2)*(ErrorVector);  % claculation of global error based on the scalar option
    elseif   contains(calibration.Costfunction, 'Vector')
        GlobalError = (WeightMatrix)*ErrorVector; 					% claculation of global error based on the vector option
    elseif   contains(calibration.Costfunction, 'PureError')
        GlobalError = ErrorVector;  								% claculation of global error based on the pure error option
    end

    for iii=1:size(GlobalError,1)
        if isnan(GlobalError(iii,1))
            GlobalError(iii,1) = 100000000;  % reassignment of high error for NaN values
        end
    end

end
end