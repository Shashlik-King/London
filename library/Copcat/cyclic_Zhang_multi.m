function [element] = cyclic_Zhang_multi(element,multiplier)
% Applies reduction to the total y and p values in PISA param
element.PISA_param(:,1) = element.PISA_param(:,1) .* multiplier.y(1:size(element.PISA_param(:,1),1));
element.PISA_param(:,2) = element.PISA_param(:,2) .* multiplier.p(1:size(element.PISA_param(:,1),1));
element.PISA_param(:,3) = element.PISA_param(:,3) .* multiplier.p(1:size(element.PISA_param(:,1),1));
element.PISA_param(:,8) = element.PISA_param(:,8) .* multiplier.y(1:size(element.PISA_param(:,1),1));
element.PISA_param(:,9) = element.PISA_param(:,9) .* multiplier.p(1:size(element.PISA_param(:,1),1));
element.PISA_param(:,10) = element.PISA_param(:,10) .* multiplier.p(1:size(element.PISA_param(:,1),1));
end