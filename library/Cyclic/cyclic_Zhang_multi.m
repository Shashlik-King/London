function [element] = cyclic_Zhang_multi(element,multiplier)
% Applies reduction to the total y and p values in PISA param
element.PISA_param(:,1)  = element.PISA_param(:,1)  .* multiplier(1:size(element.PISA_param(:,1),1),2);
element.PISA_param(:,2)  = element.PISA_param(:,2)  .* multiplier(1:size(element.PISA_param(:,1),1),1);
element.PISA_param(:,3)  = element.PISA_param(:,3)  .* multiplier(1:size(element.PISA_param(:,1),1),1);
element.PISA_param(:,8)  = element.PISA_param(:,8)  .* multiplier(1:size(element.PISA_param(:,1),1),2);
element.PISA_param(:,9)  = element.PISA_param(:,9)  .* multiplier(1:size(element.PISA_param(:,1),1),1);
element.PISA_param(:,10) = element.PISA_param(:,10) .* multiplier(1:size(element.PISA_param(:,1),1),1);
end