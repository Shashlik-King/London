function [multiplier_p , multiplier_y] = springs_modifier(batch,N_eq)
% Interpolate
multiplier_new_p = interp1(batch.p(2,:)', batch.p(1,:)' , N_eq);
multiplier_new_y = interp1(batch.y(2,:) , batch.y(1,:) , N_eq);
% Multiply
% multiplier_p = multiplier_p * multiplier_new_p;
% multiplier_y = multiplier_y * multiplier_new_y;
multiplier_p = multiplier_new_p / max(batch.p(1,:));
multiplier_y = multiplier_new_y / max(batch.y(1,:));
end