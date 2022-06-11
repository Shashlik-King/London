# -*- coding: utf-8 -*-
"""
Created on Fri Jun 10 09:33:37 2022

@author: AYBR
"""

import PySimpleGUI as sg
import mysql.connector
import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit
import math
import pandas as pd
from sklearn.linear_model import LinearRegression 
from math import *
import os, xlsxwriter
import array
import os
from os import walk
import math
import sys
import ctypes
from datetime import datetime, date, timezone
from collections import Counter
import xlsxwriter
import openpyxl
import shutil

#Main function
class Main:  

    print('============================Start=================================')
    plt.close('all')

def __init__(self): 
        self
# =============================================================================
#Read of MYSQL database - Parameters Level 1
# =============================================================================
conn=mysql.connector.connect(user='owdb_user',password='ituotdowdb',host='dklycopilod1',database='owdb')
mycursor=conn.cursor()
mycursor.execute("""SELECT * FROM owdb.Pisa_Param_Level_1""")
db_all = mycursor.fetchall()
df=db_all
    
df1=pd.DataFrame(df, columns=['Project','Soil_unit','Parameter','Type_f','Dep_f','Type_g','Dep_g','Rev','Coe_1_1','Coe_1_2','Coe_1_3','Coe_2_1','Coe_2_2','Coe_2_3','Coe_3_1','Coe_3_2','Coe_3_3'])
print('==================================================================')
print('Dataframe extracted from mySQL:')
print(df1)
conn.close()

# =============================================================================
#Read of MYSQL database - All design profiles
# =============================================================================
conn=mysql.connector.connect(user='ewdb_user',password='ituotdewdb',host='dklycopilod1',database='ewdb')
mycursor=conn.cursor()
mycursor.execute("""SELECT * FROM ewdb.soil_data_source""")
db_all = mycursor.fetchall()
df=db_all
    

df2=pd.DataFrame(df, columns=['id','layer','soil_revision','Depth','Unit','w','Gam','Ip','FC','St','eps50','qt_LE','qt_CLBE','qt_BE','qt_CHBE','qt_HE','fs_LE','fs_CLBE','fs_BE','fs_CHBE','fs_HE','su_LE','su_CLBE','su_BE','su_CHBE','su_HE','Dr','phi_LE','phi_CLBE','phi_BE','phi_CHBE','phi_HE','Gmax_LE','Gmax_CLBE','Gmax_BE','Gmax_CHBE','Gmax_HE','M0','OCR','K0','k','status','responsible','inserted_by','timestamp'])
print('==================================================================')
print('Dataframe extracted from mySQL:')
print(df2)
conn.close()

# =============================================================================
#Read of Excel database - PISA sand
# =============================================================================
conn=mysql.connector.connect(user='owdb_user',password='ituotdowdb',host='dklycopilod1',database='owdb')
mycursor=conn.cursor()
mycursor.execute("""SELECT * FROM owdb.COPCAT_Data_Base where instr(name,'sand') and project = 'PISA'""")
db_all = mycursor.fetchall()
df=db_all
    
df3=pd.DataFrame(df, columns=['name','project','location','rev','diameter','length','notes','soil_type','y_u_f','y_u_1','y_u_2','y_u_3','P_u_f','P_u_1','P_u_2','P_u_3','k_p_f','k_p_1','k_p_2','k_p_3','n_p_f','n_p_1','n_p_2','n_p_3','tetam_u_f','tetam_u_1','tetam_u_2','tetam_u_3','m_u_f','m_u_1','m_u_2','m_u_3','k_m_f','k_m_1','k_m_2','k_m_3','n_m_f','n_m_1','n_m_2','n_m_3','yB_u_f','yB_u_1','yB_u_2','yB_u_3','HB_u_f','HB_u_1','HB_u_2','HB_u_3','k_H_f','k_H_1','k_H_2','k_H_3','n_H_f','n_H_1','n_H_2','n_H_3','tetaMb_u_f','tetaMb_u_1','tetaMb_u_2','tetaMb_u_3','MB_u_f','MB_u_1','MB_u_2','MB_u_3','k_MB_f','k_MB_1','k_MB_2','k_MB_3','n_MB_f','n_MB_1','n_MB_2','n_MB_3','preparer','timestamp'])
print('==================================================================')
print('Dataframe extracted from mySQL:')
print(df3)
conn.close()

# =============================================================================
#Read of Excel database - Cowden clay
# =============================================================================
conn=mysql.connector.connect(user='owdb_user',password='ituotdowdb',host='dklycopilod1',database='owdb')
mycursor=conn.cursor()
mycursor.execute("""SELECT * FROM owdb.COPCAT_Data_Base where instr(name,'cowden') and project = 'PISA'""")
db_all = mycursor.fetchall()
df=db_all
    
df4=pd.DataFrame(df, columns=['name','project','location','rev','diameter','length','notes','soil_type','y_u_f','y_u_1','y_u_2','y_u_3','P_u_f','P_u_1','P_u_2','P_u_3','k_p_f','k_p_1','k_p_2','k_p_3','n_p_f','n_p_1','n_p_2','n_p_3','tetam_u_f','tetam_u_1','tetam_u_2','tetam_u_3','m_u_f','m_u_1','m_u_2','m_u_3','k_m_f','k_m_1','k_m_2','k_m_3','n_m_f','n_m_1','n_m_2','n_m_3','yB_u_f','yB_u_1','yB_u_2','yB_u_3','HB_u_f','HB_u_1','HB_u_2','HB_u_3','k_H_f','k_H_1','k_H_2','k_H_3','n_H_f','n_H_1','n_H_2','n_H_3','tetaMb_u_f','tetaMb_u_1','tetaMb_u_2','tetaMb_u_3','MB_u_f','MB_u_1','MB_u_2','MB_u_3','k_MB_f','k_MB_1','k_MB_2','k_MB_3','n_MB_f','n_MB_1','n_MB_2','n_MB_3','preparer','timestamp'])
print('==================================================================')
print('Dataframe extracted from mySQL:')
print(df4)
conn.close()

# =============================================================================
#Choose a position 
# =============================================================================
position='WTG-55'
diameter='9.7'
length='40.0'

# =============================================================================
#Extract design profile for the position
# =============================================================================
array_df1=df1.to_numpy()
array_df2=df2.to_numpy()
array_df3=df3.to_numpy()
array_df4=df4.to_numpy()

k=0
for index_df2 in range(len(df2)):
    if df2['id'][index_df2]!=position:
        array_df2=np.delete(array_df2,k,0)
    else:
        k=k+1  

# =============================================================================
#Assign PISA parameters
# =============================================================================
array_PISA=[]
index_PISA=0
for index_PISA in range(0,len(array_df2),2):
    array_df3=df3.to_numpy()
    array_df4=df4.to_numpy()
    array_to_supress_sand=array_df3
    array_to_supress_clay=array_df4
    
    if (math.isnan(array_df2[index_PISA][26])):
        dr_position='NaN'
    else:  
        dr_position=int(array_df2[index_PISA][26])
        
    str_dr=str(dr_position)
    str_PISA='Sand_'+str_dr
    
    index_PISA_2=0
    for index_PISA_2 in range(len(array_to_supress_sand)):
        if array_to_supress_sand[index_PISA_2][0] == str_PISA:
            array_PISA=array_PISA+[array_to_supress_sand[index_PISA_2]]
            array_PISA[int(index_PISA/2)][0]=str(array_PISA[int(index_PISA/2)][0]+'_'+str(int(index_PISA/2)))
    
    if str_PISA == 'Sand_NaN':
        array_PISA=array_PISA+[array_to_supress_clay[0]]
        array_PISA[int(index_PISA/2)][0]=str(array_PISA[int(index_PISA/2)][0]+'_'+str(int(index_PISA/2)))
        
array_PISA_non_modified=array_PISA

# =============================================================================
#Assign PU from regression
# =============================================================================
new_array=[]
for index_param in range(0,len(array_df2),2):
    #print('index_param: '+str(index_param))
    for index_df1 in range(len(array_df1)):
        if array_df1[index_df1][1] == array_df2[index_param][4]:
            #print('index_df1: '+str(index_df1))
            #print(array_df1[index_df1])
            
            if(array_df1[index_df1][6]=='z_D'):
                g_dep=array_df2[index_param][3]/float(diameter)
            elif(array_df1[index_df1][6]=='z_L'):
                g_dep=array_df2[index_param][3]/float(length)
            elif(array_df1[index_df1][6]=='L_D'):
                g_dep=float(length)/float(diameter)
            else:
                print('Error found regarding the g_dependant!')
                sys.exit()
                
            if(array_df1[index_df1][4]=='Su'):
                f_dep=array_df2[index_param][22]
            elif(array_df1[index_df1][4]=='tan_phi'):
                f_dep=math.tan(radians(array_df2[index_param][28]))
            elif(array_df1[index_df1][4]=='Dr'):
                f_dep=array_df2[index_param][26]/100
            else:
                print('Error found regarding the f_dependant!')
                sys.exit()
            
            type_f=array_df1[index_df1][3]
            type_g=array_df1[index_df1][5]
            
            if type_f==0 and type_g==0:
                Level_1_1=array_df1[index_df1][8]
                Level_1_2=None
                Level_1_3=None
                Level_2_1=None
                Level_2_2=None
                Level_2_3=None
                Level_3_1=None
                Level_3_2=None
                Level_3_3=None
                
                pug=type_g
                pu1=Level_1_1
                pu2=0
                pu3=0

            elif type_f==0 and type_g==1:
                Level_1_1=array_df1[index_df1][8]
                Level_1_2=None
                Level_1_3=None
                Level_2_1=array_df1[index_df1][11]
                Level_2_2=None
                Level_2_3=None
                Level_3_1=None
                Level_3_2=None
                Level_3_3=None

                pug=type_g
                pu1=Level_1_1
                pu2=Level_2_1
                pu3=0
                
            elif type_f==0 and type_g==2:
                Level_1_1=array_df1[index_df1][8]
                Level_1_2=None
                Level_1_3=None
                Level_2_1=array_df1[index_df1][11]
                Level_2_2=None
                Level_2_3=None
                Level_3_1=array_df1[index_df1][14]
                Level_3_2=None
                Level_3_3=None
                
                pug=type_g
                pu1=Level_1_1
                pu2=Level_2_1
                pu3=Level_3_1

            elif type_f==1 and type_g==0:
                Level_1_1=array_df1[index_df1][8]
                Level_1_2=array_df1[index_df1][9]
                Level_1_3=None
                Level_2_1=None
                Level_2_2=None
                Level_2_3=None
                Level_3_1=None
                Level_3_2=None
                Level_3_3=None
                
                pug=type_g
                pu1=float(Level_1_1)+float(Level_1_2)*float(f_dep)
                pu2=0
                pu3=0

            elif type_f==1 and type_g==1:
                Level_1_1=array_df1[index_df1][8]
                Level_1_2=array_df1[index_df1][9]
                Level_1_3=None
                Level_2_1=array_df1[index_df1][11]
                Level_2_2=array_df1[index_df1][12]
                Level_2_3=None
                Level_3_1=None
                Level_3_2=None
                Level_3_3=None
                
                pug=type_g
                pu1=float(Level_1_1)+float(Level_1_2)*float(f_dep)
                pu2=float(Level_2_1)+float(Level_2_2)*float(f_dep)
                pu3=0
                

            elif type_f==1 and type_g==2:
                Level_1_1=array_df1[index_df1][8]
                Level_1_2=array_df1[index_df1][9]
                Level_1_3=None
                Level_2_1=array_df1[index_df1][11]
                Level_2_2=array_df1[index_df1][12]
                Level_2_3=None
                Level_3_1=array_df1[index_df1][14]
                Level_3_2=array_df1[index_df1][15]
                Level_3_3=None
                
                pug=type_g
                pu1=float(Level_1_1)+float(Level_1_2)*float(f_dep)
                pu2=float(Level_2_1)+float(Level_2_2)*float(f_dep)
                pu3=float(Level_3_1)+float(Level_3_2)*float(f_dep)

            elif type_f==2 and type_g==0:
                Level_1_1=array_df1[index_df1][8]
                Level_1_2=array_df1[index_df1][9]
                Level_1_3=array_df1[index_df1][10]
                Level_2_1=None
                Level_2_2=None
                Level_2_3=None
                Level_3_1=None
                Level_3_2=None
                Level_3_3=None
                
                pug=type_g
                pu1=float(Level_1_1)+float(Level_1_2)*np.exp(float(Level_1_3)*float(f_dep))
                pu2=0
                pu3=0

            elif type_f==2 and type_g==1:
                Level_1_1=array_df1[index_df1][8]
                Level_1_2=array_df1[index_df1][9]
                Level_1_3=array_df1[index_df1][10]
                Level_2_1=array_df1[index_df1][11]
                Level_2_2=array_df1[index_df1][12]
                Level_2_3=array_df1[index_df1][13]
                Level_3_1=None
                Level_3_2=None
                Level_3_3=None
                
                pug=type_g
                pu1=float(Level_1_1)+float(Level_1_2)*np.exp(float(Level_1_3)*float(f_dep))
                pu2=float(Level_2_1)+float(Level_2_2)*np.exp(float(Level_2_3)*float(f_dep))
                pu3=0

            elif type_f==2 and type_g==2:
                Level_1_1=array_df1[index_df1][8]
                Level_1_2=array_df1[index_df1][9]
                Level_1_3=array_df1[index_df1][10]
                Level_2_1=array_df1[index_df1][11]
                Level_2_2=array_df1[index_df1][12]
                Level_2_3=array_df1[index_df1][13]
                Level_3_1=array_df1[index_df1][14]
                Level_3_2=array_df1[index_df1][15]
                Level_3_3=array_df1[index_df1][16]
                
                pug=type_g
                pu1=float(Level_1_1)+float(Level_1_2)*np.exp(float(Level_1_3)*float(f_dep))
                pu2=float(Level_2_1)+float(Level_2_2)*np.exp(float(Level_2_3)*float(f_dep))
                pu3=float(Level_3_1)+float(Level_3_2)*np.exp(float(Level_3_3)*float(f_dep))
            
            new_array=new_array+[pug,pu1,pu2,pu3]
            break
     

for index_new in range(int(len(new_array)/4)):
    array_PISA[index_new][12]=new_array[index_new*4]
    array_PISA[index_new][13]=new_array[index_new*4+1]
    array_PISA[index_new][14]=new_array[index_new*4+2]
    array_PISA[index_new][15]=new_array[index_new*4+3]


# =============================================================================
#Create excel
# =============================================================================
wb = openpyxl.load_workbook('Back_calculation.xlsx')
#ws=wb.get_active_sheet()
ws1=wb.create_sheet()
ws1.title=position


max_array_r=len(array_PISA)
max_array_c=74

for index_row in range(max_array_r):
    for index_column in range(max_array_c):
        ws1.cell(row=index_row+1, column=index_column+2).value=array_PISA[index_row][index_column]
        ws1.cell(row=index_row+1, column=1).value=array_df2[index_row*2+1][4]
        
wb.save('Back_calculation.xlsx')
wb.close()