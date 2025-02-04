library(ggh4x)
library(ggplot2)
library(tidyverse)

setwd("path/to/Dr_Sakai_taxo_sig_effect/")

data <- read_tsv("path/to/PPI_taxonomy_effect.txt")
head(data)
colnames(data)
data$taxonomy <- factor(data$`...1`, levels = unique(data$`...1`))
data$taxonomy <- factor(data$`1`, levels = unique(data$`1`))
data$colour <- ifelse(data$effect < 0, "up", "down")
data$hjust <- ifelse(data$effect > 0, 1.05, -0.05)
p <- ggplot(data = data, mapping = aes(x = effect, y = taxonomy, width=0.7)) + 
  geom_text(aes(x = 0, hjust =hjust, label = taxonomy), size=3) + 
  geom_bar(stat = "identity", aes(fill = colour))+
  scale_x_continuous(limits = c(-1.0, 1.2)) +
  geom_vline(xintercept = 0, colour = "black" )+
  theme_classic() +
  scale_fill_manual(values = c("red2", "blue2"))+
  xlab("Effect size\nUser (n=199) − Non-user (n=593)") + 
  theme(legend.position="none", 
        axis.line=element_line(color="black"),
        axis.title.y=element_blank(), 
        axis.title.x=element_text(size=15), 
        axis.line.y=element_blank(),
        axis.ticks.y=element_blank(),
        axis.text.x.bottom = element_text(size=15), 
        axis.text.y=element_blank())

ggsave(file = "path/to/Fig2E.png", plot = p, dpi = 300, width = 6, height = 4)
