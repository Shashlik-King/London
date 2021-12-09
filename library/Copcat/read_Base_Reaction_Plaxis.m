function [output]=read_Base_Reaction_Plaxis(file_name_plaxis,index_rotation,scour_Depth)
file_name                                = file_name_plaxis.main;
sheet                                    = file_name_plaxis.sheet;

pYCurves                                 = xlsread(file_name,sheet,'B11:AL132');
Depths_Slice                             = pYCurves(:,1:2);
Depths_Slice(isnan(Depths_Slice(:,1)),:) = [];

depth                                    = ((Depths_Slice(end,1)+Depths_Slice(end,2))/2)+scour_Depth;
Springs                                  = pYCurves(end-1:end,4:end);

X_curve                                  = abs(Springs(end-1,:));
Y_curve                                  = abs(Springs(end,:));

output.X_curve                           = X_curve;
output.Y_curve                           = Y_curve;
output.depth                             = depth(1,1);
output.rotation                          = index_rotation;

end