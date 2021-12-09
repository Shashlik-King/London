function [SumRes,NumSpring,Global_Data,PureErrorTotal,PureWeightTotal]=comparingSprings_base(closestValue,closestIndex,depth,X_curve,Y_curve,depth_av,p_av,X_Cospin,object_layers,element,soil,pile)
% in this fuction only 1 springs corresponding to the last element and last
% plaxis curve would be considered

PureErrorTotal=[];
PureWeightTotal=[];
for unit=1:length(object_layers)
    NumTargetUnit=0;
    PureErrorUnit=[];
    PureWeightUnit=[];
    nameOfUnit=['soil',num2str(object_layers(unit))];
    Selected_index.Plaxis_idx=[];
    Selected_index.Cospin_idx=[];    
    
    for i=1:length(closestValue)  % closestvalue here is automatically a scalar 
        soil_index(i)=element.soil_layer(end,1);  % the soil index would be the last soil of the objective layer
        if soil_index(i)==object_layers(unit)
        
            NumTargetUnit=NumTargetUnit+1;
            obserY=unique(Y_curve(i,:),'stable');
            obserX=unique(X_curve(i,:),'stable');
            SimulY=p_av(closestIndex(i),:);
            SimulX=X_Cospin(closestIndex(i),:);
            Selected_index.Cospin_idx=[Selected_index.Cospin_idx,closestIndex(i)];
            Selected_index.Plaxis_idx=[Selected_index.Plaxis_idx,i]; 
            Vertical_Stress=(element.sigma_v_eff(closestIndex(i),1)+element.sigma_v_eff(closestIndex(i),2))/2;
            [E50,Eini,Eult]=IsFullymobilized(obserX,obserY);
            Global_Data.(nameOfUnit).Ismobolized(NumTargetUnit,:)= [E50,Eini,Eult];

            [Residual(unit,i),Asso_simul]=errorPYcalcu(obserX,obserY,SimulY,SimulX,Vertical_Stress)
            Error=obserY-Asso_simul;
            index_target_soil=ones(1,size(Error,2));
            index_target_soil(1,:)=closestIndex(i);
            index_target_soil(2,:)=object_layers(unit);

             if strcmp(element.type{end,1},'ss') 
                 NormFactor(1,1:size(obserY,2))= 1/(sqrt((Vertical_Stress)*pile.diameter*0.01));
             else
                  NormFactor(1,1:size(obserY,2))= 1/((max(obserY))*0.01);
                  %NormFactor(1,1:size(obserY,2))=1/0.01;
             end
                
            PureErrorUnit=[PureErrorUnit; Error'];
            PureWeightUnit=[PureWeightUnit; NormFactor'];

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

end 

end 




    
    



















