library(tidyverse)
library(viridis)
library(cowplot)
library(ggpubr)

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
  mutate(gtdb = taxonomy) %>% 
  separate(taxonomy, into=c("taxonomy", "phylum"), sep="p__") %>%
  separate(filename, into=c("org", "sample"), sep="-vs-") %>% 
  select(-taxonomy, -org)

danish_wwtps_div_info$sample <- gsub(".IS_genome_info.tsv", "", danish_wwtps_div_info$sample)
danish_wwtps_div_info$phylum <- gsub(";.*", "", danish_wwtps_div_info$phylum)
danish_wwtps_div_info$sample <- gsub("_.*", "", danish_wwtps_div_info$sample)

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

above_3_samples <- danish_wwtps_div_info %>% 
  count(genome, phylum) %>% 
  arrange(desc(n)) %>% 
  filter(n > 3) %>% # select those genomes that are present in 3 or more samples
  pull(genome)

top_10_lineages <- danish_wwtps_div_info %>% 
  count(genome, phylum) %>% 
  arrange(desc(n)) %>% 
  mutate(genome = gsub(".fa", "", genome)) %>% 
  top_n(10, n) %>% 
  pull(genome)

danish_wwtps_div_info %>% 
  filter(genome %in% above_5_samples) %>% 
  ggplot(aes(x=r2_mean, y=nucl_diversity)) + geom_point(aes(color=phylum)) + facet_wrap(~ sample)

danish_wwtps_div_info %>% 
  filter(genome %in% above_3_samples) %>% 
  ggplot(aes(x=r2_mean, y=nucl_diversity)) + geom_point(aes(color=phylum)) + facet_wrap(~ sample)

danish_wwtps_div_info %>% 
  filter(genome %in% above_5_samples) %>% 
  group_by(genome, phylum) %>% 
  summarize(mean_nucl_div = mean(nucl_diversity), mean_r2 = mean(r2_mean), n=n()) %>% 
  ggplot(aes(x=mean_r2, y=mean_nucl_div)) + geom_point(aes(color=phylum))

danish_wwtps_div_info %>% 
  mutate(sample = gsub("_.*", "", sample)) %>% 
  filter(genome %in% above_5_samples) %>% 
  ggplot(aes(x=sample, y=nucl_diversity)) + geom_point(aes(color=phylum)) + facet_wrap(~ gtdb)

species_labels <- labeller(genome = gtdb)

wwtps_levels <- c("Hirt", "Hjor", "AalE", "AalW", "Mari", "Skiv", "Vibo", "Rand", "Ega", "Viby", "EsbE", "EsbW", "Fred", "Ribe", "Hade", "OdNW", "Ejby", "OdNE", "Lyne", "Damh", "Aved")
danish_wwtps_div_info$sample <- factor(danish_wwtps_div_info$sample, levels=wwtps_levels)


danish_div_top_species <- danish_wwtps_div_info %>% 
  mutate(genome = gsub(".fa", "", genome)) %>%
  filter(genome %in% top_10_lineages) %>% 
  mutate(gtdb = gsub("d__Bacteria;", "", gtdb)) %>% 
  ggplot(aes(x=as_factor(sample), y=nucl_diversity)) + 
  geom_point(aes(color=phylum), size=1.5) + 
  facet_wrap(gtdb ~ genome, ncol=1, labeller = function(df) {
    list(as.character(df[,1]))
  }) + 
  theme_bw() + 
  theme(legend.position = "bottom", axis.text.x= element_text(angle=85, hjust=1), strip.text=element_text(size=6.5), axis.title.x=element_text(face="bold"), axis.title.y=element_text(face="bold")) +
  scale_y_continuous(expand=c(0, .005)) +
  xlab("WWTP Sample") +
  ylab("Nucleotide Diversity of Species in WWTP Sample") +
  labs(color="Phylum")

danish_div_top_species

danish_wwtps_top10_div

ggsave("figs/Danish-WWTPs-Top10-diversity.png", danish_wwtps_top10_div, width=18, height=7, units=c("in"))

ggsave("figs/Danish_WWTPs-top-species-diversity-samples.png", danish_div_top_species, width=25, height=35, units=c("cm"))

# compare to relative abundance for lineages of interest 
danish_wwtps_relative_abundance <- read.csv("results/Danish_WWTPs/Danish-WTTPs-relative-abundance.csv")

colnames(danish_wwtps_relative_abundance) <- sub("_.*", "", colnames(danish_wwtps_relative_abundance))

top10_rel_abund <- danish_wwtps_relative_abundance %>% 
  filter(Genome %in% top_10_lineages) %>% 
  select(Genome, Hirt, Hjor, AalE, AalW, Mari, Skiv, Vibo, Rand, Ega, Viby, EsbE, EsbW, Fred, Ribe, Hade, OdNW, Ejby, OdNE, Lyne, Damh, Aved) %>% 
  pivot_longer(-Genome, names_to="wwtp", values_to="relative_abundance") %>% 
  mutate(genome = Genome) %>% 
  select(-Genome)

danish_names <- danish_mags_metadata %>% 
  mutate(genome = gsub(".fa", "", genome)) %>% 
  select(genome, taxonomy)

top10_rel_abund_info <- left_join(top10_rel_abund, danish_names) %>% 
  select(genome, taxonomy, wwtp, relative_abundance)

View(top10_rel_abund_info)

genome_levels <- c("AalE_18-Q3-R2-46_BATAC.579", 
                   "Ejby_18-Q3-R6-50_BAT3C.200", 
                   "Ega_18-Q3-R5-49_BAT3C.193", 
                   "Ejby_18-Q3-R6-50_MAXAC.192", 
                   "Rand_18-Q3-R56-63_MAXAC.001", 
                   "Skiv_18-Q3-R9-52_BAT3C.176", 
                   "EsbW_18-Q3-R4-48_MAXAC.006_sub", 
                   "OdNE_18-Q3-R46-58_BAT3C.305",
                   "Skiv_18-Q3-R9-52_MAXAC.078_sub", 
                   "EsbE_18-Q3-R3-47_MAXAC.059", 
                   "Bjer_18-Q3-R1-45_MAXAC.014", 
                   "Hjor_18-Q3-R7-51_MAXAC.006" 
                   )

top10_rel_abund_info$genome <- factor(top10_rel_abund_info$genome, levels=genome_levels)

relative_abundance_plot <- top10_rel_abund_info %>% 
  ggplot(aes(x=as_factor(wwtp), y=fct_rev(genome), fill=relative_abundance)) +
  geom_tile(color="white") +
  scale_fill_viridis(option="magma", alpha=1, begin=0, end=1, direction=-1, expand=c(0,0)) + 
  theme(axis.text.x= element_text(angle=85, hjust=1), legend.position="bottom", axis.text.y=element_blank(), axis.ticks.y=element_blank(), axis.title.y=element_blank(), axis.title.x=element_text(face="bold")) +
  scale_y_discrete(expand=c(0,0)) +
  scale_x_discrete(expand=c(0,0)) +
  xlab("WWTP Sample") +
  labs(fill="Relative Abundance")

relative_abundance_plot

# grid figures 

danish_abund_div_grid <- plot_grid(danish_div_top_species,relative_abundance_plot, ncol=2, align="h", axis="b", rel_widths=c(2,1.2))

danish_abund_div_grid

ggsave("figs/danish_abund_div_grid.png", danish_abund_div_grid, width=30, height=25, units=c("cm"))

# Aggregate mean nucl diversity for each genome, genome has to be present in at least 3 samples to calculate the average 

genomes3 <- danish_wwtps_div_info %>% 
  count(genome, phylum) %>% 
  arrange(desc(n)) %>% 
  filter(n >= 3) %>% 
  pull(genome)

avg_nucl_diversity3 <- danish_wwtps_div_info %>% 
  filter(genome %in% genomes3) %>% 
  select(genome, nucl_diversity, phylum) %>% 
  group_by(genome, phylum) %>% 
  summarize(mean_pi = mean(nucl_diversity))

danish_wwtps_div_info %>% 
  filter(genome %in% genomes3) %>% 
  ggplot(aes(x=phylum, y=nucl_diversity)) +
  geom_boxplot() +
  geom_jitter() +
  facet_wrap(~ sample, nrow=3, scales="free_x")

# species in at least 3 samples for comparisons
avg_nucl_diversity3 %>% 
  ggplot(aes(x=phylum, y=mean_pi, fill=phylum)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(aes(alpha=0.5)) +
  ylab("Average Nucleotide Diversity of \n Species Across All WWTP Samples") +
  theme_bw() +
  theme(axis.text.x= element_text(angle=85, hjust=1), legend.position="none", axis.title.x=element_blank(), axis.title.y=element_text(face="bold"))

phyla_nucleotide_diversity <- danish_wwtps_div_final_info_phylum %>% 
  ggplot(aes(x=phylum, y=mean_pi, fill=phylum)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(aes(alpha=0.5)) +
  ylab("Average Nucleotide Diversity of \n Species Across All WWTP Samples") +
  theme_bw() +
  theme(axis.text.x= element_text(angle=85, hjust=1), legend.position="none", axis.title.x=element_blank(), axis.title.y=element_text(face="bold"))

ggsave("figs/danish_wwtp_phyla_div.png", phyla_nucleotide_diversity, width=20, height=10, units=c("cm"))  

