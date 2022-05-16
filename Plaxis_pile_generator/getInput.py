def readFile(fileName):
    file = open(fileName,'r') 
    allLines = file.readlines()
    lines = []
    for line in allLines:
        if line[0] != '#':
            lines.append(line)
    file.close()
    return lines

def getInfo(df):
    import math
    import numpy as np
    
    pPropDict= dict(D=float(df['Diameter'][0]),
                    L=float(df['Total length'][0]),l=float(df['buried length'][0]),
                    h=float(df['slice height'][0]))
                    
    seaLevel=float(df['Sea level'][0])
    
    global_scour=float(df['Global_scour'][0])
    
    local_scour=float(df['Local_scour'][0])
    
    forceDict=dict(V=float(df['Vertical'][0]),H=float(df['Horizontal'][0]),
                M=float(df['Bending moment'][0]))
    
    DispDict= dict(Disp_phase_1=float(df['D/200'][0])*float(df['Diameter'][0]),Disp_phase_2=float(df['D/10'][0])*float(df['Diameter'][0]))
    
    SLS_load = df['SLS_load'].dropna().values.tolist()
    mesh_coarseness = df['mesh_coarseness'].dropna().values.tolist();
    
    sPropList=[]
    soil_layers=[0]
    for i in range(len(df['t_i'].values.tolist())):
        
        sPropList.append(dict(t=float(df['t_i'].dropna().values.tolist()[i]),Constitutive=str(df['Constitutive_model'].dropna().values.tolist()[i]),Interface_constitutive=str(df['Interface_model'].dropna().values.tolist()[i]),Eoed=float(df['E_oed'].dropna().values.tolist()[i]),
                                E50=float(df['E_50'].dropna().values.tolist()[i]), 
                                E=float(df['E_ur'].dropna().values.tolist()[i]),
                                m=float(df['m'].dropna().values.tolist()[i]), nu=float(df['v_i'].dropna().values.tolist()[i]),
        						c=float(df['c_i'].dropna().values.tolist()[i]), gamma07=float(df['gamma07'].dropna().values.tolist()[i]),
                                G0ref=float(df['G0'].dropna().values.tolist()[i]), 
                                phi=float(df['phi_i'].dropna().values.tolist()[i]), dref=float(df['d_ref'].dropna().values.tolist()[i]), psi=float(df['psi'].dropna().values.tolist()[i]),
                                cinc=float(df['c_inc_i'].dropna().values.tolist()[i]), gamma=float(df['gamma'].dropna().values.tolist()[i]),
                                K0=float(df['K0'].dropna().values.tolist()[i]), Ri=float(df['R_inter_i'].dropna().values.tolist()[i]), OCR=float(df['OCR'].dropna().values.tolist()[i]),
                                Drainage=float(df['Drainage'].dropna().values.tolist()[i]),Dilation=float(df['dilation cut-off'].dropna().values.tolist()[i]),
                                e0=float(df['e0'].dropna().values.tolist()[i]),emin=float(df['emin'].dropna().values.tolist()[i]),emax=float(df['emax'].dropna().values.tolist()[i]),
                                                         
                                G0_suA=float(df['G0/suA'].dropna().values.tolist()[i]),Gur_suA=float(df['Gur/suA'].dropna().values.tolist()[i]),gamma_f_C=float(df['gamma_f_C'].dropna().values.tolist()[i]),
                                gamma_f_E=float(df['gamma_f_E'].dropna().values.tolist()[i]),gamma_f_DSS=float(df['gamma_f_DSS'].dropna().values.tolist()[i]),
                                su_A_ref=float(df['su_A_ref'].dropna().values.tolist()[i]),zref=float(df['zref'].dropna().values.tolist()[i]),
                                suA_inc=float(df['suA_inc'].dropna().values.tolist()[i]),suP_suA=float(df['suP/suA'].dropna().values.tolist()[i]),
                                tau0_suA=float(df['tau0/suA'].dropna().values.tolist()[i]),suDSS_suA=float(df['suDSS/suA'].dropna().values.tolist()[i])))
        
                                
    
    for i in range(len(df['t_i'].values.tolist())):    
        if round(soil_layers[i]-float(df['t_i'].values.tolist()[i]),2)>-float(df['buried length'][0]):
            soil_layers.append(round(soil_layers[i]-float(df['t_i'].values.tolist()[i]),2))
        else:
            break

    soil_layers2=[]
    for i in range(int(df['buried length'][0])+1):
        if float(-i) not in soil_layers:
            Condition=True
            for j in range(len(soil_layers)):
                if abs(abs(float(-i))-abs(soil_layers[j]))>0.5:
                    if abs(abs(float(-i))-abs(df['buried length'][0]))>0.5:
                        Condition=True
                    else:
                        Condition=False
                        break                        
                else:
                    Condition=False
                    break
            if Condition==True:   
                soil_layers2.append(float(-i)) 
                
    soil_layers=soil_layers+soil_layers2            
    soil_layers.sort(reverse = False)
    
    pile_thickness=[]
    thickness_layers=[]
    for i in range(len(df['Thickness'].values.tolist())):
        if np.isnan(df['Thickness'].values.tolist()[i])== False :
            pile_thickness.append(round(df['Thickness'].values.tolist()[i],3))
            thickness_layers.append(round(-df['bot_thickness'].values.tolist()[i],2))
    
   
    return pPropDict, seaLevel, forceDict, DispDict, sPropList, soil_layers, pile_thickness, thickness_layers, global_scour, local_scour, SLS_load, mesh_coarseness