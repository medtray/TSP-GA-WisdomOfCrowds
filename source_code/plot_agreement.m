function [x,y]=plot_agreement(matrix,cost,max_agreement)
x=[];
y=[];
for i=1:size(matrix,1)
    
    
     path=matrix(i,:);
     matrix1 = matrix;
     matrix1(i, :) = [];
    [cost_matrix1] = aggregation_cost(matrix1,size(matrix1,2),3,3,matrix1);
    
    agreement=0;
    for k=1:size(path,2)-1
        agreement=agreement+ cost_matrix1(path(1,k),path(1,k+1));
    end
    
    total_agreement=agreement/((size(path,2)-1)*max_agreement);
    x=[x total_agreement];
    y=[y cost(i,1)];
    clear matrix1
    
end

end