function [kstop,ksbot]=DirectLookUP_Sec(x_ave,ytop,ybot,PLAXIS)
                                
                                    
[minValue,closestIndex] = min(abs(x_ave-PLAXIS.depth'));
                                                                       
 X_curve=PLAXIS.X_curve;
 Y_curve=PLAXIS.Y_curve;
 
 %obserX=unique(X_curve(closestIndex,:),'stable');
 %obserY=unique(Y_curve(closestIndex,:),'stable');

 obserX=[0,X_curve(closestIndex,:)];
 obserY=[0,Y_curve(closestIndex,:)];
                                    
  
 % get the P corresponding to the Y value 
 if ytop<=obserX(end)
 
 P_top=interp1(obserX,obserY,ytop);
 else 
 P_top= obserY(end);  
 
 end 
   
 if ybot<=obserX(end) 
 P_bot=interp1(obserX,obserY,ybot);
 else 
 P_bot= obserY(end);   
 end 
 
 
 K_ini=obserY(1,2)/obserX(1,2);
 
 if ytop == 0
    kstop = K_ini; 
elseif x_ave == 0
    kstop = 0;
else
	kstop = P_top./ytop;
 end
 
if ybot == 0
    ksbot = K_ini;
else
	ksbot = P_bot./ybot;

end 
end 
