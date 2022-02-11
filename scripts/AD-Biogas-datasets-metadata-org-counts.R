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

# Selecting genomes from the German Biogas facilities (8 metagenomes)

german_biogas_genomes <- biogas_genomes_table %>% filter(sample == "AS20ysBPTH" | sample == "AS21ysBPME" | sample == "AS22ysBPME" | sample == "AS23ysBPME") %>% 
  select(genome, gtdb_classification, completeness, contamination, size_bp, GC) %>% 
  drop_na()

german_biogas_genomes$isolate <- gsub("METABAT_", "", german_biogas_genomes$genome)

# Selecting genomes from Ziels ACSIP experiment 

ziels_acsip_genomes <- biogas_genomes_table %>% 
  filter(sample == "AS06rmzACSIP") %>% 
  select(genome, gtdb_classification, completeness, contamination, size_bp, GC) %>% 
  drop_na()

ziels_acsip_genomes$isolate <- gsub("METABAT_", "", ziels_acsip_genomes$genome)

# combine with metadata from NCBI with genbank accessions to get the correct genomes to the correct datasets

ncbi_bioproject_details <- read_tsv("metadata/AD_Biogas/PRJNA602310_AssemblyDetails.txt") %>% 
  select(Assembly, Isolate) %>% 
  mutate(isolate = Isolate) %>% 
  select(Assembly, isolate)

# german biogas isolates/genbank names 
german_biogas_genomes_table <- left_join(german_biogas_genomes, ncbi_bioproject_details)

# ad sip isolates/genbank names
ziels_acsip_genomes_table <- left_join(ziels_acsip_genomes, ncbi_bioproject_details)
