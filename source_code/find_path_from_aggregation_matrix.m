function [path] = find_path_from_aggregation_matrix(matrix)
[M,I] = max(matrix(:));
[I_row, I_col] = ind2sub(size(matrix),I);
path=[];
path=[path I_row I_col];
matrix(I_row,I_col)=-1;
matrix(I_col,I_row)=-1;

while (size(path,2)< size(matrix,1))
    
    u=matrix(path(1,1),:);
    v=matrix(path(1,size(path,2)),:);
    matrix(path(1,1),path(1,size(path,2)))=-1;
    matrix(path(1,size(path,2)),path(1,1))=-1;
    
    [M1,I1] = max(u);
    [M2,I2] = max(v);
    
    if (M1>M2)
        
        matrix(path(1,1),:)=-1;
        matrix(:,path(1,1))=-1;
        path=[I1 path];
    else
        matrix(path(1,size(path,2)),:)=-1;
        matrix(:,path(1,size(path,2)))=-1;
        path=[path I2];
        
    end
    
end

end

