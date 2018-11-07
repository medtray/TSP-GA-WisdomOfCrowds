function [cost] = path_cost(path,distance_matrix)

cost=0;
for k=1:size(path,2)-1
    
    cost=cost+ distance_matrix(path(1,k),path(1,k+1));
end

