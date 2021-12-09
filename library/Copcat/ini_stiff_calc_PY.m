function [soil,element]=ini_stiff_calc_PY(soil,object_layers,soil_index,PLAX,pile,element) 

refined_Depth = PLAX.depth_stiff;
bad_Depth     = PLAX.index_rotation_stiff(:,2);

Y_Curve_Stiff = PLAX.Y_curve_stiff;
X_Curve_Stiff = PLAX.X_curve_stiff;

for i=1:length(bad_Depth)
    Bad_index = find(refined_Depth==bad_Depth(i));    
    refined_Depth(refined_Depth==bad_Depth(i)) = [];
end 

for iii=1:length(refined_Depth)
   IndexinPlaxis(iii) = find(-(refined_Depth(iii)) <= soil.toplevel,1,'last');         
end 

Indexoftarget   = find(IndexinPlaxis==object_layers);
formulation     = 1; % 1 = linear, 2 quadratic
norm_ini_stiff  = Y_Curve_Stiff(:,end)./X_Curve_Stiff(:,end); % calculate normalised initial stiffness
norm_ini_stiff  = norm_ini_stiff(Indexoftarget(1):Indexoftarget(end),:);
XXX             = refined_Depth/pile.diameter;
XXX             = XXX(Indexoftarget(1):Indexoftarget(end),:);
p               = polyfit(XXX,norm_ini_stiff/soil.G0(object_layers,:),formulation);
for i=1:size(object_layers,2)
    
    if soil_index==object_layers(i)
        %P_Y Curve parameters  
        non_norm_ini_stiff               = norm_ini_stiff/soil.G0(object_layers,:); % non-normalised initial stiffness
        soil.ini_stiff(soil_index,1)     = formulation;                             % formulation
        soil.ini_stiff(soil_index,2)     = p(i,1);                                  %Kp1
        soil.ini_stiff(soil_index,3)     = p(i,2);                                  %Kp2
        if formulation == 1
            soil.ini_stiff(soil_index,4) = 0;                                       %Kp3
        elseif formulation == 2
            soil.ini_stiff(soil_index,4) = p(i,3);                                  %Kp3
        end
    end 
end 

