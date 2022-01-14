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
