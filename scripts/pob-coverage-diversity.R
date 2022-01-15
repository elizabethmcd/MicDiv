library(tidyverse)

# POB Dataset Coverage and Diversity 

# coverage
pob_coverage_dir <- "results/POB/quick_profiles/"
pob_files <- dir(pob_coverage_dir, pattern=".csv")
pob_coverage <- data_frame(filename = pob_files) %>% mutate(file_contents = map(filename, ~ read.csv(file.path(pob_coverage_dir, .)))
) %>% 
  unnest()

pob_coverage_filtered <- pob_coverage %>% 
  filter(coverage > 10 & breadth > 0.9) %>% 
  mutate(sample = gsub("-genomeCoverage.csv", "", filename)) %>% 
  select(genome, sample, coverage, breadth)

pob_queue_pairs <- pob_coverage_filtered %>% 
  select(genome, sample) %>% 
  mutate(genome = paste(genome, "fa", sep=".")) %>% 
  mutate(sample = paste(sample, "mapping.sorted.bam", sep="-"))

write_tsv(pob_queue_pairs, "queues/POB-inStrain-profile-queues.txt", col_names = FALSE)

# diversity
