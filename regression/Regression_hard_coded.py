# -*- coding: utf-8 -*-
"""
Created on Tue May  3 08:45:27 2022

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
from CPT_for_Gmax import *
import array
from os import walk
import math
import sys

def f(dependant, type_function, variable):
    #print('========================================')
    #print(dependant)
    
    #constant function
    if type_function==0:
        print('Constant_f')
        value=variable
    
    #linear function
    elif type_function==1:
        #print('Linear_f')
        value=variable[0]+variable[1]*dependant
    
    #exponential function
    elif type_function==2:
        print('Exponential_f')
        value=variable[0]+variable[1]**(variable[2]*dependant)
      
    #error type
    else:
        print('Function f type not correctly defined.')
    
    return value


def g(inputdata, variable_total):
    
    
    
    inmuptdata ={}
    
    
    
    type_function_g =inmuptdata['type of function']
    
    type_function_f=
    
    dependant_f
    
    
    dependant_g
    
    variable_f_1=variable_total[0:2]
    variable_f_2=variable_total[2:4]
    variable_g=variable_total[4:6]
    
    dependant_f=np.array(dependant_f)*0.01
    dependant_g=np.array(dependant_g)
    
    #Pu_1
    Constant_1=f(dependant_f, type_function_f, variable_f_1)
    
    #Pu_2
    Constant_2=f(dependant_f, type_function_f, variable_f_2)
    
    #constant function
    if type_function_g==0:
        print('Constant_g')
        value=Constant_1
    
    #linear function
    elif type_function_g==1:
        #print('Linear_g')
        value=Constant_1+Constant_2*dependant_g
    
    #exponential function
    elif type_function_g==2:
        print('Exponential_g')
        value=Constant_1+Constant_2**(Constant_3*dependant_g)
      
    #error type
    else:
        print('Function g type not correctly defined.')
    
    #print(value)
    return value


def Error_function(param_regression, type_function_g, type_function_f, variable_total, dependant_f, dependant_g):
    
    max_param_regression=np.amax(param_regression)
    #print(max_param_regression)
    error = (param_regression - g(type_function_g, type_function_f, variable_total, dependant_f, dependant_g))**2/(max_param_regression**2)
    sum_error=np.sum(error)
    return sum_error

def g_predict(input_data,gref_c0,gref_c1,m):
    
    #print('Hello')
    
    Dr_arr = 0.01* np.array(input_data['Dr'],dtype='float64')
    Depth_arr = np.array(input_data['depth'],dtype='float64')
    #k0_arr = np.array(input_data['K0'])
    c_arr = np.array(input_data['c'],dtype='float64')
    phi_arr = np.array(input_data['phi_rad'],dtype='float64')
        
    sigmaV=Depth_arr*9.8
# =============================================================================
#     sigmaH=sigmaV*k0_arr
# =============================================================================
    sigma3=sigmaV
# =============================================================================
#     for i in range (0, len(sigma3)):
#         sigma3[i]=min(sigmaV[i],sigmaH[i])
# =============================================================================
    
    M=(gref_c0 + gref_c1*Dr_arr)*((c_arr*np.cos((phi_arr))+sigma3*np.sin((phi_arr)))/(c_arr*np.cos((phi_arr))+100*np.sin((phi_arr))))**m
    #print('M= ')
    #print(M)
    
    return M

def g_predict_AYBR(input_data,gref_c0,gref_c1,m):
    
    #print('Hello')
    
    Dr_arr = 0.01* np.array(input_data['Dr'],dtype='float64')
    Depth_arr = np.array(input_data['depth'],dtype='float64')
    z_L = np.array(input_data['z_L'],dtype='float64')
    #k0_arr = np.array(input_data['K0'])
    c_arr = np.array(input_data['c'],dtype='float64')
    phi_arr = np.array(input_data['phi_rad'],dtype='float64')
        
    sigmaV=Depth_arr*9.8
# =============================================================================
#     sigmaH=sigmaV*k0_arr
# =============================================================================
    sigma3=sigmaV
# =============================================================================
#     for i in range (0, len(sigma3)):
#         sigma3[i]=min(sigmaV[i],sigmaH[i])
# =============================================================================
    
    M=(gref_c0 + gref_c1*z_L)*((c_arr*np.cos((phi_arr))+sigma3*np.sin((phi_arr)))/(c_arr*np.cos((phi_arr))+100*np.sin((phi_arr))))**m
    #print('M= ')
    #print(M)
    
    return M

def f_predict_AYBR(input_data,gref_c0,gref_c1,m):
    
    #print('Hello')
    
    Dr_arr = 0.01* np.array(input_data['Dr'],dtype='float64')
    Depth_arr = np.array(input_data['depth'],dtype='float64')
    #k0_arr = np.array(input_data['K0'])
    c_arr = np.array(input_data['c'],dtype='float64')
    phi_arr = np.array(input_data['phi_rad'],dtype='float64')
        
    sigmaV=Depth_arr*9.8
# =============================================================================
#     sigmaH=sigmaV*k0_arr
# =============================================================================
    sigma3=sigmaV
# =============================================================================
#     for i in range (0, len(sigma3)):
#         sigma3[i]=min(sigmaV[i],sigmaH[i])
# =============================================================================
    
    M=(gref_c0 + gref_c1*Dr_arr)*((c_arr*np.cos((phi_arr))+sigma3*np.sin((phi_arr)))/(c_arr*np.cos((phi_arr))+100*np.sin((phi_arr))))**m
    #print('M= ')
    #print(M)
    
    return M

class Main:  
# =============================================================================
#Read of MYSQL database
# =============================================================================
#let s admit the following case: 
    #Unit= SS1
    #Model= GHS
    #Contour=A_FC1.4_OCR1_DR83
    
    conn=mysql.connector.connect(user='owdb_user',password='ituotdowdb',host='dklycopilod1',database='owdb')
    mycursor=conn.cursor()
    mycursor.execute("""SELECT * FROM owdb.Pisa_Param""")
    db_all = mycursor.fetchall()
    
    df=db_all
        
    df1=pd.DataFrame(df, columns=['Unit_name','Cons_Name','Project_name','Location_name','Rev','Layer_number','Depth','Pile_length','Pile_Diamter','Yu','Pu','Kp','np','Teta','Mu','Km','nm','Yb','Hb','Kb','nb','TetaMb','Mb','kMb','nMb','ASR','Dr','phi','Su','G0','SigmaV','CSR','Neq','CF_OCR','CF_Dr','Contour_diagram_name'])
    print('==================================================================')
    print('Dataframe extracted from mySQL:')
    print(df1)
    
    array_regression=df1.to_numpy()
    k=0
    for j in range(len(df1)):
        #print(j)
        if df1['Depth'].values[j]!=-0.0 and df1['Unit_name'].values[j]=='SS1' and (df1['Cons_Name'].values[j]=='GHS') and (df1['Contour_diagram_name'].values[j]=='A_FC1.4_OCR1_DR83' ):
            k=k+1
        else:
            #remove the lines that do not validate: unit / model / contour chosen
            array_regression=np.delete(array_regression,k,0)
            
    print('==================================================================')
    print('Array extracted from mySQL:')             
    print(array_regression)
    print('==================================================================')
    print('Size of the array:')  
    print(range(len(array_regression)))       
    print('==================================================================')
    
# =============================================================================
#Regression as per PNGI
# =============================================================================

#let s admit the following case: 
    #PU as the variable - array_regression[:,10]
    #Dr as the dependant f - array_regression[:,26]
    #z/L as the dependant g - array_regression[:,6]/array_regression[:,7]
    #Linear function type for g and f
    #g(1, 1, array_regression[:,10], array_regression[:,26], array_regression[:,6]/array_regression[:,7])
    
    PU=array_regression[:,10]
    Dr=array_regression[:,26]
    z_L=-array_regression[:,6]/array_regression[:,7]
    depth=-array_regression[:,6]
    cu=array_regression[:,28]
    phi=array_regression[:,27]
    bulk=array_regression[:,8]
    
    phi_rad=[0]*(len(phi))
    for i in range(len(phi)):
        phi_rad[i]=np.radians(phi[i])
    
    input_data={}
    input_data['PU']=PU
    input_data['Dr']=Dr
    input_data['z_L']= z_L
    input_data['depth']=depth
    input_data['c']=cu
    input_data['phi']=phi
    input_data['bulk']=bulk
    input_data['phi_rad']=phi_rad
    
    variable_total= [0.3667, 25.89, 0.3375, -8.9, 1, 1]
    
    PISA=g(1, 1, variable_total, input_data['Dr'], input_data['z_L'])
    
    print('==================================================================')
    print('PISA: ', PISA)
    
    z_L_db=1.275/30
    z_L_db2=1.275/34
    
    check=25.7389-8.3845*z_L_db
    print('==================================================================')
    print('Check_1: ',check)
    
    check=25.7389-8.3845*z_L_db2
    print('==================================================================')
    print('Check_2: ',check)
    
    error=Error_function(PISA, 1, 1, variable_total, input_data['Dr'], input_data['z_L'])
    print('==================================================================')
    print('Error: ', error)
    
    #print(input_data)
    poptM, pcovM = curve_fit(g_predict,input_data,PISA)
    print('==================================================================')
    print('Parameters PISA: ', variable_total)
    print('==================================================================')
    print('Parameters Calculated: ', poptM)
    
    predict_PISA=g_predict(input_data,poptM[0],poptM[1],poptM[2]) 
    print('==================================================================')
    print('Predict_PISA: ', predict_PISA)
    
    error=Error_function(predict_PISA, 1, 1, variable_total, input_data['Dr'], input_data['z_L'])
    print('==================================================================')
    print('Error_predict: ', error)
   
    
    # =============================================================================
    #Plotting
    # =============================================================================
    depth_profile=np.amax(depth)
    calc_y=round(depth_profile/5)+1
    
    M_profile=np.amax(PISA)
    calc_yM=round(M_profile/100)+1
    
    fig = plt.figure(figsize=(5, 10))
    ax1 = fig.add_subplot(111)
    #ax1.grid()
    
    line1=plt.scatter(PISA,depth)
    line1.set_label("Real values")
    
    line6=plt.scatter(predict_PISA,depth,color='black')
    line6.set_label('Predicted values')

    ax1.set_xlabel('PU')
    # ax1.set_xlim(0,max(Gmax))
    min_depth=0
    max_depth=calc_y*5
    plt.ylim([min_depth,max_depth])
    plt.xlim([0,calc_yM*M_profile*2])
    plt.gca().invert_yaxis()
    ax1.set_ylabel('Depth [m]')
    
    ax1.legend()
    plt.title("PU= "+str(round(poptM[0],2))+"+"+str(round(poptM[1],2))+ "*Dr MPa and m=" + str(round(poptM[2],2)))
    # plt.title(unique_SU+", k0="+str(round(np.mean(input_data['K0']),2)))
    #ax1.set_xscale('log')

    # =============================================================================
    #Regression AYBR
    # =============================================================================
     
    poptM, pcovM = curve_fit(g_predict_AYBR,input_data,PISA)
    predict_PU=g_predict_AYBR(input_data,poptM[0],poptM[1],poptM[2]) 
    print('==================================================================')
    print('Parameters PISA: ', variable_total)
    print('==================================================================')
    print('Parameters Calculated: ', poptM)
     
    poptM, pcovM = curve_fit(f_predict_AYBR,input_data,predict_PU)
    predict_PU2=f_predict_AYBR(input_data,poptM[0],poptM[1],poptM[2]) 
    print('==================================================================')
    print('Parameters PISA: ', variable_total)
    print('==================================================================')
    print('Parameters Calculated: ', poptM)
     