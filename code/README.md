## Figure 1C
table.txt (column 2:ASV, 3:Antibiotics, 4:PPIs, 5: Acetaminophen,6:Probiotics)

```sh
Rscript Fig1C_ggplot_Num_violin_plot_tate_graph.R table.txt 2 3,4,5,6 0.8 figure1C.pdf
```

## Figure 1D
table.txt (column 2:ASV, 7:Drinking, 8:Smoking, 9:Number of defecations per days,10: Yogurt, 11:LABB, 12:Chesese, 13: Miso soup)

```sh
Rscript Fig1D_ggplot_Num_violin_plot_tate_graph.R table.txt 2 7,8,9,10,11,12,13 0.8 figure1D.pdf
```

## Figure 2A, 2B

table.txt (column 2:ASV,3:KO,4:Cancer)

```sh
Rscript Fig2AB_arrange_violin_plot_one_tate_graph.R table.txt 2 4 0.5 figure2A.pdf
Rscript Fig2AB_arrange_violin_plot_one_tate_graph.R table.txt 3 4 0.5 figure2B.pdf
```

## Figure 2C, 2D, 2E

```sh
Rscript Fig2C_heatmap.R
Rscript Fig2D_heatmap.R
Rscript Fig2E_heatmap.R
```

## Figure 3B

```sh
python Fig3B_forestplot_step1.py
Rscript Fig3B_forestplot_step2.R
```

## Figure 3C

```sh
python Fig3C_forest_medicine.py
Rscript Fig3C_forestplot.R
```
