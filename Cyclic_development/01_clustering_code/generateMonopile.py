## PLAXIS boilerplate ##
import os, sys,math, getInput
#sys.path.append('C:\Program Files\Plaxis\PLAXIS 3D\python\Lib\site-packages')
from plxscripting.easy import *
#s_i, g_i = new_server('localhost', 10000, password='!YNW<c6W>mg?Mt8v')



def generateMono(df):
    # Importing modules 
    #
    # Initialize input scripting server
    s_i, g_i = new_server('localhost', 10000, password='!YNW<c6W>mg?Mt8v')
    #
    # Defining some functions and local parameters for convenience  
    def process_text_get_normal(text):
        vector_text = text.split('\n')[1]
        normal_vector_string = vector_text.split(': ')[-1].strip('(').strip(')')
        return [float(item) for item in normal_vector_string.split(';')]
    
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
    	
    seaBedLevel = 0
    nuSteel = 0.3
    gammaSteel = 0
    ESteel = 210000000

    eps = 1e-5
    nStepsPYCurve = 20

    pileProp, waterLevel, force, displacement, soilProp,soil_layers,pile_thickness, thickness_layers, global_scour, local_scour, clustering_vector, circle_division,vertical_separation = getInput.getInfo(df)
    print(pileProp, waterLevel, force, displacement, soilProp, soil_layers,pile_thickness, thickness_layers, global_scour, local_scour)
    
    #
    # Start a new project
    s_i.new()
    #
    # Project properties
    projecttitle = 'Monopile model with Python'
    g_i.Project.setproperties("Title", projecttitle,
                              "UnitForce", "kN",
                              "UnitLength", "m",
                              "UnitTime", "day")
    #
    # Create soil materials
    modelSize =  10.*pileProp['D']
    g_i.Soilcontour.initializerectangular(-modelSize,0,modelSize,modelSize)
    #
    # Create soil materials
    i = 1
    for prop in soilProp:
        if prop['Constitutive']== "HSsmall":
            if prop['Drainage'] == 1:
                drainageType = "Undrained B"
            elif prop['Drainage'] == 2:
                drainageType = "Undrained A"
            else:
                drainageType = "Drained"
                
            if int(prop['Dilation'])==0:
                params = [("MaterialName", "Soil_"+str(i)), 
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
                params = [("MaterialName", "Soil_"+str(i)), 
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

            params = [("MaterialName", "Soil_"+str(i)), 
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
        i = i + 1
        make_soilmat(g_i,params)
    
    ######################################################
    # SOIL GEOMETRY
    #
    firstBorehole = g_i.borehole(0,0)
    firstBorehole.Head.set(waterLevel)
    i = 0
    depth=seaBedLevel
    for prop in soilProp:
        g_i.soillayer(1)
        if i == 0:
            g_i.setsoillayerlevel(firstBorehole, i, seaBedLevel)        
        depth = depth + soilProp[i]['t']
        g_i.setsoillayerlevel(firstBorehole, i+1, -depth )
        g_i.setmaterial(g_i.Soils[-1], g_i.Materials[i])
        i = i + 1
    #    
    # Setting interface soils
    # 
    layer_thickness=[0]
    interfaceProp=soilProp.copy()
    for i in range(len(interfaceProp)):
        interfaceProp[i]['c']=interfaceProp[i]['c']*interfaceProp[i]['Ri']
        interfaceProp[i]['cinc']=interfaceProp[i]['cinc']*interfaceProp[i]['Ri']
        interfaceProp[i]['phi']=math.degrees(math.atan(math.tan(math.radians(interfaceProp[i]['phi']))*interfaceProp[i]['Ri'])) 
        interfaceProp[i]['psi']=0
        
        interfaceProp[i]['suP_suA']=interfaceProp[i]['suP_suA']*interfaceProp[i]['Ri']
        interfaceProp[i]['suDSS_suA']=interfaceProp[i]['suDSS_suA']*interfaceProp[i]['Ri']
        interfaceProp[i]['su_A_ref']=interfaceProp[i]['su_A_ref']*interfaceProp[i]['Ri']
        
        layer_thickness.append(-interfaceProp[i]['t']+layer_thickness[-1])
        interfaceProp[i]['Ri']=1
    i = 1
    for prop in interfaceProp:
        if prop['Constitutive']== "HSsmall":
            if prop['Drainage'] == 1:
                drainageType = "Undrained B"
            elif prop['Drainage'] == 2:
                drainageType = "Undrained A"			
            else:
                drainageType = "Drained"
            if int(prop['Dilation'])==0:
                params = [("MaterialName", "Interface_"+str(i)), 
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
                          ("phi", prop['phi']),
                          ("K0nc", 1 - math.sin(math.radians(prop['phi']))),
                          ("psi", prop['psi'])]
            else:
                params = [("MaterialName", "Interface_"+str(i)), 
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
                          ("phi", prop['phi']),
                          ("K0nc", 1 - math.sin(math.radians(prop['phi']))),
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

            params = [("MaterialName", "Interface_"+str(i)), 
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
        i = i + 1
        make_soilmat(g_i,params)
    layer_thickness.remove(0)
    
    # STRUCTURES
    #
    g_i.gotostructures()
    D = pileProp['D']
    L = pileProp['L']
    l = pileProp['l']
    #
    # Lateral surface
    topLevel = seaBedLevel + L - l
    polycurve_1 = g_i.polycurve(0, 0, topLevel , 1, 0, 0, 0, 1, 0)
    polycurve_1.Offset1 = D / 2
    polycurve_1.add()
    polycurve_1.Segments[-1].SegmentType = 'Arc'
    polycurve_1.Segments[-1].ArcProperties.Radius =  D / 2
    polycurve_1.Segments[-1].ArcProperties.CentralAngle = 180
    polycurve_1.Segments[-1].ArcProperties.RelativeStartAngle1 = 90
    lateralSurface = g_i.extrude(polycurve_1, 0, 0, -L)
    lateralSurface.AxisFunction = ' Manual'
    lateralSurface.AxisVectorZ = 1.0
    #
    # Top surface
    polycurve_1.add()
    polycurve_1.Segments[-1].LineProperties.Length = D
    polycurve_1.Segments[-1].LineProperties.RelativeStartAngle1 = 90
    topSurface = g_i.surface(polycurve_1)
    #
    # Vertical partition and bottom surface
    #sliceHeight = pileProp['h']
    #nSurf = int (L/sliceHeight)
    updated_thickness=[]
    for i in range(len(pile_thickness)):
        if thickness_layers[i] not in soil_layers:
            Condition=True
            #Condition2=False
            for j in range(len(soil_layers)):
                if abs((-thickness_layers[i])+(soil_layers[j]))>0.5:
                    Condition=True
                    #if thickness_layers[i]>0:
                        #Condition2=True
                    
                else:
                    Condition=False
                    updated_thickness.append(soil_layers[j])
                    break
            if Condition==True:
                updated_thickness.append(thickness_layers[i])
                #if Condition2==False:
                soil_layers.append(thickness_layers[i])
        else:
            updated_thickness.append(thickness_layers[i])    
    soil_layers.sort(reverse = False)        
    bottomSurface = g_i.arrayr(topSurface, 2, 0, 0, -L)
    bottomSurface2 = g_i.arrayr(topSurface, 2, 0, 0, -L)
    for i in range(len(soil_layers)):
        if abs(soil_layers[i])<0.001:
            zero_surf=g_i.arrayr(topSurface, 2, 0, 0, -L+l+soil_layers[i])
        else:
            g_i.arrayr(topSurface, 2, 0, 0, -L+l+soil_layers[i])
     
    pileProp, waterLevel, force, displacement, soilProp,soil_layers,pile_thickness, thickness_layers, global_scour, local_scour,clustering_vector, circle_division,vertical_separation = getInput.getInfo(df)
 # Features: plate, interfaces and rigid bodies
    g_i.posinterface(lateralSurface)
    g_i.neginterface(lateralSurface)
    g_i.plate(lateralSurface)
    g_i.neginterface(bottomSurface)
    bottomSurface.NegativeInterface.ApplyStrengthReduction = False
    g_i.plate(topSurface)
    g_i.rigidbody(topSurface)
    g_i.Rigidbodies[-1].Xref = 0
    g_i.Rigidbodies[-1].yref = 0
    g_i.Rigidbodies[-1].Zref = topLevel
    g_i.Rigidbodies[-1].TranslationConditionx = "Displacement"
    g_i.Rigidbodies[-1].TranslationConditiony = "Displacement"
    g_i.Rigidbodies[-1].RotationConditionx = "Rotation"
    g_i.Rigidbodies[-1].RotationConditionz = "Rotation"
    #
    
    #################################################################################################
    #--------------------------- Splitting into clusters -------------------------------------------#
    #################################################################################################
    scour_level=-global_scour-local_scour
    surface_quarter = g_i.surface((0, D/2, 0), (0, clustering_vector[-1], 0), (0, clustering_vector[-1], -l), (0, D/2, -l))
    #surface_quarter = g_i.surface((0, D/2, scour_level), (0, clustering_vector[-1], scour_level), (0, clustering_vector[-1], -l), (0, D/2, -l))
    
    g_i.arrayp(surface_quarter, (0, 0, 0), (0, 0, 1), -90, int(circle_division[0]+1), True)
    g_i.arrayp(surface_quarter, (0, 0, 0), (0, 0, 1), 90, int(circle_division[0]+1), True)
    
    for j in range(len(clustering_vector)):
        #polycurve_2 = g_i.polycurve(0, 0, scour_level , 1, 0, 0, 0, 1, 0)
        polycurve_2 = g_i.polycurve(0, 0, 0 , 1, 0, 0, 0, 1, 0)
        polycurve_2.Offset1 = clustering_vector[j]
        polycurve_2.add()
        polycurve_2.Segments[-1].SegmentType = 'Arc'
        polycurve_2.Segments[-1].ArcProperties.Radius =  clustering_vector[j]
        polycurve_2.Segments[-1].ArcProperties.CentralAngle = 180
        polycurve_2.Segments[-1].ArcProperties.RelativeStartAngle1 = 90
        lateralSurface = g_i.extrude(polycurve_2, 0, 0, -l)
        lateralSurface.AxisFunction = ' Manual'
        lateralSurface.AxisVectorZ = 1.0
    
    g_i.delete(polycurve_2)
    
    #polycurve_3 = g_i.polycurve(0, D/2, scour_level , 1, 0, 0, 0, 1, 0)
    polycurve_3 = g_i.polycurve(0, D/2, 0 , 1, 0, 0, 0, 1, 0)
    polycurve_3.add()
    polycurve_3.Segments[-1].SegmentType = 'Arc'
    polycurve_3.Segments[-1].ArcProperties.Radius =  -D/2
    polycurve_3.add()
    polycurve_3.Segments[-1].LineProperties.RelativeStartAngle1 = 90
    polycurve_3.Segments[-1].LineProperties.Length = clustering_vector[-1]-D/2
    polycurve_3.add()
    polycurve_3.Segments[-1].SegmentType = 'Arc'
    polycurve_3.Segments[-1].ArcProperties.RelativeStartAngle1 = 90
    polycurve_3.Segments[-1].ArcProperties.Radius =  clustering_vector[-1]
    polycurve_3.symmetricclose()
    out_surface = g_i.surface(polycurve_3)
    
    
    j=-vertical_separation[0]
    vertical_clusters=[]
    
    while j >=-l:
        vertical_clusters.append(soil_layers[min(range(len(soil_layers)), key = lambda i: abs(soil_layers[i]-j))])
        j=j-vertical_separation[0]
    if -l not in vertical_clusters:
        vertical_clusters.append(-l)
        
    for i in range(len(vertical_clusters)-1):
        g_i.arrayr(out_surface, 2, 0, 0, vertical_clusters[i])
    bot_cluster_surf=g_i.arrayr(out_surface, 2, 0, 0, vertical_clusters[-1])
        
    x_surface=g_i.surface((clustering_vector[-1], 0, 0),(clustering_vector[-1], 0, -l),(-clustering_vector[-1], 0, -l),(-clustering_vector[-1], 0, 0))
    
    g_i.combine(out_surface,x_surface, bot_cluster_surf,bottomSurface2,lateralSurface,zero_surf)   
    #------------------------------------------------------------------------------------------------
   
    
# =============================================================================
#     plate_Mat_dict={}
#     for i in range(len(pile_thickness)):
#         #x='plateMat_'+str(i)
#         GSteel = ESteel / (2 * (1 + nuSteel))
#         plate_params = [("MaterialName", "Monopile_"+str(i)),
#                         ("d", pile_thickness[i]),
#                         ("Nu12", nuSteel),
#                         ("IsIsotropic", True),
#                         ("IsLinear", True),
#                         ("E1", ESteel),
#                         ("E2", ESteel),
#                         ("G12", GSteel),
#                         ("G13", GSteel),
#                         ("G23", GSteel),
#                         ("Density", gammaSteel)]
#         plate_Mat_dict[i] = g_i.platemat(*plate_params)
#     for plate in g_i.Plates:
#         strBB = plate.Parent.BoundingBox.value
#         z1 = float(strBB.split(';')[2].split(')')[0])
#         z2 = float(strBB.split(';')[4].split(')')[0])
#         z=max(z1,z2)
#         count=0
#         while z<=thickness_layers[count]:
#             count=count+1
#         g_i.setmaterial(plate, plate_Mat_dict[count])
# =============================================================================
    #
# =============================================================================
#     # Bounding box for mesh refinement
#    bounding_box=g_i.surface(-clustering_vector[-1]-D/2, 0, seaBedLevel,-clustering_vector[-1]-D/2, clustering_vector[-1]+D/2, seaBedLevel,
#                clustering_vector[-1]+D/2, clustering_vector[-1]+D/2, seaBedLevel,clustering_vector[-1]+D/2, 0, seaBedLevel)
#    g_i.extrude(bounding_box, 0, 0, -l-D)
#     
#     
# =============================================================================
# =============================================================================
#     polycurve_2 = g_i.polycurve(0, 0, -global_scour-local_scour , 1, 0, 0, 0, 1, 0)
#     polycurve_2.Offset1 = (3*D / 4)
#     polycurve_2.add()
#     polycurve_2.Segments[-1].SegmentType = 'Arc'
#     polycurve_2.Segments[-1].ArcProperties.Radius =  (3*D / 4)
#     polycurve_2.Segments[-1].ArcProperties.CentralAngle = 180
#     polycurve_2.Segments[-1].ArcProperties.RelativeStartAngle1 = 90
#     polycurve_2.add()
#     polycurve_2.Segments[-1].LineProperties.Length = (3*D / 2)
#     polycurve_2.Segments[-1].LineProperties.RelativeStartAngle1 = 90
#     scour_Surface = g_i.surface(polycurve_2)
# 
#     polycurve_3 = g_i.polycurve(0, 0, -global_scour , 1, 0, 0, 0, 1, 0)
#     polycurve_3.Offset1 = (3*D / 4)+3*local_scour
#     polycurve_3.add()
#     polycurve_3.Segments[-1].SegmentType = 'Arc'
#     polycurve_3.Segments[-1].ArcProperties.Radius =  (3*D / 4)+3*local_scour
#     polycurve_3.Segments[-1].ArcProperties.CentralAngle = 180
#     polycurve_3.Segments[-1].ArcProperties.RelativeStartAngle1 = 90
#     polycurve_3.add()
#     polycurve_3.Segments[-1].LineProperties.Length = 2*((3*D / 4)+3*local_scour)
#     polycurve_3.Segments[-1].LineProperties.RelativeStartAngle1 = 90
#     scour_Surface2 = g_i.surface(polycurve_3)
#     
#     g_i.line((3*D / 4,0,-global_scour-local_scour),((3*D / 4)+3*local_scour,0,-global_scour))
#     g_i.revolve(g_i.Lines[-1],0,0,-1,0,0,-5,-180)
#     
#     for i in range(len(df2)):
#         g_i.point(df2["X"][i]+(D/2),df2["Y"][i],df2["Z"][i])
#     
#     #
# =============================================================================

    if int(df['State_var'][0])==1:
        for i in range(len(df2)):
            g_i.point(df2["X"][i]+(D/2),df2["Y"][i],df2["Z"][i])
    # Check if model depth is too large or not enough
    g_i.gotostages()
    last_layer=g_i.Soilvolumes[-1]
    last_layer_bb= last_layer.BoundingBox.value
    last_layer_depth = float(last_layer_bb.split(';')[2].split(')')[0])
    #
    # MESH
    #
    g_i.gotomesh()
    for volume in g_i.Volumes:
        volume.CoarsenessFactor = 0.5
    g_i.mesh(0.05, 256, True) 
    
    if int(df['State_var'][0])==1:
        g_i.selectmeshpoints()
        s_o, g_o = new_server('localhost', 10001, password='!YNW<c6W>mg?Mt8v')
        for i in range(len(df2)):
            g_o.addcurvepoint("Node",df2["X"][i]+(D/2),df2["Y"][i],df2["Z"][i])
            g_o.update()
    #
    # STAGED CONSTRUCTION  
    #
    g_i.gotostages()
    #	
    # Initial phase: K0 procedure
    g_i.deactivate(g_i.Plates, g_i.InitialPhase)
    g_i.deactivate(g_i.Interfaces, g_i.InitialPhase)
    
    plate_Mat_dict={}
    for i in range(len(pile_thickness)):
        #x='plateMat_'+str(i)
        GSteel = ESteel / (2 * (1 + nuSteel))
        plate_params = [("MaterialName", "Monopile_"+str(i)),
                        ("d", pile_thickness[i]),
                        ("Nu12", nuSteel),
                        ("IsIsotropic", True),
                        ("IsLinear", True),
                        ("E1", ESteel),
                        ("E2", ESteel),
                        ("G12", GSteel),
                        ("G13", GSteel),
                        ("G23", GSteel),
                        ("Density", gammaSteel)]
        plate_Mat_dict[i] = g_i.platemat(*plate_params)
    for plate in g_i.Plates:
        strBB = plate.Parent.BoundingBox.value
        z1 = float(strBB.split(';')[2].split(')')[0])
        z2 = float(strBB.split(';')[4].split(')')[0])
        z=max(z1,z2)
        count=0
        while z<=thickness_layers[count]:
            count=count+1
        #plate.Material[g_i.InitialPhase]= g_i.Materials[count]
        g_i.setmaterial(plate,g_i.InitialPhase, plate_Mat_dict[count])
    #
    # Phase1: Pile Installation
    pilephase = g_i.phase(g_i.InitialPhase)
    g_i.setcurrentphase(pilephase)
    pilephase.Identification = "Pile installation"
    g_i.activate(g_i.Plates, pilephase)
    # Activates interfaces below seabed. In plaxis the command "echo NegativeInterface_1_1.parent.boundingbox" gives back the string: "min: (-4.01; -0.01; 8.99) max: (4.01; 4.01; 
    for interface in g_i.Interfaces:
        strBB = interface.Parent.BoundingBox.value
        z1 = float(strBB.split(';')[2].split(')')[0])
        z2 = float(strBB.split(';')[4].split(')')[0])
        if max(z1,z2) <= 0.1:
            g_i.activate(interface, pilephase)
    # Sets interface materials instead of default adjacent soil properties       
    for interface in g_i.NegativeInterface_1:
        strBB = interface.Parent.BoundingBox.value
        z1 = float(strBB.split(';')[2].split(')')[0])
        z2 = float(strBB.split(';')[4].split(')')[0])
        if max(z1,z2) <= 0.1:
            interface.MaterialMode[pilephase] = "Custom"
            #print(z1,z2,max(z1,z2),min(z1,z2))            
            j = 0
            while min(z1,z2) < layer_thickness[j]-0.1:
                j=j+1

            
            interface.Material[pilephase] = g_i.Materials[j+len(interfaceProp)]   
    for interface in g_i.PositiveInterface_1:
        strBB = interface.Parent.BoundingBox.value
        z1 = float(strBB.split(';')[2].split(')')[0])
        z2 = float(strBB.split(';')[4].split(')')[0])
        if max(z1,z2) <= 0.1:
            interface.MaterialMode[pilephase] = "Custom"
            j = 0
            while min(z1,z2) < layer_thickness[j]-0.1:
                j=j+1
            interface.Material[pilephase] = g_i.Materials[j+len(interfaceProp)]        
    g_i.activate(g_i.Rigidbodies, pilephase)
    #
    # Phase2: Vertical loading
    vloadingphase = g_i.phase(pilephase)
    g_i.setcurrentphase(vloadingphase)
    vloadingphase.Identification = "Vertical loading"
    vloadingphase.Deform.IgnoreUndrainedBehaviour = True
    for rb in g_i.Rigidbodies:
        rb.Fz[vloadingphase] = force['V']
    #
    # Phase3: Horizontal loading until Displacement D/10,000
# =============================================================================
    dummy = g_i.phase(vloadingphase)
    g_i.setcurrentphase(dummy)
    
    for soils in g_i.Soils:
        strBB = soils.Parent.BoundingBox.value
        z1 = float(strBB.split(';')[2].split(')')[0])
        z2 = float(strBB.split(';')[4].split(')')[0])
        x1 = float(strBB.split(';')[0].split('(')[1])
        x2 = float(strBB.split(';')[2].split('(')[1])
       
        if min(z1,z2) >= -global_scour-local_scour:
            if max(x1,x2) > D:
                
                g_i.deactivate(soils, dummy)
            
# =============================================================================
#     dummy2 = g_i.phase(dummy)
#     g_i.setcurrentphase(dummy2)
#     for soils in g_i.Soils:
#         strBB = soils.Parent.BoundingBox.value
#         z1 = float(strBB.split(';')[2].split(')')[0])
#         z2 = float(strBB.split(';')[4].split(')')[0])
#         x1 = float(strBB.split(';')[0].split('(')[1])
#         x2 = float(strBB.split(';')[2].split('(')[1])
#        
#         if min(z1,z2) >= -global_scour:
#             x=1
#                         
#         elif min(z1,z2) >= -global_scour-local_scour-0.1:
#     
#             if (max(x1,x2)> (D/2+0.1)):
#                 
#                 if max(x1,x2)< ((3*D / 4)+3*local_scour+0.3):
#                     g_i.deactivate(soils, dummy2)
# =============================================================================
# =============================================================================
    hmloadingphase = g_i.phase(dummy)
    g_i.setcurrentphase(hmloadingphase)
    hmloadingphase.Deform.ResetDisplacementsToZero = True
    hmloadingphase.MaxStepsStored = hmloadingphase.Deform.MaxSteps
    hmloadingphase.Identification = "Displacement D/200"
    hmloadingphase.Deform.UseDefaultIterationParams = False
    hmloadingphase.Deform.MaxLoadFractionPerStep = (1./nStepsPYCurve)
    for rb in g_i.Rigidbodies:
        rb.ux[hmloadingphase] = (displacement['Disp_phase_1']*(pileProp['L']-(pileProp['l']/3)))/((2/3)*pileProp['l'])	#Applying displacement at top of the rigid body in order to obtain the input prescribed displacements at mudline
    
    # Phase4: Horizontal loading until Displacement D/10
    hmloadingphase2 = g_i.phase(dummy)
    g_i.setcurrentphase(hmloadingphase2)
    hmloadingphase2.Deform.ResetDisplacementsToZero = True
    hmloadingphase2.MaxStepsStored = hmloadingphase2.Deform.MaxSteps
    hmloadingphase2.Identification = "Displacement D/10"
    hmloadingphase2.Deform.UseDefaultIterationParams = False
    hmloadingphase2.Deform.MaxSteps=4000
    hmloadingphase2.MaxStepsStored = hmloadingphase2.Deform.MaxSteps
    hmloadingphase2.Deform.MaxLoadFractionPerStep = (1./nStepsPYCurve)

    for rb in g_i.Rigidbodies:
        rb.ux[hmloadingphase2] = (displacement['Disp_phase_2']*(pileProp['L']-(pileProp['l']/3)))/((2/3)*pileProp['l'])	#Applying displacement at top of the rigid body in order to obtain the input prescribed displacements at mudline
    
    #
    # Group creation for output
    listLateralInterfaces = []
    listBottomInterfaces = []
    
    for interface in g_i.Interfaces:
        strBB = interface.Parent.BoundingBox.value
        z1 = float(strBB.split(';')[2].split(')')[0])
        z2 = float(strBB.split(';')[4].split(')')[0])
        if (z1+z2)/2 <= 0 and (z1+z2)/2 > (seaBedLevel - l) \
                         and ('Negative' in interface.Name.value):
            listLateralInterfaces.append(interface)
        if abs(-(z1+z2)/2 + seaBedLevel - l) < eps:
           listBottomInterfaces.append(interface)
    groupLateralInterfaces = g_i.group(listLateralInterfaces)
    groupBottomInterfaces = g_i.group(listBottomInterfaces)
    g_i.rename(groupLateralInterfaces, "LateralInterfaces")
    g_i.rename(groupBottomInterfaces, "BottomInterfaces")
    
    listPlates= []
    for plate in g_i.Plates:
        strBB2 = plate.Parent.BoundingBox.value
        z1 = float(strBB2.split(';')[2].split(')')[0])
        z2 = float(strBB2.split(';')[4].split(')')[0])
        if (z1+z2)/2 <= 0:
            listPlates.append(plate)
    groupPlates = g_i.group(listPlates)        
    g_i.rename(groupPlates, "PlatesLat2")
    #
    # Calculate and save
    g_i.calculate()
    cwd = os.getcwd()
    try:
        os.mkdir('Plaxisfiles')
    except OSError:
        print ("Creation of the directory failed")
    else:
        print ("Successfully created the directory")
    os.chdir(cwd+"\Plaxisfiles")  

    cwd = os.getcwd()   
    try:
        os.mkdir(df['Model name'][0])
    except OSError:
        print ("Creation of the directory failed")
    else:
        print ("Successfully created the directory")
        
    os.chdir(cwd+"\\"+df['Model name'][0])
    
    workbook1 = xlsxwriter.Workbook('Updated_thickness.xlsx')
    worksheet1 = workbook1.add_worksheet('New')
    worksheet1.write('B1',"Thickness")
    worksheet1.write('A1',"Layer_bottom")
    worksheet1.write_column('A2', updated_thickness)
    worksheet1.write_column('B2', pile_thickness)
    workbook1.close()
    
    #input_cospin.inputcospin(df,soilProp,pileProp,waterLevel,updated_thickness,pile_thickness)
    results_directory= os.getcwd()
    
    if df['Save Project'][0]==1:
        try:
            os.mkdir('Plaxis Project')
        except OSError:
            print ("Creation of the directory failed")
        else:
            print ("Successfully created the directory")
        os.chdir(cwd+"\\"+df['Model name'][0]+'\Plaxis Project')
    
        filename = cwd+"\\"+df['Model name'][0]+'\Plaxis Project' + '\halfPile3D.p3d'
        
        g_i.save(filename)
        
    g_i.view(g_i.Phases[-2])
    
    return results_directory, vertical_clusters

def resultPostProcessing(df,results_directory,vertical_clusters):

# =============================================================================
#     import getInput
#     import math, sys, os, csv, xlsxwriter
# =============================================================================
    #import matplotlib.pyplot as plt
    #import numpy as np
    s_i, g_i = new_server('localhost', 10000, password='!YNW<c6W>mg?Mt8v')
    print('Input reached and connected')
    s_o, g_o = new_server('localhost', 10001, password='!YNW<c6W>mg?Mt8v')
    print('Output reached and connected')
    # here above both activation of input and output, fetch information from both
    # here below a lot of functions 
    def properOrientation(g):
        """
        Args:
            g (class): global object of the PLAXIS 3D Imput model
        Returns:
           boolean: true if plate local axis 1 points upwards, false otherwise
        
        Notice that bottom interface does not match the conditions!!
        """
        eps = 1e-5
        res = True
        for interface in g.Interfaces:
            surface = interface.Parent
            hasPlate = False
            for feature in surface.UserFeatures:
                if 'Plate' in feature._plx_type:
                   hasPlate = True
            if hasPlate and not (abs(surface.AxisFunction == 1) and 
                    abs(surface.AxisVectorX - 0.0) < eps and 
                    abs(surface.AxisVectorY - 0.0) < eps and 
                    abs(surface.AxisVectorZ - 1.0) < eps):
                res = False
                break
        return res
        
    def getNodeCoordinates(nodeNumbers, x, y, z):
        """
        Args:
            nodeNumbers (list): List of node numbers
            x  (list)         : List of corresponding nodal x-coordinates
            y  (list)         : List of corresponding nodal y-coordinates
            z  (list)         : List of corresponding nodal z-coordinates
        Returns:
            dict: keys (int)     : Node number
                  values (tuple) : Corresponding nodal coordinates
        """
        nodeCoordinates={}
        count = 0
        for nodeNumber in nodeNumbers:
            if not nodeNumber in nodeCoordinates.keys():
                nodeCoordinates[nodeNumber] = (x[count],y[count],z[count])
            count = count + 1
        return nodeCoordinates
    
    def getStressPointCoordinates(elementID, x, y, z):
        """
        Args:
            elementID (list): List of element numbers
            x  (list)       : List of corresponding nodal x-coordinates
            y  (list)       : List of corresponding nodal y-coordinates
            z  (list)       : List of corresponding nodal z-coordinates
        Returns:
            dict: keys (int)     : Element number
                  values (tuple) : Corresponding coordinates
        """
        elementCoordinates={}
        nComp = 6
        pos = 0
        for element in range(0, len(elementID), nComp):
            elementCoordinates[elementID[element]]=[]
            for i in range(nComp):
                elementCoordinates[elementID[element]].append((x[pos], y[pos], z[pos]))
                pos = pos + 1
        return elementCoordinates
    
    def shapeF(xi, eta):
        """
        Args:
            xi  (float): First local coordinate.
            eta (float): Second local coordinate.
        Returns:
            list: Values of shape function H at (xi, eta) for each nodes (6 components)
        """
        H = [0, 0, 0, 0, 0, 0]
        H[0] =  (1-xi-eta) * (1-2*xi-2*eta)
        H[1] =  -xi  * (1-2*xi )
        H[2] =  -eta * (1-2*eta)
        H[3] =   4*xi  * (1-xi-eta)
        H[4] =   4*xi*eta
        H[5] =   4*eta * (1-xi-eta)
        return H     
    
    def derivShapeF_Xi(xi, eta):
        """
        Args:
            xi  (float): First local coordinate.
            eta (float): Second local coordinate.
        Returns:
            list: Values of first derivative of shape function dH/dXi at (xi, eta) 
                  for each nodes (6 components)
        """
        dHdXi = [0, 0, 0, 0, 0, 0]
        dHdXi[0] = 4*(xi+eta) -3
        dHdXi[1] = 4* xi      -1
        dHdXi[2] = 0
        dHdXi[3] = 4*(1 - 2*xi - eta )
        dHdXi[4] = 4*eta
        dHdXi[5] = -4*eta
        return dHdXi     
    
    def derivShapeF_Eta(xi, eta):
        """
        Args:
            xi  (float): First local coordinate.
            eta (float): Second local coordinate.
        Returns:
            list: Values of second derivative of shape function dH/dEta at (xi, eta) 
                  for each nodes (6 components)
        """
        dHdEta = [0, 0, 0, 0, 0, 0]
        dHdEta[0] = 4*(xi+eta) -3
        dHdEta[1] = 0
        dHdEta[2] = 4* eta     -1
        dHdEta[3] = -4*xi
        dHdEta[4] = 4*xi
        dHdEta[5] = 4*(1 - xi - 2*eta)
        return dHdEta
    
    def crossProd(a, b):
        """
        Args:
            a (list): First parameter.
            b (list): Second parameter.
        Returns:
            list: Vector c cross-product of a and b: c = a^b
        """
        c = [a[1]*b[2] - a[2]*b[1],
             a[2]*b[0] - a[0]*b[2],
             a[0]*b[1] - a[1]*b[0]]
        return c
        
    def vecLength(a):
        """
        Args:
            a (list): Vector of arbitrary dimension
        Returns:
            float: Vector length
        """
        return math.sqrt(sum(i**2 for i in a))
    
    def getResultsPerElement(elementID, resultID, nComp):
        """
        Args:
            elementID (list) : List of element numbers
            resultID  (list) : List of corresponding results
            nComp (int)      : Number of result components
        Returns:
            dict: keys (int)    : Element number
                  values (list) : Corresponding element results
        """
        elementResults = {}
        pos = 0
        for element in range(0, len(resultID), nComp):
            elementResults[elementID[element]] = resultID[pos:pos+nComp]
            pos = pos + nComp
        return elementResults
        
    def getResultsPerNode(nodeID, resultID, nComp):
        """
        Args:
            nodeID (list)    : List of node numbers
            resultID  (list) : List of corresponding results
            nComp (int)      : Number of result components
        Returns:
            dict: keys (int)    : Node number
                  values (list) : Corresponding nodal results
        """
        nodeResults = {}
        pos = 0
        for node in range(0, len(resultID), nComp):
            nodeResults[nodeID[node]] = resultID[pos:pos+nComp]
            pos = pos + nComp
        return nodeResults
        
    def interpolate(nodalValues):
        """
        Args:
            nodalValues (dict): keys (int)    : Element number
                                values (list) : Nodal element values
        Returns:
            dict: keys (int)    : Element number
                  values (list) : Gauss point element values
        """
        xi   = (0.091576, 0.091576, 0.81685 , 0.10810, 0.44595, 0.44595)
        eta  = (0.81685 , 0.091576, 0.091576, 0.44595, 0.10810, 0.44595)
        nGauss = 6
        nNode = 6
        gaussPointValues = {}
        for element in nodalValues.keys():
            elementValues = [0 for i in range(nGauss)]
            for i in range(nGauss):
                for j in range(nNode):
                    elementValues[i] = elementValues[i] + shapeF(xi[i], eta[i])[j]*nodalValues[element][j]
            gaussPointValues[element] = elementValues
        return(gaussPointValues)
    
    def calculateJacobianAndNormal(connec, coord): 
        """
        Args:
            connec (dict): keys (int)    : Element number
                           values (list) : Element connectivity
            coord (dict):  keys (int)    : Node number
                           values (tuple): Node coordinates
        Returns:
            dict: keys (int)    : Element number
                  values (list) : Jacobian values for each element Gauss points
            dict: keys (int)    : Element number
                  values (list) : Normal vector coordinates for each element Gauss points (tuple)
        """
        xi   = (0.091576, 0.091576, 0.81685 , 0.10810, 0.44595, 0.44595)
        eta  = (0.81685 , 0.091576, 0.091576, 0.44595, 0.10810, 0.44595)
        nGauss = 6
        nNode = 6
        jacobian = {}
        normal = {}
        for element in connec.keys():
            dArea = [0 for i in range(nGauss)]
            vN = [0 for i in range(nGauss)]
            for i in range(nGauss):
                ddXi = [0, 0, 0]
                ddEta = [0, 0 ,0]
                j = 0
                for node in connec[element]:
                    for k in range(3):
                        ddXi[k]  = ddXi[k]  + derivShapeF_Xi(xi[i], eta[i])[j]*coord[node][k]
                        ddEta[k] = ddEta[k] + derivShapeF_Eta(xi[i], eta[i])[j]*coord[node][k]
                    j = j + 1
                dA = crossProd(ddXi, ddEta)
                lengthDA = vecLength(dA)
                dArea[i]= lengthDA/2 #Divide by 2 for triangular elements            
                vN[i] = (dA[0]/lengthDA, dA[1]/lengthDA, dA[2]/lengthDA)
            jacobian[element] = dArea
            normal[element] = vN
        return jacobian, normal
    
    def calculateNodalForces(sigN, tauS, tauT, jacob, normal, vS): 
        """
        Args:
            sigN (dict):   keys (int)    : Element number
                           values (list) : Normal stress for each element Gauss points
            tauS (dict):   keys (int)    : Element number
                           values (list) : Shear stress S (tau) for each element Gauss points
            tauT (dict):   keys (int)    : Element number
                           values (list) : Shear stress T (tau2) for each element Gauss points
            jacob (dict):  keys (int)    : Element number
                           values (list) : Jacobian values for each element Gauss points
            normal (dict): keys (int)    : Element number
                           values (list) : Global coordinates (list) of the local axis vN
            vS (list)                    : Local Axis 2 coordinates
        Returns:
            dict: keys (int)    : Element number
                  values (list) : Nodal forces for each element Gauss points in global axis
        """
        wFac = (0.10995, 0.10995, 0.10995, 0.22338, 0.22338, 0.22338)
        xi   = (0.091576, 0.091576, 0.81685 , 0.10810, 0.44595, 0.44595)
        eta  = (0.81685 , 0.091576, 0.091576, 0.44595, 0.10810, 0.44595)
        nGauss = 6
        nNode = 6
        globalForces = {}
        for element in jacob.keys():
            fGlo = [0 for m in range(18)]
            for i in range(nGauss):
                vN = normal[element][i]
                vT = crossProd(vN,vS)
                R11, R21, R31 = vN[0], vN[1], vN[2]  
                R12, R22, R32 = vS[0], vS[1], vS[2]  
                R13, R23, R33 = vT[0], vT[1], vT[2]  
                for j in range(nNode):
                    k = 3*j
                    fN = shapeF(xi[i], eta[i])[j]*sigN[element][i]*wFac[i]*jacob[element][i]
                    fS = shapeF(xi[i], eta[i])[j]*tauS[element][i]*wFac[i]*jacob[element][i]
                    fT = shapeF(xi[i], eta[i])[j]*tauT[element][i]*wFac[i]*jacob[element][i]
                    fX = R11*fN + R12*fS + R13*fT
                    fY = R21*fN + R22*fS + R23*fT
                    fZ = R31*fN + R32*fS + R33*fT
                    fGlo[k]   =  fGlo[k]   + fX
                    fGlo[k+1] =  fGlo[k+1] + fY
                    fGlo[k+2] =  fGlo[k+2] + fZ
            globalForces[element] = fGlo
        return globalForces
       
    def createElementSlices(coord,layers):
        """
        Args:
            coord (dict):    keys (int)    : Element number
                             values (tuple): Stress point coordinates
            pileProp (dict): keys (str)    : 'D', 't', 'L', 'l', 'h'
                             values (list) : Corresponding values
        Returns:
            dict: keys (int)    : Slice number
                  values (list) : Element numbers in slice
                  
        returns a list of slices with corresponding elements belonging to each slice          
        """
        slices = {}
        nGauss = 6
        for element in coord.keys():
            elementAverageElevation = 0 
            for i in range(nGauss):
                elementAverageElevation = elementAverageElevation + coord[element][i][2]/nGauss
            j=0
            while elementAverageElevation > layers[j]:
                j=j+1
            sliceNumber = j
            if sliceNumber in slices.keys():
                slices[sliceNumber].append(element)
            else:
                slices[sliceNumber]=[element]
        return slices    
    #
    def getBottomForcesInPile(nodalForces, connec, coord, xR, nPlug): #nPlug       Include this inside parenthesis for removing plug contribution
        """
        Args:
            nodalForces (dict):   keys (int)    : Element number
                                  values (list) : Element nodal forces
            connec (dict):   keys (int)    : Element number
                             values (list) : Element connectivity
            coord (dict):    keys (int)    : Node number
                             values (tuple): Node coordinates
            xR (float): Reference x-position
            nPLug (float): Soil plug Weight
        Returns:
            tuple: FX, FZ and MY forces
        """
        nNode = 6
        FX, FZ, MY = 0, 0, 0
        for element in nodalForces.keys():
            for n in range(nNode):
                j = 3*n
                nodeNumber = connec[element][n]
                x, y, z = coord[nodeNumber]
                FX = FX + 2*nodalForces[element][j]
                FZ = FZ + 2*nodalForces[element][j+2]
                MY = MY + 2*(x-xR)*(nodalForces[element][j+2])
        return FX, -FZ+nPlug, MY    #-FZ+nPlug
    #
    def calculateNPlug(sigN, D, area):
        """
        Args:
            sigN (list)  : Normal total stress
            D (float)    : Pile diameter
            area (string): 'Half' or 'Full'
        Returns:
            force (float): Normal force acting upwards
        """
        averageSig = 0
        nPoints = len(sigN)
        for sig in sigN:
            averageSig = averageSig + sig/nPoints
        force = 0.125*math.pi*averageSig*D**2
        if area == 'Full':
            force=force*2
        return force 
    #
    def getForcesInSlices(nodalForces, connec, slices,slice_heights, coord, pileProp, xR, bottomForces):
        """
        Args:
            nodalForces (dict):   
                        keys (int)    : Element number
                        values (list) : Element nodal forces
            connec (dict):        
                        keys (int)    : Element number
                        values (list) : Element connectivity
            slices (dict):        
                        keys (int)    : Slice number
                        values (list) : Element connectivity
            coord (dict):         
                        keys (int)    : Node number
                        values (tuple): Node coordinates
            pileProp (dict): 
                        keys (str)    : 'D', 't', 'L', 'l', 'h'
                        values (list) : Corresponding values
            xR (float)                : Reference x-position
            bottomForces (tuple)      : FX, FZ and MY forces at the bottom
        Returns:
            dict: 
                        keys (str)    : Z, N, V, M
                        values (list) : Corresponding Z, N, V and M values for each slice
        """
        nNode = 6
        sliceHeight  = pileProp['h']
        totalLength  = pileProp['L']
        buriedLength = pileProp['l']
        numberOfSlice = len(slice_heights)
        pileForces={}
        pileForces['Z'] = [-buriedLength]
        pileForces['N'] = [bottomForces[1]]
        pileForces['V'] = [bottomForces[0]]
        pileForces['M'] = [bottomForces[2]]
        for sliceNumber in slices.keys():
            print
            sliceHeight = slice_heights[sliceNumber]
            accumulated_heigth=sum(slice_heights[:(sliceNumber+1)])
            pileForces['Z'].append(round(-buriedLength+accumulated_heigth,2))
            zR, NSlice, VSlice, MSlice = pileForces['Z'][-1], pileForces['N'][-1], pileForces['V'][-1], pileForces['M'][-1]
            MSlice = MSlice + sliceHeight*VSlice
            for element in slices[sliceNumber]:
                for n in range(nNode):
                    k = 3*n
                    nodeNumber = connec[element][n]
                    x, y, z = coord[nodeNumber]
                    NSlice = NSlice + 2*nodalForces[element][k+2]
                    MSlice = MSlice - 2*(z-zR)*nodalForces[element][k] + 2*(x-xR)*nodalForces[element][k+2]
                    VSlice = VSlice + 2*nodalForces[element][k]
            pileForces['N'].append(NSlice)
            pileForces['V'].append(VSlice)
            pileForces['M'].append(MSlice)
        return pileForces    
    
    def pYValues(nodalForces, nodalUX, connec, slices,sHeights, numberOfSlice):
        """
        Args:
            nodalForces (dict):   
                        keys (int)    : Element number
                        values (list) : Element nodal forces
            nodalUX (dict):   
                        keys (int)    : Node number
                        values (float): X-Displacement
            connec (dict):        
                        keys (int)    : Element number
                        values (list) : Element connectivity
            slices (dict):        
                        keys (int)    : Slice number
                        values (list) : Element connectivity
            numberOfSlice (int)       : Number of relevant slices
        Returns:
            lists: Corresponding p and y values for each buried slice
        """
        nNode = 6
        p = [0 for m in range(numberOfSlice)]   
        y = [0 for m in range(numberOfSlice)]
        for sliceNumber in range(numberOfSlice):
            count = 0
            for element in slices[sliceNumber]:
                for n in range(nNode):
                    k = 3*n
                    p[sliceNumber] = p[sliceNumber] + 2*nodalForces[element][k]/sHeights[sliceNumber]  # factor 2 due to symmetry         #summatory of all the loads in the x-direcction from nodes belonging to elements which are in the same slide
                    y[sliceNumber] = y[sliceNumber] + nodalUX[connec[element][n]][0]                                #summatory of all the displacemnt in the x-direcction from nodes belonging to elements which are in the same slide. In the next lines they are averaged
                count = count + nNode
            y[sliceNumber] = y[sliceNumber]/count
        return p, y    
    
    
    
    
    #def rotation(UZ,Xcoord,UX):
    #    rot_radiands=[0 for m in range(len(UX))]
    #    rot_degrees_all={}
    #    m=0
    #    for i in UX.keys():       
    #       rot_radiands[m]=math.atan(UZ[i][0]/(UX[i][0]+Xcoord[i][0]))
    #        rot_degrees_all[i]=math.degrees(rot_radiands[m])
    #        m=m+1
    #        
    #    index_surf=[]
    #    for i, j in Xcoord.items():
    #        if (j==[4] or j==[-4]):
    #            index_surf.append(i)
    #        
    #    rot_degrees=[rot_degrees_all[k] for k in index_surf]   
    #    theta= (sum(rot_degrees))/len(rot_degrees)   
    #    
    #    return theta  
    
    def mtValues(nodalForces,nodalForces_v, nodalUX, nodalUZ, Xcoord, connec, slices, numberOfSlice):
    
        """
		Args:
			nodalForces (dict):   
						keys (int)    : Element number
						values (list) : Element nodal forces
			nodalUX (dict):   
						keys (int)    : Node number
						values (float): X-Displacement
			nodalUZ (dict):   
						keys (int)    : Node number
						values (float): Z-Displacement
			connec (dict):        
						keys (int)    : Element number
						values (list) : Element connectivity
			slices (dict):        
						keys (int)    : Slice number
						values (list) : Element connectivity
			numberOfSlice (int)       : Number of relevant slices
		Returns:
			lists: Corresponding M and theta values for each buried slice
		"""
        nNode = 6
        M = [0 for m in range(numberOfSlice)]   
        T = [0 for m in range(numberOfSlice)]
        for sliceNumber in range(numberOfSlice):
            count = 0
            for element in lateralSlices[sliceNumber]:
                for n in range(nNode):
                    k = 3*n
                    M[sliceNumber] = M[sliceNumber] + 2*((nodalForces[element][k+2]-nodalForces_v[element][k+2])*(Xcoord[connec[element][n]][0]))  # factor 2 due to symmetry         #summatory of all the moments along the y-axis from nodes belonging to elements which are in the same slide
					
                    xcoord_node = Xcoord[connec[element][n]][0]                               #filtering nodes on the x-axes (D=4 or D=-4) in order to caltulate rotation
                    if (xcoord_node == (pileProp['D']/2) or xcoord_node == -(pileProp['D']/2)):
                        T[sliceNumber] = T[sliceNumber] + (math.atan((nodalUZ[connec[element][n]][0])/(nodalUX[connec[element][n]][0]+xcoord_node)))                      
                        count = count + 1 
            T[sliceNumber] = T[sliceNumber]/count            
        return M, T  
   
    def unique(list1): 
  
        # intilize a null list 
        unique_list = [] 
          
        # traverse for all elements 
        for x in list1: 
            # check if exists in unique_list or not 
            if x not in unique_list: 
                unique_list.append(x)
        return  unique_list        
    
    
    #################################################################################################
    #                                   PRELIMINARY OPERATIONS                                      #
    #################################################################################################
    
    structuralForces = int(df['Structural forces'][0])
    Curves = int(df['Soil reaction curves'][0])
    
    # Reading some input data that will be used during post-processing
    pileProp, waterLevel, force, displacement, soilProp,soil_layers,pile_thickness, thickness_layers, global_scour, local_scour, clustering_vector, circle_division,vertical_separation = getInput.getInfo(df)
    if (-pileProp['l']) in soil_layers:
        soil_layers.remove(-pileProp['l'])
#    soil_layers.sort(reverse=False)
    
    # Primary check on the orientation of the interface as the information cannot be retrieved in an Output script
    if not properOrientation(g_i): 																#calling function for checking orientation of axis 1 pointing upwards, if not ok, script will stop
        print("Surface over which integration has to be performed should have local axis 1 pointing along z positive")
        sys.exit()
    
    # Retrieve nodes and stress points coordinates along with element connectivity for both lateral and bottom interfaces
    D_10 = g_o.Phases[-1]
    D_200 = g_o.Phases[-2]
    Initial_phase= g_o.Phases[0]
    
    intResults = g_o.ResultTypes.Interface
    print("Fetching interface element numbers, node numbers and coordinates")
    for group in g_o.Groups:
        if group.Name.value == "BottomInterfaces": 												#identify the nodes at bottom interfaces through naming properly the interface "Bottom Interfaces", see script building monopile.
            bottomNodX       = g_o.getresults(group, D_10, intResults.X, 'node')
            bottomNodY       = g_o.getresults(group, D_10, intResults.Y, 'node')
            bottomNodZ       = g_o.getresults(group, D_10, intResults.Z, 'node')
            bottomIntX       = g_o.getresults(group, D_10, intResults.X, 'stresspoint')
            bottomIntY       = g_o.getresults(group, D_10, intResults.Y, 'stresspoint')
            bottomIntZ       = g_o.getresults(group, D_10, intResults.Z, 'stresspoint')
            bottomNodeID     = g_o.getresults(group, D_10, intResults.NodeID, 'node')      #gives the node of each of the elements in the group, if a node belongs to several elements it will be repeated on the list
            bottomElementID  = g_o.getresults(group, D_10, intResults.ElementID, 'node')   #gives the element that each node belongs to (so each element is repeated 6 times, one per node)
        if group.Name.value == "LateralInterfaces":
            lateralNodX      = g_o.getresults(group, D_10, intResults.X, 'node')
            lateralNodY      = g_o.getresults(group, D_10, intResults.Y, 'node')
            lateralNodZ      = g_o.getresults(group, D_10, intResults.Z, 'node')
            lateralIntX      = g_o.getresults(group, D_10, intResults.X, 'stresspoint')
            lateralIntY      = g_o.getresults(group, D_10, intResults.Y, 'stresspoint')
            lateralIntZ      = g_o.getresults(group, D_10, intResults.Z, 'stresspoint')
            lateralNodeID    = g_o.getresults(group, D_10, intResults.NodeID, 'node')
            lateralElementID = g_o.getresults(group, D_10, intResults.ElementID, 'node')
        
    
    # Store coordinates and connectivity in dictionnaries for easier to develop and more readable code
    print("Storing coordinates and connectivity in dictionnaries") #creating dictonaries by calling functions from the script (top of script), main methodology to fetch data is through dictionaries.
    
    lateralInterfaceNodeCoordinates = getNodeCoordinates(lateralNodeID, lateralNodX, lateralNodY, lateralNodZ)
    lateralInterfaceStressPointCoordinates = getStressPointCoordinates(lateralElementID, lateralIntX, lateralIntY, lateralIntZ)
    lateralElementConnectivity = getResultsPerElement(lateralElementID, lateralNodeID, 6)   #gives the list of nodes separated by element number (key:element number)
    
    
    bottomInterfaceNodeCoordinates = getNodeCoordinates(bottomNodeID, bottomNodX, bottomNodY, bottomNodZ)
    bottomInterfaceStressPointCoordinates = getStressPointCoordinates(bottomElementID, bottomIntX, bottomIntY, bottomIntZ)
    bottomElementConnectivity = getResultsPerElement(bottomElementID, bottomNodeID, 6)  #gives the list of nodes separated by element number (key:element number)
    
    # Evaluate element connectivity per slice in lateral interface as forces will be calculated per slice
    # The slicing is defined in the input file and represents the pile discretization for the definition of the p-y curve
    # The same discretization will also be used  for generating the evolution of the structural forces along the pile
    # createElementSlices returns a dictionnary the values of which represent the interface element number in each slice (key)
    print("Evaluating element numbers per slice")
    lateralSlices2 = createElementSlices(lateralInterfaceStressPointCoordinates, soil_layers)

    slicess=[]
    for slice in range(len(lateralSlices2)):
        slicess.append(slice)
    
    lateralSlices={k: lateralSlices2[k] for k in slicess} 
    
    if (-pileProp['l']) not in soil_layers:
        soil_layers.append(float(-pileProp['l']))
    soil_layers.sort(reverse=False)
    
        
    slice_heights=[]    
    for z in range(len(soil_layers)-1):
        slice_heights.append(round(abs(soil_layers[z]-soil_layers[z+1]),2))
    #del slice_heights[-1]
    

    ################------DElETING SLICES OF SCOUR-------##############
    soil_layers2=[]
    for sl in range(len(soil_layers)):
        soil_layers2.append(-soil_layers[len(soil_layers)-sl-1])
        
    remove_layers=0
    rml=0
    while (global_scour+local_scour)-remove_layers >0.1:
        remove_layers=soil_layers2[rml]
        rml=rml+1
        
    for iii in range(rml-1):
        del slice_heights[-1]
        del soil_layers2[0]
        
    ########################################################################################
    #                                       CLUSTERS                                       #
    ########################################################################################   
    
    D = pileProp['D']
    
    clusters_node_id = {}
    clusters_node_x = {}
    clusters_node_y = {}
    clusters_node_z = {}
    clusters_element_id = {}
    
    clusters_x = {}
    clusters_y = {}
    clusters_z = {}
    
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

    cluster_normalization={} 
                                         
    for i in all_clusters.keys():


        Drainage_cluster = g_i.echo(all_clusters[i][0].Material[Initial_phase].DrainageType).split(':')[1].split('(')[0].strip()
        
        if Drainage_cluster =="Undrained":
            
            cluster_normalization[i]=float(g_i.echo(all_clusters[i][0].Material[Initial_phase].cref).split(':')[1].split('k')[0].strip())
        
        if Drainage_cluster =="Drained":
            
            cluster_normalization[i] = -sum(g_o.getresults(all_clusters[i][0], Initial_phase, g_o.ResultTypes.Soil.SigzzE, 'node')[:])/len(g_o.getresults(all_clusters[i][0], Initial_phase, g_o.ResultTypes.Soil.SigzzE, 'node')[:])
            
            
    for i in all_clusters.keys():
        
        clusters_node_id[i] = g_o.getresults(all_clusters[i][0], D_10, g_o.ResultTypes.Soil.NodeID, 'node')
        clusters_node_x[i] = g_o.getresults(all_clusters[i][0], D_10, g_o.ResultTypes.Soil.X, 'node')
        clusters_node_y[i] = g_o.getresults(all_clusters[i][0], D_10, g_o.ResultTypes.Soil.Y, 'node') 
        clusters_node_z[i] = g_o.getresults(all_clusters[i][0], D_10, g_o.ResultTypes.Soil.Z, 'node')
        clusters_element_id[i] = g_o.getresults(all_clusters[i][0], D_10, g_o.ResultTypes.Soil.ElementID, 'node')
        clusters_x[i] = sum(g_o.getresults(all_clusters[i][0], D_10, g_o.ResultTypes.Soil.X, 'node')[:])/len(g_o.getresults(all_clusters[i][0], D_10, g_o.ResultTypes.Soil.X, 'node')[:])
        clusters_y[i] = sum(g_o.getresults(all_clusters[i][0], D_10, g_o.ResultTypes.Soil.Y, 'node')[:])/len(g_o.getresults(all_clusters[i][0], D_10, g_o.ResultTypes.Soil.Y, 'node')[:])
        clusters_z[i] = sum(g_o.getresults(all_clusters[i][0], D_10, g_o.ResultTypes.Soil.Z, 'node')[:])/len(g_o.getresults(all_clusters[i][0], D_10, g_o.ResultTypes.Soil.Z, 'node')[:])
            
    
    ######################################################################################## 
    # Calculate jacobians and normals for interface elements as they will be used during post-processing
    print("Calculating jacobians and normals for interface elements")
    lateralJacobian, lateralNormal =  calculateJacobianAndNormal(lateralElementConnectivity, lateralInterfaceNodeCoordinates)
    bottomJacobian, bottomNormal = calculateJacobianAndNormal(bottomElementConnectivity, bottomInterfaceNodeCoordinates)
    
    # Defining at which steps the curve points will be extracted for each of the phases giving as input target MStage values
    Mstage1  = []
    Mstage2  = []
    Mstage_points_curve1_all = []
    Mstage_points_curve2_all = []
    Mstage_target1=[0.004,1] 	  #[0.004,0.01,0.02,0.03,0.04,0.05,0.06,0.08,0.1,0.15,0.2,0.3,0.4,0.6,0.8,1]									# target MStage points where we want results (Phase D/200)
    Mstage_target2=[0.004,0.1,1]  #[0.004,0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08,0.09,0.1,0.12,0.15,0.175,0.2,0.25,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1]  # target MStage points where we want results (Phase D/10)

    
    for step in D_200.Steps:
        Mstage1.append(step.Reached.SumMstage.value)
    for m in range(len(Mstage_target1)):  
    	Mstage_points_curve1_all.append(min(range(len(Mstage1)), key=lambda i: abs(Mstage1[i]-Mstage_target1[m])))
    Mstage_points_curve1 = unique(Mstage_points_curve1_all)    
    print('The steps at which curve points will extracted for phase D/200 are ',Mstage_points_curve1)
    
    for step in D_10.Steps:
        Mstage2.append(step.Reached.SumMstage.value)
    for m in range(len(Mstage_target2)):  
    	Mstage_points_curve2_all.append(min(range(len(Mstage2)), key=lambda i: abs(Mstage2[i]-Mstage_target2[m])))
    Mstage_points_curve2= unique(Mstage_points_curve2_all) 
    print('The steps at which curve points will extracted for phase D/10 are ',Mstage_points_curve2)
    #################################################################################################
	#                       Forces at the the end fo vertical loading phase                         #
	#################################################################################################

    V_phase = g_o.Phases[-3]

    for group in g_o.Groups:
    	if group.Name.value == "BottomInterfaces":
    		bottomNodalSigTot_v  = g_o.getresults(group, V_phase, intResults.InterfaceEffectiveNormalStress, 'node')
    		bottomTau1_v         = g_o.getresults(group, V_phase, intResults.InterfaceShearStress, 'stresspoint')
    		bottomTau2_v         = g_o.getresults(group, V_phase, intResults.InterfaceShearStress2, 'stresspoint')
    	if group.Name.value == "LateralInterfaces":
    		lateralNodalSigTot_v = g_o.getresults(group, V_phase, intResults.InterfaceTotalNormalStress, 'node')
    		lateralTau1_v        = g_o.getresults(group, V_phase, intResults.InterfaceShearStress, 'stresspoint')
    		lateralTau2_v        = g_o.getresults(group, V_phase, intResults.InterfaceShearStress2, 'stresspoint')		

	# Stored fetched results in dictionnaries to provide data structure
    bottomTauSLocal_v       = getResultsPerElement(bottomElementID, bottomTau1_v, 6)
    bottomTauTLocal_v       = getResultsPerElement(bottomElementID, bottomTau2_v, 6)
    bottomNodalSigNLocal_v  = getResultsPerElement(bottomElementID, bottomNodalSigTot_v, 6)
    lateralTauSLocal_v      = getResultsPerElement(lateralElementID, lateralTau1_v, 6)
    lateralTauTLocal_v      = getResultsPerElement(lateralElementID, lateralTau2_v, 6)
    lateralNodalSigNLocal_v = getResultsPerElement(lateralElementID, lateralNodalSigTot_v, 6)				
    bottomSigNLocal_v  = interpolate(bottomNodalSigNLocal_v)
    lateralSigNLocal_v = interpolate(lateralNodalSigNLocal_v)

	# Calculating global nodal forces for interface elements
    localAxis2 = [1, 0, 0]
    bottomGlobalNodalForces_v  = calculateNodalForces(bottomSigNLocal_v, bottomTauSLocal_v, bottomTauTLocal_v, bottomJacobian, bottomNormal, localAxis2)
    localAxis2 = [0, 0, 1]
    lateralGlobalNodalForces_v = calculateNodalForces(lateralSigNLocal_v, lateralTauSLocal_v, lateralTauTLocal_v, lateralJacobian, lateralNormal, localAxis2)

    os.chdir(results_directory)
    
    if structuralForces==1:
    	nSteps1 = len(Mstage_points_curve1)
    	workbook1 = xlsxwriter.Workbook('Structural Forces D_200.xlsx')
    	worksheet1 = workbook1.add_worksheet('N')
    	worksheet2 = workbook1.add_worksheet('V')
    	worksheet3 = workbook1.add_worksheet('M')
    	worksheet4 = workbook1.add_worksheet('Pile Displacement')
    	F1=[]
    		
    	j=0
    	for step in (D_200.Steps[t] for t in Mstage_points_curve1):
    		print('Processing step #',j+1,' out of ',nSteps1, 'steps, Phase D/200')
            # Fetch interface stress results meant to be integrated to provide nodal forces in global axis later on
    		for group in g_o.Groups:
    			if group.Name.value == "BottomInterfaces":
    				bottomNodalSigTot  = g_o.getresults(group, step, intResults.InterfaceEffectiveNormalStress, 'node')
    				bottomTau1         = g_o.getresults(group, step, intResults.InterfaceShearStress, 'stresspoint')
    				bottomTau2         = g_o.getresults(group, step, intResults.InterfaceShearStress2, 'stresspoint')
    			if group.Name.value == "LateralInterfaces":
    				lateralNodalSigTot = g_o.getresults(group, step, intResults.InterfaceTotalNormalStress, 'node')
    				lateralTau1        = g_o.getresults(group, step, intResults.InterfaceShearStress, 'stresspoint')
    				lateralTau2        = g_o.getresults(group, step, intResults.InterfaceShearStress2, 'stresspoint')		
    				lateralNodDispX    = g_o.getresults(group, step, intResults.Ux, 'node')
    				lateralIncDispX    = g_o.getresults(group, step, intResults.IRelUx, 'node')         # relative displacement between the two nodes sharing coordinates (interface/structure) 
    				lateralDispX = [x - y for x, y in zip(lateralNodDispX, lateralIncDispX)]            # sum of the interface displacement + relative displaceme
    		
    		# Stored fetched results in dictionnaries to provide data structure
    		bottomTauSLocal       = getResultsPerElement(bottomElementID, bottomTau1, 6)
    		bottomTauTLocal       = getResultsPerElement(bottomElementID, bottomTau2, 6)
    		bottomNodalSigNLocal  = getResultsPerElement(bottomElementID, bottomNodalSigTot, 6)
    		lateralTauSLocal      = getResultsPerElement(lateralElementID, lateralTau1, 6)
    		lateralTauTLocal      = getResultsPerElement(lateralElementID, lateralTau2, 6)
    		lateralNodalSigNLocal = getResultsPerElement(lateralElementID, lateralNodalSigTot, 6)
    
    		# Interpolate total stress to Gauss points as Output only provides them at nodes
    		bottomSigNLocal  = interpolate(bottomNodalSigNLocal)
    		lateralSigNLocal = interpolate(lateralNodalSigNLocal)
    
    		# Calculating global nodal forces for interface elements
    		localAxis2 = [1, 0, 0]
    		bottomGlobalNodalForces  = calculateNodalForces(bottomSigNLocal, bottomTauSLocal, bottomTauTLocal, bottomJacobian, bottomNormal, localAxis2)
    		localAxis2 = [0, 0, 1]
    		lateralGlobalNodalForces = calculateNodalForces(lateralSigNLocal, lateralTauSLocal, lateralTauTLocal, lateralJacobian, lateralNormal, localAxis2)
    
    		# Calculating force distribution within the pile
    		# Strategy first consists in integrating stresses at bottom level (done in pileBottomForce) to obtain N, V and M at bottom
    		# and then start integrating forces slice by slice from bottom level (done in structuralForces) to get N, V, M distribution over the pile
    		# The contribution of the soil plug can be eventually deducted (which is what is being done here). This is debattable though
    		xRef, yRef = 0, 0
    		nPlug = calculateNPlug (bottomNodalSigTot, pileProp['D'], 'Half')
    		pileBottomForce = getBottomForcesInPile(bottomGlobalNodalForces, bottomElementConnectivity, bottomInterfaceNodeCoordinates, xRef, nPlug)    
    		structuralForces1 = getForcesInSlices(lateralGlobalNodalForces, lateralElementConnectivity, lateralSlices,slice_heights, lateralInterfaceNodeCoordinates, pileProp, xRef, pileBottomForce)
    	
    		#Calculating horizontal displacement at slices intersection
    		index_disp=[]
    		for x in soil_layers:

    			w=0
    			for p in range(len(lateralNodX)):
    				if (lateralNodX[p]==(pileProp['D']/2) and abs(lateralNodZ[p]-x)<0.001):
    					index_disp.append(w)
    					break
    				else:
    					w=w+1
    		Disp_Slices=[lateralDispX[m] for m in index_disp]
    		Disp_Slices.reverse()
    		#Creating excels with Structural information
    		
    		row=0
    		col=0
    		
    		structuralForces1['Z'].reverse()
    		structuralForces1['N'].reverse()
    		structuralForces1['V'].reverse()
    		structuralForces1['M'].reverse()
    		
    		if j==0:
    			for i in range(len(structuralForces1['Z'])):
    				row = row+1
    				worksheet1.write(row+2, col, structuralForces1['Z'][i])
    				worksheet2.write(row+2, col, structuralForces1['Z'][i])
    				worksheet3.write(row+2, col, structuralForces1['Z'][i])
    				worksheet4.write(row+2, col, structuralForces1['Z'][i])
    			row = 0
    			
    			worksheet1.write(row, col, 'Fx Reached')
    			worksheet2.write(row, col, 'Fx Reached')
    			worksheet3.write(row, col, 'Fx Reached')
    			worksheet4.write(row, col, 'Fx Reached')
    			
    			worksheet1.write(row+2, col, 'Depth')
    			worksheet2.write(row+2, col, 'Depth')
    			worksheet3.write(row+2, col, 'Depth')
    			worksheet4.write(row+2, col, 'Depth')
    			
    		worksheet1.write(0, j+1, step.Reached.ForceX.value)
    		worksheet2.write(0, j+1, step.Reached.ForceX.value)
    		worksheet3.write(0, j+1, step.Reached.ForceX.value)
    		worksheet4.write(0, j+1, step.Reached.ForceX.value)
    		F1.append(step.Reached.ForceX.value)
    		
    		worksheet1.write(2, j+1, 'Step '+str(Mstage_points_curve1[j]+1))
    		worksheet2.write(2, j+1, 'Step '+str(Mstage_points_curve1[j]+1))
    		worksheet3.write(2, j+1, 'Step '+str(Mstage_points_curve1[j]+1))
    		worksheet4.write(2, j+1, 'Step '+str(Mstage_points_curve1[j]+1))
    				
    		for i in range(len(structuralForces1['Z'])):
    		
    			worksheet1.write(row+3, j+1, structuralForces1['N'][i])
    			worksheet2.write(row+3, j+1, structuralForces1['V'][i])
    			worksheet3.write(row+3, j+1, structuralForces1['M'][i])
    			worksheet4.write(row+3, j+1, Disp_Slices[i])
    			row +=1
    			
    		j = j+1
    		
    	workbook1.close()
    	
    	nSteps2 = len(Mstage_points_curve2)
    	workbook2 = xlsxwriter.Workbook('Structural Forces D_10.xlsx')
    	worksheet5 = workbook2.add_worksheet('N')
    	worksheet6 = workbook2.add_worksheet('V')
    	worksheet7 = workbook2.add_worksheet('M')
    	worksheet8 = workbook2.add_worksheet('Pile Displacement')
    	F2=[]
    	
    	j=0
    	for step in (D_10.Steps[t] for t in Mstage_points_curve2):
    		print('Processing step #',j+1,' out of ',nSteps2, 'steps, Phase D/10')
    		# Fetch interface stress results meant to be integrated to provide nodal forces in global axis later on
    		for group in g_o.Groups:
    			if group.Name.value == "BottomInterfaces":
    				bottomNodalSigTot  = g_o.getresults(group, step, intResults.InterfaceEffectiveNormalStress, 'node')
    				bottomTau1         = g_o.getresults(group, step, intResults.InterfaceShearStress, 'stresspoint')
    				bottomTau2         = g_o.getresults(group, step, intResults.InterfaceShearStress2, 'stresspoint')
    			if group.Name.value == "LateralInterfaces":
    				lateralNodalSigTot = g_o.getresults(group, step, intResults.InterfaceTotalNormalStress, 'node')
    				lateralTau1        = g_o.getresults(group, step, intResults.InterfaceShearStress, 'stresspoint')
    				lateralTau2        = g_o.getresults(group, step, intResults.InterfaceShearStress2, 'stresspoint')		
    				lateralNodDispX    = g_o.getresults(group, step, intResults.Ux, 'node')
    				lateralIncDispX    = g_o.getresults(group, step, intResults.IRelUx, 'node')         # relative displacement between the two nodes sharing coordinates (interface/structure) 
    				lateralDispX = [x - y for x, y in zip(lateralNodDispX, lateralIncDispX)]            # sum of the interface displacement + relative displaceme
    		
    		# Stored fetched results in dictionnaries to provide data structure
    		bottomTauSLocal       = getResultsPerElement(bottomElementID, bottomTau1, 6)
    		bottomTauTLocal       = getResultsPerElement(bottomElementID, bottomTau2, 6)
    		bottomNodalSigNLocal  = getResultsPerElement(bottomElementID, bottomNodalSigTot, 6)
    		lateralTauSLocal      = getResultsPerElement(lateralElementID, lateralTau1, 6)
    		lateralTauTLocal      = getResultsPerElement(lateralElementID, lateralTau2, 6)
    		lateralNodalSigNLocal = getResultsPerElement(lateralElementID, lateralNodalSigTot, 6)
    
    		# Interpolate total stress to Gauss points as Output only provides them at nodes
    		bottomSigNLocal  = interpolate(bottomNodalSigNLocal)
    		lateralSigNLocal = interpolate(lateralNodalSigNLocal)
    
    		# Calculating global nodal forces for interface elements
    		localAxis2 = [1, 0, 0]
    		bottomGlobalNodalForces  = calculateNodalForces(bottomSigNLocal, bottomTauSLocal, bottomTauTLocal, bottomJacobian, bottomNormal, localAxis2)
    		localAxis2 = [0, 0, 1]
    		lateralGlobalNodalForces = calculateNodalForces(lateralSigNLocal, lateralTauSLocal, lateralTauTLocal, lateralJacobian, lateralNormal, localAxis2)
    
    		# Calculating force distribution within the pile
    		# Strategy first consists in integrating stresses at bottom level (done in pileBottomForce) to obtain N, V and M at bottom
    		# and then start integrating forces slice by slice from bottom level (done in structuralForces) to get N, V, M distribution over the pile
    		# The contribution of the soil plug can be eventually deducted (which is what is being done here). This is debattable though
    		xRef, yRef = 0, 0
    		nPlug = calculateNPlug (bottomNodalSigTot, pileProp['D'], 'Half')
    		pileBottomForce = getBottomForcesInPile(bottomGlobalNodalForces, bottomElementConnectivity, bottomInterfaceNodeCoordinates, xRef, nPlug)    
    		structuralForces2 = getForcesInSlices(lateralGlobalNodalForces, lateralElementConnectivity, lateralSlices,slice_heights, lateralInterfaceNodeCoordinates, pileProp, xRef, pileBottomForce)
    		
    		#Calculating horizontal displacement at slices intersection   			
    		index_disp=[]
    		for x in soil_layers:

    			w=0
    			for p in range(len(lateralNodX)):
    				if (lateralNodX[p]==(pileProp['D']/2) and abs(lateralNodZ[p]-x)<0.001):
    					index_disp.append(w)
    					break
    				else:
    					w=w+1
    		Disp_Slices=[lateralDispX[m] for m in index_disp]
    		Disp_Slices.reverse()
              		
    		#Creating excels with Structural information
    		
    		row=0
    		col=0
    		
    		structuralForces2['Z'].reverse()
    		structuralForces2['N'].reverse()
    		structuralForces2['V'].reverse()
    		structuralForces2['M'].reverse()
    		
    		if j==0:
    			for i in range(len(structuralForces2['Z'])):
    				row = row+1
    				worksheet5.write(row+2, col, structuralForces2['Z'][i])
    				worksheet6.write(row+2, col, structuralForces2['Z'][i])
    				worksheet7.write(row+2, col, structuralForces2['Z'][i])
    				worksheet8.write(row+2, col, structuralForces2['Z'][i])
    			row = 0
    			
    			worksheet5.write(row, col, 'Fx Reached')
    			worksheet6.write(row, col, 'Fx Reached')
    			worksheet7.write(row, col, 'Fx Reached')
    			worksheet8.write(row, col, 'Fx Reached')
    			
    			worksheet5.write(row+2, col, 'Depth')
    			worksheet6.write(row+2, col, 'Depth')
    			worksheet7.write(row+2, col, 'Depth')
    			worksheet8.write(row+2, col, 'Depth')
    			
    		worksheet5.write(0, j+1, step.Reached.ForceX.value)
    		worksheet6.write(0, j+1, step.Reached.ForceX.value)
    		worksheet7.write(0, j+1, step.Reached.ForceX.value)
    		worksheet8.write(0, j+1, step.Reached.ForceX.value)
    		F2.append(step.Reached.ForceX.value)
            
    		worksheet5.write(2, j+1, 'Step '+str(Mstage_points_curve2[j]+1))
    		worksheet6.write(2, j+1, 'Step '+str(Mstage_points_curve2[j]+1))
    		worksheet7.write(2, j+1, 'Step '+str(Mstage_points_curve2[j]+1))
    		worksheet8.write(2, j+1, 'Step '+str(Mstage_points_curve2[j]+1))
    				
    		for i in range(len(structuralForces2['Z'])):
    		
    			worksheet5.write(row+3, j+1, structuralForces2['N'][i])
    			worksheet6.write(row+3, j+1, structuralForces2['V'][i])
    			worksheet7.write(row+3, j+1, structuralForces2['M'][i])
    			worksheet8.write(row+3, j+1, Disp_Slices[i])
    			row +=1
    			
    		j = j+1
    		
    	workbook2.close()       
      
    if structuralForces==1:
    	nSteps1 = len(Mstage_points_curve1)
    	workbook1 = xlsxwriter.Workbook('Structural Forces D_200.xlsx')
    	worksheet1 = workbook1.add_worksheet('N')
    	worksheet2 = workbook1.add_worksheet('V')
    	worksheet3 = workbook1.add_worksheet('M')
    	worksheet4 = workbook1.add_worksheet('Pile Displacement')
    	F1=[]
    		
    	j=0
    	for step in (D_200.Steps[t] for t in Mstage_points_curve1):
    		print('Processing step #',j+1,' out of ',nSteps1, 'steps, Phase D/200')
            # Fetch interface stress results meant to be integrated to provide nodal forces in global axis later on
    		for group in g_o.Groups:
    			if group.Name.value == "BottomInterfaces":
    				bottomNodalSigTot  = g_o.getresults(group, step, intResults.InterfaceEffectiveNormalStress, 'node')
    				bottomTau1         = g_o.getresults(group, step, intResults.InterfaceShearStress, 'stresspoint')
    				bottomTau2         = g_o.getresults(group, step, intResults.InterfaceShearStress2, 'stresspoint')
    			if group.Name.value == "LateralInterfaces":
    				lateralNodalSigTot = g_o.getresults(group, step, intResults.InterfaceTotalNormalStress, 'node')
    				lateralTau1        = g_o.getresults(group, step, intResults.InterfaceShearStress, 'stresspoint')
    				lateralTau2        = g_o.getresults(group, step, intResults.InterfaceShearStress2, 'stresspoint')		
    				lateralNodDispX    = g_o.getresults(group, step, intResults.Ux, 'node')
    				lateralIncDispX    = g_o.getresults(group, step, intResults.IRelUx, 'node')         # relative displacement between the two nodes sharing coordinates (interface/structure) 
    				lateralDispX = [x - y for x, y in zip(lateralNodDispX, lateralIncDispX)]            # sum of the interface displacement + relative displaceme
    		
    		# Stored fetched results in dictionnaries to provide data structure
    		bottomTauSLocal       = getResultsPerElement(bottomElementID, bottomTau1, 6)
    		bottomTauTLocal       = getResultsPerElement(bottomElementID, bottomTau2, 6)
    		bottomNodalSigNLocal  = getResultsPerElement(bottomElementID, bottomNodalSigTot, 6)
    		lateralTauSLocal      = getResultsPerElement(lateralElementID, lateralTau1, 6)
    		lateralTauTLocal      = getResultsPerElement(lateralElementID, lateralTau2, 6)
    		lateralNodalSigNLocal = getResultsPerElement(lateralElementID, lateralNodalSigTot, 6)
    
    		# Interpolate total stress to Gauss points as Output only provides them at nodes
    		bottomSigNLocal  = interpolate(bottomNodalSigNLocal)
    		lateralSigNLocal = interpolate(lateralNodalSigNLocal)
    
    		# Calculating global nodal forces for interface elements
    		localAxis2 = [1, 0, 0]
    		bottomGlobalNodalForces  = calculateNodalForces(bottomSigNLocal, bottomTauSLocal, bottomTauTLocal, bottomJacobian, bottomNormal, localAxis2)
    		localAxis2 = [0, 0, 1]
    		lateralGlobalNodalForces = calculateNodalForces(lateralSigNLocal, lateralTauSLocal, lateralTauTLocal, lateralJacobian, lateralNormal, localAxis2)
    
    		# Calculating force distribution within the pile
    		# Strategy first consists in integrating stresses at bottom level (done in pileBottomForce) to obtain N, V and M at bottom
    		# and then start integrating forces slice by slice from bottom level (done in structuralForces) to get N, V, M distribution over the pile
    		# The contribution of the soil plug can be eventually deducted (which is what is being done here). This is debattable though
    		xRef, yRef = 0, 0
    		nPlug = calculateNPlug (bottomNodalSigTot, pileProp['D'], 'Half')
    		pileBottomForce = getBottomForcesInPile(bottomGlobalNodalForces, bottomElementConnectivity, bottomInterfaceNodeCoordinates, xRef, nPlug)    
    		structuralForces1 = getForcesInSlices(lateralGlobalNodalForces, lateralElementConnectivity, lateralSlices,slice_heights, lateralInterfaceNodeCoordinates, pileProp, xRef, pileBottomForce)
    	
    		#Calculating horizontal displacement at slices intersection
    		index_disp=[]
    		for x in soil_layers:

    			w=0
    			for p in range(len(lateralNodX)):
    				if (lateralNodX[p]==(pileProp['D']/2) and abs(lateralNodZ[p]-x)<0.001):
    					index_disp.append(w)
    					break
    				else:
    					w=w+1
    		Disp_Slices=[lateralDispX[m] for m in index_disp]
    		Disp_Slices.reverse()
    		#Creating excels with Structural information
    		
    		row=0
    		col=0
    		
    		structuralForces1['Z'].reverse()
    		structuralForces1['N'].reverse()
    		structuralForces1['V'].reverse()
    		structuralForces1['M'].reverse()
    		
    		if j==0:
    			for i in range(len(structuralForces1['Z'])):
    				row = row+1
    				worksheet1.write(row+2, col, structuralForces1['Z'][i])
    				worksheet2.write(row+2, col, structuralForces1['Z'][i])
    				worksheet3.write(row+2, col, structuralForces1['Z'][i])
    				worksheet4.write(row+2, col, structuralForces1['Z'][i])
    			row = 0
    			
    			worksheet1.write(row, col, 'Fx Reached')
    			worksheet2.write(row, col, 'Fx Reached')
    			worksheet3.write(row, col, 'Fx Reached')
    			worksheet4.write(row, col, 'Fx Reached')
    			
    			worksheet1.write(row+2, col, 'Depth')
    			worksheet2.write(row+2, col, 'Depth')
    			worksheet3.write(row+2, col, 'Depth')
    			worksheet4.write(row+2, col, 'Depth')
    			
    		worksheet1.write(0, j+1, step.Reached.ForceX.value)
    		worksheet2.write(0, j+1, step.Reached.ForceX.value)
    		worksheet3.write(0, j+1, step.Reached.ForceX.value)
    		worksheet4.write(0, j+1, step.Reached.ForceX.value)
    		F1.append(step.Reached.ForceX.value)
    		
    		worksheet1.write(2, j+1, 'Step '+str(Mstage_points_curve1[j]+1))
    		worksheet2.write(2, j+1, 'Step '+str(Mstage_points_curve1[j]+1))
    		worksheet3.write(2, j+1, 'Step '+str(Mstage_points_curve1[j]+1))
    		worksheet4.write(2, j+1, 'Step '+str(Mstage_points_curve1[j]+1))
    				
    		for i in range(len(structuralForces1['Z'])):
    		
    			worksheet1.write(row+3, j+1, structuralForces1['N'][i])
    			worksheet2.write(row+3, j+1, structuralForces1['V'][i])
    			worksheet3.write(row+3, j+1, structuralForces1['M'][i])
    			worksheet4.write(row+3, j+1, Disp_Slices[i])
    			row +=1
    			
    		j = j+1
    		
    	workbook1.close()
    	
    	nSteps2 = len(Mstage_points_curve2)
    	workbook2 = xlsxwriter.Workbook('Structural Forces D_10.xlsx')
    	worksheet5 = workbook2.add_worksheet('N')
    	worksheet6 = workbook2.add_worksheet('V')
    	worksheet7 = workbook2.add_worksheet('M')
    	worksheet8 = workbook2.add_worksheet('Pile Displacement')
    	F2=[]
    	
    	j=0
    	for step in (D_10.Steps[t] for t in Mstage_points_curve2):
    		print('Processing step #',j+1,' out of ',nSteps2, 'steps, Phase D/10')
    		# Fetch interface stress results meant to be integrated to provide nodal forces in global axis later on
    		for group in g_o.Groups:
    			if group.Name.value == "BottomInterfaces":
    				bottomNodalSigTot  = g_o.getresults(group, step, intResults.InterfaceEffectiveNormalStress, 'node')
    				bottomTau1         = g_o.getresults(group, step, intResults.InterfaceShearStress, 'stresspoint')
    				bottomTau2         = g_o.getresults(group, step, intResults.InterfaceShearStress2, 'stresspoint')
    			if group.Name.value == "LateralInterfaces":
    				lateralNodalSigTot = g_o.getresults(group, step, intResults.InterfaceTotalNormalStress, 'node')
    				lateralTau1        = g_o.getresults(group, step, intResults.InterfaceShearStress, 'stresspoint')
    				lateralTau2        = g_o.getresults(group, step, intResults.InterfaceShearStress2, 'stresspoint')		
    				lateralNodDispX    = g_o.getresults(group, step, intResults.Ux, 'node')
    				lateralIncDispX    = g_o.getresults(group, step, intResults.IRelUx, 'node')         # relative displacement between the two nodes sharing coordinates (interface/structure) 
    				lateralDispX = [x - y for x, y in zip(lateralNodDispX, lateralIncDispX)]            # sum of the interface displacement + relative displaceme
    		
    		# Stored fetched results in dictionnaries to provide data structure
    		bottomTauSLocal       = getResultsPerElement(bottomElementID, bottomTau1, 6)
    		bottomTauTLocal       = getResultsPerElement(bottomElementID, bottomTau2, 6)
    		bottomNodalSigNLocal  = getResultsPerElement(bottomElementID, bottomNodalSigTot, 6)
    		lateralTauSLocal      = getResultsPerElement(lateralElementID, lateralTau1, 6)
    		lateralTauTLocal      = getResultsPerElement(lateralElementID, lateralTau2, 6)
    		lateralNodalSigNLocal = getResultsPerElement(lateralElementID, lateralNodalSigTot, 6)
    
    		# Interpolate total stress to Gauss points as Output only provides them at nodes
    		bottomSigNLocal  = interpolate(bottomNodalSigNLocal)
    		lateralSigNLocal = interpolate(lateralNodalSigNLocal)
    
    		# Calculating global nodal forces for interface elements
    		localAxis2 = [1, 0, 0]
    		bottomGlobalNodalForces  = calculateNodalForces(bottomSigNLocal, bottomTauSLocal, bottomTauTLocal, bottomJacobian, bottomNormal, localAxis2)
    		localAxis2 = [0, 0, 1]
    		lateralGlobalNodalForces = calculateNodalForces(lateralSigNLocal, lateralTauSLocal, lateralTauTLocal, lateralJacobian, lateralNormal, localAxis2)
    
    		# Calculating force distribution within the pile
    		# Strategy first consists in integrating stresses at bottom level (done in pileBottomForce) to obtain N, V and M at bottom
    		# and then start integrating forces slice by slice from bottom level (done in structuralForces) to get N, V, M distribution over the pile
    		# The contribution of the soil plug can be eventually deducted (which is what is being done here). This is debattable though
    		xRef, yRef = 0, 0
    		nPlug = calculateNPlug (bottomNodalSigTot, pileProp['D'], 'Half')
    		pileBottomForce = getBottomForcesInPile(bottomGlobalNodalForces, bottomElementConnectivity, bottomInterfaceNodeCoordinates, xRef, nPlug)    
    		structuralForces2 = getForcesInSlices(lateralGlobalNodalForces, lateralElementConnectivity, lateralSlices,slice_heights, lateralInterfaceNodeCoordinates, pileProp, xRef, pileBottomForce)
    		
    		#Calculating horizontal displacement at slices intersection   			
    		index_disp=[]
    		for x in soil_layers:

    			w=0
    			for p in range(len(lateralNodX)):
    				if (lateralNodX[p]==(pileProp['D']/2) and abs(lateralNodZ[p]-x)<0.001):
    					index_disp.append(w)
    					break
    				else:
    					w=w+1
    		Disp_Slices=[lateralDispX[m] for m in index_disp]
    		Disp_Slices.reverse()
              		
    		#Creating excels with Structural information
    		
    		row=0
    		col=0
    		
    		structuralForces2['Z'].reverse()
    		structuralForces2['N'].reverse()
    		structuralForces2['V'].reverse()
    		structuralForces2['M'].reverse()
    		
    		if j==0:
    			for i in range(len(structuralForces2['Z'])):
    				row = row+1
    				worksheet5.write(row+2, col, structuralForces2['Z'][i])
    				worksheet6.write(row+2, col, structuralForces2['Z'][i])
    				worksheet7.write(row+2, col, structuralForces2['Z'][i])
    				worksheet8.write(row+2, col, structuralForces2['Z'][i])
    			row = 0
    			
    			worksheet5.write(row, col, 'Fx Reached')
    			worksheet6.write(row, col, 'Fx Reached')
    			worksheet7.write(row, col, 'Fx Reached')
    			worksheet8.write(row, col, 'Fx Reached')
    			
    			worksheet5.write(row+2, col, 'Depth')
    			worksheet6.write(row+2, col, 'Depth')
    			worksheet7.write(row+2, col, 'Depth')
    			worksheet8.write(row+2, col, 'Depth')
    			
    		worksheet5.write(0, j+1, step.Reached.ForceX.value)
    		worksheet6.write(0, j+1, step.Reached.ForceX.value)
    		worksheet7.write(0, j+1, step.Reached.ForceX.value)
    		worksheet8.write(0, j+1, step.Reached.ForceX.value)
    		F2.append(step.Reached.ForceX.value)
            
    		worksheet5.write(2, j+1, 'Step '+str(Mstage_points_curve2[j]+1))
    		worksheet6.write(2, j+1, 'Step '+str(Mstage_points_curve2[j]+1))
    		worksheet7.write(2, j+1, 'Step '+str(Mstage_points_curve2[j]+1))
    		worksheet8.write(2, j+1, 'Step '+str(Mstage_points_curve2[j]+1))
    				
    		for i in range(len(structuralForces2['Z'])):
    		
    			worksheet5.write(row+3, j+1, structuralForces2['N'][i])
    			worksheet6.write(row+3, j+1, structuralForces2['V'][i])
    			worksheet7.write(row+3, j+1, structuralForces2['M'][i])
    			worksheet8.write(row+3, j+1, Disp_Slices[i])
    			row +=1
    			
    		j = j+1
    		
    	workbook2.close()
        
    #################################################################################################
	#                                       CLUSTER  EXTRACTION                                     #
	#################################################################################################
    
    if structuralForces==1:
    	nSteps1 = len(Mstage_points_curve1)
    	workbook1 = xlsxwriter.Workbook('Clusters_D200.xlsx')
    	worksheet1 = workbook1.add_worksheet('CSR')
    	worksheet2 = workbook1.add_worksheet('Dev_Stress')
    	worksheet3 = workbook1.add_worksheet('PWP')
        
    	worksheet1.set_column('A:D', 23)
    	worksheet2.set_column('A:D', 23)
    	worksheet3.set_column('A:D', 23)
    	worksheet1.set_column('E:BZ', 13)
    	worksheet2.set_column('E:BZ', 13)
    	worksheet3.set_column('E:BZ', 13)
        
    	bold = workbook1.add_format({'bold': True})
        
    	F1=[]
    	M1=[]
    		
    	j=0
        
    	cluser_tau={}
    	cluser_q={}
    	cluser_pwp={}
        
    	for i in all_clusters.keys():
            cluser_tau[i]=[]
            cluser_q[i]=[]
            cluser_pwp[i]=[]
        
    	for step in (D_200.Steps[t] for t in Mstage_points_curve1):
    		print('Processing step #',j+1,' out of ',nSteps1, 'steps, Phase D/200')
            # Fetch interface stress results meant to be integrated to provide nodal forces in global axis later on
    		
    		for group in g_o.Groups:
    			if group.Name.value == "BottomInterfaces":
    				bottomNodalSigTot  = g_o.getresults(group, step, intResults.InterfaceEffectiveNormalStress, 'node')
    				bottomTau1         = g_o.getresults(group, step, intResults.InterfaceShearStress, 'stresspoint')
    				bottomTau2         = g_o.getresults(group, step, intResults.InterfaceShearStress2, 'stresspoint')
    			if group.Name.value == "LateralInterfaces":
    				lateralNodalSigTot = g_o.getresults(group, step, intResults.InterfaceTotalNormalStress, 'node')
    				lateralTau1        = g_o.getresults(group, step, intResults.InterfaceShearStress, 'stresspoint')
    				lateralTau2        = g_o.getresults(group, step, intResults.InterfaceShearStress2, 'stresspoint')		
    				lateralNodDispX    = g_o.getresults(group, step, intResults.Ux, 'node')
    				lateralIncDispX    = g_o.getresults(group, step, intResults.IRelUx, 'node')         # relative displacement between the two nodes sharing coordinates (interface/structure) 
    				lateralDispX = [x - y for x, y in zip(lateralNodDispX, lateralIncDispX)]            # sum of the interface displacement + relative displaceme
    		
    		# Stored fetched results in dictionnaries to provide data structure
    		bottomTauSLocal       = getResultsPerElement(bottomElementID, bottomTau1, 6)
    		bottomTauTLocal       = getResultsPerElement(bottomElementID, bottomTau2, 6)
    		bottomNodalSigNLocal  = getResultsPerElement(bottomElementID, bottomNodalSigTot, 6)
    		lateralTauSLocal      = getResultsPerElement(lateralElementID, lateralTau1, 6)
    		lateralTauTLocal      = getResultsPerElement(lateralElementID, lateralTau2, 6)
    		lateralNodalSigNLocal = getResultsPerElement(lateralElementID, lateralNodalSigTot, 6)
    
    		# Interpolate total stress to Gauss points as Output only provides them at nodes
    		bottomSigNLocal  = interpolate(bottomNodalSigNLocal)
    		lateralSigNLocal = interpolate(lateralNodalSigNLocal)
    
    		# Calculating global nodal forces for interface elements
    		localAxis2 = [1, 0, 0]
    		bottomGlobalNodalForces  = calculateNodalForces(bottomSigNLocal, bottomTauSLocal, bottomTauTLocal, bottomJacobian, bottomNormal, localAxis2)
    		localAxis2 = [0, 0, 1]
    		lateralGlobalNodalForces = calculateNodalForces(lateralSigNLocal, lateralTauSLocal, lateralTauTLocal, lateralJacobian, lateralNormal, localAxis2)
    
    		# Calculating force distribution within the pile
    		# Strategy first consists in integrating stresses at bottom level (done in pileBottomForce) to obtain N, V and M at bottom
    		# and then start integrating forces slice by slice from bottom level (done in structuralForces) to get N, V, M distribution over the pile
    		# The contribution of the soil plug can be eventually deducted (which is what is being done here). This is debattable though
    		xRef, yRef = 0, 0
    		nPlug = calculateNPlug (bottomNodalSigTot, pileProp['D'], 'Half')
    		pileBottomForce = getBottomForcesInPile(bottomGlobalNodalForces, bottomElementConnectivity, bottomInterfaceNodeCoordinates, xRef, nPlug)    
    		structuralForces1 = getForcesInSlices(lateralGlobalNodalForces, lateralElementConnectivity, lateralSlices,slice_heights, lateralInterfaceNodeCoordinates, pileProp, xRef, pileBottomForce)
    	
    		M1.append(round(2*structuralForces1['M'][-1],3))
            
    		for i in all_clusters.keys():
                
    		    cluser_tau[i].append((sum(g_o.getresults(all_clusters[i][0], step, g_o.ResultTypes.Soil.MobilizedShearStrength, 'node')[:])/len(g_o.getresults(all_clusters[i][0], step, g_o.ResultTypes.Soil.MobilizedShearStrength, 'node')[:]))/cluster_normalization[i])
    		    cluser_q[i].append(sum(g_o.getresults(all_clusters[i][0], step, g_o.ResultTypes.Soil.DeviatoricStress, 'node')[:])/len(g_o.getresults(all_clusters[i][0], step, g_o.ResultTypes.Soil.DeviatoricStress, 'node')[:]))
    		    cluser_pwp[i].append(sum(g_o.getresults(all_clusters[i][0], step, g_o.ResultTypes.Soil.PExcess, 'node')[:])/len(g_o.getresults(all_clusters[i][0], step, g_o.ResultTypes.Soil.PExcess, 'node')[:]))
            
    		F1.append(round(2*step.Reached.ForceX.value,3))
    		j = j+1
    		
  		
    	worksheet1.write(0, 3, 'Fx Reached [kN]', bold)
    	worksheet2.write(0, 3, 'Fx Reached [kN]', bold)
    	worksheet3.write(0, 3, 'Fx Reached [kN]', bold)

    	worksheet1.write_row(0, 4, F1)
    	worksheet2.write_row(0, 4, F1)
    	worksheet3.write_row(0, 4, F1)
        
    	worksheet1.write(1, 3, 'Moment Mudline [kNm]', bold)
    	worksheet2.write(1, 3, 'Moment Mudline [kNm]', bold)
    	worksheet3.write(1, 3, 'Moment Mudline [kNm]', bold)
        
    	worksheet1.write_row(1, 4, M1)
    	worksheet2.write_row(1, 4, M1)
    	worksheet3.write_row(1, 4, M1)
        
    	worksheet1.write(2, 0, 'Cluster', bold)
    	worksheet1.write(2, 1, 'Mean_X', bold)
    	worksheet1.write(2, 2, 'Mean_Y', bold)
    	worksheet1.write(2, 3, 'Mean_Z', bold)
 
    	worksheet2.write(2, 0, 'Cluster', bold)
    	worksheet2.write(2, 1, 'Mean_X', bold)
    	worksheet2.write(2, 2, 'Mean_Y', bold)
    	worksheet2.write(2, 3, 'Mean_Z', bold)
        
    	worksheet3.write(2, 0, 'Cluster', bold)
    	worksheet3.write(2, 1, 'Mean_X', bold)
    	worksheet3.write(2, 2, 'Mean_Y', bold)
    	worksheet3.write(2, 3, 'Mean_Z', bold)
        
    	Steps=[]
        
    	for z in range(len(cluser_tau[i])):
            
    	    Steps.append("Step "+str(z+1))
            
    	worksheet1.write_row(2, 4, Steps, bold)
    	worksheet2.write_row(2, 4, Steps, bold)
    	worksheet3.write_row(2, 4, Steps, bold)
    	
    	row=3
        
    	for i in all_clusters.keys():
            
            worksheet1.write_row(row, 4, cluser_tau[i])
            worksheet2.write_row(row, 4, cluser_q[i])
            worksheet3.write_row(row, 4, cluser_pwp[i])
            
            worksheet1.write(row, 0, i)
            worksheet1.write(row, 1, round(clusters_x[i],2))
            worksheet1.write(row, 2, round(clusters_y[i],2))
            worksheet1.write(row, 3, round(clusters_z[i],2))

            worksheet2.write(row, 0, i)
            worksheet2.write(row, 1, round(clusters_x[i],2))
            worksheet2.write(row, 2, round(clusters_y[i],2))
            worksheet2.write(row, 3, round(clusters_z[i],2))
            
            worksheet3.write(row, 0, i)
            worksheet3.write(row, 1, round(clusters_x[i],2))
            worksheet3.write(row, 2, round(clusters_y[i],2))
            worksheet3.write(row, 3, round(clusters_z[i],2))
            
            row=row+1    
  		
    		
    	workbook1.close()
        
        #_____________________________   D10   __________________________________#

        
    	nSteps2 = len(Mstage_points_curve2)
    	workbook2 = xlsxwriter.Workbook('Clusters_D10.xlsx')
    	worksheet4 = workbook2.add_worksheet('CSR')
    	worksheet5 = workbook2.add_worksheet('Dev_Stress')
    	worksheet6 = workbook2.add_worksheet('PWP')
        
    	worksheet4.set_column('A:D', 23)
    	worksheet5.set_column('A:D', 23)
    	worksheet6.set_column('A:D', 23)
    	worksheet4.set_column('E:BZ', 13)
    	worksheet5.set_column('E:BZ', 13)
    	worksheet6.set_column('E:BZ', 13)
        
    	bold = workbook2.add_format({'bold': True})
        
    	F2=[]
    	M2=[]
    		
    	j=0
        
    	cluser_tau={}
    	cluser_q={}
    	cluser_pwp={}
        
    	for i in all_clusters.keys():
            cluser_tau[i]=[]
            cluser_q[i]=[]
            cluser_pwp[i]=[]
        
    	for step in (D_10.Steps[t] for t in Mstage_points_curve2):
    		print('Processing step #',j+1,' out of ',nSteps2, 'steps, Phase D/10')
            # Fetch interface stress results meant to be integrated to provide nodal forces in global axis later on
    		
    		for group in g_o.Groups:
    			if group.Name.value == "BottomInterfaces":
    				bottomNodalSigTot  = g_o.getresults(group, step, intResults.InterfaceEffectiveNormalStress, 'node')
    				bottomTau1         = g_o.getresults(group, step, intResults.InterfaceShearStress, 'stresspoint')
    				bottomTau2         = g_o.getresults(group, step, intResults.InterfaceShearStress2, 'stresspoint')
    			if group.Name.value == "LateralInterfaces":
    				lateralNodalSigTot = g_o.getresults(group, step, intResults.InterfaceTotalNormalStress, 'node')
    				lateralTau1        = g_o.getresults(group, step, intResults.InterfaceShearStress, 'stresspoint')
    				lateralTau2        = g_o.getresults(group, step, intResults.InterfaceShearStress2, 'stresspoint')		
    				lateralNodDispX    = g_o.getresults(group, step, intResults.Ux, 'node')
    				lateralIncDispX    = g_o.getresults(group, step, intResults.IRelUx, 'node')         # relative displacement between the two nodes sharing coordinates (interface/structure) 
    				lateralDispX = [x - y for x, y in zip(lateralNodDispX, lateralIncDispX)]            # sum of the interface displacement + relative displaceme
    		
    		# Stored fetched results in dictionnaries to provide data structure
    		bottomTauSLocal       = getResultsPerElement(bottomElementID, bottomTau1, 6)
    		bottomTauTLocal       = getResultsPerElement(bottomElementID, bottomTau2, 6)
    		bottomNodalSigNLocal  = getResultsPerElement(bottomElementID, bottomNodalSigTot, 6)
    		lateralTauSLocal      = getResultsPerElement(lateralElementID, lateralTau1, 6)
    		lateralTauTLocal      = getResultsPerElement(lateralElementID, lateralTau2, 6)
    		lateralNodalSigNLocal = getResultsPerElement(lateralElementID, lateralNodalSigTot, 6)
    
    		# Interpolate total stress to Gauss points as Output only provides them at nodes
    		bottomSigNLocal  = interpolate(bottomNodalSigNLocal)
    		lateralSigNLocal = interpolate(lateralNodalSigNLocal)
    
    		# Calculating global nodal forces for interface elements
    		localAxis2 = [1, 0, 0]
    		bottomGlobalNodalForces  = calculateNodalForces(bottomSigNLocal, bottomTauSLocal, bottomTauTLocal, bottomJacobian, bottomNormal, localAxis2)
    		localAxis2 = [0, 0, 1]
    		lateralGlobalNodalForces = calculateNodalForces(lateralSigNLocal, lateralTauSLocal, lateralTauTLocal, lateralJacobian, lateralNormal, localAxis2)
    
    		# Calculating force distribution within the pile
    		# Strategy first consists in integrating stresses at bottom level (done in pileBottomForce) to obtain N, V and M at bottom
    		# and then start integrating forces slice by slice from bottom level (done in structuralForces) to get N, V, M distribution over the pile
    		# The contribution of the soil plug can be eventually deducted (which is what is being done here). This is debattable though
    		xRef, yRef = 0, 0
    		nPlug = calculateNPlug (bottomNodalSigTot, pileProp['D'], 'Half')
    		pileBottomForce = getBottomForcesInPile(bottomGlobalNodalForces, bottomElementConnectivity, bottomInterfaceNodeCoordinates, xRef, nPlug)    
    		structuralForces2 = getForcesInSlices(lateralGlobalNodalForces, lateralElementConnectivity, lateralSlices,slice_heights, lateralInterfaceNodeCoordinates, pileProp, xRef, pileBottomForce)
    		
    		M2.append(round(2*structuralForces2['M'][-1],3))
            
    		for i in all_clusters.keys():
                
    		    cluser_tau[i].append((sum(g_o.getresults(all_clusters[i][0], step, g_o.ResultTypes.Soil.MobilizedShearStrength, 'node')[:])/len(g_o.getresults(all_clusters[i][0], step, g_o.ResultTypes.Soil.MobilizedShearStrength, 'node')[:]))/cluster_normalization[i])
    		    cluser_q[i].append(sum(g_o.getresults(all_clusters[i][0], step, g_o.ResultTypes.Soil.DeviatoricStress, 'node')[:])/len(g_o.getresults(all_clusters[i][0], step, g_o.ResultTypes.Soil.DeviatoricStress, 'node')[:]))
    		    cluser_pwp[i].append(sum(g_o.getresults(all_clusters[i][0], step, g_o.ResultTypes.Soil.PExcess, 'node')[:])/len(g_o.getresults(all_clusters[i][0], step, g_o.ResultTypes.Soil.PExcess, 'node')[:]))
            
    		F2.append(round(2*step.Reached.ForceX.value,3))
    		j = j+1
    		
  		
    	worksheet4.write(0, 3, 'Fx Reached', bold)
    	worksheet5.write(0, 3, 'Fx Reached', bold)
    	worksheet6.write(0, 3, 'Fx Reached', bold)

    	worksheet4.write_row(0, 4, F2)
    	worksheet5.write_row(0, 4, F2)
    	worksheet6.write_row(0, 4, F2)
        
    	worksheet4.write(1, 3, 'Moment Mudline [kNm]', bold)
    	worksheet5.write(1, 3, 'Moment Mudline [kNm]', bold)
    	worksheet6.write(1, 3, 'Moment Mudline [kNm]', bold)
        
    	worksheet4.write_row(1, 4, M2)
    	worksheet5.write_row(1, 4, M2)
    	worksheet6.write_row(1, 4, M2)
        
    	worksheet4.write(2, 0, 'Cluster', bold)
    	worksheet4.write(2, 1, 'Mean_X', bold)
    	worksheet4.write(2, 2, 'Mean_Y', bold)
    	worksheet4.write(2, 3, 'Mean_Z', bold)
 
    	worksheet5.write(2, 0, 'Cluster', bold)
    	worksheet5.write(2, 1, 'Mean_X', bold)
    	worksheet5.write(2, 2, 'Mean_Y', bold)
    	worksheet5.write(2, 3, 'Mean_Z', bold)
        
    	worksheet6.write(2, 0, 'Cluster', bold)
    	worksheet6.write(2, 1, 'Mean_X', bold)
    	worksheet6.write(2, 2, 'Mean_Y', bold)
    	worksheet6.write(2, 3, 'Mean_Z', bold)
        
    	Steps=[]
        
    	for z in range(len(cluser_tau[i])):
            
    	    Steps.append("Step "+str(z+1))
            
    	worksheet4.write_row(2, 4, Steps, bold)
    	worksheet5.write_row(2, 4, Steps, bold)
    	worksheet6.write_row(2, 4, Steps, bold)
    	
    	row=3
        
    	for i in all_clusters.keys():
            
            worksheet4.write_row(row, 4, cluser_tau[i])
            worksheet5.write_row(row, 4, cluser_q[i])
            worksheet6.write_row(row, 4, cluser_pwp[i])
            
            worksheet4.write(row, 0, i)
            worksheet4.write(row, 1, round(clusters_x[i],2))
            worksheet4.write(row, 2, round(clusters_y[i],2))
            worksheet4.write(row, 3, round(clusters_z[i],2))

            worksheet5.write(row, 0, i)
            worksheet5.write(row, 1, round(clusters_x[i],2))
            worksheet5.write(row, 2, round(clusters_y[i],2))
            worksheet5.write(row, 3, round(clusters_z[i],2))
            
            worksheet6.write(row, 0, i)
            worksheet6.write(row, 1, round(clusters_x[i],2))
            worksheet6.write(row, 2, round(clusters_y[i],2))
            worksheet6.write(row, 3, round(clusters_z[i],2))
            
            row=row+1    
  		
    		
    	workbook2.close()
     
    
    g_o.close()
# Importing modules 
import os, sys, math, getInput#,input_cospin
#sys.path.append('C:\Program Files\Plaxis\PLAXIS 3D\python\Lib\site-packages')
from plxscripting.easy import *
import pandas as pd
import csv, xlsxwriter
#s_i, g_i = new_server('localhost', 10000, password='!YNW<c6W>mg?Mt8v')
import numpy as np


file = 'Data_Base.xlsx'
xl = pd.ExcelFile(file)
excel_sheets=(xl.sheet_names)



Main_folder = os.getcwd()
item=0
for item in range(len(excel_sheets)):
    df=xl.parse(excel_sheets[item])
    
    if int(df['Run Project'][0])==1:
        #df2=xl2.parse(sheet_name=excel_sheets[item])
        results_directory ,vertical_clusters = generateMono(df)  
        resultPostProcessing(df,results_directory,vertical_clusters)
        os.chdir(Main_folder)