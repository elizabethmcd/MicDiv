library(tidyverse)

####################################  
# inStrain profile genome info for all high-coverage genome:sample pairs in the Danish WWTPs dataset
#################################### 

# read in all genome info files to one dataframe

genome_info_path <- "results/Danish_WWTPs/inStrain_genome_info/"
files <- dir(genome_info_path, pattern="*_genome_info.tsv")
danish_wwtps_info <- data_frame(filename = files) %>%
  mutate(file_contents = map(filename, ~ read_tsv(file.path(genome_info_path, .)))
  ) %>% 
  unnest()

# filter by coverage and breadth
danish_wwtps_info_filtered <- danish_wwtps_info %>% 
  filter(coverage > 10 & breadth > 0.9)

# combine with metadata
danish_mags_metadata <- read.csv("results/Danish_WWTPs/Singleton2021-MAG-summaries.csv") %>% 
  select(MAG, GTDBTax, Comp, Cont)
colnames(danish_mags_metadata) <- c("genome", "taxonomy", "completeness", "contamination")

danish_wwtps_div_table <- danish_wwtps_info_filtered %>% select(genome, filename, coverage, breadth, nucl_diversity, r2_mean, d_prime_mean)

# clean names and filter by completeness and contamination
danish_wwtps_div_info <- left_join(danish_wwtps_div_table, danish_mags_metadata) %>% 
  filter(completeness > 80 & contamination < 5) %>% 
  separate(taxonomy, into=c("taxonomy", "phylum"), sep="p__") %>%
  separate(filename, into=c("org", "sample"), sep="-vs-") %>% 
  select(-taxonomy, -org)

danish_wwtps_div_info$sample <- gsub(".IS_genome_info.tsv", "", danish_wwtps_div_info$sample)
danish_wwtps_div_info$phylum <- gsub(";.*", "", danish_wwtps_div_info$phylum)

# plotting diversity and r2/D' by sample 
danish_wwtps_div_info %>% ggplot(aes(x=sample, y=nucl_diversity)) + geom_point(aes(color=phylum))

danish_wwtps_div_info %>% ggplot(aes(x=d_prime_mean, y=r2_mean)) + geom_point(aes(color=phylum)) + facet_wrap(~ sample)

# count number of samples each genome is in 
danish_wwtps_div_info %>% 
  count(genome, phylum) %>% 
  arrange(desc(n))

# select those that are in 5 or more samples
above_5_samples <- danish_wwtps_div_info %>% 
  count(genome, phylum) %>% 
  arrange(desc(n)) %>% 
  filter(n > 5) %>% # select those genomes that are present in 5 or more samples
  pull(genome)

danish_wwtps_div_info %>% 
  filter(genome %in% above_5_samples) %>% 
  ggplot(aes(x=r2_mean, y=nucl_diversity)) + geom_point(aes(color=phylum)) + facet_wrap(~ sample)

danish_wwtps_div_info %>% 
  filter(genome %in% above_5_samples) %>% 
  group_by(genome, phylum) %>% 
  summarize(mean_nucl_div = mean(nucl_diversity), mean_r2 = mean(r2_mean), n=n()) %>% 
  ggplot(aes(x=mean_r2, y=mean_nucl_div)) + geom_point(aes(color=phylum))


