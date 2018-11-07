function [population_after_crossover] = double_points_crossover(population,Population_Size,Total_Distance,n,distances)
 
        randomOrder = randperm(Population_Size);
        o=0;
        for p = 4:4:Population_Size
            o=o+1;
            rtes = population(randomOrder(p-3:p),:);
            dists = Total_Distance(randomOrder(p-3:p));
            [ignore,idx] = min(dists); 
            bestOf4Route = rtes(idx,:);
             i=0;
             Pop_Sample=zeros(7,n);
            for k=1:4
               
                if (k ~=idx)
                    
                pop1=zeros(1,n);
                pop2=zeros(1,n);
                crossover=rtes(k,:);
                crossover_element=rtes(k,:);
                best=bestOf4Route;
                
                border1 = randi([1 floor(n/3)],1,1);
                border2= randi([floor(n/3)+1 floor(2*n/3)],1,1);
              
                pop2(1,border1+1:border2)=best(1,border1+1:border2);
                pop1(1,border1+1:border2)=crossover_element(1,border1+1:border2);
                
                u=[best(border2+1:n),best(1:border1),best(1,border1+1:border2)];
                best(1,:)=u;
                
                v=[crossover_element(border2+1:n),crossover_element(1:border1),crossover_element(1,border1+1:border2)];
                crossover_element(1,:)=v;
                
                a=crossover(1,border1+1:border2);
                for kk=1:size(a,2)
                best(best==a(1,kk))=[];
                end
                
                aa=bestOf4Route(1,border1+1:border2);
                for kkk=1:size(aa,2)
                crossover_element(crossover_element==aa(1,kkk))=[];
                end
                
                
                pop1(1,border2+1:n)=best(1,1:n-border2);
                pop1(1,1:border1)=best(1,n-border2+1:n-border2+border1);
                i=i+1;
                Pop_Sample(i,:)=pop1;
                
                pop2(1,border2+1:n)=crossover_element(1,1:n-border2);
                pop2(1,1:border1)=crossover_element(1,n-border2+1:n-border2+border1);
                i=i+1;
                Pop_Sample(i,:)=pop2;
                end
                
                
            end
            
            
           Pop_Sample(7,:)=bestOf4Route;
            New_Pop(7*(o-1)+1:7*o,:) = Pop_Sample;
        end
        Total_distance1=zeros(size(New_Pop,1),1);
        
        for p = 1:size(New_Pop,1)
            d = distances(New_Pop(p,n),New_Pop(p,1)); 
            for k = 2:n
                d = d + distances(New_Pop(p,k-1),New_Pop(p,k));
            end
            Total_Distance1(p) = d;
        end
   
        [B,I]=sort(Total_Distance1,'ascend');
   
        population_after_crossover = New_Pop(I(1,1:Population_Size),:);
        clear best;
        clear crossover_element;
        clear Total_Distance1;

end

