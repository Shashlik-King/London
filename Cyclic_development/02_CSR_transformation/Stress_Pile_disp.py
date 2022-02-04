# -*- coding: utf-8 -*-
"""
Created on Wed Jan 19 12:46:39 2022

@author: CGQU
"""
import os, sys, math
import pandas as pd
import numpy as np
import csv, xlsxwriter
import scipy.interpolate
import matplotlib.pyplot as plt 

class cluster_class():

    def __init__(self, transformation_matrix,depth):
        self.transformation_matrix=transformation_matrix
        self.depth=depth
        
class time_series_class():

    def __init__(self, dataframe,depth):
        self.dataframe=dataframe
        self.depth=depth


#######################################################################
#                       Importing cluster data                        #
#######################################################################

file = 'Clusters_D200.xlsx'
xl = pd.ExcelFile(file)
excel_sheets=(xl.sheet_names)

df_cluster_200=xl.parse(excel_sheets[0],skiprows=2)
F_cluster_200=(np.array(xl.parse(excel_sheets[0]).columns)[4:]/2).tolist()
F_cluster_200=[int(num) for num in F_cluster_200]
df_cluster_200_steps=list(np.array(df_cluster_200.columns)[4:])
df_cluster_200.rename(columns={i:j for i,j in zip(df_cluster_200_steps,F_cluster_200)}, inplace=True)

file = 'Clusters_D10.xlsx'
xl = pd.ExcelFile(file)
excel_sheets=(xl.sheet_names)

df_cluster_10=xl.parse(excel_sheets[0],skiprows=2)
F_cluster_10=(np.array(xl.parse(excel_sheets[0]).columns)[4:]/2).tolist()
F_cluster_10=[int(num) for num in F_cluster_10]
df_cluster_10_steps=list(np.array(df_cluster_10.columns)[4:])
df_cluster_10.rename(columns={i:j for i,j in zip(df_cluster_10_steps,F_cluster_10)}, inplace=True)

df_cluster_10.drop(['Cluster','Mean_X','Mean_Y','Mean_Z'], axis=1, inplace=True)

df_cluster=pd.concat([df_cluster_200, df_cluster_10],axis=1)


#######################################################################
#                         Importing pile data                         #
#######################################################################


file = 'Structural Forces D_200.xlsx'
xl = pd.ExcelFile(file)
excel_sheets=(xl.sheet_names)

df_pile_200=xl.parse(excel_sheets[3],skiprows=2)
F_pile_200=(np.array(xl.parse(excel_sheets[3]).columns)[1:]).tolist()
F_pile_200=[int(num) for num in F_pile_200]
df_pile_200_steps=list(np.array(df_pile_200.columns)[1:])
df_pile_200.rename(columns={i:j for i,j in zip(df_pile_200_steps,F_pile_200)}, inplace=True)

file = 'Structural Forces D_10.xlsx'
xl = pd.ExcelFile(file)
excel_sheets=(xl.sheet_names)

df_pile_10=xl.parse(excel_sheets[3],skiprows=2)
F_pile_10=(np.array(xl.parse(excel_sheets[3]).columns)[1:]).tolist()
F_pile_10=[int(num) for num in F_pile_10]
df_pile_10_steps=list(np.array(df_pile_10.columns)[1:])
df_pile_10.rename(columns={i:j for i,j in zip(df_pile_10_steps,F_pile_10)}, inplace=True)

df_pile_10.drop(['Depth'], axis=1, inplace=True)

df_pile=pd.concat([df_pile_200, df_pile_10],axis=1)

#######################################################################
#                         Transformation Matrix                       #
#######################################################################
cluster_dict={}

cwd = os.getcwd()
try:
    os.mkdir('Transformation_Matrix')
except OSError:
    print ("Creation of the directory failed")
else:
    print ("Successfully created the directory")
os.chdir(cwd+"\Transformation_Matrix")

Pile_depths=df_pile['Depth'].values.tolist()

F_cluster=list(np.array(df_cluster.columns)[4:])

for i in range(len(df_cluster)):

    cluster_depth=df_cluster['Mean_Z'][i]
    disp_step=[]
    CSR_step=[]

    for j in F_cluster:

        Pile_disp=df_pile[j].values.tolist()

        y_interp = scipy.interpolate.interp1d(Pile_depths, Pile_disp)

        disp_step.append(float(y_interp(cluster_depth)))
        CSR_step.append(df_cluster[j][i])

    vectors = np.array((CSR_step,disp_step)).T

    cluster_dict[df_cluster['Cluster'][i]]=cluster_class(vectors,cluster_depth)

    np.save(df_cluster['Cluster'][i]+'.npy', vectors)



#######################################################################
#                         CSR - time series                           #
#######################################################################
os.chdir(cwd)

try:
    os.mkdir('CSR_time_series')
except OSError:
    print ("Creation of the directory failed")
else:
    print ("Successfully created the directory")


os.chdir(cwd+"\\Nodes")

cwd2 = os.getcwd()

Time_series_dict={}

file = 'node_depth.xlsx'
xl = pd.ExcelFile(file)
excel_sheets=(xl.sheet_names)
depth_nodes=list((xl.parse(excel_sheets[0])['top']+xl.parse(excel_sheets[0])['bot'])/2)
depth_nodes=[round(num,2) for num in depth_nodes]

for j in range(len(cluster_dict)):
    
    depth=cluster_dict[df_cluster['Cluster'][j]].depth
    
    indx=min(range(len(depth_nodes)), key=lambda i: abs(depth_nodes[i]-depth))+1
    
    df = pd.read_excel('Final_table_node_'+str(indx)+'.csv')[['Deflection 1 - sM','Deflection 2 - Sm','Deflection 3 - sm','Deflection 4 - SM']]
    df['Max_disp'] = df[['Deflection 1 - sM','Deflection 2 - Sm','Deflection 3 - sm','Deflection 4 - SM']].max(axis=1)
    df['Min_disp'] = df[['Deflection 1 - sM','Deflection 2 - Sm','Deflection 3 - sm','Deflection 4 - SM']].min(axis=1)
    df['Mean_disp'] = df[['Max_disp','Min_disp']].mean(axis=1)
    df['Range_disp'] = abs(df['Max_disp']-df['Mean_disp'])
    
    x_data=cluster_dict[df_cluster['Cluster'][j]].transformation_matrix[:,1]
    y_data=cluster_dict[df_cluster['Cluster'][j]].transformation_matrix[:,0]
    CSR_interp=[]
        
    for i in range(len(df)):
        
        x=df['Range_disp'].values.tolist()[i]
        print(df_cluster['Cluster'][j],x_data.min(),x_data.max(),x)
        y_interp2 = scipy.interpolate.interp1d(x_data, y_data)
        CSR_interp.append(float(y_interp2(x)))
    
    vector_2 = np.array(CSR_interp).T
    
    df_series=pd.DataFrame(pd.DataFrame(CSR_interp))
    df_series.columns =['CSR']
    
    cluster_depth=df_cluster['Mean_Z'][j]
    
    Time_series_dict[df_cluster['Cluster'][j]]=time_series_class(df_series,cluster_depth)
    
    
    os.chdir(cwd+"\CSR_time_series")
    
    np.save(df_cluster['Cluster'][j]+'.npy', vector_2)
    
    os.chdir(cwd+"\\Nodes")
        
        
        
        
    
#plt.plot(cluster_dict['cluster_5_1_1'].transformation_matrix[:,1],cluster_dict['cluster_5_1_1'].transformation_matrix[:,0])   
    
    
   #df = pd.read_csv(r''+cwd2+'\\Final_table_node_'+str(indx[0])+'.csv', sep=",",usecols=['top','bot'])

#df_pile_200=xl.parse(excel_sheets[3],skiprows=2)

#df_cluster_200=xl.parse(excel_sheets[0],skiprows=2)

