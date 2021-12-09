function [E50,Eini,Eult]=IsFullymobilized(obserX,obserY)

Eult = (obserY(end)- obserY(end-1))/(obserX(end)-obserX(end-1));
Eini = (obserY(2)- obserY(1))/(obserX(2)-obserX(1));
Y50  = obserY(end)/2;
X50  = interp1(obserY,obserX,Y50);
E50  = Y50/X50;

end 