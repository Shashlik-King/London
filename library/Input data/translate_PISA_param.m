function [element] = translate_PISA_param(element,variable,var_name,constant,con_name)
%% Translates parameter names "var_name" specified in "Inverse_Model.m" to column indicies for PISA parameter overwrite

%% TRANSLATING VARIABLES
%% P-y 
for i = 1:size(var_name,2)
    switch var_name{i}
        %%%%%%%%% p-y
        case 'y_u_F'
            element.PISA_param_index(i,1) = 1;
            element.PISA_param_index(i,2) = 1;
        case 'y_u_1'
            element.PISA_param_index(i,1) = 1;
            element.PISA_param_index(i,2) = 2;
        case 'y_u_2'
            element.PISA_param_index(i,1) = 1;
            element.PISA_param_index(i,2) = 3;
        case 'y_u_3'
            element.PISA_param_index(i,1) = 1;
            element.PISA_param_index(i,2) = 4;
        case 'p_u_F'
            element.PISA_param_index(i,1) = 1;
            element.PISA_param_index(i,2) = 5;
        case 'p_u_1'
            element.PISA_param_index(i,1) = 1;
            element.PISA_param_index(i,2) = 6;
        case 'p_u_2'
            element.PISA_param_index(i,1) = 1;
            element.PISA_param_index(i,2) = 7;
        case 'p_u_3'
            element.PISA_param_index(i,1) = 1;
            element.PISA_param_index(i,2) = 8;
        case 'k_p_F'
            element.PISA_param_index(i,1) = 1;
            element.PISA_param_index(i,2) = 9;
        case 'k_p_1'
            element.PISA_param_index(i,1) = 1;
            element.PISA_param_index(i,2) = 10;
        case 'k_p_2'
            element.PISA_param_index(i,1) = 1;
            element.PISA_param_index(i,2) = 11;
        case 'k_p_3'
            element.PISA_param_index(i,1) = 1;
            element.PISA_param_index(i,2) = 12;
        case 'n_p_F'
            element.PISA_param_index(i,1) = 1;
            element.PISA_param_index(i,2) = 13;
        case 'n_p_1'
            element.PISA_param_index(i,1) = 1;
            element.PISA_param_index(i,2) = 14;
        case 'n_p_2'
            element.PISA_param_index(i,1) = 1;
            element.PISA_param_index(i,2) = 15;
        case 'n_p_3'
            element.PISA_param_index(i,1) = 1;
            element.PISA_param_index(i,2) = 16;
            
            
            
            %%%%%%%%% m-t
        case 'tetam_u_F'
            element.PISA_param_index(i,1) = 2;
            element.PISA_param_index(i,2) = 1;
        case 'tetam_u_1'
            element.PISA_param_index(i,1) = 2;
            element.PISA_param_index(i,2) = 2;
        case 'tetam_u_2'
            element.PISA_param_index(i,1) = 2;
            element.PISA_param_index(i,2) = 3;
        case 'tetam_u_3'
            element.PISA_param_index(i,1) = 2;
            element.PISA_param_index(i,2) = 4;
        case 'm_u_F'
            element.PISA_param_index(i,1) = 2;
            element.PISA_param_index(i,2) = 5;
        case 'm_u_1'
            element.PISA_param_index(i,1) = 2;
            element.PISA_param_index(i,2) = 6;
        case 'm_u_2'
            element.PISA_param_index(i,1) = 2;
            element.PISA_param_index(i,2) = 7;
        case 'm_u_3'
            element.PISA_param_index(i,1) = 2;
            element.PISA_param_index(i,2) = 8;
        case 'k_m_F'
            element.PISA_param_index(i,1) = 2;
            element.PISA_param_index(i,2) = 9;
        case 'k_m_1'
            element.PISA_param_index(i,1) = 2;
            element.PISA_param_index(i,2) = 10;
        case 'k_m_2'
            element.PISA_param_index(i,1) = 2;
            element.PISA_param_index(i,2) = 11;
        case 'k_m_3'
            element.PISA_param_index(i,1) = 2;
            element.PISA_param_index(i,2) = 12;
        case 'n_m_F'
            element.PISA_param_index(i,1) = 2;
            element.PISA_param_index(i,2) = 13;
        case 'n_m_1'
            element.PISA_param_index(i,1) = 2;
            element.PISA_param_index(i,2) = 14;
        case 'n_m_2'
            element.PISA_param_index(i,1) = 2;
            element.PISA_param_index(i,2) = 15;
        case 'n_m_3'
            element.PISA_param_index(i,1) = 2;
            element.PISA_param_index(i,2) = 16; 
            
            
            
            
           %%%%%%%%% Hb 
       case 'yB_u_F'
            element.PISA_param_index(i,1) = 3;
            element.PISA_param_index(i,2) = 1;
        case 'yB_u_1'
            element.PISA_param_index(i,1) = 3;
            element.PISA_param_index(i,2) = 2;
        case 'yB_u_2'
            element.PISA_param_index(i,1) = 3;
            element.PISA_param_index(i,2) = 3;
        case 'yB_u_3'
            element.PISA_param_index(i,1) = 3;
            element.PISA_param_index(i,2) = 4;
        case 'HB_u_F'
            element.PISA_param_index(i,1) = 3;
            element.PISA_param_index(i,2) = 5;
        case 'HB_u_1'
            element.PISA_param_index(i,1) = 3;
            element.PISA_param_index(i,2) = 6;
        case 'HB_u_2'
            element.PISA_param_index(i,1) = 3;
            element.PISA_param_index(i,2) = 7;
        case 'HB_u_3'
            element.PISA_param_index(i,1) = 3;
            element.PISA_param_index(i,2) = 8;
        case 'k_H_F'
            element.PISA_param_index(i,1) = 3;
            element.PISA_param_index(i,2) = 9;
        case 'k_H_1'
            element.PISA_param_index(i,1) = 3;
            element.PISA_param_index(i,2) = 10;
        case 'k_H_2'
            element.PISA_param_index(i,1) = 3;
            element.PISA_param_index(i,2) = 11;
        case 'k_H_3'
            element.PISA_param_index(i,1) = 3;
            element.PISA_param_index(i,2) = 12;
        case 'n_H_F'
            element.PISA_param_index(i,1) = 3;
            element.PISA_param_index(i,2) = 13;
        case 'n_H_1'
            element.PISA_param_index(i,1) = 3;
            element.PISA_param_index(i,2) = 14;
        case 'n_H_2'
            element.PISA_param_index(i,1) = 3;
            element.PISA_param_index(i,2) = 15;
        case 'n_H_3'
            element.PISA_param_index(i,1) = 3;
            element.PISA_param_index(i,2) = 16;  
            
            
            
           %%%%%%%%% Mb  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'tetaMb_u_F'
            element.PISA_param_index(i,1) = 4;
            element.PISA_param_index(i,2) = 1;
        case 'tetaMb_u_1'
            element.PISA_param_index(i,1) = 4;
            element.PISA_param_index(i,2) = 2;
        case 'tetaMb_u_2'
            element.PISA_param_index(i,1) = 4;
            element.PISA_param_index(i,2) = 3;
        case 'tetaMb_u_3'
            element.PISA_param_index(i,1) = 4;
            element.PISA_param_index(i,2) = 4;
        case 'MB_u_F'
            element.PISA_param_index(i,1) = 4;
            element.PISA_param_index(i,2) = 5;
        case 'MB_u_1'
            element.PISA_param_index(i,1) = 4;
            element.PISA_param_index(i,2) = 6;
        case 'MB_u_2'
            element.PISA_param_index(i,1) = 4;
            element.PISA_param_index(i,2) = 7;
        case 'MB_u_3'
            element.PISA_param_index(i,1) = 4;
            element.PISA_param_index(i,2) = 8;
        case 'k_Mb_F'
            element.PISA_param_index(i,1) = 4;
            element.PISA_param_index(i,2) = 9;
        case 'k_Mb_1'
            element.PISA_param_index(i,1) = 4;
            element.PISA_param_index(i,2) = 10;
        case 'k_Mb_2'
            element.PISA_param_index(i,1) = 4;
            element.PISA_param_index(i,2) = 11;
        case 'k_Mb_3'
            element.PISA_param_index(i,1) = 4;
            element.PISA_param_index(i,2) = 12;
        case 'n_Mb_F'
            element.PISA_param_index(i,1) = 4;
            element.PISA_param_index(i,2) = 13;
        case 'n_Mb_1'
            element.PISA_param_index(i,1) = 4;
            element.PISA_param_index(i,2) = 14;
        case 'n_Mb_2'
            element.PISA_param_index(i,1) = 4;
            element.PISA_param_index(i,2) = 15;
        case 'n_Mb_3'
            element.PISA_param_index(i,1) = 4;
            element.PISA_param_index(i,2) = 16;  
            
% % p-y            
% 'y_u_F' 'y_u_1' 'y_u_2' 'y_u_3'
% 'p_u_F' 'p_u_1' 'p_u_2' 'p_u_3'
% 'k_p_F' 'k_p_1' 'k_p_2' 'k_p_3'
% 'n_p_F' 'n_p_1' 'n_p_2' 'n_p_3' 

% % m-t
% 'tetam_u_F' 'tetam_u_1' 'tetam_u_2' 'tetam_u_3'
% 'm_u_F' 'm_u_1' 'm_u_2' 'm_u_3'
% 'k_m_F' 'k_m_1' 'k_m_2' 'k_m_3'
% 'n_m_F' 'n_m_1' 'n_m_2' 'n_m_3' 

% % Hb
% 'yB_u_F' 'yB_u_1' 'yB_u_2' 'yB_u_3'
% 'HB_u_F' 'HB_u_1' 'HB_u_2' 'HB_u_3'
% 'k_H_F' 'k_H_1' 'k_H_2' 'k_H_3'
% 'n_H_F' 'n_H_1' 'n_H_2' 'n_H_3'

% % Mb
% 'tetaM_u_F' 'tetaM_u_1' 'tetaM_u_2' 'tetaM_u_3'
% 'MB_u_F' 'MB_u_1' 'MB_u_2' 'MB_u_3'
% 'k_M_F' 'k_M_1' 'k_M_2' 'k_M_3'
% 'n_M_F' 'n_M_1' 'n_M_2' 'n_M_3' 

    end
end

%% TRANSLATING VARIABLES
%% P-y 
for i = 1:size(con_name,2)
    switch con_name{i}
        %%%%%%%%% p-y
        case 'y_u_F'
            element.PISA_param_index_con(i,1) = 1;
            element.PISA_param_index_con(i,2) = 1;
        case 'y_u_1'
            element.PISA_param_index_con(i,1) = 1;
            element.PISA_param_index_con(i,2) = 2;
        case 'y_u_2'
            element.PISA_param_index_con(i,1) = 1;
            element.PISA_param_index_con(i,2) = 3;
        case 'y_u_3'
            element.PISA_param_index_con(i,1) = 1;
            element.PISA_param_index_con(i,2) = 4;
        case 'p_u_F'
            element.PISA_param_index_con(i,1) = 1;
            element.PISA_param_index_con(i,2) = 5;
        case 'p_u_1'
            element.PISA_param_index_con(i,1) = 1;
            element.PISA_param_index_con(i,2) = 6;
        case 'p_u_2'
            element.PISA_param_index_con(i,1) = 1;
            element.PISA_param_index_con(i,2) = 7;
        case 'p_u_3'
            element.PISA_param_index_con(i,1) = 1;
            element.PISA_param_index_con(i,2) = 8;
        case 'k_p_F'
            element.PISA_param_index_con(i,1) = 1;
            element.PISA_param_index_con(i,2) = 9;
        case 'k_p_1'
            element.PISA_param_index_con(i,1) = 1;
            element.PISA_param_index_con(i,2) = 10;
        case 'k_p_2'
            element.PISA_param_index_con(i,1) = 1;
            element.PISA_param_index_con(i,2) = 11;
        case 'k_p_3'
            element.PISA_param_index_con(i,1) = 1;
            element.PISA_param_index_con(i,2) = 12;
        case 'n_p_F'
            element.PISA_param_index_con(i,1) = 1;
            element.PISA_param_index_con(i,2) = 13;
        case 'n_p_1'
            element.PISA_param_index_con(i,1) = 1;
            element.PISA_param_index_con(i,2) = 14;
        case 'n_p_2'
            element.PISA_param_index_con(i,1) = 1;
            element.PISA_param_index_con(i,2) = 15;
        case 'n_p_3'
            element.PISA_param_index_con(i,1) = 1;
            element.PISA_param_index_con(i,2) = 16;
            
            
            
            %%%%%%%%% m-t
        case 'tetam_u_F'
            element.PISA_param_index_con(i,1) = 2;
            element.PISA_param_index_con(i,2) = 1;
        case 'tetam_u_1'
            element.PISA_param_index_con(i,1) = 2;
            element.PISA_param_index_con(i,2) = 2;
        case 'tetam_u_2'
            element.PISA_param_index_con(i,1) = 2;
            element.PISA_param_index_con(i,2) = 3;
        case 'tetam_u_3'
            element.PISA_param_index_con(i,1) = 2;
            element.PISA_param_index_con(i,2) = 4;
        case 'm_u_F'
            element.PISA_param_index_con(i,1) = 2;
            element.PISA_param_index_con(i,2) = 5;
        case 'm_u_1'
            element.PISA_param_index_con(i,1) = 2;
            element.PISA_param_index_con(i,2) = 6;
        case 'm_u_2'
            element.PISA_param_index_con(i,1) = 2;
            element.PISA_param_index_con(i,2) = 7;
        case 'm_u_3'
            element.PISA_param_index_con(i,1) = 2;
            element.PISA_param_index_con(i,2) = 8;
        case 'k_m_F'
            element.PISA_param_index_con(i,1) = 2;
            element.PISA_param_index_con(i,2) = 9;
        case 'k_m_1'
            element.PISA_param_index_con(i,1) = 2;
            element.PISA_param_index_con(i,2) = 10;
        case 'k_m_2'
            element.PISA_param_index_con(i,1) = 2;
            element.PISA_param_index_con(i,2) = 11;
        case 'k_m_3'
            element.PISA_param_index_con(i,1) = 2;
            element.PISA_param_index_con(i,2) = 12;
        case 'n_m_F'
            element.PISA_param_index_con(i,1) = 2;
            element.PISA_param_index_con(i,2) = 13;
        case 'n_m_1'
            element.PISA_param_index_con(i,1) = 2;
            element.PISA_param_index_con(i,2) = 14;
        case 'n_m_2'
            element.PISA_param_index_con(i,1) = 2;
            element.PISA_param_index_con(i,2) = 15;
        case 'n_m_3'
            element.PISA_param_index_con(i,1) = 2;
            element.PISA_param_index_con(i,2) = 16; 
            
            
            
            
           %%%%%%%%% Hb 
       case 'yB_u_F'
            element.PISA_param_index_con(i,1) = 3;
            element.PISA_param_index_con(i,2) = 1;
        case 'yB_u_1'
            element.PISA_param_index_con(i,1) = 3;
            element.PISA_param_index_con(i,2) = 2;
        case 'yB_u_2'
            element.PISA_param_index_con(i,1) = 3;
            element.PISA_param_index_con(i,2) = 3;
        case 'yB_u_3'
            element.PISA_param_index_con(i,1) = 3;
            element.PISA_param_index_con(i,2) = 4;
        case 'HB_u_F'
            element.PISA_param_index_con(i,1) = 3;
            element.PISA_param_index_con(i,2) = 5;
        case 'HB_u_1'
            element.PISA_param_index_con(i,1) = 3;
            element.PISA_param_index_con(i,2) = 6;
        case 'HB_u_2'
            element.PISA_param_index_con(i,1) = 3;
            element.PISA_param_index_con(i,2) = 7;
        case 'HB_u_3'
            element.PISA_param_index_con(i,1) = 3;
            element.PISA_param_index_con(i,2) = 8;
        case 'k_H_F'
            element.PISA_param_index_con(i,1) = 3;
            element.PISA_param_index_con(i,2) = 9;
        case 'k_H_1'
            element.PISA_param_index_con(i,1) = 3;
            element.PISA_param_index_con(i,2) = 10;
        case 'k_H_2'
            element.PISA_param_index_con(i,1) = 3;
            element.PISA_param_index_con(i,2) = 11;
        case 'k_H_3'
            element.PISA_param_index_con(i,1) = 3;
            element.PISA_param_index_con(i,2) = 12;
        case 'n_H_F'
            element.PISA_param_index_con(i,1) = 3;
            element.PISA_param_index_con(i,2) = 13;
        case 'n_H_1'
            element.PISA_param_index_con(i,1) = 3;
            element.PISA_param_index_con(i,2) = 14;
        case 'n_H_2'
            element.PISA_param_index_con(i,1) = 3;
            element.PISA_param_index_con(i,2) = 15;
        case 'n_H_3'
            element.PISA_param_index_con(i,1) = 3;
            element.PISA_param_index_con(i,2) = 16;  
            
            
            
           %%%%%%%%% Mb  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'tetaMb_u_F'
            element.PISA_param_index_con(i,1) = 4;
            element.PISA_param_index_con(i,2) = 1;
        case 'tetaMb_u_1'
            element.PISA_param_index_con(i,1) = 4;
            element.PISA_param_index_con(i,2) = 2;
        case 'tetaMb_u_2'
            element.PISA_param_index_con(i,1) = 4;
            element.PISA_param_index_con(i,2) = 3;
        case 'tetaMb_u_3'
            element.PISA_param_index_con(i,1) = 4;
            element.PISA_param_index_con(i,2) = 4;
        case 'MB_u_F'
            element.PISA_param_index_con(i,1) = 4;
            element.PISA_param_index_con(i,2) = 5;
        case 'MB_u_1'
            element.PISA_param_index_con(i,1) = 4;
            element.PISA_param_index_con(i,2) = 6;
        case 'MB_u_2'
            element.PISA_param_index_con(i,1) = 4;
            element.PISA_param_index_con(i,2) = 7;
        case 'MB_u_3'
            element.PISA_param_index_con(i,1) = 4;
            element.PISA_param_index_con(i,2) = 8;
        case 'k_Mb_F'
            element.PISA_param_index_con(i,1) = 4;
            element.PISA_param_index_con(i,2) = 9;
        case 'k_Mb_1'
            element.PISA_param_index_con(i,1) = 4;
            element.PISA_param_index_con(i,2) = 10;
        case 'k_Mb_2'
            element.PISA_param_index_con(i,1) = 4;
            element.PISA_param_index_con(i,2) = 11;
        case 'k_Mb_3'
            element.PISA_param_index_con(i,1) = 4;
            element.PISA_param_index_con(i,2) = 12;
        case 'n_Mb_F'
            element.PISA_param_index_con(i,1) = 4;
            element.PISA_param_index_con(i,2) = 13;
        case 'n_Mb_1'
            element.PISA_param_index_con(i,1) = 4;
            element.PISA_param_index_con(i,2) = 14;
        case 'n_Mb_2'
            element.PISA_param_index_con(i,1) = 4;
            element.PISA_param_index_con(i,2) = 15;
        case 'n_Mb_3'
            element.PISA_param_index_con(i,1) = 4;
            element.PISA_param_index_con(i,2) = 16;  
    end
end
end
% end