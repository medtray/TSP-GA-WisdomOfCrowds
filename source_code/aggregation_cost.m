function [cost_matrix] = aggregation_cost(population,n,b1,b2,distance_matrix)

cost_matrix=zeros(n,n);

for i=1:size(population,1)
    for j=1:size(population,2)-1
        cost_matrix(population(i,j),population(i,j+1))=cost_matrix(population(i,j),population(i,j+1))+1;
    end
end

for i=1:n
    for j=1:i
        k=cost_matrix(i,j)+cost_matrix(j,i);
        cost_matrix(i,j)=k;
        cost_matrix(j,i)=k;
    end
end

% max_cost_element=max(max(cost_matrix));
% 
% for i=1:n
%     for j=1:n
%         cost_matrix(i,j)=distance_matrix(i,j)*(1-betainv(cost_matrix(i,j)/max_cost_element,b1,b2));
%     end
% end

end
