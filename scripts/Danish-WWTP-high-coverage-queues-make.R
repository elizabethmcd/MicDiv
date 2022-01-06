library(tidyverse)

wwtp_coverage <- read.csv("results/Danish_WWTPs/Danish-WWTPs-curated-coverage.csv")

wwtp_mags <- read.csv("metadata/Danish_WWTPs/Singleton2021-MAG-summaries.csv")
colnames(wwtp_mags)

wwtp_sprep_mags <- wwtp_mags %>% 
  filter(HQSpRep == "SPREPHQ") %>% 
  select(MAG, GTDBTax)

colnames(wwtp_sprep_mags) <- c("genome", "taxonomy")

coverage_mags <- left_join(wwtp_sprep_mags, wwtp_coverage)

high_coverage_mags <- coverage_mags %>% 
  filter(rowSums(.[3:24]>10)>=3)

high_coverage_pairs <- high_coverage_mags %>% 
  select(-taxonomy) %>% 
  pivot_longer(-genome, names_to="wwtp", values_to="coverage") %>% 
  filter(coverage > 10)

high_coverage_pairs_names <- left_join(high_coverage_pairs, wwtp_sprep_mags)

high_coverage_taxonomy <- high_coverage_pairs_names %>% 
  mutate(taxonomy=str_replace_all(string=taxonomy, pattern=";$", replacement="")) %>% 
  separate(taxonomy, into=c("kingdom", "phylum", "class", "order", "family", "genus", "species"), sep=";")

high_coverage_jobs <- high_coverage_pairs %>% 
  select(genome, wwtp)

high_coverage_jobs$wwtp <- gsub("\\.", "-", high_coverage_jobs$wwtp)

write_tsv(high_coverage_jobs, "queues/Danish-WWTP-high-coverage-pairs-queue.txt")

# Danish WWTP MAGs organization 

wwtp_mags <- read.csv("metadata/Danish_WWTPs/Singleton2021-MAG-summaries.csv") %>%
  filter(HQSpRep == "SPREPHQ") %>% 
  select("MAG", "GTDBTax", "Comp", "Cont", "TotBP", "NumContigs")

write.csv(wwtp_mags, "metadata/Danish_WWTPs/Danish_WWTPs_SPREP_MAG_metadata.csv", quote=FALSE, row.names = FALSE)
