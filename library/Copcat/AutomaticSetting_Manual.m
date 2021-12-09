function [loads, data]=AutomaticSetting_Manual(data,loads)

        identifier=extractBefore(data.location,3);
        if strcmp(identifier,'SG')
            data.Tubine='SGRE';
        elseif strcmp(identifier,'MV')
            data.Tubine='MVOW';
        elseif strcmp(identifier,'GE')    
            data.Tubine='GE'   ;         
        end 

        data.Depthid=extractBefore(extractAfter(data.location,'_'),2);      
        data.id=[data.Tubine,'_',data.Depthid];
        Type=extractBefore(extractAfter(data.location,'('),')');
        data.soil.type=Type;

          if contains(loads.type,'ULS')  
              loads.MF.Total                  =1.25; %Material Factor for Clay
              loads.MF.effective              =1.25; %Material Factor for sand
          else 
              loads.MF.Total                  =1.00; %Material Factor for Clay
              loads.MF.effective              =1.00; %Material Factor for sand
          end 

end 