function [output]=read_Reaction_Plaxis_mt(file_name_plaxis,index_rotation,spring_type,output,Ommit_Bad_Curves,scour_Depth,model_name)

file_name                                = file_name_plaxis.main;
sheet                                    = file_name_plaxis.sheet;

pYCurves                                 = xlsread(file_name,sheet,'B11:AL132');
Depths_Slice                             = pYCurves(:,1:2);
Depths_Slice(isnan(Depths_Slice(:,1)),:) = [];

depth                                    = ((Depths_Slice(1:end-1,1)+Depths_Slice(1:end-1,2))/2)+scour_Depth;
Springs                                  = pYCurves(1:end-2,4:end);

Y_curve                                  = abs(Springs(2:2:end,:));
X_curve                                  = abs(Springs(1:2:end,:));

Refined_Y_curve                          = Y_curve;
Refined_X_curve                          = X_curve;
Refined_depth                            = depth;
Calib_param_Org                          = [0,0,0,0,0]; 
if Ommit_Bad_Curves

    index_rotation = output.rotation;
    BadCurvesIDx   = find(index_rotation(:,1));
    type_of_curve  = 'moment';

    if isnan(BadCurvesIDx)
        disp('no ommition of curve')
    else 
        mmmm = 1;
        for iii = 1:size(BadCurvesIDx,1)
            indx_correction = BadCurvesIDx(iii);
                try 
                    [Refined_X_curve(indx_correction,:), Refined_Y_curve(indx_correction,:), coeef] = Replace_curves(X_curve(indx_correction,:),Y_curve(indx_correction,:),mmmm,Refined_depth(indx_correction),type_of_curve,model_name);
                    mmmm = mmmm+1; % counter
                    Calib_param_Org(iii,:) = [Refined_depth(i),coeef]; % where does this i come from?
                catch            
                    warning(['no fitting at depth', num2str( Refined_depth(indx_correction))]);
                    Refined_X_curve(indx_correction,:) = X_curve(indx_correction,:);
                    Refined_Y_curve(indx_correction,:) = Y_curve(indx_correction,:);           
                end 
        end 
    end 

    Refined_Y_curve(Refined_Y_curve(:,1)==-100,:) = [];
    Refined_X_curve(Refined_X_curve(:,1)==-100,:) = [];
    Refined_depth(Refined_depth(:,1)==-100,:)     = [];

end 

output.X_curve         = Refined_X_curve;
output.Y_curve         = Refined_Y_curve;
output.depth           = Refined_depth;
output.rotation        = index_rotation;
output.Calib_param_Org = Calib_param_Org;
end
