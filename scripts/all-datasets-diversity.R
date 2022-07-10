library(tidyverse)

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

all_datasets_mean_pi_phyla %>% 
  filter(phylum %in% all_top_phyla) %>% 
  ggplot(aes(x=dataset, y=mean_pi)) +
  facet_wrap(~ phylum, nrow=1) +
  geom_boxplot()

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
