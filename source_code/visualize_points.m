%visualize points in the map

function visualize_points(points)

X=points(:,1);
Y=points(:,2);
hold off
plot(X,Y,'*')
for i=1:size(X,1)
txt3 = int2str(i);
text(X(i,1),Y(i,1),txt3,'HorizontalAlignment','right')
end


end