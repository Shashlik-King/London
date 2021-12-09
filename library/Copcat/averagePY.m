function [p_av,depth_av]=averagePY(element,p)
p_av=zeros(length(p.top),length(p.top(1,:)));                               % preallocation
    for i =2:element.nelem-1
        for j=1:length(p.top(1,:))
            if p.top(i,j)<p.bottom(i-1,j)||p.top(i,j)>p.bottom(i-1,j)
                p_av(i,j) = (p.top(i,j).*(abs(element.level(i,2))-... 
                    abs(element.level(i,1)))+p.bottom(i-1,j).*...
                    (abs(element.level(i,1))-abs(element.level(i-1,1))))...
                    ./((abs(element.level(i,2))-abs(element.level(i,1)))...
                    +(abs(element.level(i,1))-abs(element.level(i-1,1))));  % averaging of p values
            else
                p_av(i,j) = p.top(i,j); 
            end
        end
    end  
depth_av=abs((element.level(:,1)+element.level(:,2))/2);                    % average of top and bottom elevation of node
depth_av(end)=[];                                                           % ommit the last element of toe
end 