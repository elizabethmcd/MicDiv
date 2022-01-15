library(tidyverse)

# Zymo coverage pairs
zymo_path <- "results/Zymo"
zymo_files <- dir(zymo_path, pattern=".csv")
zymo_coverage <- data_frame(filename = zymo_files) %>% mutate(file_contents = map(filename, ~ read.csv(file.path(zymo_path, .)))
  ) %>% 
  unnest()

zymo_queues <- zymo_coverage%>% 
  filter(coverage > 10 & breadth > 0.9) %>% 
  select(genome, filename) %>% 
  mutate(genome = paste(genome, "fa", sep=".")) %>% 
  mutate(filename = gsub("_genomeCoverage.csv", "", filename)) %>% 
  mutate(filename = paste(filename, "fastq.sorted.bam", sep="."))

write_tsv(zymo_queues, "queues/zymo-inStrain-queues.txt", col_names = FALSE)

# Diversity results 
zymo_inStrain_path <- "results/Zymo/inStrain"
zymo_div_files <- dir(zymo_inStrain_path, pattern=".tsv")
zymo_div <- data_frame(filename = zymo_div_files) %>% mutate(file_contents = map(filename, ~ read_tsv(file.path(zymo_inStrain_path, .)))
) %>% 
  unnest()

zymo_div_table <- zymo_div %>% 
  filter(coverage > 10 & breadth > 0.9) %>% 
  separate(filename, into=c("org", "sample"), "-vs-") %>% 
  mutate(sample = gsub(".IS_genome_info.tsv", "", sample)) %>% 
  select(genome, sample, coverage, breadth, nucl_diversity, r2_mean, d_prime_mean) %>% 
  mutate(genome = gsub("_complete_genome", "", genome))

zymo_div_table %>% 
  ggplot(aes(x=r2_mean, y=nucl_diversity)) + geom_point(aes(color=sample)) + facet_wrap(~ genome, ncol=2) + theme_bw()
