
clear all
clc
close all


tic
%read data from file
[filename, pathname] = uigetfile({'*','All Files'}, 'Select a data file');
info.filename=filename;
info.pathname = pathname;
fid = fopen([info.pathname '\' info.filename]);
tline = fgetl(fid);
i=0;
j=0;
while ischar(tline)
    i=i+1;
    if (i>7)
        j=j+1;
        %disp(tline)
        a=tline;
        tmp= a(strfind(a,' ')+1:end);
        points(j,1)=str2double(tmp(1:strfind(tmp,' ')-1));
        points(j,2)=str2double(tmp(strfind(tmp,' ')+1:end));
    end
    tline = fgetl(fid);
end

cities=size(points,1);
ix = randperm(cities);
points = points(ix,:);
coords=points;
%Compute distances between each pair of cities
distances = zeros(cities);
for i=1:cities,
    for j=1:i,
        x1 = coords(i,1);
        y1 = coords(i,2);
        x2 = coords(j,1);
        y2 = coords(j,2);
        distances(i,j)=sqrt((x1-x2)^2+(y1-y2)^2);
        distances(j,i)=distances(i,j);
    end;
end;

stations=[1:cities];
Population_Size=80;
Iter_number=1200;
showResult  = true;
xy=coords;
[N,dimension] = size(xy);
[nr,nc] = size(distances);
n = N;
Population_Size = 4*ceil(Population_Size/4);
Iter_number= max(1,round(real(Iter_number(1))));


nb_of_ga=10;
final=zeros(nb_of_ga*Population_Size,n);
for xxxx=1:nb_of_ga
     
% Initialize the Population
population = zeros(Population_Size,n);
population(1,:) = (1:n);
for k = 2:Population_Size
    population(k,:) = randperm(n);
end
    
% initizalize the variables
Global_Min = Inf;
Total_Distance = zeros(1,Population_Size);
Distance_History = zeros(1,Iter_number);
Pop_Sample = zeros(4,n);
New_Pop = zeros(Population_Size,n);

figure('Name','TSP_GA | Current Best Solution','Numbertitle','off');
H = gca;
 % Evaluate Each Population Member (Compute its corresponding cost)
        for p = 1:Population_Size
            d = distances(population(p,n),population(p,1)); % Closed Path
            for k = 2:n
                d = d + distances(population(p,k-1),population(p,k));
            end
            Total_Distance(p) = d;
        end
        
        % Find the Best Route within the Population
        [minDist,index] = min(Total_Distance);
        Distance_History(1) = minDist;
        if minDist < Global_Min
            Global_Min = minDist;
            BestRoute = population(index,:);
           
                % Plot the Best Path of the first population
                rte = BestRoute([1:n 1]);
                if dimension > 2, plot3(H,xy(rte,1),xy(rte,2),xy(rte,3),'g*-');
                else plot(H,xy(rte,1),xy(rte,2),'g*-'); end
                title(H,sprintf('Total Cost = %1.4f, Iteration = %d',minDist,1));
                drawnow;
          
        end

for iter = 2:Iter_number
       
        
        %use single point crossover operation
       [population_after_crossover] = single_point_crossover(population,Population_Size,Total_Distance,n,distances);
       population=population_after_crossover;
    
    
        % Evaluate Each Population Member (Compute its corresponding cost)
        for p = 1:Population_Size
            d = distances(population(p,n),population(p,1)); % Closed Path
            for k = 2:n
                d = d + distances(population(p,k-1),population(p,k));
            end
            Total_Distance(p) = d;
        end
        
        %use single point crossover operation
       [population_after_crossover] = double_points_crossover(population,Population_Size,Total_Distance,n,distances);
       population=population_after_crossover;
       
        % Evaluate Each Population Member (Compute its corresponding cost)
        for p = 1:Population_Size
            d = distances(population(p,n),population(p,1)); 
            for k = 2:n
                d = d + distances(population(p,k-1),population(p,k));
            end
            Total_Distance(p) = d;
        end
        
        
       
        
        
        randomOrder = randperm(Population_Size);
        for p = 4:4:Population_Size
            rtes = population(randomOrder(p-3:p),:);
            dists = Total_Distance(randomOrder(p-3:p));
            [ignore,idx] = min(dists); 
            bestOf4Route = rtes(idx,:);
            Path_Insertion_Points = sort(ceil(n*rand(1,2)));
            I = Path_Insertion_Points(1);
            J = Path_Insertion_Points(2);
            for k = 1:4 
                Pop_Sample(k,:) = bestOf4Route;
                
                
                switch k
                    case 2
                        [Pop_Sample(k,:)] = mutation_slide(bestOf4Route,I,J);
                    case 3
                        [Pop_Sample(k,:)] = mutation_flip(bestOf4Route,I,J);
                    case 4
                        [Pop_Sample(k,:)] = mutation_swap(bestOf4Route,I,J);
                end
                        
                        
                    
            end
            New_Pop(p-3:p,:) = Pop_Sample;
        end
        population = New_Pop;
        
         
        for p = 1:Population_Size
            d = distances(population(p,n),population(p,1)); 
            for k = 2:n
                d = d + distances(population(p,k-1),population(p,k));
            end
            Total_Distance(p) = d;
        end
        
        % Find the Best Route within the Population
        [minDist,index] = min(Total_Distance);
        Distance_History(iter) = minDist;
        if minDist < Global_Min
            Global_Min = minDist;
            BestRoute = population(index,:);
           
                % Plot the Best Path
                
                rte = BestRoute([1:n 1]);
                if dimension > 2, plot3(H,xy(rte,1),xy(rte,2),xy(rte,3),'g*-');
                else plot(H,xy(rte,1),xy(rte,2),'g*-'); end
                title(H,sprintf('Total Cost = %1.4f, Iteration = %d',minDist,iter));
                drawnow;
          
        end
   
        
end
toc
final((xxxx-1)*Population_Size+1:xxxx*Population_Size,:)=population(:,:);
end

Total_Distance2=zeros(size(final,1),1);

for p = 1:size(final,1)
            d = distances(final(p,n),final(p,1)); 
            for k = 2:n
                d = d + distances(final(p,k-1),final(p,k));
            end
            Total_Distance2(p) = d;
        end

  [B,I]=sort(Total_Distance2,'ascend');
  population_woc = final(I(1:8,1),:);
%population_woc=final;
% [chromosome] = gready_search(distances,cities,points,'neighbour');
[cost_matrix] = aggregation_cost(population_woc,n,3,3,distances);
[path] = find_path_from_aggregation_matrix(cost_matrix)

% [path] = gready_search(cost_matrix,cities,points,'neighbour');

% for k=1:size(population_woc)
% [population_woc(k,:)] = exchange2(population_woc(k,:),cost_matrix);
% end

% clear population;
% population=population_woc;
%   
%         for p = 1:size(population,1)
%             d = distances(population(p,n),population(p,1)); 
%             for k = 2:n
%                 d = d + distances(population(p,k-1),population(p,k));
%             end
%             Total_Distance(p) = d;
%         end
%         
%         % Find the Best Route within the Population
%         [minDist,index] = min(Total_Distance);
%         Distance_History(iter) = minDist;
%         
%             Global_Min = minDist;
%             BestRoute = population(index,:);
%            
%                 % Plot the Best Path
BestRoute=path;
d = distances(BestRoute(1,n),BestRoute(1,1)); 
            for k = 2:n
                d = d + distances(BestRoute(1,k-1),BestRoute(1,k));
            end
          minDist=d;      
%                 rte = BestRoute([1:n 1]);
%                 if dimension > 2, plot3(H,xy(rte,1),xy(rte,2),xy(rte,3),'g*-');
%                 else plot(H,xy(rte,1),xy(rte,2),'g*-'); end
%                 title(H,sprintf('Total Cost = %1.4f, Iteration = %d',minDist,iter));
%                 drawnow;




 %% Show results
     % Plots the GA Results
        figure('Name','TSP_GA | Results','Numbertitle','off');
        subplot(2,2,1);
        if dimension > 2, plot3(xy(:,1),xy(:,2),xy(:,3),'*','Color','b');
        else plot(xy(:,1),xy(:,2),'*','Color','b'); end
        title('City Locations');
        subplot(2,2,2);
        imagesc(distances(BestRoute,BestRoute));
        title('Distance Matrix');
        subplot(2,2,3);
        rte = BestRoute([1:n 1]);
        if dimension > 2, plot3(xy(rte,1),xy(rte,2),xy(rte,3),'r.-');
        else plot(xy(rte,1),xy(rte,2),'g*-'); end
        title(sprintf('Total Cost = %1.4f',minDist));
        subplot(2,2,4);
        plot(Distance_History,'b','LineWidth',2);
        title('Best Solution Evolution');
        set(gca,'XLim',[0 Iter_number+1],'YLim',[0 1.1*max([1 Distance_History])]);
        
        %final(1,xxxx)=minDist;
        
%end