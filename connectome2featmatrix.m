function [ft, posft, names] = connectome2featmatrix(fcpath)


ft = [];
for s = 1:length(fcpath)
    roisub = load(fcpath{s});
    if isfield(roisub, 'Z') % testing if the path is raw conn output
        names = roisub.names;
        if diff(size(roisub.Z))
            conn_z = roisub.Z(:,1:end-1);
        else
            conn_z = roisub.Z;
        end
        ft = [ft; conn_z(triu(true(size(conn_z)),1))'];
    
    elseif isfield(roisub, 'zconnec') % testing if the path is connectome output
        names = roisub.roi_names;
        conn_z = roisub.zconnec;
        ft = [ft; conn_z(triu(true(size(conn_z)),1))'];   
        
    else % otherwise the path must point to a square matrix
        roisub_fields = fieldnames(roisub);
        conn_z = roisub.(roisub_fields{1});
        ft = [ft; conn_z(triu(true(size(conn_z)),1))'];
        
        names = cell(size(conn_z,1));
        for n = 1:length(names)
            names{n} = [roi,num2str(n)];
        end
    end
    
end

% posft variable maps the ft vectors back to the original space featxfeat
posft = nan(size(conn_z));
count = 0;
for j = 1:size(conn_z,2)
    for i = 1:size(conn_z,1)
        if i<j
            count = count+1;
            posft(i,j) = count;
        end
    end
end