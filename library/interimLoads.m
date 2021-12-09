function [loads] = interimLoads (plots,id,soil,loads,settings)
    if strcmp(id,'A04')
        if strcmp(settings.interface,'FAC') 
            loads.M=-545782;
            loads.H=7526;
            loads.Vc=29079;
            loads.Mz=21864;
        else
            loads.M=-409328;
            loads.H=5575;
            loads.Vc=20771;
            loads.Mz=15617;
        end
    elseif strcmp(id,'G01')
        if strcmp(settings.interface,'FAC')
            loads.M=-532834;
            loads.H=7414;
            loads.Vc=28650;
            loads.Mz=21864;
        else
            loads.M=-399575;
            loads.H=5492;
            loads.Vc=20464;
            loads.Mz=15617;
        end        
    elseif strcmp(id,'G04')
        if strcmp(settings.interface,'FAC')
            loads.M = -522556;
            loads.H = 7324;
            loads.Vc=28309;
            loads.Mz=21864;
        else
            loads.M = -391833;
            loads.H = 5426;
            loads.Vc=20220;
            loads.Mz=15617;
        end        
    end
    
    

end