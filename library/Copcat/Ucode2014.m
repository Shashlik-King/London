function [variable]= Ucode2014(Inversemode,loadcase,object_layers,PYcreator,CallModels,Weight,PLAX,calibration,scour,soil,pile,loads,settings,PYcreator_stiff,var_name,focus,constant,con_name,spring_type,Stratigraphy,Database,start,LB,UB,Layered_wise_calibration,Apply_Direct_springs,Input)
if Inversemode
    parpool('local');
    option.DeriativeCheck='on';
    option.DiffMinChange=0.001;
    option.DiffMaxChange=0.01;
    option.Display='iter-detailed';
    %option.PlotFcns=@optimplotstepsize;
    option.PlotFcns=@optimplotresnorm;
    option.UseParallel=1;
    
    if Layered_wise_calibration==1 && PYcreator==1
      fid=fopen('ParametersHistory.txt','w+');
        for layer=1:size(start,1) 
            start_single=start(layer,:);
            LB_single=LB(layer,:);
            UB_single=UB(layer,:);
            object_layers_single=object_layers(layer);
            disp(['Calibration of layer',num2str(object_layers_single)])
           [Variable_single,RESNORM,RESIDUAL,EXITFLAG,output] = lsqnonlin(@(Variable_single)BatchRun(Variable_single,loadcase,object_layers_single,PYcreator,CallModels,Weight,PLAX,calibration,scour,soil,pile,loads,settings,0,PYcreator_stiff,var_name,focus,constant,con_name,spring_type,Stratigraphy,Database,Apply_Direct_springs,0,Input),start_single,LB_single,UB_single,option);      
           variable(layer,:)=Variable_single;
           fprintf(fid,'%g\t',variable(layer,:));
           fprintf(fid,'\n'); 
        end
        delete(gcp);
      fclose(fid);
    else 
    %%%%Optimisation algorithm%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [variable,RESNORM,RESIDUAL,EXITFLAG,output] = lsqnonlin(@(variable)BatchRun(variable,loadcase,object_layers,PYcreator,CallModels,Weight,PLAX,calibration,scour,soil,pile,loads,settings,0,PYcreator_stiff,var_name,focus,constant,con_name,spring_type,Stratigraphy,Database,Apply_Direct_springs,0,Input),start,LB,UB,option);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    delete(gcp)
    end 
else
    variable=start;
end

end 