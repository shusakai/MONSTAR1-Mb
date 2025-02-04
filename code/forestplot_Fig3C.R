library(metafor)
library(tidyverse)

data <- read_tsv("pathto/output_of_forest_medicine.py.txt") 
#unique(data$alloc)
data$subgroup <- factor(data$subgroup, levels = rev(c("Antibiotics Survey", "Antibiotics EDC", "PPI Survey", "PPI EDC", "Acetaminophen", "Intestinal regulator","Steroid")))
res <- rma(yi, vi, data=data, method="EE", slab=subgroup)

pdf("Figure3C.pdf")
par(font=2)
forest(res, xlim=c(-8, 4.5), at=log(c(0.05, 1, 10)), atransf=exp,
       ilab=cbind(patient), ilab.xpos=c(-4),
       cex=0.88, ylim=c(0, 10), order=subgroup,
       rows=rev(c(7, 6, 5, 4, 3, 2, 1)), 
       psize=1, header="Subgroup", annotate = T, xlab="Hazard ratio", mlab = "Summary")

### set font expansion factor (as in forest() above) and use a bold font
#op <- par(cex=0.8, font=1)
### add additional column headings to the plot
text(c(-4), 9, c("No. of Patients (%)"))

dev.off()






