function [sample_after_slide] = mutation_slide(sample,I,J)

sample_after_slide =sample;
                   
sample_after_slide(1,I:J) = sample(1,[I+1:J I]);


end