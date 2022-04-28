function DB_write_PISA_param(DB_output,Input,spring_type,soil,pile,element,Geo)
% Read and write excel database

%% MySQL dDatabase settings
    [settings] = DB_master;
    settings.db_table='Pisa_Param';
%     [settings] = DB_dev;
%     [settings] = DB_feature;    
%% Opening MySQL Database

mysqlstr_ini        = ['INSERT INTO ',settings.db_table,' (Unit_name,Cons_name,Project_name,Location_name,Rev,Layer_number,Depth,Pile_length,Pile_Diameter,'...
    'Yu,Pu,Kp,np,Teta,Mu,Km,nm,Yb,Hb,Kb,nb,'...
    'TetaMb,Mb,kMb,nMb,ASR,Dr,phi,Su,G0,SigmaV,'...
    'CSR,Neq,CF_OCR,CF_Dr,Contour_diagram_name) VALUES ('];
    
%% New data assignment
    
    mysql('open',settings.db_server,settings.db_user,settings.db_pass); % ('open','server','username','password')
    mysql(['use ',settings.db_name]); % name of database
    
    New.revision = Input.revision{1,2};
    disp('Writing parameters into Database starting. Please wait.')
    
    %get PISA_param at the right depth
    element_clean= element.PISA_param;
    toDelete=[3 5 7 10 12 14];
    element_clean(:, toDelete)=[];
    index=[];
    n=1;
%     for k = 1:length(soil.(char(Input.ModelsSpil(1))).toplevel)
%         [q(k), idx(k)] = ismember(soil.(char(Input.ModelsSpil(1))).toplevel(k), element.level(:,1), 'rows');
%         index=[index, idx(k)];
%     end
    for k = 1:length(soil.(char(Input.ModelsSpil(Geo))).toplevel)
        if k~=length(soil.(char(Input.ModelsSpil(Geo))).toplevel)
            while element.level(n) > soil.(char(Input.ModelsSpil(Geo))).toplevel(k+1)
                index=[index, k];
                n=n+1;
            end
            k=k+1;
        else
            while element.level(n,1) > min(element.level(:,1))
                index=[index, k];
                n=n+1;
            end
            index=[index, k];
            k=k+1;
        end
    end
    
    for i = 1:size(Input.Layered_Data,1)
        New.name{i} = Input.Layered_Data{i,5}; % specifies the soil layer name
        New.project{i} = Input.Project_name{1,2}; % specifies the project name
        if Input.PYCreator{1,2}==1 && spring_type == 0
            New.notes{i} = 'Reaction curves - p-y'; % specifies calibration type used
        elseif Input.PYCreator{1,2}==1 && spring_type == 1
            New.notes{i} = 'Reaction curves - m-t'; % specifies calibration type used
        elseif Input.PYCreator{1,2}==1 && spring_type == 2
            New.notes{i} = 'Reaction curves - H-b'; % specifies calibration type used
        elseif Input.PYCreator{1,2}==1 && spring_type == 3
            New.notes{i} = 'Reaction curves - M-b'; % specifies calibration type used
        elseif Input.PYCreator{1,2}==0
            New.notes{i} = 'Pile_response'; % specifies calibration type used
        end
    end
    for j = 1:length(index)
        %split naming to get constitutive model / unit / layer
        %GHS_SS1_1
        x0=Input.SoilInfo(index(j),4);
        for r=1:length(x0)
           temp=strsplit(x0{r},'_');
           a(r)=temp(1);
           b(r)=temp(2);
           c(r)=temp(3);
        end
        New.soil_type{j} = Input.SoilType{index(j),1};
        database_str = [mysqlstr_ini,'''',b{1},''',''',a{1},''',''',New.project{index(j)},''',''',Input.Location_name{1,2},''',',num2str(New.revision),',',c{1},',',num2str(element.level(j,1)),',',num2str(pile.(char(Input.ModelsSpil(Geo))).length_start(1)),',',num2str(pile.(char(Input.ModelsSpil(Geo))).diameter(1)),''];
        %strcat(New.project{index(j)},'_',num2str(j))
        for ii = 1:16
            database_str = [database_str,',',num2str(element_clean(j,ii))];
        end
        database_str = [database_str,',',num2str(soil.(char(Input.ModelsSpil(Geo))).ASR(index(j))),',',num2str(soil.(char(Input.ModelsSpil(Geo))).Dr(index(j))),',',num2str(soil.(char(Input.ModelsSpil(Geo))).phi(index(j))),',',num2str(soil.(char(Input.ModelsSpil(Geo))).cu(index(j))),',',num2str(soil.(char(Input.ModelsSpil(Geo))).G0(index(j))),',',num2str(soil.(char(Input.ModelsSpil(Geo))).SigmaV(index(j))),',',num2str(soil.(char(Input.ModelsSpil(Geo))).CSR(index(j))),',',num2str(soil.(char(Input.ModelsSpil(Geo))).Neq(index(j))),',',num2str(soil.(char(Input.ModelsSpil(Geo))).CF_OCR(index(j))),',',num2str(soil.(char(Input.ModelsSpil(Geo))).CF_Dr(index(j))),',''',soil.(char(Input.ModelsSpil(Geo))).batch{index(j)},'''',');'];
        if contains(database_str,'NaN')
            database_str=strrep(database_str,'NaN','0');
        end
        mysql(database_str)
    end
    disp('Writing into Database finished.')
    mysql('close')
    disp('Finished exporting py-curves')
 
disp('---------------------------------------------------------------------')

%% Constitutive model Database
% Possibility to add FE model input to the DB


end
