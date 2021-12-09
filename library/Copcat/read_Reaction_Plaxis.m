function [output] = read_Reaction_Plaxis(file_name_plaxis,index_rotation,spring_type,Ommit_Bad_Curves,scour_Depth,model_name)

file_name                                = file_name_plaxis.main;
sheet                                    = file_name_plaxis.sheet;

pYCurves                                 = xlsread(file_name,sheet,'B11:AL132');
Depths_Slice                             = pYCurves(:,1:2);
Depths_Slice(isnan(Depths_Slice(:,1)),:) = [];

depth                                    = ((Depths_Slice(1:end-1,1)+Depths_Slice(1:end-1,2))/2)+scour_Depth;
Springs                                  = pYCurves(1:end-2,4:end); % take out the base spring

Y_curve                                  = abs(Springs(2:2:end,:));
X_curve                                  = abs(Springs(1:2:end,:));
X_curve_org                              = Springs(1:2:end,:);

Refined_Y_curve                          = Y_curve;
Refined_X_curve                          = X_curve;
Refined_depth                            = depth;
type_of_curve                            = 'Shear';

%% omit the curves around the rotation point
mmmm = 1;
if Ommit_Bad_Curves
    for i = 1:size(Y_curve,1) 
        X_test              = X_curve_org(i,:);
        X_test(X_test==0)   = 1;
        simbolX             = X_test./abs(X_test);
        NSymbolinX          = unique(simbolX(1,:));
        if  size(NSymbolinX,2) > 1
            index_rotation(i,1)  = i;
            index_rotation(i,2)  = Refined_depth(i);
            Refined_depth(i);
            [Refined_X_curve(i,:), Refined_Y_curve(i,:), coeef] = Replace_curves(X_curve(i,:),Y_curve(i,:),mmmm,Refined_depth(i),type_of_curve,model_name);
            mmmm                 = mmmm+1;
            Calib_param_Org(i,:) = [Refined_depth(i),coeef];       
        else
            index_rotation(i,1)  = 0;
            index_rotation(i,2)  = 0;
        end
    end
else
    Calib_param_Org = [0,0,0,0,0];
end

output.X_curve         = Refined_X_curve;
output.Y_curve         = Refined_Y_curve;
output.depth           = Refined_depth;
output.rotation        = index_rotation;
output.Calib_param_Org = Calib_param_Org;

end
