# -*- coding: utf-8 -*-
"""
Created on Tue Feb  9 12:48:26 2021

@author: CGQU
"""


import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit
import math
import pandas as pd
from sklearn.linear_model import LinearRegression 
from math import *
import os, xlsxwriter,openpyxl
from scipy.stats import kde
from scipy.stats import gaussian_kde



#from TX_translator import *
get_ipython().run_line_magic('matplotlib', 'qt')
'''
Dr_k0_sand = 0  
Specififc_CPT_active = 0
Specififc_CPT_name = "GT1A_BH01"
  
k0_clay = 0
Su_cal = 0
plot_density  = 1
plot_normal   = 0

def unique(list1): 
  
    # intilize a null list 
    unique_list = [] 
      
    # traverse for all elements 
    for x in list1: 
        # check if exists in unique_list or not 
        if x not in unique_list: 
            unique_list.append(x)
    return  unique_list        

from os import walk

cwd = os.getcwd()
file_names = []
BH_names = []
name = []
Su_lab = []
Su_Fugro = []
Depth = []
OCR =[]
K0_lab = []

inventory_excel="Test_inventory.xlsx"
xl = pd.ExcelFile(inventory_excel)
excel_sheets=(xl.sheet_names)
inventory=pd.read_excel(inventory_excel,sheet_name="Inventory")

used_tests=inventory[inventory["Use"]==1]
Soil_unit_tests=inventory[inventory["Use"]==1]["Unit"].values.tolist()

unique_SU=unique(Soil_unit_tests)

for j in range(len(used_tests)):
    name.append(used_tests["PointID"].values.tolist()[j]+"_"+used_tests["Samp_Ref"].values.tolist()[j])
    BH_names.append(used_tests["PointID"].values.tolist()[j])
    Depth.append(used_tests["Depth"].values.tolist()[j])
    Su_lab.append(used_tests["SU"].values.tolist()[j])
    Su_Fugro.append(used_tests["SU"].values.tolist()[j])
    OCR.append(used_tests["OCR"].values.tolist()[j])
    K0_lab.append(used_tests["K0_lab"].values.tolist()[j])
    
CPT_excel="CPT_soil_unit_red_name.xlsx"
xl = pd.ExcelFile(CPT_excel)
excel_sheets=(xl.sheet_names)
cpt=pd.read_excel(CPT_excel,sheet_name=unique_SU[0])
df=cpt[['BH','Depth [m]','SBH_NQT','SBH_FRR' , 'SBH_QNET' , 'SBH_FRES' , "SBH_BQ" , "SBH_RES"]].dropna()


plt.figure(figsize=(5,15))
plt.scatter(df['SBH_QNET'], df["Depth [m]"] ,  label="qt")
plt.legend(loc='best')
plt.ylabel('Depth (m)')
plt.xlabel('Cone resistance (MPa)')
plt.legend(loc='best')
plt.gca().invert_yaxis()
plt.show()


##############################################################################################################
#----------------------------------------------- Dr_K0_Sand -------------------------------------------------#
##############################################################################################################

if Dr_k0_sand ==1:
    
    density = 10.0
   
    # any filttering of data if needed
    df2=df[df["Depth [m]"] > 0.5] 
    df3=df2[df2["SBH_QNET"] < 100]
    
    if Specififc_CPT_active==0:
        depth=np.array(df3["Depth [m]"])
        qt=np.array(df3["SBH_QNET"])
        qc=np.array(df3["SBH_RES"])
    else:
        # Filtering for a specific CPT
        df3=df3[df3["BH"] == "OCW_GT2_BOSSA"] 
        depth=np.array(df3["Depth [m]"])
        qt=np.array(df3["SBH_QNET"])
        qc=np.array(df3["SBH_RES"])
    
    
    
    k0_cpt_fugro = np.zeros(len(depth))
    k0_cpt_Lunne = np.zeros(len(depth))
    OCR_cpt_Lunne = np.zeros(len(depth))
    phi= np.zeros(len(depth))
    k0_nc = np.zeros(len(depth))
    sin_phi = np.zeros(len(depth))
    Dr_fugro_dry = np.zeros(len(depth))
    Dr_fugro_sat = np.zeros(len(depth))
    
    sigmv = density*depth
    phi = 17.6 + 11.0 *np.log10( (10.0*qt) / ( (sigmv/100.0)**0.5 ) ) 
    phi_rad = phi*3.1415/180.0
    sin_phi = np.sin(phi_rad)
    
    k0_cpt_fugro = ( (sigmv**(1.15*sin_phi/(1-3.7*sin_phi)))*( (1-sin_phi)**(1/(1-3.7*sin_phi))) 
                                                  / ( (2.876**(sin_phi/(1-3.7*sin_phi)))
                                                     * (qt**(0.815*sin_phi/(1-3.7*sin_phi)))    )
                                                  )
    
    OCR_cpt_Lunne = (0.33*((1000.0*qt-(sigmv+10.0))**0.72))/sigmv
    k0_cpt_Lunne = (1-sin_phi)*(OCR_cpt_Lunne**sin_phi)
    
    k0_nc = 1-sin_phi
    
    K0_dr = 0.5
    
    Dr_fugro_dry = (1/0.0296)*np.log((qc/2.494)*(0.01*sigmv*(((1+2*K0_dr)/3)**0.46)  ) )
    
    Dr_fugro_sat = ( 0.01*(-1.87+2.32*np.log( 1000.0*qc/( (100*sigmv)**0.5 )  ) ) + 1 )*Dr_fugro_dry
    
    # n_bins = 10
    
    # fig, axs = plt.subplots(1, 2, sharey=True, tight_layout=True)
    
    # # We can set the number of bins with the `bins` kwarg
    # axs[0].hist(k0, bins=n_bins)
    # axs[1].hist(qt, bins=n_bins)
    
    
    plt.figure(figsize=(5,15))
    # plt.plot(k0_cpt_fugro, depth, marker='.', label="K0_CPT_Fugro")
    plt.scatter(k0_cpt_Lunne, depth, label="K0_CPT_Lunne")
    plt.scatter(k0_nc, depth ,  label="K0_NC")
    plt.legend(loc='best')
    plt.ylabel('Depth (m)')
    plt.xlabel('K0')
    plt.legend(loc='best')
    plt.gca().invert_yaxis()
    plt.show()
    
    plt.figure(figsize=(5,15))
    plt.scatter(OCR_cpt_Lunne, depth ,  label="OCR-Lunne")
    plt.legend(loc='best')
    plt.ylabel('Depth (m)')
    plt.xlabel('OCR')
    plt.legend(loc='best')
    plt.gca().invert_yaxis()
    plt.show()

    plt.figure(figsize=(5,15))
    plt.scatter(Dr_fugro_sat, depth )
    plt.legend(loc='best')
    plt.ylabel('Depth (m)')
    plt.xlabel('Relative Density %')
    plt.legend(loc='best')
    plt.gca().invert_yaxis()
    plt.show()    
    
    # plt.figure(figsize=(5,15))
    # plt.plot(qt, depth ,  label="qt")
    # plt.legend(loc='best')
    # plt.ylabel('Depth (m)')
    # plt.xlabel('Cone resistance (MPa)')
    # plt.legend(loc='best')
    # plt.gca().invert_yaxis()
    # plt.show()



my_dict={}

#####################################selection of the tests based on the depth of sample 
for i in range(len(used_tests)):
    test_BH=used_tests["PointID"].values.tolist()[i]
    test_Depth=used_tests["Depth"].values.tolist()[i]
    df_loc=df[df["BH"] ==test_BH]
    df_ld=df_loc[df_loc['Depth [m]']>(test_Depth-0.52)]
    df_ld2=df_ld[df_ld['Depth [m]']<(test_Depth+0.52)]
    my_dict[i]=df_ld2

  
    
    
#######create a dictiorary based on G_Max, Depth and name of BH 
###### to be done ##########3
    
'''    
#########PS log and SCPT selection of the depth 


def CPT_coreponding_G_ref(Depth,BH_Name,G_ref,df_CPT,OCR_Pc,phi_cr):
    Used_Gref={}
    Used_Gref["BH_name"]=BH_Name
    Used_Gref["Depth"]=Depth
    
    df_CPT = df_CPT.reset_index(drop=True)
    
    my_dict={}
    Average_DR=[]
    Average_DR_Baldi=[]
    Average_K0_lunne=[]
    Average_K0_Fugro=[]
    Average_OCR=[]
    Average_qt=[]
    
    for i in range(len(Used_Gref["Depth"])):
        test_BH=Used_Gref["BH_name"][i]
        test_Depth=Used_Gref["Depth"][i]
        idx=[]
        
        for jjj in range(len(df_CPT["BH"])):
            if test_BH in df_CPT["BH"][jjj]:
               idx.append(jjj)
               
        df_loc=df_CPT.filter(idx,axis=0)
        
        #df_loc=df[df["BH"] ==test_BH]
        df_ld=df_loc[df_loc['Depth [m]']>(test_Depth-0.25)]
        df_ld2=df_ld[df_ld['Depth [m]']<(test_Depth+0.25)]
        my_dict[i]=df_ld2
    
    colors = ['#1f27b4','#ff1f0e','#2ca02c','#d69728','#9497bd','#8c564b','#e377c2','#7f7f5f','#bcbd72','#17becf','#1a55FF','#8B008B','#008000','#FF4500', '#000000','#D2691E', '#ADFF2F', '#AFEEEE','#FFFF00']
    
    mark=0
    markerss=['o',	'*',	'.',	',',	'x',	'X',	'+',	'P',	's',	'D',	'd',	'p',	'H',	'h',	'v',	'^','<','H',	'h',	'v',	'^',	'<', '<','H',	'h',	'v',	'^',	'<']
          
    color_dic={}
    col=0
    unique_BH=list(set(Used_Gref["BH_name"]))
    
    for ccc in unique_BH:
        color_dic[ccc]=colors[col]
        col=col+1
          

    plt.figure(figsize=(5,10))
    ax = plt.subplot(111)
    
    for i in range(len(Used_Gref["Depth"])):
        qt = my_dict[i]["SBH_QNET"]
        qc= my_dict[i]["SBH_RES"]
        depth_GRef = my_dict[i]["Depth [m]"]
        test_BH=Used_Gref["BH_name"][i]
        Depth_txt="{:.2f}".format(round(Used_Gref["Depth"][i], 2))
        plt.scatter(qt, depth_GRef, label=test_BH+" Depth of "+Depth_txt, c=color_dic[test_BH])
        plt.legend(bbox_to_anchor=(1.02, 1.2), loc='upper left') #bbox_to_anchor=(0.5, 0.5)
        plt.ylabel('Depth (m)')
        plt.xlabel('Cone resistance (MPa)')
        mark=mark+1
    plt.gca().invert_yaxis()    
    plt.show()
    
    # plt.figure(figsize=(5,10))
    # ax = plt.subplot(111)
    plt.figure(figsize=(5,10))
    ax = plt.subplot(111)
    
    for i in range(len(Used_Gref["Depth"])):
        qt = my_dict[i]["SBH_QNET"]
        qc = my_dict[i]["SBH_RES"]    
        depth_GRef = my_dict[i]["Depth [m]"]
        depth=depth_GRef
        test_BH=Used_Gref["BH_name"][i]
    ######calculation of the DR    
        density = 10.0
       
        # any filttering of data if needed
        #df2=df[df["Depth [m]"] > 0.5] 
        #df3=df2[df2["SBH_QNET"] < 100]
        
        qt = np.array(qt)
        qc = np.array(qc)
        k0_cpt_Lunne = np.zeros(len(depth))
        OCR_cpt_Lunne = np.zeros(len(depth))
        phi= np.zeros(len(depth))
        k0_nc = np.zeros(len(depth))
        sin_phi = np.zeros(len(depth))
        Dr_fugro_dry = np.zeros(len(depth))
        Dr_fugro_sat = np.zeros(len(depth))
        
        
        sigmv = density*depth
        phi = 17.6 + 11.0 *np.log10( (10.0*qt) / ( (sigmv/100.0)**0.5 ) ) 
        phi_rad = phi*3.1415/180.0
        sin_phi = np.sin(phi_rad)
        
        k0_cpt_fugro = ((sigmv**(1.15*sin_phi/(1-3.7*sin_phi)))*( (1-sin_phi)**(1/(1-3.7*sin_phi))) 
                                                      / ( (2.876**(sin_phi/(1-3.7*sin_phi)))
                                                         * (qt**(0.815*sin_phi/(1-3.7*sin_phi)))    ))
        
        OCR_cpt_Lunne = (0.33*((1000.0*qt))**0.72)/sigmv
        # OCR_cpt_Lunne = np.array(OCR_cpt_Lunne)  
        # index = [i for i, x in enumerate(OCR_cpt_Lunne) if x < 1.0]
        # OCR_cpt_Lunne[index] = 1.0 # OCR cannot be less than one
        # index = np.nonzero(OCR_cpt_Lunne < 1.0)
        # if len(index)>0:
        #     OCR_cpt_Lunne[index] = 1.0 # OCR cannot be less than one
        # index = [i for i, x in enumerate(OCR_cpt_Lunne) if x > 10.0]
        # if len(index)>0:
        #     OCR_cpt_Lunne[index] = 10 # OCR cannot be less than one       
        
        # OCR_trend  = OCR_coff*(depth**OCR_P)  
        
        OCR_trend = (OCR_Pc+sigmv)/sigmv
        
        
        k0_cpt_Lunne = (1-np.sin(phi_cr*3.1415/180))*(OCR_trend**np.sin(phi_cr*3.1415/180))
        
        
        ### CAP on K0 and Dr for further analysis
        k0_cpt_Lunne = np.array(k0_cpt_Lunne)  
        index = [i for i, x in enumerate(k0_cpt_Lunne) if x > 1]
        k0_cpt_Lunne[index] = 1 # OCR cannot be less than one
        
        # if len(index)>0:
        #     k0_cpt_Lunne[index] = 10 # OCR cannot be less than one         
        # for i  in range(len(k0_cpt_Lunne)):
        #     if k0_cpt_Lunne[i] > 1.0:
        #        k0_cpt_Lunne[i] = 1.0 # OCR cannot be less than one
        
        k0_nc = 1-sin_phi
        
        K0_dr = k0_cpt_Lunne
        
        sigmm = (sigmv +2*K0_dr*sigmv)/3
        
        Dr_Baldi = (1/2.61) * np.log( 1000*qc/ ( 181*( sigmm**0.55 )  )   )
        

        Dr_fugro_dry  = (1/0.0296)*np.log((qc/2.494)*((0.01*sigmv*((1+2*K0_dr)/3))**0.46))
        
        Dr_fugro_sat = (0.01*(-1.87+2.32*np.log((1000.0*qc)/((100*sigmv)**0.5)))+1)*Dr_fugro_dry
        
        
        ### CAP on K0 and Dr for further analysis
        Dr_fugro_sat = np.array(Dr_fugro_sat)
        index = index = [i for i, x in enumerate(Dr_fugro_sat) if x > 100]
        Dr_fugro_sat[index] = 100 # OCR cannot be less than one         
        
        k0_cpt_Lunne = np.array(k0_cpt_Lunne)  
        index = [i for i, x in enumerate(k0_cpt_Lunne) if x > 1]
        k0_cpt_Lunne[index] = 1 # OCR cannot be less than one
        
        
        
        Average_DR.append(np.average(Dr_fugro_sat))
        Average_K0_lunne.append(np.average(k0_cpt_Lunne))
        Average_K0_Fugro.append(np.average(k0_cpt_fugro))        
        Average_qt.append(np.average(qt))
        Average_OCR.append(np.average(OCR_trend))

        
        depth_GRef = my_dict[i]["Depth [m]"]
        test_BH=Used_Gref["BH_name"][i]
        Depth_txt="{:.2f}".format(round(Used_Gref["Depth"][i], 2))
        plt.scatter(Dr_fugro_sat, depth_GRef, label=test_BH+" Depth of "+Depth_txt, c=color_dic[test_BH])
        plt.legend(bbox_to_anchor=(1.02, 1.2), loc='upper left') #bbox_to_anchor=(0.5, 0.5)
        plt.ylabel('Depth (m)')
        plt.xlabel('relative Density')
        mark=mark+1 
    plt.gca().invert_yaxis()    
    plt.show()
    
    
    return Average_K0_lunne,Average_K0_Fugro, Average_DR,Average_OCR,Average_qt



'''





   
    
    
########################################################################################    
Nkt = 15
colors = ['#1f27b4','#ff1f0e','#2ca02c','#d69728','#9497bd','#8c564b','#e377c2','#7f7f5f','#bcbd72','#17becf','#1a55FF','#8B008B','#008000','#FF4500', '#000000','#D2691E', '#ADFF2F', '#AFEEEE','#FFFF00']

Su_mean =[]

if Su_cal==1:

    # Su
    # col  =0
    # plt.figure(figsize=(3,10))
    # for i in range(len(used_tests)):
    #     Su = (my_dict[i]["SBH_QNET"] )/(Nkt*0.001)
    #     Su_mean.append(np.mean(Su))
    #     depth_su = my_dict[i]["Depth [m]"]
    #     test_BH=used_tests["PointID"].values.tolist()[i]
        
    #     plt.plot(Su, depth_su ,  label= name[i],color=colors[col])
    #     if len(depth_su)>0:
    #         plt.plot([Su_lab[i] , Su_lab[i]], [min(depth_su) , max(depth_su)] ,color=colors[col])
    #         # plt.plot([Su_Fugro[i] , Su_Fugro[i]], [min(depth_su) , max(depth_su)] ,color=colors[col])
    #     # plt.legend(loc='best')
    #     plt.ylabel('Depth (m)')
    #     plt.xlabel('Undrianed Shear Strength (KPa)')
    #     col = col +1
    # plt.gca().invert_yaxis()    
    # plt.show() 
    
    # CPT
    col = 0
    plt.figure(figsize=(5,10))
    for i in range(len(used_tests)):
        qt = my_dict[i]["SBH_QNET"]
        depth_su = my_dict[i]["Depth [m]"]
        test_BH=used_tests["PointID"].values.tolist()[i]
        plt.plot(qt, depth_su ,  label= name[i],color=colors[col])
        plt.legend(loc='best')
        plt.ylabel('Depth (m)')
        plt.xlabel('Cone resistance (MPa)')
        plt.legend(loc='best')
        col = col +1
    plt.gca().invert_yaxis()    
    plt.show()       
    
    #K0
    col = 0
    plt.figure(figsize=(5,10))
    for i in range(len(used_tests)):
        
        test_Depth=used_tests["Depth"].values.tolist()[i]
        fs = my_dict[i] ['SBH_FRES']
        qt = my_dict[i]["SBH_QNET"]
        depth_su = my_dict[i]["Depth [m]"]
        sigmv = depth_su*10
        phi=30.8*(np.log10(1000*fs/sigmv)+1.26)
        phi_rad = phi*3.1415/180.0
        sin_phi = np.sin(phi_rad)
        k0 = (1-sin_phi)*(OCR[i]**sin_phi)
        test_BH=used_tests["PointID"].values.tolist()[i]
        plt.plot(k0, depth_su ,  label= name[i],color=colors[col])
        if len(depth_su)>0:
            plt.plot([K0_lab[i] , K0_lab[i]], [min(depth_su) , max(depth_su)] ,color=colors[col])
        plt.ylabel('Depth (m)')
        plt.xlabel('K0 - Mayne (2001)')
        # plt.legend(loc='best')
        col = col +1
    plt.gca().invert_yaxis()    
    plt.show()    
    
    
    # Mayne (2009)
    col = 0
    plt.figure(figsize=(5,10))
    for i in range(len(used_tests)):
        
        test_Depth=used_tests["Depth"].values.tolist()[i]
        fs = my_dict[i] ['SBH_FRES']
        qt = my_dict[i]["SBH_QNET"]
        Bq = my_dict[i]["SBH_BQ"]
        depth_su = my_dict[i]["Depth [m]"]
        sigmv = depth_su*10
        phi=29.5 * (Bq**0.121)*(np.log10(qt)+0.256+0.336*Bq)
        phi_rad = phi*3.1415/180.0
        sin_phi = np.sin(phi_rad)
        k0 = (1-sin_phi)*(OCR[i]**sin_phi)
        test_BH=used_tests["PointID"].values.tolist()[i]
        plt.plot(k0, depth_su ,  label= name[i],color=colors[col])
        if len(depth_su)>0:
            plt.plot([K0_lab[i] , K0_lab[i]], [min(depth_su) , max(depth_su)] ,color=colors[col])
        plt.ylabel('Depth (m)')
        plt.xlabel('K0 - Mayne  (2017)')
        # plt.legend(loc='best')
        col = col +1
        
    plt.gca().invert_yaxis()    
    plt.show() 






if plot_density==1:
    fig = plt.figure(figsize=(10, 10))
    ax = fig.add_subplot(111)
    ax = plt.gca()
    
    x=np.array(df["SBH_FRR"])
    y=np.array(df["SBH_NQT"])
    
    xy = np.vstack([x,y])
    z = gaussian_kde(xy)(xy)
    
    # Sort the points by density, so that the densest points are plotted last
    idx = z.argsort()
    x, y, z = x[idx], y[idx], z[idx]
    
    
    line0=ax.scatter(x, y, c=z, s=5, edgecolor='')
    line0.set_label(unique_SU[0])
    fig.colorbar(line0, label='Number of points per pixel')
    
    #line0=plt.scatter(df["SBH_FRR"].values.tolist(),df["SBH_NQT"].values.tolist(),s=1)
    #line0.set_label(unique_SU[0])
    #Change in plot
    mark=0
    markerss=['o',	'*',	'.',	',',	'x',	'X',	'+',	'P',	's',	'D',	'd',	'p',	'H',	'h',	'v',	'^',	'<']
    for i in range(len(used_tests)):
        
        x=my_dict[i]["SBH_FRR"].values.tolist()
        y=my_dict[i]["SBH_NQT"].values.tolist()
        if not x:
            print("There is no CPT data available for test "+used_tests["PointID"].values.tolist()[i]+"_"+used_tests["Samp_Ref"].values.tolist()[i])
        else:
            line1=plt.scatter(x,y,marker=markerss[mark],s = 9)
            line1.set_label(used_tests["PointID"].values.tolist()[i]+"_"+used_tests["Samp_Ref"].values.tolist()[i])
            mark=mark+1
        
    ax.legend(loc='upper left')    
    ax.set_yscale('log')
    ax.set_xscale('log')
    xmin, xmax, ymin, ymax = (0.1, 10, 1, 1000)
    ax.set_xlim(xmin, xmax)
    ax.set_ylim(ymin, ymax)
    ax.set_zorder(2)
    ax.set_facecolor('none')
    
    ax_tw_x = ax.twinx()
    ax_tw_x.axis('off')
    ax2 = ax_tw_x.twiny()
    
    im = plt.imread("Graph.png")
    ax2.imshow(im, extent=[xmin, xmax, ymin, ymax], aspect='auto')
    ax2.axis('off')
    
    
    plt.show()
# =============================================================================
# =============================================================================
if plot_normal==1:
    fig = plt.figure(figsize=(10, 10))
    ax = fig.add_subplot(111)
    ax = plt.gca()
    
    line0=plt.scatter(df["SBH_FRR"].values.tolist(),df["SBH_NQT"].values.tolist(),s=1)
    line0.set_label(unique_SU[0])
    
    
    mark=0
    markerss=['o',	'*',	'.',	',',	'x',	'X',	'+',	'P',	's',	'D',	'd',	'p',	'H',	'h',	'v',	'^',	'<']
    for i in range(len(used_tests)):
        
        x=my_dict[i]["SBH_FRR"].values.tolist()
        y=my_dict[i]["SBH_NQT"].values.tolist()
        if not x:
            print("There is no CPT data available for test "+used_tests["PointID"].values.tolist()[i]+"_"+used_tests["Samp_Ref"].values.tolist()[i])
        else:
            line1=plt.scatter(x,y,marker=markerss[mark],s = 9)
            line1.set_label(used_tests["PointID"].values.tolist()[i]+"_"+used_tests["Samp_Ref"].values.tolist()[i])
            mark=mark+1
        
    ax.legend(loc='upper left')    
    ax.set_yscale('log')
    ax.set_xscale('log')
    xmin, xmax, ymin, ymax = (0.1, 10, 1, 1000)
    ax.set_xlim(xmin, xmax)
    ax.set_ylim(ymin, ymax)
    ax.set_zorder(2)
    ax.set_facecolor('none')
    
    ax_tw_x = ax.twinx()
    ax_tw_x.axis('off')
    ax2 = ax_tw_x.twiny()
    
    im = plt.imread("Graph.png")
    ax2.imshow(im, extent=[xmin, xmax, ymin, ymax], aspect='auto')
    ax2.axis('off')
    
    plt.show()
# 
# =============================================================================
# =============================================================================






# =============================================================================
# nbins=300
# k = kde.gaussian_kde([x,y])
# xi, yi = np.mgrid[x.min():x.max():nbins*1j, y.min():y.max():nbins*1j]
# zi = k(np.vstack([xi.flatten(), yi.flatten()]))
# =============================================================================
# Change color palette
#plt.pcolormesh(xi, yi, zi.reshape(xi.shape), cmap=plt.cm.Greens_r)


#plt.colorbar()

#plt.show()


'''    
    
