# -*- coding: utf-8 -*-
"""
Created on Tue Feb 15 13:55:53 2022

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

def Predict_regression(array_regression,PARAMref_c0,PARAMref_c1,m0):
    
    #PU => pu1 , pu2
    
    
    
    
    
    
    
    Dr_arr = 0.01* np.array(input_data['Dr'])
    Depth_arr = np.array(input_data['depth'])
    k0_arr = np.array(input_data['K0'])
    c_arr = np.array(input_data['c'])
    phi_arr = np.array(input_data['phi'])
    bulk_arr = np.array(input_data['bulk'])
    
    #m0 = np.array(input_data['m'])
    
    # gref_c0
    # z=((gref_c0 + gref_c1*Dr_arr))
    # y=((c_arr*np.cos(np.radians(phi_arr))+Depth_arr*k0_arr*(bulk_arr-10)*np.sin(np.radians(phi_arr))))
    # x=((c_arr*np.cos(np.radians(phi_arr))+100*np.sin(np.radians(phi_arr)))**(m0))
    
    # print(type(z))
    # print(type(y))
    # print(type(x))
    sigmaV=Depth_arr*9.8
    sigmaH=sigmaV*k0_arr
    sigma3=sigmaV
    for i in range (0, len(sigma3)):
        sigma3[i]=min(sigmaV[i],sigmaH[i])
    
    G=(gref_c0 + gref_c1*Dr_arr)*((c_arr*np.cos(np.radians(phi_arr))+sigma3*np.sin(np.radians(phi_arr)))/(c_arr*np.cos(np.radians(phi_arr))+100*np.sin(np.radians(phi_arr))))**(m0)
 
    #print(type(G))
    
    return G


class Main:
    def __init__(self, Gmax_scpt, Gmax_PS, Gmax_BE,Gmax_RC,Gmax_Out,Gmax,Depth_scpt,Depth_PS,Depth_BE,Depth_RC,Depth_Out,Depth,input_data,predict_ratio): 
        self.Gmax_scpt=Gmax_scpt
        self.Gmax_PS=Gmax_PS        
        self.Gmax_BE=Gmax_BE   
        self.Gmax_RC=Gmax_RC   
        self.Gmax_Out=Gmax_Out
        self.Gmax=Gmax
        self.Depth_scpt=Depth_scpt
        self.Depth_PS=Depth_PS
        self.Depth_BE=Depth_BE
        self.Depth_RC=Depth_RC
        self.Depth_Out=Depth_Out
        self.Depth=-Depth
        self.input_data=input_data
        self.predict_ratio=predict_ratio

# =============================================================================
#Read of MYSQL database
# =============================================================================

conn=mysql.connector.connect(user='owdb_user',password='ituotdowdb',host='dklycopilod1',database='owdb')
mycursor=conn.cursor()
mycursor.execute("""SELECT * FROM owdb.Pisa_Param""")
db_all = mycursor.fetchall()

df=db_all
    
df1=pd.DataFrame(df, columns=['Unit_name','Cons_Name','Project_name','Location_name','Rev','Layer_number','Depth','Pile_length','Pile_Diamter','Yu','Pu','Kp','np','Teta','Mu','Km','nm','Yb','Hb','Kb','nb','TetaMb','Mb','kMb','nMb','ASR','Dr','phi','Su','G0','SigmaV','CSR','Neq','CF_OCR','CF_Dr','Contour_diagram_name'])
print('==================================================================')
print('Dataframe extracted from mySQL:')
print(df1)
    
# =============================================================================
#Table construction
# =============================================================================

layout = [ [sg.Text('Input table for regression')],
           [sg.Text('Name'),sg.Input(k='-IN-'),sg.Text(size=(14,1), key='-OUT-')],
           [sg.Text('Date  '),sg.Input(k='-IN-'),sg.Text(size=(14,1), key='-OUT-')],
           [sg.Button('Exit')] ]


headings = ['Unit', 'Parameter', 'Automatic','Type g()','Type f()', 'Dependant', 'Model','Batch cyclic']
header =  [[sg.Text('  ')] + [sg.Text(h, size=(19,1)) for h in headings]]

#Lists for each column
list1=['SS1','H1','H2','H3','PC1','PC2','PH1','PH2','PM1','PM2','PM3','PM4','PM5','CC1','CC2','CC3']
list2=['Yu','Pu','Kp','np','Teta','Mu','Km','nm','Yb','Hb','Kb','nb','TetaMb','Mb','kMb','nMb']
list3=['0','1']
list4=['0','1','2']
list5=['0','1','2']
list6=['z/L','z/D','Dr','tan(Phi)','Su','G0','CSR','CF','Batch']
list7=['ALL','NGI','GHS']
list8=['ALL','A_FC1.4_OCR1_DR70','A_FC1.4_OCR1_DR83','A_FC1.4_OCR1_DR83_undrained','B_FC15.1_OCR1_DR69_undrained','Batch3_FC14_OCR1_DR77','Batch3_FC14_OCR6_DR80','19b_FC30_OCR6_DR50','20a_FC18_OCR6_DR80','21a_FC11_OCR1.3_DR35','21a_FC17_OCR1.5_DR85','Unit2a_OCR16_Ip16','Unit2c_OCR8_Ip37','C2_OCR6_Ip55','Drammen_Clay_4_PC2','Drammen_Clay_4_PH2','Drammen_Clay_4_PM2','Drammen_Clay_4_CC3']

input_rows = [[sg.Combo(list1, size=(20,1)),sg.Combo(list2, size=(20,1)),sg.Combo(list3, size=(20,1)),sg.Combo(list4, size=(20,1)),sg.Combo(list5, size=(20,1)),sg.Combo(list6, size=(20,1)),sg.Combo(list7, size=(20,1)),sg.Combo(list8, size=(20,1))] for row in range(10)]

layout = layout + header + input_rows 

window = sg.Window('Regression',layout,finalize=True)

while True: 
    event, values = window.read()
    #print(event, values)
    if event == sg.WIN_CLOSED or event == 'Exit':
        break
    window['-OUT-'].update(values['-IN-'])
window.close()


# =============================================================================
#Table verification
# =============================================================================

inputs_regression = values

#check of the 10 lines if units empty or filled
list_regression = [0,8,16,24,32,40,48,56,64,72]
list_toDo = []

for i in range(len(list_regression)):
    if values[list_regression[i]]!='':
        list_toDo=list_toDo+[i]
        
#print(list_toDo)   

#Check where we have units for the regression
if list_toDo==[]:
    print('==================================================================')
    print ('No unit selected for the regression!')
    sys.exit()

#Check if we have all column filled for the units used for the regression
for i in range(len(list_toDo)):
    if values[list_toDo[i]+1] == '' or values[list_toDo[i]+2] == '' or values[list_toDo[i]+3] == '' or values[list_toDo[i]+4] == '' or values[list_toDo[i]+5] == '' or values[list_toDo[i]+6] == '' or values[list_toDo[i]+7] == '' :
        print('==================================================================')
        print ('Missing info to run the regression - empty column!')
        sys.exit()

#Set up of naming and date in case of empty filling
if values['-IN-']=='':
    name_regression=('Default_naming')
else :
    name_regression=values['-IN-']
    
if values['-IN-0']=='':
    date_project='01-01-2022'
else :
    date_project=values['-IN-0']

    
# =============================================================================
#Regression
# =============================================================================

#Transform dataframe of mysql in a simple array
array_regression=df1.to_numpy()

#Batch run of the regressions for each line fully filled
for i in range(len(list_toDo)):
    print('==================================================================')
    print('Start of the regression:')
    
    #Lookup at if 'Automatic' is set to 0 or 1 - if 1 run all possibilities
    if values[list_toDo[i]+2]==1 :
        print('==================================================================')
        print('Version used is not ready for automatic regression!')
        
        # TO DO AYBR
        
    else :
        print('==================================================================')
        print('Non automatic regression selected!')
        k=0
        for j in range(len(df1)):
            #print(j)
            if df1['Unit_name'].values[j]==values[list_toDo[i]] and (df1['Cons_Name'].values[j]==values[list_toDo[i]+6] or values[list_toDo[i]+6]=='ALL') and (df1['Contour_diagram_name'].values[j]==values[list_toDo[i]+7] or values[list_toDo[i]+7]=='ALL'):
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

#Send the information in the prediction equation
#popt, pcov = curve_fit(G_predict_AYBR,input_data,Gmax,bounds=((0,0,m_total),(np.inf,np.inf,m_total+0.0001)))
#predict_ratio=G_predict_AYBR(input_data,popt[0],popt[1],popt[2]) 
                
#finish exporting the selected lines
#send them to the functions 
#make the prediction
#calculate the error
#print prediction/real values 


# =============================================================================
#     #df1=df1.astype({'Depth, (m bsf)':'float','Gam, (kN/m3)':'float','Dr, (%)':'float','phi CLBE, (deg)':'float','Gmax BE, (MPa)':'float','M0, (MPa)':'float','K0, (-)':'float','c':'float'})
#     
#     Unit_name=df1['Unit_name'].values
#     # depth=depth.astype(float)
#     
#     gamma=df1['Gam, (kN/m3)'].values
#     # gamma=gamma.astype(float) 
#     
#     Dr=df1['Dr, (%)'].values
#     # Dr=Dr.astype(float)
#     
#     phi=df1['phi CLBE, (deg)'].values
#     # phi=phi.astype(float)
#     
#     Gmax=df1['Gmax BE, (MPa)'].values
#     # Gmax=Gmax.astype(float)
#     
#     M0=df1['M0, (MPa)'].values
#     # M0=M0.astype(float)
#     
#     E50=M0*0.75
#     
#     K0=df1['K0, (-)'].values
#     # K0=K0.astype(float)
#     
#     c=df1['c'].values
#     # c=c.astype(float)
#     
#     title=excel_sheets[i]
#     print(title)
# =============================================================================

# =============================================================================
#         
#     input_data={}
#     input_data['depth']=depth
#     input_data['bulk']=gamma
#     input_data['Dr']= Dr
#     input_data['phi']=phi
#     input_data['Gmax']=Gmax
#     input_data['M0']=M0
#     input_data['K0']=K0
#     input_data['c']=c
#     
#     input_data['E50']=M0*0.75
# =============================================================================


#     
#     p0=[200,200,0.5]
#     popt, pcov = curve_fit(G_predict_AYBR,input_data,Gmax,bounds=((0,0,0),(np.inf,np.inf,1)))
#     predict_ratio=G_predict_AYBR(input_data,popt[0],popt[1],popt[2]) 
#     
#     p0M=[200,200,0.5]
#     poptM, pcovM = curve_fit(M_predict_AYBR,input_data,M0,bounds=((0,0,0),(np.inf,np.inf,1)))
#     predict_ratioM=M_predict_AYBR(input_data,poptM[0],poptM[1],poptM[2]) 
#     
#     p0E50=[200,200,0.5]
#     poptE50, pcovE50 = curve_fit(E50_predict_AYBR,input_data,E50,bounds=((0,0,0),(np.inf,np.inf,1)))
#     predict_ratioE50=E50_predict_AYBR(input_data,poptE50[0],poptE50[1],poptE50[2]) 
#     
#     # print(popt[0])
#     # print(popt[1])
#     print("Best m_G:" +str(popt[2]))
#     
#     # print(popt[0])
#     # print(popt[1])
#     print("Best m_M:"+str(poptM[2]))
#     
#     # print(popt[0])
#     # print(popt[1])
#     print("Best m_E50:"+str(poptE50[2]))
#     
#     array1 = Gmax
#     array2 = predict_ratio
#     difference_array = np.subtract(array1, array2)
#     squared_array = np.square(difference_array)
#     mseG_perfect = squared_array.mean()
#     #print("mse G:"+str(mseG))
#         
#     array1 = M0
#     array2 = predict_ratioM
#     difference_array = np.subtract(array1, array2)
#     squared_array = np.square(difference_array)
#     mseM_perfect = squared_array.mean()
#     #print("mse M:"+str(mseM))
#         
#         
#     length_array=abs(math.floor(popt[2]*100)-math.floor(poptM[2]*100))
#     test_array=np.linspace(math.floor(min(popt[2],poptM[2])*100)/100,math.floor(min(popt[2],poptM[2])*100)/100+length_array*0.01,length_array+1)
#     
#     m_test=test_array[1]
#     mse_total=np.inf
#     m_total=0
#      
#     for i in range (0, len(test_array)):
#         test=test_array[i]
#         p0=[200,200,0.5]
#         popt, pcov = curve_fit(G_predict_AYBR,input_data,Gmax,bounds=((0,0,test),(np.inf,np.inf,test+0.0001)))
#         predict_ratio=G_predict_AYBR(input_data,popt[0],popt[1],popt[2]) 
#         
#         p0M=[200,200,0.5]
#         poptM, pcovM = curve_fit(M_predict_AYBR,input_data,M0,bounds=((0,0,test),(np.inf,np.inf,test+0.0001)))
#         predict_ratioM=M_predict_AYBR(input_data,poptM[0],poptM[1],poptM[2]) 
#         
#         array1 = Gmax
#         array2 = predict_ratio
#         difference_array = np.subtract(array1, array2)
#         squared_array = np.square(difference_array)
#         mseG = squared_array.mean()/mseG_perfect
#         #print("mse G:"+str(mseG))
#         
#         array1 = M0
#         array2 = predict_ratioM
#         difference_array = np.subtract(array1, array2)
#         squared_array = np.square(difference_array)
#         mseM = squared_array.mean()/mseM_perfect
#         #print("mse M:"+str(mseM))
#         
#         #print("mse Total:"+str(mseG+mseM))
#         mse_test= mseG+mseM
#         
#         if mse_test < mse_total:
#             mse_total=mse_test
#             m_total=test_array[i]
#         
#     print(mse_total)
#     print(m_total)
#     
#     
#     popt, pcov = curve_fit(G_predict_AYBR,input_data,Gmax,bounds=((0,0,m_total),(np.inf,np.inf,m_total+0.0001)))
#     predict_ratio=G_predict_AYBR(input_data,popt[0],popt[1],popt[2]) 
#         
#     poptM, pcovM = curve_fit(M_predict_AYBR,input_data,M0,bounds=((0,0,m_total),(np.inf,np.inf,m_total+0.0001)))
#     predict_ratioM=M_predict_AYBR(input_data,poptM[0],poptM[1],poptM[2]) 
#     
#     poptE50, pcovE50 = curve_fit(E50_predict_AYBR,input_data,E50,bounds=((0,0,m_total),(np.inf,np.inf,m_total+0.0001)))
#     predict_ratioE50=E50_predict_AYBR(input_data,poptE50[0],poptE50[1],poptE50[2]) 
#     
#     array1 = Gmax
#     array2 = predict_ratio
#     difference_array = np.subtract(array1, array2)
#     squared_array = np.square(difference_array)
#     mseG = squared_array.mean()
#     print("mse G:"+str(mseG))
#     
#     
#     array1 = M0
#     array2 = predict_ratioM
#     difference_array = np.subtract(array1, array2)
#     squared_array = np.square(difference_array)
#     mseM = squared_array.mean()
#     print("mse M:"+str(mseM))
#     
#     print("mse Total:"+str(mseG+mseM))
#     
#     depth_profile=np.amax(depth)
#     calc_y=round(depth_profile/5)+1
#     
#     G_profile=np.amax(Gmax)
#     calc_yG=round(G_profile/100)+1
#     
#     M_profile=np.amax(M0)
#     calc_yM=round(M_profile/100)+1
#     
#     E50_profile=np.amax(E50)
#     calc_yE50=round(E50_profile/100)+1
#     
#     fig = plt.figure(figsize=(5, 10))
#     ax1 = fig.add_subplot(111)
#     #ax1.grid()
#     
#     line1=plt.scatter(Gmax,depth)
#     line1.set_label(title+": real values")
#     
#     line6=plt.scatter(predict_ratio,depth,color='black')
#     line6.set_label('Predicted values')
# 
#     ax1.set_xlabel('G0 [MPa]')
#     # ax1.set_xlim(0,max(Gmax))
#     min_depth=0
#     max_depth=calc_y*5
#     plt.ylim([min_depth,max_depth])
#     plt.xlim([0,calc_yG*100])
#     plt.gca().invert_yaxis()
#     ax1.set_ylabel('Depth [m]')
#     
#     ax1.legend()
#     plt.title(title+": Gref= "+str(round(popt[0],2))+"+"+str(round(popt[1],2))+ "*Dr MPa and m=" + str(round(popt[2],2)))
#     # plt.title(unique_SU+", k0="+str(round(np.mean(input_data['K0']),2)))
#     #ax1.set_xscale('log')
#     
#     fig = plt.figure(figsize=(5, 10))
#     ax1 = fig.add_subplot(111)
# 
#     line1=plt.scatter(M0,depth)
#     line1.set_label(title+": real values")
#     
#     line6=plt.scatter(predict_ratioM,depth,color='black')
#     line6.set_label('Predicted values')
# 
#     ax1.set_xlabel('M0 [MPa]')
#     # ax1.set_xlim(0,max(Gmax))
#     min_depth=0
#     
#     max_depth=calc_y*5
#     plt.ylim([min_depth,max_depth])
#     plt.xlim([0,calc_yM*100])
#     plt.gca().invert_yaxis()
#     ax1.set_ylabel('Depth [m]')
#     
#     ax1.legend()
#     plt.title(title+": Mref= "+str(round(poptM[0],2))+"+"+str(round(poptM[1],2))+ "*Dr MPa and m=" + str(round(poptM[2],2)))
#     # plt.title(unique_SU+", k0="+str(round(np.mean(input_data['K0']),2)))
#     #ax1.set_xscale('log')
#     
#     fig = plt.figure(figsize=(5, 10))
#     ax1 = fig.add_subplot(111)
# 
#     line1=plt.scatter(E50,depth)
#     line1.set_label(title+": real values")
#     
#     line6=plt.scatter(predict_ratioE50,depth,color='black')
#     line6.set_label('Predicted values')
# 
#     ax1.set_xlabel('E50 [MPa]')
#     # ax1.set_xlim(0,max(Gmax))
#     min_depth=0
#     
#     max_depth=calc_y*5
#     plt.ylim([min_depth,max_depth])
#     plt.xlim([0,calc_yE50*100])
#     plt.gca().invert_yaxis()
#     ax1.set_ylabel('Depth [m]')
#     
#     ax1.legend()
#     plt.title(title+": E50ref= "+str(round(poptE50[0],2))+"+"+str(round(poptE50[1],2))+ "*Dr MPa and m=" + str(round(poptE50[2],2)))
#     ##Other plots
#     # plt.figure(figsize=(5, 10))
#     # plt.scatter(Dr ,input_data['depth'],  label="Jamiolkowski et al. (2003)")
#     # # plt.scatter(DR_Baldi ,input_data['depth'],  label="Baldi et al. (1986)")
#     # plt.legend(loc='best')
#     # plt.ylabel('Depth (m)')
#     # plt.xlabel('Relative Density')
#     # plt.ylim([min_depth,max_depth])
#     # plt.legend(loc='best')
#     # plt.gca().invert_yaxis()
#     # plt.show()        
#     
#     # plt.figure(figsize=(5, 10))
#     # plt.scatter(K0 ,input_data['depth'],  label="k0-OCR")
#     # #plt.scatter(k0_cpt_Fugro ,input_data['depth'],  label="qc - Fugro'report")
#     # plt.legend(loc='best')
#     # plt.ylabel('Depth (m)')
#     # plt.xlabel('K0')
#     # plt.ylim([min_depth,max_depth])
#     # plt.legend(loc='best')
#     # plt.gca().invert_yaxis()
#     # plt.show()
#     
# =============================================================================

