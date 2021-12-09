classdef General_out
   properties  
       LC
       Permanent_rot
       CriticalPile
       Deflection
       UR_DNV
   end 
      methods
      function obj = General_out(N,~)
         if nargin ~= 0
            obj(N) = General_out;
         end
      end 
   end
end