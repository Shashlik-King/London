function [kttop,ktbot]=DirectLookUP_tan(x_ave,ytop,ybot,PLAXIS)
                                
                                    
[minValue,closestIndex] = min(abs(x_ave-PLAXIS.depth'));
                                                                       
 X_curve=PLAXIS.X_curve;
 Y_curve=PLAXIS.Y_curve;
 
 %obserX=unique(X_curve(closestIndex,:),'stable');
 %obserY=unique(Y_curve(closestIndex,:),'stable');

 obserX=[0,X_curve(closestIndex,:)];
 obserY=[0,Y_curve(closestIndex,:)];
                                    
 % get the P corresponding to the Y value 
 
if  ytop<=obserX(end)-0.00001

 P_top_1=interp1(obserX,obserY,ytop);
 P_top_2=interp1(obserX,obserY,ytop+0.00001);
 
 Delta_top=0.00001;
else 
  P_top_2=obserY(end);
  P_top_1=obserY(end-1); 
  Delta_top=obserX(end)-obserX(end-1);
end 


 if  ybot<=obserX(end)-0.00001

 P_bot_1=interp1(obserX,obserY,ybot);
 P_bot_2=interp1(obserX,obserY,ybot+0.00001);
 
 Delta_bot=0.00001;
else 
  P_bot_2=obserY(end);
  P_bot_1=obserY(end-1); 
  Delta_bot=obserX(end)-obserX(end-1);
end  
 

% % % % % % % % % % % % % %  
% % % % % % % % % % % % % %  [minValue,Index] = min(abs(ytop-obserX));
% % % % % % % % % % % % % %  
% % % % % % % % % % % % % %  if Index<=size(obserX,2)-3 &&Index>=3
% % % % % % % % % % % % % %      
% % % % % % % % % % % % % %     fitting_vector_X= obserX(Index-2:Index+2);
% % % % % % % % % % % % % %     fitting_vector_Y= obserY(Index-2:Index+2);     
% % % % % % % % % % % % % %      
% % % % % % % % % % % % % %  elseif Index<3
% % % % % % % % % % % % % %     fitting_vector_X= obserX(1:5);
% % % % % % % % % % % % % %     fitting_vector_Y= obserY(1:5); 
% % % % % % % % % % % % % %      
% % % % % % % % % % % % % %  elseif  Index>size(obserX,2)-3  
% % % % % % % % % % % % % %  
% % % % % % % % % % % % % %     fitting_vector_X= obserX(end-5:end);
% % % % % % % % % % % % % %     fitting_vector_Y= obserY(end-5:end); 
% % % % % % % % % % % % % %     
% % % % % % % % % % % % % %  end 
% % % % % % % % % % % % % %  
% % % % % % % % % % % % % %  p = polyfit(fitting_vector_X,fitting_vector_Y,4);
% % % % % % % % % % % % % %  
% % % % % % % % % % % % % % 
% % % % % % % % % % % % % %  
% % % % % % % % % % % % % %  P_top_1 = polyval(p,ytop);
% % % % % % % % % % % % % %     
% % % % % % % % % % % % % %  %P_top_1=interp1(ytop,obserX,obserY);
% % % % % % % % % % % % % %  
% % % % % % % % % % % % % %  P_top_2 = polyval(p,ytop+0.00001);
% % % % % % % % % % % % % %  
% % % % % % % % % % % % % %  %P_bot_1=interp1(ybot,obserX,obserY);
% % % % % % % % % % % % % %  
% % % % % % % % % % % % % %  ptop=P_top_2-P_top_1;
% % % % % % % % % % % % % %  
% % % % % % % % % % % % % %  P_bot_1 = polyval(p,ybot);
% % % % % % % % % % % % % %     
% % % % % % % % % % % % % %  %P_top_1=interp1(ytop,obserX,obserY);
% % % % % % % % % % % % % %  
% % % % % % % % % % % % % %  P_bot_2 = polyval(p,ybot+0.00001);
 
 %P_bot_1=interp1(ybot,obserX,obserY);
 
 ptop=P_top_2-P_top_1;
 pbot=P_bot_2-P_bot_1;
 

 K_ini=obserY(1,2)/obserX(1,2);
 

if x_ave == 0;
    % This statement is included because Kttop = dp/dy cannot be evaluated 
    % at xtop = 0 since putop_n in this case turns zero. However, the stiff-
    % ness at the soil surface is zero/low
    kttop = 0; 
else
	kttop = ptop/Delta_top;
end

	ktbot = pbot/Delta_bot;
end 
