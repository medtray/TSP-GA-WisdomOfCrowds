function GUI_AI
clear all; close all;
global info;
global points;

%  Create and then hide the UI as it is being constructed.
f = figure('Visible','off','Position',[360,500,1300,900]);
set(f,'name', 'Artificial Intelligence','numbertitle','off','units','normalized');

% Construct the components.
htext  = uipanel('Parent',f); 
hinit  = uipanel('Parent',htext,'Title','Input map','Position',[0.01,0.5,0.8,0.8],'Units', 'normalized');
ha = axes('Parent',hinit,'Units','pixels','Position',[50,15,500,300]);

hI  = uipanel('Parent',htext,'Title','Final result','Position',[0.5,0.5,0.48,0.5]);
   
hload2    = uicontrol(htext,'Style','pushbutton','String','Choose a map',...
    'Units','normalized','Position',[0.17 .45 .15 .04],'Callback',@btnOpen_Callback2); 

hwork = uicontrol(htext,'Style','pushbutton','String','Find a path',...
    'Units','normalized','Position',[0.64 .45 .15 .04],'Callback',@work_Callback);

hfeat  = uipanel('Parent',htext,'Title','Find the route','Units','normalized','Position',[0.01,0.01,0.78,0.41]);

hparam  = uipanel('Parent',hfeat,'Title','Methods used for the search','Position',[0,0,0.4,0.9]);
hbrute_force = uicontrol(hparam,'Style','Checkbox',...
             'String','Brute Force','Units','normalized','Position',[0.01,0.65,0.2,.2],...
             'Callback',@checkbox_brute_force_Callback);
         
hgready_search = uicontrol(hparam,'Style','Checkbox',...
             'String','Gready Search','Units','normalized','Position',[0.01,0.50,0.3,.2],...
             'Callback',@checkbox_gready_search_Callback);  
         
hga = uicontrol(hparam,'Style','Checkbox',...
             'String','Genetic Algorithm','Units','normalized','Position',[0.01,0.35,0.3,.2],...
             'Callback',@checkbox_ga_Callback);         


movegui(f,'center')

% Make the window visible.
set(f,'Visible','on');

%read data from a file
function btnOpen_Callback2(source,eventdata)
       
% ha = axes('Parent',hinit,'Units','pixels','Position',[50,15,500,300]);
 cla(ha,'reset');
 clear points;

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
fclose(fid);

axes(ha);
hold off
visualize_points(points)



end

%choose a method of search to use
  function checkbox_brute_force_Callback(hObject,source, eventdata)
      brute_force=0;  
      brute_force=get(hbrute_force,'Value');
      if (brute_force ~= 0)
          
          set(hgready_search,'Enable','off');
          set(hga,'Enable','off');
     
      else
          set(hgready_search,'Enable','on');
          set(hga,'Enable','on');
      end
  end

function checkbox_gready_search_Callback(hObject,source, eventdata)
      gready_search=0;  
      gready_search=get(hgready_search,'Value');
      if (gready_search ~= 0)
         set(hbrute_force,'Enable','off');
         set(hga,'Enable','off');
      else
       set(hbrute_force,'Enable','on');
       set(hga,'Enable','on');
      end
end

function checkbox_ga_Callback(hObject,source, eventdata)
      ga=0;  
      ga=get(hga,'Value');
      if (ga ~= 0)
         set(hbrute_force,'Enable','off');
         set(hgready_search,'Enable','off');
      else
       set(hbrute_force,'Enable','on');
       set(hgready_search,'Enable','on');
      end
end


% function work contains the different methods of search

function work_Callback(hObject,source,eventdata) 

% if we want to use brute force
if (get(hbrute_force,'Value')~= 0)
    cla(ha,'reset');
    visualize_points(points)
     tic
     tmp=info.filename
     tmp=tmp(1:strfind(tmp,'.')-1)
     input=str2num(tmp(strfind(tmp,'m')+1:length(tmp)))
   distance= matrix_distance(points);
  [low_cost_road,low_cost]= find_road(distance,points)
  tElapsed = toc;
  tElapsed=num2str(tElapsed);
  low_cost_s=num2str(low_cost);
  low_cost_road_s=num2str(low_cost_road);
  visualize_road(points,low_cost_road)
  final_result(low_cost_road_s,low_cost_s,tElapsed)
  hold off
    
end

% if we want to use gready search

if (get(hgready_search,'Value')~= 0)
    cla(ha,'reset');
    visualize_points(points)
     tic
     tmp=info.filename
     tmp=tmp(1:strfind(tmp,'.')-1)
     input=str2num(tmp(strfind(tmp,'m')+1:length(tmp)));
     distances= matrix_distance(points);
     size(distances);
     cities= size(points,1);
     [path] = gready_search(distances,cities,points,'neighbour');
     
     tElapsed = toc;
     tElapsed=num2str(tElapsed);
  
     [cost] = path_cost(path,distances);
     cost_s=num2str(cost);
     path_s=num2str(path);
     visualize_road(points,path)
     final_result(path_s,cost_s,tElapsed)
     hold off

end

% if we want to use genetic algorithm

if (get(hga,'Value')~= 0)
    cla(ha,'reset');
    visualize_points(points)
     tic
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
Population_Size=15;
Iter_number=10000;
showResult  = true;
xy=coords;
[N,dimension] = size(xy);
[nr,nc] = size(distances);
n = N;
Population_Size = 4*ceil(Population_Size/4);
Iter_number= max(1,round(real(Iter_number(1))));
     
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

figure('Name','Searching for the best solution','Numbertitle','off');
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
            d = distances(population(p,n),population(p,1)); % Closed Path
            for k = 2:n
                d = d + distances(population(p,k-1),population(p,k));
            end
            Total_Distance(p) = d;
        end
        
        
       
        
        % use swap mutaion
        randomOrder = randperm(Population_Size);
        for p = 4:4:Population_Size
            rtes = population(randomOrder(p-3:p),:);
            dists = Total_Distance(randomOrder(p-3:p));
            [ignore,idx] = min(dists); 
            bestOf4Route = rtes(idx,:);
            Path_Insertion_Points = sort(ceil(n*rand(1,2)));
            I = Path_Insertion_Points(1);
            J = Path_Insertion_Points(2);
            for k = 1:4 % Mutate the Best to get Three New Routes
                Pop_Sample(k,:) = bestOf4Route;
                
                % Flip
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
set(f, 'HandleVisibility', 'off');
close all;
set(f, 'HandleVisibility', 'on');
toc
 
        tElapsed = toc;
     tElapsed=num2str(tElapsed);
  
     [cost] = path_cost(rte,distances);
     cost_s=num2str(cost);
     path_s=num2str(rte);
     axes(ha)
     visualize_road(points,rte)
     final_result(path_s,cost_s,tElapsed)
     

end

end

% show the final result

    function final_result(a,b,c)    
hwindowtxt3 = uicontrol(htext,'Style','text','String',['The minimum route is:' a],'Units','normalized','Position',[0.53 0.7 0.4 0.2]);  
hwindowtxt2 = uicontrol(htext,'Style','text','String',['The cost is:' b],'Units','normalized','Position',[0.53 0.55 0.4 0.2]);  
hwindowtxt4 = uicontrol(htext,'Style','text','String',['The time needed is:' c],'Units','normalized','Position',[0.53 0.5 0.4 0.2]);  

    end
  
end




