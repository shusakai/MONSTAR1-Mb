# Figure 1.C
table.txt (column 2:ASV, 3:Antibiotics, 4:PPIs, 5: Acetaminophen,6:Probiotics)

Rscript ggplot_Num_violin_plot_tate_graph.R table.txt 2 3,4,5,6 0.8 figure1C.pdf

# Figure 1.D
table.txt (column 2:ASV, 7:Drinking, 8:Smoking, 9:Number of defecations per days,10: Yogurt, 11:LABB, 12:Chesese, 13: Miso soup)

Rscript ggplot_Num_violin_plot_tate_graph.R table.txt 2 7,8,9,10,11,12,13 0.8 figure1D.pdf

# Figure 2.A, 2.B

table.txt (column 2:ASV,3:KO,4:Cancer)
Rscript arrange_violin_plot_one_tate_graph.R table.txt 2 4 0.5 figure2A.pdf
Rscript arrange_violin_plot_one_tate_graph.R table.txt 3 4 0.5 figure2B.pdf

# Figure 3.B
forest_medicine.py
Rscript forestplot_Fig3C.R
