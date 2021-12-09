function [loads] = load_cases(data,settings,loads)

if contains(data.location,'PISA')
    [num,txt] = xlsread('LOADS.xlsx',char(data.location(1:6)));
else
    [num,txt] = xlsread('LOADS.xlsx',char(data.location(1:6)));
end

row_index = find(contains(txt(:,2),data.load_case))-3;

if strcmp(settings.interface,'FAC')
    loads.H  = num(row_index,2);
    loads.M  = -num(row_index,3);
    loads.Vc = num(row_index,5);
    loads.Vt = 0;
    loads.Mz = num(row_index,4); 
else
    loads.H  = num(row_index,6);
    loads.M  = -num(row_index,7);
    loads.Vc = num(row_index,9);
    loads.Vt = 0;
    loads.Mz = num(row_index,8);
end

if loads.n_cycles== 10000
    loads.A  = 'TUHH';         
    loads.H  = loads.H*0.3;
    loads.M  = loads.M*0.3;   
end 
end

