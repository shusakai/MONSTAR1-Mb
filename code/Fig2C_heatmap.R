if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("ComplexHeatmap")

taxonomy_heatmap <- function(effectsize, sig_taxonomy_name, sig_taxonomy_index, annotation_table) {
  library(ComplexHeatmap)
  library(circlize)
  df_pik3ca_pathway <- read.table(file = effectsize, 
                                  sep = "\t", 
                                  header = T, 
                                  row.names = 1, 
                                  stringsAsFactors = TRUE
  )
  
  colnames(df_pik3ca_pathway) <- NULL
  
  
  label_text <- as.vector(read.table(file = sig_taxonomy_name, 
                                     sep = "\t", 
                                     header = F)$V1)
  
  label_text_index <- as.vector(read.table(file = sig_taxonomy_index, 
                                           sep = "\t", 
                                           header = F)$V1)
  
  df_annotation <- read.table(file = annotation_table, 
                              sep = "\t", 
                              row.names = 1, 
                              header = T)
  
  
  
  ha <- rowAnnotation(Pathway_level1 = as.matrix(df_annotation[, "level1"]),
                      annotation_name_rot = 45, 
                      col = list(Pathway_level1 = c("Metabolism" = "gray", 
                                                    "Genetic" = "green", 
                                                    "Human" = "pink", 
                                                    "Environmental" = "blue", 
                                                    "Organismal" = "yellow",
                                                    "Cellular" = "red", 
                                                    "-" = "black")
                      )
  )
  
  text_anno <- rowAnnotation(foo = anno_mark(at = label_text_index, 
                                             labels = label_text))
  
  f1 = colorRamp2(seq(min(-2), 
                      max(2), 
                      length = 3), 
                  c("blue", "#EEEEEE", "red")
  )
  
  Heatmap(t(as.matrix(df_pik3ca_pathway)), 
          clustering_distance_rows = "euclidean", 
          clustering_method_rows = "average", 
          clustering_distance_columns = "euclidean", 
          clustering_method_columns = "average", 
          left_annotation = ha, 
          right_annotation = text_anno, 
          row_title = "Pathway_level3", 
          column_title = "Cancer", 
          column_title_side = "bottom", 
          col = f1, 
          heatmap_legend_param = list(
            title = "effect_size", at = c(-2, -1, 0, 1, 2), 
            labels = c("-2", "-1", "0", "1", "2")
          ), 
          width = unit(8, "cm"), 
          height = unit(8, "cm"), 
          column_names_rot = 45
  )
}


taxonomy_heatmap("path/to/cancer_pathway_effectsize.txt", 
                 "path/to/cancer_sig_pathway_name.txt", 
                 "path/to/cancer_sig_pathway_index.txt", 
                 "path/to/cancer_annotation_table.txt")




