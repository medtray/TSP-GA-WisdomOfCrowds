function [sample_after_flip] = mutation_flip(sample,I,J)

sample_after_flip =sample;

sample_after_flip(1,I:J) = sample(1,J:-1:I);

                                         
end

