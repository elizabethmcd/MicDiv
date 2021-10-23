library(tidyverse)

# MCFA Genomes Metadata Organization 

mcfa_checkm <- read_tsv("metadata/MCFA/mcfa_dereplicated_bins_stats.txt", col_names = FALSE)
mcfa_gtdb <- read_tsv("metadata/MCFA/gtdbtk.bac120.summary.tsv") %>% 
  select(user_genome, classification)

colnames(mcfa_checkm) <- c("user_genome", "lineage", "completeness", "contamination", "size", "contigs", "gc", "x")

mcfa_metadata <- left_join(mcfa_gtdb, mcfa_checkm) %>% 
  select(-lineage, -x)

write.csv(mcfa_metadata, "metadata/MCFA/mcfa_genomes_metadata.csv", quote=FALSE, row.names = FALSE)
