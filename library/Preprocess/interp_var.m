function [var_q]=interp_var(depth,var,depth_q)

% depth_q=4.3;
% var=[Gmax,Gmax,Gmax];

var_q=zeros(length(depth_q),size(var,2));

for ii=1:length(depth_q)
    
    x = depth_q(ii);
    
    idx0=find(depth==x);
    
    if ~isempty(idx0)
        
        v=mean(var(idx0,:),1);
        disp('Interplated point lies at an interface. An average was used!')
        
    else
        
        idx1=find(depth>x,1);
        
        if isempty(idx1)
           warning('Queried depth does not exist in the profile. The last point was used!');
           idx1=length(depth);
        end
        
        x1=depth(idx1);
        x2=depth(idx1-1);
        
        v1=var(idx1,:);
        v2=var(idx1-1,:);
        
        v = (v1-v2)/(x1-x2)*(x-x1)+v1;
        
            
    end
    
    var_q(ii,:)=v;
    
end



