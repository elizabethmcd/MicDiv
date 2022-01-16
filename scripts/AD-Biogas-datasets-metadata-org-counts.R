library(tidyverse)
library(qdap)

# Organizing AD biogas genomes dataset metadata and selecting certain genomes and datasets for further investigation 

biogas_checkm <- read.csv("metadata/AD_Biogas/ad_biogas_genomes_checkm_info.csv")
biogas_taxonomy <- read.csv("metadata/AD_Biogas/ad_biogas_gtdb_taxonomy.csv")
colnames(biogas_checkm)[1] <- c("genome")

biogas_metadata <- left_join(biogas_checkm, biogas_taxonomy) %>% 
  select(genome, gtdb_classification, Completeness, Contamination, Genome.size..bp., GC) %>% 
  filter(Completeness > 85 & Contamination < 10)
colnames(biogas_metadata) <- c("genome", "gtdb_classification", "completeness", "contamination", "size_bp", "GC")

biogas_metadata_info <- biogas_metadata %>% 
  mutate(sample = genome) %>% 
  mutate(sample = gsub("^(?:[^_]+_){1}([^_]+).*", "\\1", sample))  

# read in sample info 
biogas_samples <- read.csv("metadata/AD_Biogas/ad_biogas_mags_dataset_information.csv") %>% 
  select(Experiment, Assembly, Scale, MAGs_n, Accession, Samples_n)

colnames(biogas_samples) <- c("experiment", "sample", "scale", "MAGs_n", "accession", "samples_n")

biogas_genomes_table <- left_join(biogas_metadata_info, biogas_samples)

biogas_samples_genome_counts <- biogas_genomes_table %>% 
  count(sample, experiment, scale, accession, samples_n) %>% 
  arrange(desc(n))

write.csv(biogas_samples_genome_counts, "metadata/AD_Biogas/AD-biogas-samples-genomes-counts.csv", row.names = FALSE, quote = FALSE)
