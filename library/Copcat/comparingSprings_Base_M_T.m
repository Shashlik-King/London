function [SumRes,NumSpring,Global_Data,PureErrorTotal,PureWeightTotal,Selected_index,Soil_number_total]=comparingSprings_Base_M_T(closestValue,closestIndex,depth,X_curve,Y_curve,depth_av,p_av,X_Cospin,object_layers,element,soil,pile,Plaxis_P_Y,Simu_P,Simu_Y,loads)

Y_plaxis=Plaxis_P_Y.X_curve;
P_plaxis=Plaxis_P_Y.Y_curve;

PureErrorTotal=[];
PureWeightTotal=[];
Soil_number_total=[];

for unit=1:length(object_layers)
    NumTargetUnit=0;
    PureErrorUnit=[];
    PureWeightUnit=[];
    Soil_number_pure=[];
    nameOfUnit=['soil',num2str(object_layers(unit))];
    Selected_index.Plaxis_idx=[];
    Selected_index.Cospin_idx=[];
    for i=1:length(closestValue)
        soil_index(i)=element.soil_layer(end,1);  % the soil index would be the last soil of the objective layer
        if soil_index(i)==object_layers(unit)

            NumTargetUnit=NumTargetUnit+1;
            obser_PlX_P=unique(P_plaxis(i,:),'stable');
            obser_PLX_Y=unique(Y_plaxis(i,:),'stable');
            Selected_index.Cospin_idx=[Selected_index.Cospin_idx,closestIndex(i)];
            Selected_index.Plaxis_idx=[Selected_index.Plaxis_idx,i];
            
            obserY=unique(Y_curve(i,:));  % here y is m
            obserX=unique(X_curve(i,:));  % here X is thehta
            SimulY=p_av(closestIndex(i),:);
            SimulX=X_Cospin(closestIndex(i),:);
            
            Vertical_Stress=(element.sigma_v_eff(end,1)+element.sigma_v_eff(end,2))/2;
            [E50,Eini,Eult]=IsFullymobilized(obserX,obserY);
            Global_Data.(nameOfUnit).Ismobolized(NumTargetUnit,:)= [E50,Eini,Eult];
            
            [Residual(unit,i),Asso_simul]=errorPYcalcu(obserX,obserY,SimulY,SimulX,Vertical_Stress);
            Error=obserY-Asso_simul;
            index_target_soil=ones(1,size(Error,2));
            index_target_soil(1,:)=closestIndex(i);
            index_target_soil(2,:)=object_layers(unit);
            
            
            
            if contains(element.type{end,1},'SS')
                %NormFactor(1,1:size(obserY,2))= 1/(sqrt((Vertical_Stress)*0.01));
                NormFactor(1,1:size(obserY,2))= 1./(sqrt(obser_PlX_P)*pile.diameter*0.01);
            else
                NormFactor(1,1:size(obserY,2))= 1/(sqrt(max(obserY)*0.01));
                %NormFactor(1,1:size(obserY,2))= 1/(sqrt(element.cu(closestIndex(i),1)*((pile.diameter)^2)*0.01));
                %NormFactor(1,1:size(obserY,2))=1/0.01;
            end
            
            PureErrorUnit=[PureErrorUnit; Error'];
            PureWeightUnit=[PureWeightUnit; NormFactor'];
            
            Soil_number_pure=[Soil_number_pure;index_target_soil'];
            
            Global_Data.(nameOfUnit).Normalfactor(NumTargetUnit,:)= NormFactor;
            Global_Data.(nameOfUnit).obserY(NumTargetUnit,:)=obserY;
            Global_Data.(nameOfUnit).depthElem(NumTargetUnit,1)=element.level(closestIndex(i),1);
            Global_Data.(nameOfUnit).depthElem(NumTargetUnit,2)=closestValue(i,1);
            
            Global_Data.(nameOfUnit).SimulY(NumTargetUnit,:)=SimulY;
            Global_Data.(nameOfUnit).Asso_simul(NumTargetUnit,:)=Asso_simul;
            
            Global_Data.(nameOfUnit).SimulX(NumTargetUnit,:)=SimulX;
            Global_Data.(nameOfUnit).obserX(NumTargetUnit,:)=obserX;

        else
            Residual(unit,i)=0;
        end
        
        SumRes(unit,1)=sum(Residual(unit,:));
        NumSpring(unit,1)=NumTargetUnit;
        Global_Data.(nameOfUnit).Selected_index=Selected_index;
    end
    
    PureErrorTotal=[PureErrorTotal;PureErrorUnit];
    PureWeightTotal=[PureWeightTotal;PureWeightUnit];
    Soil_number_total=[Soil_number_total;Soil_number_pure];
    
end
end


























