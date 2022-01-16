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
pob_div_dir <- "results/POB/genome_info/"
pob_div_files <- dir(pob_div_dir, pattern=".tsv")
pob_div <- data_frame(filename = pob_div_files) %>% mutate(file_contents = map(filename, ~ read_tsv(file.path(pob_div_dir, .)))
) %>% 
  unnest()

pob_div_filtered <- pob_div %>% 
  filter(coverage > 10 & breadth > 0.9) %>% 
  separate(filename, into=c("org", "sample"), "-vs-") %>% 
  select(genome, sample, coverage, breadth, nucl_diversity, r2_mean, d_prime_mean) %>% 
  mutate(sample = gsub(".IS_genome_info.tsv", "", sample))
