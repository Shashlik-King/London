# -*- coding: utf-8 -*-
"""
Created on Wed Jan 12 11:38:39 2022

@author: CGQU
"""

from plxscripting.easy import *
import pandas as pd
import csv, xlsxwriter, math, getInput,sys,os
#s_i, g_i = new_server('localhost', 10000, password='!YNW<c6W>mg?Mt8v')
import numpy as np

s_i, g_i = new_server('localhost', 10000, password='!YNW<c6W>mg?Mt8v')

def make_soilmat(g_i, parameters, material=None):
    """ Creates or updates a soil material dataset with the defined parameter
        values.
        overcoming the interdependencies of parameters and the issues
        of derived parameters
        g_i: Plaxis global object
        parameters: a list of tuples, each: ("parameter name", value)
        optional: material. When defined, it will update this material object
    """

    # add required parameters to tuple when not present
    # to be expanded

    # create material
    if material is None:
        material = g_i.soilmat(*parameters)
    else:
        # update properties:
        g_i.setproperties(material, *parameters)

    # force to check parameters and execute manually when needed
    soil_attributes = dir(material)
    for item in parameters:
        param_name = item[0]
        param_value = item[1]

        # check presence of parameter in material object (case insensitive)
        paramname_input = None
        for soil_attribute_name in soil_attributes:
            if soil_attribute_name.lower() == param_name.lower():
                paramname_input = soil_attribute_name

        if paramname_input and hasattr(material, paramname_input):
            param_obj = getattr(material, paramname_input)
            try:
                if param_obj.value != param_value:
                    # print("Old value {} = {} => {}".format(param_name,
                    #                                        param_obj.value,
                    #                                        param_value))
                    param_obj.set(param_value)
            except:
                print("Could not set: {}".format(param_name))

    return material	

file = 'Soil_clusters.xlsx'
xl = pd.ExcelFile(file)
excel_sheets=(xl.sheet_names)

df=xl.parse(excel_sheets[0])
model_name=excel_sheets[0]

soil_list=[]
for i in range(len(df['Cluster'].dropna().values.tolist())):
    
    
    soil_list.append(dict(Cluster=str(df['Cluster'].dropna().values.tolist()[i]),Constitutive=str(df['Constitutive_model'].dropna().values.tolist()[i]),Eoed=float(df['E_oed'].dropna().values.tolist()[i]),
                            E50=float(df['E_50'].dropna().values.tolist()[i]), 
                            E=float(df['E_ur'].dropna().values.tolist()[i]),
                            m=float(df['m'].dropna().values.tolist()[i]), nu=float(df['v_i'].dropna().values.tolist()[i]),
    						c=float(df['c_i'].dropna().values.tolist()[i]), gamma07=float(df['gamma07'].dropna().values.tolist()[i]),
                            G0ref=float(df['G0'].dropna().values.tolist()[i]), 
                            phi=float(df['phi_i'].dropna().values.tolist()[i]), dref=float(df['d_ref'].dropna().values.tolist()[i]), psi=float(df['psi'].dropna().values.tolist()[i]),
                            cinc=float(df['c_inc_i'].dropna().values.tolist()[i]), gamma=float(df['gamma'].dropna().values.tolist()[i]),
                            K0=float(df['K0'].dropna().values.tolist()[i]), Ri=float(df['R_inter_i'].dropna().values.tolist()[i]), 
                            Drainage=float(df['Drainage'].dropna().values.tolist()[i]),Dilation=float(df['dilation cut-off'].dropna().values.tolist()[i]),
                            e0=float(df['e0'].dropna().values.tolist()[i]),emin=float(df['emin'].dropna().values.tolist()[i]),emax=float(df['emax'].dropna().values.tolist()[i]),
                                                     
                            Gur_suA=float(df['Gur/suA'].dropna().values.tolist()[i]),gamma_f_C=float(df['gamma_f_C'].dropna().values.tolist()[i]),
                            gamma_f_E=float(df['gamma_f_E'].dropna().values.tolist()[i]),gamma_f_DSS=float(df['gamma_f_DSS'].dropna().values.tolist()[i]),
                            su_A_ref=float(df['su_A_ref'].dropna().values.tolist()[i]),zref=float(df['zref'].dropna().values.tolist()[i]),
                            suA_inc=float(df['suA_inc'].dropna().values.tolist()[i]),suP_suA=float(df['suP/suA'].dropna().values.tolist()[i]),
                            tau0_suA=float(df['tau0/suA'].dropna().values.tolist()[i]),suDSS_suA=float(df['suDSS/suA'].dropna().values.tolist()[i])))

material_dict={}

for prop in soil_list:
    if prop['Constitutive']== "HSsmall":
        if prop['Drainage'] == 1:
            drainageType = "Undrained B"
        elif prop['Drainage'] == 2:
            drainageType = "Undrained A"
        else:
            drainageType = "Drained"
            
        if int(prop['Dilation'])==0:
            params = [("MaterialName", prop['Cluster']), 
                      ("SoilModel", 4),
                      ("DrainageType", drainageType),
                      ("gammaUnsat", prop['gamma']),
                      ("gammaSat", prop['gamma']),
                      ("Gref", prop['E']/2/(1+prop['nu'])),
                      ("E50ref", prop['E50']),
                      ("EoedRef", prop['Eoed']),
                      ("powerm", prop['m']),
                      ("G0ref", prop['G0ref']),
                      ("gamma07", prop['gamma07']),
                      ("nu", prop['nu']),
                      ("cref", prop['c']),
                      ("cinc", prop['cinc']),
                      ("verticalref", prop['dref']),
                      ("Rinter", prop['Ri']),
                      ("K0Determination", 0),
                      ("K0Primary", prop['K0']),
                      ("K0PrimaryIsK0Secondary", True),
                      ("K0nc", 1 - math.sin(math.radians(prop['phi']))),
                      ("phi", prop['phi']),
                      ("psi", prop['psi'])]
        else:
            params = [("MaterialName", prop['Cluster']), 
                      ("SoilModel", 4),
                      ("DrainageType", drainageType),
                      ("gammaUnsat", prop['gamma']),
                      ("gammaSat", prop['gamma']),
                      ("Gref", prop['E']/2/(1+prop['nu'])),
                      ("E50ref", prop['E50']),
                      ("EoedRef", prop['Eoed']),
                      ("powerm", prop['m']),
                      ("G0ref", prop['G0ref']),
                      ("gamma07", prop['gamma07']),
                      ("nu", prop['nu']),
                      ("cref", prop['c']),
                      ("cinc", prop['cinc']),
                      ("verticalref", prop['dref']),
                      ("Rinter", prop['Ri']),
                      ("K0Determination", 0),
                      ("K0Primary", prop['K0']),
                      ("K0PrimaryIsK0Secondary", True),
                      ("K0nc", 1 - math.sin(math.radians(prop['phi']))),
                      ("phi", prop['phi']),
                      ("psi", prop['psi']),
                      ("DilatancyCutOff", True),
                      ("einit", prop['e0']),
                      ("emin", prop['emin']),
                      ("emax",prop['emax'])]  
    elif prop['Constitutive']== "NGI_ADP":  
        if prop['Drainage'] == 1:
            drainageType = "Undrained C"  
        elif prop['Drainage'] == 0:   
            drainageType = "Drained" 

        params = [("MaterialName", prop['Cluster']), 
                      ("SoilModel", 9),
                      ("DrainageType", drainageType),
                      ("gammaUnsat", prop['gamma']),
                      ("gammaSat", prop['gamma']),
                      ("IncreaseOfShearStrengthWithVerticalRef", prop['suA_inc']),
                      ("ReferenceShearStrength", prop['su_A_ref']),
                      ("AxialFailureStrainTriaxialCompression", prop['gamma_f_C']),
                      ("AxialFailureStrainTriaxialExtension", prop['gamma_f_E']),
                      ("UnloadingShearStiffness", prop['Gur_suA']),
                      ("ShearFailureStrainDirectSimpleShear", prop['gamma_f_DSS']),
                      ("nu", prop['nu']),
                      ("RelativeDirectShearStrength", prop['suDSS_suA']),
                      ("InitialMobilization", prop['tau0_suA']),
                      ("RelativePassiveStrength", prop['suP_suA']),
                      ("Rinter", prop['Ri']),
                      ("K0Determination", 0),
                      ("K0Primary", prop['K0']),
                      ("K0PrimaryIsK0Secondary", True),
                      (" verticalref", prop['zref'])]                  

    material_dict[prop['Cluster']]=make_soilmat(g_i,params)

soil_list[1]["Cluster"]
    
file2 = 'Data_Base.xlsx'
xl2 = pd.ExcelFile(file2)
excel_sheets=(xl.sheet_names)

df2=xl2.parse(model_name)


pileProp, waterLevel, force, displacement, soilProp,soil_layers,pile_thickness, thickness_layers, global_scour, local_scour, clustering_vector, circle_division,vertical_separation = getInput.getInfo(df2)
print(pileProp, waterLevel, force, displacement, soilProp, soil_layers,pile_thickness, thickness_layers, global_scour, local_scour)

D = pileProp['D']
L = pileProp['L']
l = pileProp['l']

j=-vertical_separation[0]
vertical_clusters=[]

while j >=-l:
    vertical_clusters.append(soil_layers[min(range(len(soil_layers)), key = lambda i: abs(soil_layers[i]-j))])
    j=j-vertical_separation[0]
if -l not in vertical_clusters:
    vertical_clusters.append(-l)
    

clustering=[D/2]
    
for i in range(len(clustering_vector)):
    clustering.append(clustering_vector[i])
   
clusters_pos={}
clusters_neg={}

for i  in range(len(vertical_clusters)):
    for z in range(len(clustering)-1):
       name_dict="cluster_"+str(i+1)+"_"+str(z+1)
       clusters_neg[name_dict]=[]
       clusters_pos[name_dict]=[]
    
for soils in g_i.Soils:
    strBB = soils.Parent.BoundingBox.value

    z1 = float(strBB.split(';')[2].split(')')[0])
    z2 = float(strBB.split(';')[4].split(')')[0])
    x1 = float(strBB.split(';')[0].split('(')[1])
    x2 = float(strBB.split(';')[2].split('(')[1])
    y1 = float(strBB.split(';')[1])
    y2 = float(strBB.split(';')[3])
    
      
    for i  in range(len(vertical_clusters)):            
        if abs(z1-vertical_clusters[i])<0.2: 
            
           if x1 < -0.2:                 
                hipotenuse= math.sqrt(x1**2+y1**2)                   
#                    hipotenuse= math.sqrt(x1**2+y1**2) 
#                    for j in range(int(circle_division[0])*2):
 #                   print(hipotenuse,x1,y1)   
                for z in range(len(clustering)-1):
                                           
                    if hipotenuse>(clustering[z]+0.2) and hipotenuse<=(clustering[z+1]+0.2):
                        
  #                          print(hipotenuse,clustering_vector[z],x1,y1,z1,clustering[z+1],"yes")
                        
                        name_dict="cluster_"+str(i+1)+"_"+str(z+1)
                        
                        clusters_neg[name_dict].append([x1,soils,y1,z1]) #soils
           else:
                hipotenuse= math.sqrt(x2**2+y1**2)
                
                for z in range(len(clustering)-1):
                                           
                    if hipotenuse>(clustering[z]+0.2) and hipotenuse<=(clustering[z+1]+0.2):
                        
#                            print(hipotenuse,clustering_vector[z],x1,y1,z1,clustering[z+1],"yes")
                        
                        name_dict="cluster_"+str(i+1)+"_"+str(z+1)
                        
                        clusters_pos[name_dict].append([x2,soils,y1,z1]) #soils                           

for i  in range(len(vertical_clusters)):
    for z in range(len(clustering)-1):
       name_dict="cluster_"+str(i+1)+"_"+str(z+1)
       clusters_pos[name_dict].sort(reverse=True)
       clusters_neg[name_dict].sort(reverse=True)
       
all_clusters_BB={}
all_clusters={}

for i  in range(len(vertical_clusters)):
    for z in range(len(clustering)-1): 
        for j in range(int(circle_division[0])*2):
            name_dict="cluster_"+str(i+1)+"_"+str(z+1)+"_"+str(j+1) 
            all_clusters[name_dict]=[]
            all_clusters_BB[name_dict]=[]
                
for i  in range(len(vertical_clusters)):
    for z in range(len(clustering)-1):
        name_dict="cluster_"+str(i+1)+"_"+str(z+1)
        for j in range(int(circle_division[0])):
            name_dict2="cluster_"+str(i+1)+"_"+str(z+1)+"_"+str(j+1) 

            all_clusters[name_dict2].append(clusters_pos[name_dict][j][1])
            
            all_clusters_BB[name_dict2].append([clusters_pos[name_dict][j][0],clusters_pos[name_dict][j][2],clusters_pos[name_dict][j][3]])
            
            name_dict3="cluster_"+str(i+1)+"_"+str(z+1)+"_"+str(j+1+int(circle_division[0]))
            
            all_clusters[name_dict3].append(clusters_neg[name_dict][j][1]) 
            
            all_clusters_BB[name_dict3].append([clusters_neg[name_dict][j][0],clusters_neg[name_dict][j][2],clusters_neg[name_dict][j][3]])

for i in all_clusters.keys():
    g_i.setmaterial(all_clusters[i][0], material_dict['cluster_1_1_1'])
    
g_i.gotostages()

eps = 1e-5
nStepsPYCurve = 20

pilephase = g_i.phase(g_i.Phases[3])
g_i.setcurrentphase(pilephase)
pilephase.Identification = "D/200 modified"


for interface in g_i.NegativeInterface_1:
    strBB = interface.Parent.BoundingBox.value
    z1 = float(strBB.split(';')[2].split(')')[0])
    z2 = float(strBB.split(';')[4].split(')')[0])
    if max(z1,z2) <= 0:
        interface.MaterialMode[pilephase] = "From adjacent soil"
  
for interface in g_i.PositiveInterface_1:
    strBB = interface.Parent.BoundingBox.value
    z1 = float(strBB.split(';')[2].split(')')[0])
    z2 = float(strBB.split(';')[4].split(')')[0])
    if max(z1,z2) <= 0:
        interface.MaterialMode[pilephase] = "From adjacent soil"
        
pilephase.Deform.ResetDisplacementsToZero = True
pilephase.MaxStepsStored = pilephase.Deform.MaxSteps
pilephase.Deform.UseDefaultIterationParams = False
pilephase.Deform.MaxLoadFractionPerStep = (1./nStepsPYCurve)
for rb in g_i.Rigidbodies:
    rb.ux[pilephase] = (displacement['Disp_phase_1']*(pileProp['L']-(pileProp['l']/3)))/((2/3)*pileProp['l'])	#Applying displacement at top of the rigid body in order to obtain the input prescribed displacements at mudline

pilephase2 = g_i.phase(g_i.Phases[3])
g_i.setcurrentphase(pilephase2)
pilephase2.Identification = "D/10 modified"

for interface in g_i.NegativeInterface_1:
    strBB = interface.Parent.BoundingBox.value
    z1 = float(strBB.split(';')[2].split(')')[0])
    z2 = float(strBB.split(';')[4].split(')')[0])
    if max(z1,z2) <= 0:
        interface.MaterialMode[pilephase] = "From adjacent soil"
  
for interface in g_i.PositiveInterface_1:
    strBB = interface.Parent.BoundingBox.value
    z1 = float(strBB.split(';')[2].split(')')[0])
    z2 = float(strBB.split(';')[4].split(')')[0])
    if max(z1,z2) <= 0:
        interface.MaterialMode[pilephase] = "From adjacent soil"
        
pilephase2.Deform.ResetDisplacementsToZero = True
pilephase2.MaxStepsStored = pilephase2.Deform.MaxSteps
pilephase2.Deform.UseDefaultIterationParams = False
pilephase2.Deform.MaxLoadFractionPerStep = (1./nStepsPYCurve)

for rb in g_i.Rigidbodies:
    rb.ux[pilephase2] = (displacement['Disp_phase_2']*(pileProp['L']-(pileProp['l']/3)))/((2/3)*pileProp['l'])	#Applying displacement at top of the rigid body in order to obtain the input prescribed displacements at mudline
 