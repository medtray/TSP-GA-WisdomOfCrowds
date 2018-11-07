%visualize a road in the map

function visualize_road(points,road)

X=points(:,1);
Y=points(:,2);

for kk=1:size(road,2)-1
x=[X(road(1,kk),1),X(road(1,kk+1),1)];
y=[Y(road(1,kk),1),Y(road(1,kk+1),1)];
hold on
plot(x,y)
end
hold on;
for i=1:size(X,1)
txt3 = int2str(i);
text(X(i,1),Y(i,1),txt3,'HorizontalAlignment','right')
end

end

