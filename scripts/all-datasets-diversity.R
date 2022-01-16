library(tidyverse)

# All datasets diversity 
# Plotting the average nucleotide diversity of a lineage in all samples in that dataset, and plotting those datasets side by side to compare population diversity in different types of environments

# Zymo synthetic 
zymo_div_final <- zymo_div_table %>%
  group_by(genome) %>% 
  summarize(mean_pi = mean(nucl_diversity)) %>% 
  mutate(dataset = "Zymo")

# R1R2 
r1r2_diversity_table <- read.csv("results/R1R2/R1R2-inStrain-diversity-table.csv")

r1r2_div_final <- r1r2_diversity_table %>% 
  group_by(Genome) %>% 
  summarize(mean_pi = mean(nucl_diversity)) %>% 
  mutate(dataset = "R1R2") %>% 
  mutate(genome = Genome) %>% 
  select(genome, mean_pi, dataset)

# POB
pob_div_final <- pob_div_filtered %>% 
  group_by(genome) %>% 
  summarize(mean_pi = mean(nucl_diversity)) %>% 
  mutate(dataset = "POB")

# Abigail reactor
abigail_diversity_table <- read.csv("results/Abigail/Abigail-inStrain-diversity-table.csv")

abigail_div_final <- abigail_diversity_table %>% 
  group_by(genome) %>% 
  summarize(mean_pi = mean(nucl_diversity)) %>% 
  mutate(dataset = "Abigail")

# MCFA
mcfa_diversity_table <- read.csv("results/MCFA/mcfa-diversity-table.csv")

mcfa_div_final <- mcfa_diversity_table %>% 
  group_by(genome) %>% 
  summarize(mean_pi = mean(nucl_diversity)) %>% 
  mutate(dataset = "MCFA")

# Danish WWTPs 
danish_div_final <- danish_wwtps_div_info %>% 
  group_by(genome) %>% 
  summarize(mean_pi = mean(nucl_diversity)) %>% 
  mutate(dataset = "Danish WWTPs")


# All datasets diversity 
all_datasets_diversity <- rbind(zymo_div_final, danish_div_final, r1r2_div_final, mcfa_div_final, pob_div_final, abigail_div_final)

all_datasets_diversity %>% ggplot(aes(x=dataset, y=mean_pi)) + geom_jitter()
