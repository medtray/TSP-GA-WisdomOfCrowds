function [sample_after_swap] = mutation_swap(sample,I,J)

sample_after_swap =sample;
                  
sample_after_swap(1,[I J]) = sample(1,[J I]);


end

