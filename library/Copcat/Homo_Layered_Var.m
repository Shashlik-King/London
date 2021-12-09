function [variable,constant]=Homo_Layered_Var(variable,constant,object_layers,Stratigraphy)
if strcmp(Stratigraphy, 'homogeneous')
    for cc = 1:size(object_layers,2)
        variable(cc,:) = variable(1,:);   % Assigning similar values to all of the layeres 
        constant(cc,:) = constant(1,:);   % Assigning similar values to all of the layeres 
    end
end
end