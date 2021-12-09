function  [element] = PISA_param_overwrite(variable,constant,function_type,object_layers,element,ii)

% % overwrite_index  = ismember(element.soil_layer(ii),object_layers);
overwrite_index  = ismember(element.soil_layer(ii),object_layers);   %PNGI


if ~(strcmp(element.model_py(ii),'Zero soil'))

%% Overwriting variables for all objective layers
    if overwrite_index == 1
        index_obj=find(object_layers==element.soil_layer(ii));
        for Var=1:size(element.PISA_param_index,1)
            if element.PISA_param_index(Var,1)==1
                element.PISA_prelim_param.p_y(ii,element.PISA_param_index(Var,2))= variable(index_obj,Var);

            elseif element.PISA_param_index(Var,1)==2
                element.PISA_prelim_param.m_t(ii,element.PISA_param_index(Var,2))= variable(index_obj,Var);

            elseif element.PISA_param_index(Var,1)==3
                element.PISA_prelim_param.Hb(ii,element.PISA_param_index(Var,2))= variable(index_obj,Var);

            elseif element.PISA_param_index(Var,1)==4
                element.PISA_prelim_param.Mb(ii,element.PISA_param_index(Var,2))= variable(index_obj,Var);

            end
        end
    end 
%% Overwriting constants for all objective layers
    if overwrite_index == 1
        index_obj=find(object_layers==element.soil_layer(ii));
        for Con=1:size(element.PISA_param_index_con,1)
            if element.PISA_param_index_con(Con,1)==1
                element.PISA_prelim_param.p_y(ii,element.PISA_param_index_con(Con,2))= constant(index_obj,Con);

            elseif element.PISA_param_index_con(Con,1)==2
                element.PISA_prelim_param.m_t(ii,element.PISA_param_index_con(Con,2))= constant(index_obj,Con);

            elseif element.PISA_param_index_con(Con,1)==3
                element.PISA_prelim_param.Hb(ii,element.PISA_param_index_con(Con,2))= constant(index_obj,Con);

            elseif element.PISA_param_index_con(Con,1)==4
                element.PISA_prelim_param.Mb(ii,element.PISA_param_index_con(Con,2))= constant(index_obj,Con);

            end
        end
    end 
    
%% Overwriting type of the function for all layers    
 
    if overwrite_index == 1
        index_obj=find(object_layers==element.soil_layer(ii));
        
        % over write the type of PY function 
        
        % type of ultimate displacment PY 
        element.PISA_prelim_param.p_y(ii,1)=function_type(index_obj,1);        
        
        % type of ultimate lateral load PY 
        element.PISA_prelim_param.p_y(ii,5)=function_type(index_obj,2);
        % type of initial stiffness PY 
        element.PISA_prelim_param.p_y(ii,9)=function_type(index_obj,3);        
        % type of curvature  PY 
        element.PISA_prelim_param.p_y(ii,13)=function_type(index_obj,4); 
        
        
        % over write type of m_t       
         % type of ultimate rotation mt 
        element.PISA_prelim_param.m_t(ii,1)=function_type(index_obj,5);        
        
        % type of ultimate lateral load mt 
        element.PISA_prelim_param.m_t(ii,5)=function_type(index_obj,6);
        % type of initial stiffness mt 
        element.PISA_prelim_param.m_t(ii,9)=function_type(index_obj,7);        
        % type of curvature  mt 
        element.PISA_prelim_param.m_t(ii,13)=function_type(index_obj,8);        
 
        
         
 
        % over write type of base toe 
        % type of ultimate rotation H-y
        element.PISA_prelim_param.Hb(ii,1)=function_type(index_obj,9);       
        % type of ultimate lateral load H-y 
        element.PISA_prelim_param.Hb(ii,5)=function_type(index_obj,10);
        % type of initial stiffness H-y 
        element.PISA_prelim_param.Hb(ii,9)=function_type(index_obj,11);        
        % type of curvature  H-y 
        element.PISA_prelim_param.Hb(ii,13)=function_type(index_obj,12);        
  
        % over write type of base moment 
        % type of ultimate rotation H-y
        element.PISA_prelim_param.Mb(ii,1)=function_type(index_obj,13);       
        % type of ultimate lateral load mt 
        element.PISA_prelim_param.Mb(ii,5)=function_type(index_obj,14);
        % type of initial stiffness mt 
        element.PISA_prelim_param.Mb(ii,9)=function_type(index_obj,15);        
        % type of curvature  mt 
        element.PISA_prelim_param.Mb(ii,13)=function_type(index_obj,16);          
        
                
    end 
    
    
    
    
    
    
    
    
    
    
end    
end 