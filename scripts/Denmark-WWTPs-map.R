library(tidyverse)
library(maps)


samples <- read.csv("metadata/Danish_WWTPs/Danish-WWTPs-lat-long.csv")
samples_modf <- samples %>% filter(plant != "Kalundborg")

p <- ggplot() + borders("world", colour="black", fill="gray65") + coord_fixed(xlim=c(8, 13), ylim=c(54.8, 57.7))
p1 <- p + geom_point(data=samples_modf, aes(x=lon, y=lat), size=0.8)
  

denmark_no_labels <- p1 + theme_classic()
denmark_no_labels
denmark_wwtps_labels <- p1 + geom_text(data=samples, aes(x=lon, y=lat, label=plant), size = 1, col = "black", nudge_y=0.05) + theme_classic()
denmark_wwtps_labels
ggsave(plot=denmark_no_labels, filename="figures/Denmark-WWTP-map-no-labels.png", width=10, height=10, units=c("cm"))
ggsave(plot=denmark_wwtps_labels, filename="figures/Denmark-WWTPs-map-labels.png", width=10, height=10, units=c('cm'))
