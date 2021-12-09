function [SumRes,NumSpring,Global_Data,PureErrorTotal,PureWeightTotal,Selected_index,Soil_number_total]=comparingSprings(closestValue,closestIndex,depth,X_curve,Y_curve,depth_av,p_av,X_Cospin,object_layers,element,soil,pile)

PureErrorTotal                  = [];                                    % preallocation
PureWeightTotal                 = [];                                    % preallocation
Soil_number_total               = [];                                    % preallocation
for unit = 1:length(object_layers)
    NumTargetUnit               = 0;                                     % preallocation
    PureErrorUnit               = [];                                    % preallocation
    PureWeightUnit              = [];                                    % preallocation
    Soil_number_pure            = [];                                    % preallocation
    nameOfUnit                  = ['soil',num2str(object_layers(unit))]; % name of unit assignment
    Selected_index.Plaxis_idx   = [];                                    % preallocation
    Selected_index.Cospin_idx   = [];                                    % preallocation 
    
    for i = 1:length(closestValue)  
        soil_index(i) = find(-closestValue(i) <= soil.toplevel,1,'last'); % selection of soil layers
        if soil_index(i)==object_layers(unit)
        
            NumTargetUnit             = NumTargetUnit+1;                % counter
            obserY                    = unique(Y_curve(i,:),'stable');  % cut away repeating values at end of spring vector
            obserX                    = unique(X_curve(i,:),'stable');  % cut away repeating values at end of spring vector
            SimulY                    = p_av(closestIndex(i),:);        % finding closest value for average p
            SimulX                    = X_Cospin(closestIndex(i),:);    % finding closest value from COSPIN simulation
            Selected_index.Cospin_idx = [Selected_index.Cospin_idx,closestIndex(i)];
            Selected_index.Plaxis_idx = [Selected_index.Plaxis_idx,i];
            Vertical_Stress           = (element.sigma_v_eff(closestIndex(i),1)+element.sigma_v_eff(closestIndex(i),2))/2;
            [E50,Eini,Eult]           = IsFullymobilized(obserX,obserY);

            Global_Data.(nameOfUnit).Ismobolized(NumTargetUnit,:) = [E50,Eini,Eult];
            [Residual(unit,i),Asso_simul]                         = errorPYcalcu(obserX,obserY,SimulY,SimulX,Vertical_Stress);
            Error                                                 = obserY-Asso_simul;
            index_target_soil                                     = ones(1,size(Error,2));
            index_target_soil(1,:)                                = closestIndex(i);
            index_target_soil(2,:)                                = object_layers(unit);
        
             if strcmp(element.type{closestIndex(i),1},'ss')
                 NormFactor(1,1:size(obserY,2)) = 1/(sqrt((Vertical_Stress)*pile.diameter*0.01));
             else
                  NormFactor(1,1:size(obserY,2)) = 1/sqrt((max(obserY))*0.01);
                  %NormFactor(1,1:size(obserY,2))=1/0.01;
             end
                
            PureErrorUnit    = [PureErrorUnit; Error'];
            PureWeightUnit   = [PureWeightUnit; NormFactor'];
            Soil_number_pure =[Soil_number_pure;index_target_soil'];

            Global_Data.(nameOfUnit).Normalfactor(NumTargetUnit,:)  = NormFactor;  
            Global_Data.(nameOfUnit).obserY(NumTargetUnit,:)        = obserY;
            Global_Data.(nameOfUnit).depthElem(NumTargetUnit,1)     = element.level(closestIndex(i),1);
            Global_Data.(nameOfUnit).depthElem(NumTargetUnit,2)     = closestValue(i,1);        

            Global_Data.(nameOfUnit).SimulY(NumTargetUnit,:)        = SimulY;
            Global_Data.(nameOfUnit).Asso_simul(NumTargetUnit,:)    = Asso_simul;

            Global_Data.(nameOfUnit).SimulX(NumTargetUnit,:)        = SimulX;
            Global_Data.(nameOfUnit).obserX(NumTargetUnit,:)        = obserX;

        else
            Residual(unit,i)=0;
        end

        SumRes(unit,1)                          = sum(Residual(unit,:));
        NumSpring(unit,1)                       = NumTargetUnit;
        Global_Data.(nameOfUnit).Selected_index = Selected_index;
 
    end 

    PureErrorTotal    = [PureErrorTotal;PureErrorUnit];
    PureWeightTotal   = [PureWeightTotal;PureWeightUnit];
    Soil_number_total = [Soil_number_total;Soil_number_pure];

end        
end 




    
    



















