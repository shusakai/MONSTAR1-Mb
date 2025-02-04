# import library
library(metafor)
library(tidyverse)

data <- read_tsv("path/to/20230718_sawada_subgroup_ASV.txt") 
unique(data$alloc)
data$alloc <- factor(data$alloc, levels = c("Age", "Gender", "Cancer", "Antibiotics", "PPI", "Probiotics",
                                            "MSI", "TMB", "Treatment line", "Therapy"))
rev(data$subgroup)
data$subgroup <- factor(data$subgroup, levels=data$subgroup)
res <- rma(yi, vi, data=data, slab=subgroup)
#res <- rma(yi, vi, data=data)
forest(res, xlim=c(-8, 4.5), at=log(c(0.05, 1, 10)), atransf=exp,
       ilab=cbind(patient), ilab.xpos=c(-4),
       cex=0.88, ylim=c(-1, 40), order=alloc,
       rows=rev(c(1:3, 5:6, 8:9, 11:12, 14:15, 17:18, 20:21, 23:30, 
                  32:33, 35:36)), 
       psize=1, header="Subgroup", annotate = T, xlab="Hazard ratio", mlab = "Summary")

### set font expansion factor (as in forest() above) and use a bold font
op <- par(cex=0.8, font=1)
### add additional column headings to the plot
text(c(-4), 39, c("No. of Patients (%)"))

### switch to bold italic font
par(font=2)

### add text for the subgroups
text(-8.1, c(37, 34, 31, 22, 19, 16, 13, 10, 7, 4), pos=4, c("Age", "Gender", "Cancer", "Antibiotics", "PPI", "Probiotics",
                                                             "MSI", "TMB", "Treatment line", "Therapy"))


