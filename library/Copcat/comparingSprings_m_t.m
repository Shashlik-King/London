function [SumRes,NumSpring,Global_Data,PureErrorTotal,PureWeightTotal,Selected_index,Soil_number_total]=comparingSprings_m_t(settings,closestValue,closestIndex,depth,X_curve,Y_curve,depth_av,p_av,X_Cospin,object_layers,element,soil,pile,Plaxis_P_Y,Simu_P,Simu_Y,loads)

Y_plaxis            = Plaxis_P_Y.X_curve;               % reassignment
P_plaxis            = Plaxis_P_Y.Y_curve;               % reassignment

PureErrorTotal      = [];                               % preallocation
PureWeightTotal     = [];                               % preallocation
Soil_number_total   = [];                               % preallocation
  
for unit=1:length(object_layers)
    NumTargetUnit = 0;                                  % preallocation
    PureErrorUnit = [];                                 % preallocation
    PureWeightUnit = [];                                % preallocation
    Soil_number_pure = [];                              % preallocation 
    nameOfUnit = ['soil',num2str(object_layers(unit))]; % preallocation
    Selected_index.Plaxis_idx = [];                     % preallocation
    Selected_index.Cospin_idx = [];                     % preallocation
    
    for i = 1:length(closestValue)
        soil_index(i) = find(-closestValue(i) <= soil.toplevel,1,'last');
        if soil_index(i)==object_layers(unit)
        %closestIndex(i) in this loop is the index of intersted element in element_data
            NumTargetUnit             = NumTargetUnit+1;
            obser_PlX_P               = unique(P_plaxis(i,:),'stable');
            obser_PLX_Y               = unique(Y_plaxis(i,:),'stable');
            Selected_index.Cospin_idx = [Selected_index.Cospin_idx,closestIndex(i)];
            Selected_index.Plaxis_idx = [Selected_index.Plaxis_idx,i];
            obserY = unique(Y_curve(i,:));              % here y is m
            obserX = unique(X_curve(i,:));              % here X is thehta
                
            if strcmp(element.type{closestIndex(i),1},'Sand')
                teta_top(1,:) = obserX;
                teta_bot(1,:) = teta_top(1,:);
                upy_top (1,:) = obser_PLX_Y;
                upy_bot (1,:) = upy_top(1,:);
                npoints       = size(teta_top,2);
                npoints2      = size(upy_top,2);
            
                if npoints==npoints2
                
                    for j = 1:npoints2
                        [ksppynode_top ksppynode_bot] = secspringstiff(settings,element,pile,loads,[upy_top(1,j) upy_bot(1,j)],closestIndex(i));
                        % for P, we are using the observation, only for normalization purposes 
                        ksppynode_top                     = obser_PlX_P(1,j)/upy_top(1,j);
                        ksppynode_bot                     = obser_PlX_P(1,j)/upy_bot(1,j);
                        ppynode_top(1,j)                  = ksppynode_top*upy_top(1,j);
                        ppynode_bot(1,j)                  = ksppynode_bot*upy_bot(1,j);
                        [ksmtetanode_top ksmtetanode_bot] = secmomstiff(settings,element,pile,[teta_top(1,j) teta_bot(1,j)],[upy_top(1,j) upy_bot(1,j)],ksppynode_top,ksppynode_bot,closestIndex(i));
                        mmtetanode_top(1,j)               = ksmtetanode_top*teta_top(1,j);
                        mmtetanode_bot(1,j)               = ksmtetanode_bot*teta_bot(1,j);
                    
                    end
                else
                    disp('data of the M_theta and P_Y are not consistans')
                    error
                end
                SimulY = mmtetanode_top;
                SimulX = teta_top;
            else
                SimulY = p_av(closestIndex(i),:);
                SimulX = X_Cospin(closestIndex(i),:);
            end
        
            Vertical_Stress                                       = (element.sigma_v_eff(closestIndex(i),1)+element.sigma_v_eff(closestIndex(i),2))/2;
            [E50,Eini,Eult]                                       = IsFullymobilized(obserX,obserY);
            Global_Data.(nameOfUnit).Ismobolized(NumTargetUnit,:) = [E50,Eini,Eult];
            [Residual(unit,i),Asso_simul]                         = errorPYcalcu(obserX,obserY,SimulY,SimulX,Vertical_Stress);
            Error                                                 = obserY-Asso_simul;
            index_target_soil                                     = ones(1,size(Error,2));
            index_target_soil(1,:)                                = closestIndex(i);
            index_target_soil(2,:)                                = object_layers(unit);

            if contains(element.type{closestIndex(i),1},'Sand')
                %NormFactor(1,1:size(obserY,2)) = 1/(sqrt((Vertical_Stress)*0.01));
                NormFactor(1,1:size(obserY,2)) = 1./(sqrt(obser_PlX_P)*pile.diameter*0.01);
            else
                %NormFactor(1,1:size(obserY,2)) = 1/(sqrt(max(obserY)*0.01));
                NormFactor(1,1:size(obserY,2)) = 1/(sqrt(element.cu(closestIndex(i),1)*((pile.diameter)^2)*0.01));
                  %NormFactor(1,1:size(obserY,2)) = 1/0.01;
            end
                
            PureErrorUnit                                          = [PureErrorUnit; Error'];               % reassignment
            PureWeightUnit                                         = [PureWeightUnit; NormFactor'];         % reassignment
            Soil_number_pure                                       = [Soil_number_pure;index_target_soil']; % reassignment
            Global_Data.(nameOfUnit).Normalfactor(NumTargetUnit,:) = NormFactor;                            % reassignment
            Global_Data.(nameOfUnit).obserY(NumTargetUnit,:)       = obserY;                                % reassignment
            Global_Data.(nameOfUnit).depthElem(NumTargetUnit,1)    = element.level(closestIndex(i),1);      % reassignment
            Global_Data.(nameOfUnit).depthElem(NumTargetUnit,2)    = closestValue(i,1);                     % reassignment
            Global_Data.(nameOfUnit).SimulY(NumTargetUnit,:)       = SimulY;                                % reassignment
            Global_Data.(nameOfUnit).Asso_simul(NumTargetUnit,:)   = Asso_simul;                            % reassignment
            Global_Data.(nameOfUnit).SimulX(NumTargetUnit,:)       = SimulX;                                % reassignment
            Global_Data.(nameOfUnit).obserX(NumTargetUnit,:)       = obserX;                                % reassignment
        else
           Residual(unit,i)                                        = 0;
        end

        SumRes(unit,1)                          = sum(Residual(unit,:));
        NumSpring(unit,1)                       = NumTargetUnit;
        Global_Data.(nameOfUnit).Selected_index = Selected_index;														   
    end 

    PureErrorTotal    = [PureErrorTotal;PureErrorUnit];       % assembly
    PureWeightTotal   = [PureWeightTotal;PureWeightUnit];     % assembly
    Soil_number_total = [Soil_number_total;Soil_number_pure]; % assembly

end 

end 