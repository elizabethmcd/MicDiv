library(tidyverse)

# All datasets diversity 
# Plotting the average nucleotide diversity of a lineage in all samples in that dataset, and plotting those datasets side by side to compare population diversity in different types of environments

# Zymo synthetic 
zymo_div_final <- zymo_div_table %>%
  group_by(genome) %>% 
  summarize(mean_pi = mean(nucl_diversity)) %>% 
  mutate(dataset = "Zymo")

# R1R2 

# Danish WWTPs 
danish_div_final <- danish_wwtps_div_info %>% 
  group_by(genome) %>% 
  summarize(mean_pi = mean(nucl_diversity)) %>% 
  mutate(dataset = "Danish WWTPs")


# All datasets diversity 
all_datasets_diversity <- rbind(zymo_div_final, danish_div_final)

all_datasets_diversity %>% ggplot(aes(x=dataset, y=mean_pi)) + geom_jitter()
