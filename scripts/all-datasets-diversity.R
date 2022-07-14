library(tidyverse)
library(cowplot)
library(viridis)
library(ggpubr)

# All datasets diversity 
# Plotting the average nucleotide diversity of a lineage in all samples in that dataset, and plotting those datasets side by side to compare population diversity in different types of environments

# Zymo synthetic 
zymo_div_final <- zymo_div_table %>%
  group_by(genome) %>% 
  summarize(mean_pi = mean(nucl_diversity)) %>% 
  mutate(dataset = "Zymo")

## R1R2 
r1r2_diversity_table <- read.csv("results/R1R2/R1R2-inStrain-diversity-table.csv")

r1r2_div_final <- r1r2_diversity_table %>% 
  group_by(Genome) %>% 
  summarize(mean_pi = mean(nucl_diversity)) %>% 
  mutate(dataset = "R1R2") %>% 
  mutate(genome = Genome) %>% 
  select(genome, mean_pi, dataset)

# merge with metadata
r1r2_metadata <- read.csv("results/R1R2/R1-Flanking-final-bins-info.csv") %>% 
  mutate(genome = bin) %>% 
  mutate(taxonomy = classification) %>% 
  separate(taxonomy, into=c("taxonomy", "phylum"), sep="p__") %>% 
  mutate(genus = phylum) %>% 
  separate(genus, into=c("species", "genus"), sep="g__") %>% 
  select(genome, phylum, genus) %>% 
  mutate(phylum = gsub(";.*", "", phylum)) %>% 
  mutate(genus = gsub(";.*", "", genus))


r1r2_div_final_info_phyla <- left_join(r1r2_div_final, r1r2_metadata) %>% 
  select(genome, phylum, mean_pi, dataset)

r1r2_div_final_info_genus <- left_join(r1r2_div_final, r1r2_metadata) %>% 
  select(genome, genus, mean_pi, dataset)

## POB
pob_div_final <- pob_div_filtered %>% 
  group_by(genome) %>% 
  summarize(mean_pi = mean(nucl_diversity)) %>% 
  mutate(dataset = "POB")

# merge with metadata
pob_metadata <- read.csv("results/POB/POS-MAGs-table.csv") %>% 
  mutate(genome = bin) %>% 
  mutate(taxonomy = classification) %>% 
  separate(taxonomy, into=c("taxonomy", "phylum"), sep="p__") %>% 
  mutate(genus = phylum) %>% 
  separate(genus, into=c("species", "genus"), sep="g__") %>% 
  select(genome, phylum, genus) %>% 
  mutate(phylum = gsub(";.*", "", phylum)) %>% 
  mutate(genus = gsub(";.*", "", genus))

pob_div_final_info_phylum <- left_join(pob_div_final, pob_metadata) %>% 
  select(genome, phylum, mean_pi, dataset)

pob_div_final_info_genus <- left_join(pob_div_final, pob_metadata) %>% 
  select(genome, genus, mean_pi, dataset)

## Abigail reactor
abigail_diversity_table <- read.csv("results/Abigail/Abigail-inStrain-diversity-table.csv")

abigail_div_final <- abigail_diversity_table %>% 
  group_by(genome) %>% 
  summarize(mean_pi = mean(nucl_diversity)) %>% 
  mutate(dataset = "Abigail")

# merge with metadata
abigail_metadata <- read.csv("results/Abigail/Abigail-bins-info.csv") %>% 
  mutate(genome = bin) %>%
  separate(taxonomy, into=c("taxonomy", "phylum"), sep="p__") %>% 
  mutate(genus = phylum) %>% 
  separate(genus, into=c("species", "genus"), sep="g__") %>% 
  select(genome, phylum, genus) %>% 
  mutate(phylum = gsub(";.*", "", phylum)) %>% 
  mutate(genus = gsub(";.*", "", genus))

abigail_div_final_info_phylum <- left_join(abigail_div_final, abigail_metadata) %>% 
  select(genome, phylum, mean_pi, dataset)

abigail_div_final_info_genus <- left_join(abigail_div_final, abigail_metadata) %>% 
  select(genome, genus, mean_pi, dataset)

# Danish WWTPs 
danish_wwtps_div_final_info_phylum <- danish_wwtps_div_info %>% 
  group_by(genome, phylum) %>% 
  summarize(mean_pi = mean(nucl_diversity)) %>% 
  mutate(dataset = "Danish_WWTPs") %>% 
  select(genome, phylum, mean_pi, dataset)

danish_wwtps_div_final_info_genus <- danish_wwtps_div_info %>% 
  mutate(taxonomy = gtdb) %>% 
  separate(taxonomy, into=c("taxonomy", "genus"), sep="g__") %>% 
  mutate(genus = gsub(";.*", "", genus)) %>% 
  group_by(genome, genus) %>% 
  summarize(mean_pi = mean(nucl_diversity)) %>% 
  mutate(dataset = "Danish_WWTPs") %>% 
  select(genome, genus, mean_pi, dataset)


# All datasets diversity 
# phyla
all_datasets_mean_pi_phyla <- rbind(abigail_div_final_info_phylum, pob_div_final_info_phylum, r1r2_div_final_info_phyla, danish_wwtps_div_final_info_phylum)

all_datasets_mean_pi_phyla %>% 
  group_by(phylum, dataset) %>% 
  count() %>% 
  arrange(desc(n))

all_top_phyla <- all_datasets_mean_pi_phyla %>% 
  group_by(phylum) %>% 
  count() %>% 
  arrange(desc(n)) %>% 
  filter(n > 20) %>% 
  pull(phylum)

all_datasets_mean_pi_phyla %>% 
  filter(phylum %in% all_top_phyla) %>% 
  ggplot(aes(x=phylum, y=mean_pi, fill=dataset)) +
  geom_boxplot()

phyla_div <- all_datasets_mean_pi_phyla %>% 
  filter(phylum %in% all_top_phyla) %>% 
  ggplot(aes(x=dataset, y=mean_pi)) + 
  geom_boxplot(aes(fill=dataset),outlier.shape = NA, position=position_dodge(1)) +
  facet_wrap(~ phylum, nrow=1, scales = "free_x") +
  geom_jitter(alpha=.5) +
  theme_bw() +
  theme(axis.text.x= element_text(angle=85, hjust=1), legend.position="top", axis.title.x=element_blank(), axis.title.y=element_text(face="bold")) +
  ylab("Average Nucleotide Diversity \n of Species Across Samples")
phyla_div

# genera 
all_datasets_mean_pi_genus <- rbind(abigail_div_final_info_genus, pob_div_final_info_genus, r1r2_div_final_info_genus, danish_wwtps_div_final_info_genus)

top_genera <- all_datasets_mean_pi_genus %>% 
  filter(genus != "") %>% 
  group_by(genus) %>% 
  count() %>% 
  arrange(desc(n)) %>% 
  filter(n > 4) %>% 
  pull(genus)

all_datasets_mean_pi_genus %>% 
  filter(genus %in% top_genera) %>% 
  ggplot(aes(x=dataset, y=mean_pi)) +
  facet_wrap(~ genus) +
  geom_boxplot()

reactors_genera <- all_datasets_mean_pi_genus %>% 
  filter(genus == 'Brevundimonas' | genus == 'Chryseobacterium_A' | genus == 'Flavobacterium' | genus == 'PAR1' | genus == 'Pseudoxanthomonas') %>% 
  ggplot(aes(x=dataset, y=mean_pi)) +
  facet_wrap(~ genus, ncol =1) +
  geom_boxplot() + 
  geom_jitter()

all_genera <- all_datasets_mean_pi_genus %>% 
  filter(genus == 'Accumulibacter' | genus == 'Dechloromonas' | genus == 'Rubrivivax') %>% 
  ggplot(aes(x=dataset, y=mean_pi)) +
  facet_wrap(~ genus, ncol=3) +
  geom_boxplot(aes(fill=dataset), outlier.shape=NA, outlier.fill = NULL, outlier.size=NULL, position=position_dodge(1)) +
  geom_jitter(alpha=.5) +
  theme_bw()+
  theme(axis.text.x= element_text(angle=85, hjust=1), legend.position="top", axis.title.x=element_blank(), axis.title.y=element_text(face="bold")) + 
  ylab("Average Nucleotide \n Diversity of Species Across Samples")
all_genera 

# getting genome files of specific species 

genomes_list <- all_datasets_mean_pi_genus %>% 
  filter(genus == 'Brevundimonas' | genus == 'Chryseobacterium_A' | genus == 'Flavobacterium' | genus == 'PAR1' | genus == 'Pseudoxanthomonas' | genus == 'Accumulibacter' | genus == 'Dechloromonas' | genus == 'Rubrivivax') %>% 
  select(-mean_pi) %>% 
  mutate(genome = paste(genome, "fa", sep="."))

genera_lists <- genomes_list %>% 
  group_split(genus)

names(genera_lists) <- c("Accumulibacter", "Brevundimonas", "Chryseobacterium_A", "Dechloromonas", "Flavobacterium", "PAR1", "Pseudoxanthomonas", "Rubrivivax")

lapply(names(genera_lists), function(x) {write.csv(genera_lists[[x]], file = paste0("results/ani_comps/", x, ".csv"), quote = FALSE, row.names = FALSE)})

# grids 
genera_grid <- plot_grid(reactors_genera, all_genera, ncol=2, labels=c("B", "C"))
genera_grid

comps_grid <- plot_grid(phyla_div, genera_grid, ncol=1, labels=c("A", ""))
comps_grid

ggsave("figs/all_datasets_comps_grid.png", comps_grid, width=20, height=25, units=c("cm"))

datasets_comps <- ggarrange(phyla_div, all_genera, ncol=1, common.legend = TRUE, heights = c(1.2,1), labels=c("A", "B"), legend = "bottom")

ggsave("figs/datasets_div_comps.png", datasets_comps, width=20, height=25, units=c("cm"))


