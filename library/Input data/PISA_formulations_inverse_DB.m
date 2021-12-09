 % Function that combines all PISA spring formulations for respective layers
% into one function to decrease QA time and chances of errors. 
%
% Units: kN, m, s, kPa
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Log of changes------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date            Initials        Change
%2020.03.25      FKMV            Programming
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%for hhhh=1: size(oobject_layers,2)
function [element]=PISA_formulations_inverse_DB(pile,soil,element,scour,settings,data,i,variable,Database)

Database_txt = Database.txt;
% Database_num = Database.num;
Database_raw = Database.raw;
if ~(strcmp(element.model_py(i),'Zero soil'))

for j=1:size(Database_txt,1)
    model_index = strcmp(Database_txt(j,1),element.model_py(i));
%     model_index = strcmp([Database_txt{j,2},' ', Database_txt{j,1}],element.model_py(i));
    if model_index == 1
        Database_index = j+1;
        break
    end
%     error('Specified model type is not found in the Database. Please Choose another modelt type.')
end
% for k = 1:size(Database_raw,2)
%     if Database_raw{Database_index,k} == '-'
%         Database_raw{Database_index,k} = 0;
%     end
% end
element.type{i,1} = Database.raw{Database_index,5};												   
% Formulations:
% 0 =Constant       = c1
% 1 = Linear        = c1 * L/D +c2
% 2 = Exponential   = c1 + c2 * exp( c3 * L/D )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Upper clay 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if strcmp(element.model_py(i),'PISA Upper clay')
% if element.soil_layer(i) == object_layers || strcmp(element.model_py(i),'PISA Upper clay')
% P-Y curves
% element.PISA_prelim_param.p_y(i,1)   = Database_raw{Database_index,5}; % Formulation
% element.PISA_prelim_param.p_y(i,3)   = Database_raw{Database_index,36}
index_offset = 5;
% Normalized ultimate lateral displacement
element.PISA_prelim_param.p_y(i,1)   = Database_raw{Database_index,1+index_offset};   % Formulation
element.PISA_prelim_param.p_y(i,2)   = Database_raw{Database_index,2+index_offset};   % Constant 1
element.PISA_prelim_param.p_y(i,3)   = Database_raw{Database_index,3+index_offset};   % Constant 2
element.PISA_prelim_param.p_y(i,4)   = Database_raw{Database_index,4+index_offset};   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.p_y(i,5)   = Database_raw{Database_index,5+index_offset};   % Formulation
element.PISA_prelim_param.p_y(i,6)   = Database_raw{Database_index,6+index_offset};   % Constant 1
element.PISA_prelim_param.p_y(i,7)   = Database_raw{Database_index,7+index_offset};   % Constant 2
element.PISA_prelim_param.p_y(i,8)   = Database_raw{Database_index,8+index_offset};   % Constant 3

% Initial stiffness
element.PISA_prelim_param.p_y(i,9)   = Database_raw{Database_index,9+index_offset}; % Formulation
element.PISA_prelim_param.p_y(i,10)  = Database_raw{Database_index,10+index_offset}; % Constant 1 
element.PISA_prelim_param.p_y(i,11)  = Database_raw{Database_index,11+index_offset};   % Constant 2 
element.PISA_prelim_param.p_y(i,12)  = Database_raw{Database_index,12+index_offset};   % Constant 3

% Curvature
element.PISA_prelim_param.p_y(i,13)  = Database_raw{Database_index,13+index_offset}; % Formulation
element.PISA_prelim_param.p_y(i,14)  = Database_raw{Database_index,14+index_offset}; % Constant 1  
element.PISA_prelim_param.p_y(i,15)  = Database_raw{Database_index,15+index_offset};   % Constant 2   
element.PISA_prelim_param.p_y(i,16)  = Database_raw{Database_index,16+index_offset};   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M-T curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.m_t(i,1)   = Database_raw{Database_index,17+index_offset}; % Formulation
element.PISA_prelim_param.m_t(i,2)   = Database_raw{Database_index,18+index_offset}; % Constant 1   30
element.PISA_prelim_param.m_t(i,3)   = Database_raw{Database_index,19+index_offset};   % Constant 2
element.PISA_prelim_param.m_t(i,4)   = Database_raw{Database_index,20+index_offset};   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.m_t(i,5)   = Database_raw{Database_index,21+index_offset}; % Formulation
element.PISA_prelim_param.m_t(i,6)   = Database_raw{Database_index,22+index_offset}; % Constant 1
element.PISA_prelim_param.m_t(i,7)   = Database_raw{Database_index,23+index_offset};   % Constant 2
element.PISA_prelim_param.m_t(i,8)   = Database_raw{Database_index,24+index_offset};   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.m_t(i,9)   = Database_raw{Database_index,25+index_offset}; % Formulation
element.PISA_prelim_param.m_t(i,10)  = Database_raw{Database_index,26+index_offset}; % Constant 1
element.PISA_prelim_param.m_t(i,11)  = Database_raw{Database_index,27+index_offset};   % Constant 2
element.PISA_prelim_param.m_t(i,12)  = Database_raw{Database_index,28+index_offset};   % Constant 3

% Curvature
element.PISA_prelim_param.m_t(i,13)  = Database_raw{Database_index,29+index_offset}; % Formulation
element.PISA_prelim_param.m_t(i,14)  = Database_raw{Database_index,30+index_offset}; % Constant 1
element.PISA_prelim_param.m_t(i,15)  = Database_raw{Database_index,31+index_offset};   % Constant 2
element.PISA_prelim_param.m_t(i,16)  = Database_raw{Database_index,32+index_offset};   % Constant 3
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          
% P-Y Toe curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.Hb(i,1)   = Database_raw{Database_index,33+index_offset}; % Formulation
element.PISA_prelim_param.Hb(i,2)   = Database_raw{Database_index,34+index_offset}; % Constant 1
element.PISA_prelim_param.Hb(i,3)   = Database_raw{Database_index,35+index_offset};   % Constant 2
element.PISA_prelim_param.Hb(i,4)   = Database_raw{Database_index,36+index_offset};   % Constant 3

% Ultimate lateral load
element.PISA_prelim_param.Hb(i,5)   = Database_raw{Database_index,37+index_offset}; % Formulation
element.PISA_prelim_param.Hb(i,6)   = Database_raw{Database_index,38+index_offset}; % Constant 1
element.PISA_prelim_param.Hb(i,7)   = Database_raw{Database_index,39+index_offset};   % Constant 2
element.PISA_prelim_param.Hb(i,8)   = Database_raw{Database_index,40+index_offset};   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.Hb(i,9)   = Database_raw{Database_index,41+index_offset}; % Formulation
element.PISA_prelim_param.Hb(i,10)  = Database_raw{Database_index,42+index_offset}; % Constant 1
element.PISA_prelim_param.Hb(i,11)  = Database_raw{Database_index,43+index_offset};   % Constant 2
element.PISA_prelim_param.Hb(i,12)  = Database_raw{Database_index,44+index_offset};   % Constant 3

% Curvature
element.PISA_prelim_param.Hb(i,13)  = Database_raw{Database_index,45+index_offset}; % Formulation
element.PISA_prelim_param.Hb(i,14)  = Database_raw{Database_index,46+index_offset}; % Constant 1
element.PISA_prelim_param.Hb(i,15)  = Database_raw{Database_index,47+index_offset};   % Constant 2
element.PISA_prelim_param.Hb(i,16)  = Database_raw{Database_index,48+index_offset};   % Constant 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M-Theta Toe curves

% Normalized ultimate lateral displacement
element.PISA_prelim_param.Mb(i,1)  = Database_raw{Database_index,49+index_offset}; % Formulation
element.PISA_prelim_param.Mb(i,2)  = Database_raw{Database_index,50+index_offset}; % Constant 1
element.PISA_prelim_param.Mb(i,3)  = Database_raw{Database_index,51+index_offset};   % Constant 2
element.PISA_prelim_param.Mb(i,4)  = Database_raw{Database_index,52+index_offset};   % Constant 3
% Ultimate lateral load
element.PISA_prelim_param.Mb(i,5)  = Database_raw{Database_index,53+index_offset}; % Formulation
element.PISA_prelim_param.Mb(i,6)  = Database_raw{Database_index,54+index_offset}; % Constant 1
element.PISA_prelim_param.Mb(i,7)  = Database_raw{Database_index,55+index_offset};   % Constant 2
element.PISA_prelim_param.Mb(i,8)  = Database_raw{Database_index,56+index_offset};   % Constant 3

% Normalized initial stiffness
element.PISA_prelim_param.Mb(i,9)   = Database_raw{Database_index,57+index_offset}; % Formulation
element.PISA_prelim_param.Mb(i,10)  = Database_raw{Database_index,58+index_offset}; % Constant 1
element.PISA_prelim_param.Mb(i,11)  = Database_raw{Database_index,59+index_offset};   % Constant 2
element.PISA_prelim_param.Mb(i,12)  = Database_raw{Database_index,60+index_offset};   % Constant 3

element.PISA_prelim_param.Mb(i,13)  = Database_raw{Database_index,61+index_offset}; % Formulation
element.PISA_prelim_param.Mb(i,14)  = Database_raw{Database_index,62+index_offset}; % Constant 1
element.PISA_prelim_param.Mb(i,15)  = Database_raw{Database_index,63+index_offset};   % Constant 2
element.PISA_prelim_param.Mb(i,16)  = Database_raw{Database_index,64+index_offset};   % Constant 3
% element.PISA_prelim_param.Mb(i,16)  = 0;   % Constant 3
end 
element.database = Database_index;
end
