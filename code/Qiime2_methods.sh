#1.Qiimeの基本データ解析（オリジナルファイルの作成）
#1.1 Qiimeの起動
#qiime2は、verion 2022年2月版を使用。

conda activate qiime2-2022.2
#1.2 fastqのインポート
#fastqのディレクトリ情報は、manifest_20220331_conv_exp_rm20220331.csvにある。

qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' --input-path ../01mkdir_pre_file/manifest_20220331_conv_exp_rm20220331.csv --output-path res01_qiime.qza --input-format PairedEndFastqManifestPhred33V2

#1.3 denoise(OTUのクラスタリング等)
qiime dada2 denoise-paired --i-demultiplexed-seqs res01_qiime.qza --p-trim-left-f 22 --p-trim-left-r 22 --p-trunc-len-f 250 --p-trunc-len-r 240 --p-n-threads 20 --o-representative-sequences rep-seqs-qiime.qza --o-table table-qiime.qza --o-denoising-stats stats-dada2.qza  --verbose

#1.4 アライメント、系統樹の作成
qiime phylogeny align-to-tree-mafft-fasttree --i-sequences rep-seqs-qiime.qza --o-alignment aligned-rep-seqs-qiime.qza --o-masked-alignment masked-aligned-rep-seqs-qiime.qza --o-tree unrooted-tree.qza --o-rooted-tree rooted-tree.qza --p-n-threads 20

#1.5 代表配列の分類
qiime feature-classifier classify-sklearn --i-classifier /BIO/ref/QIIME2/qiime2_2022.2/silva-138-99-nb-classifier.qza --i-reads rep-seqs-qiime.qza --o-classification taxonomy-qiime.qza --p-n-jobs 18

#1.6 1000リード以下 (ネガコン) を除外したテーブルを作成する
qiime feature-table filter-samples --i-table table-qiime.qza --p-min-frequency 1000 --o-filtered-table exclude_nega_table-qiime.qza

#2. 最低リード数 (38807) で希薄化（オリジナルファイルの作成）：酒井さんが作成
#2.2.1 多様性指数の算出 (Faith PD, Shannon, observed features)
qiime diversity core-metrics-phylogenetic --i-phylogeny rooted-tree.qza --i-table exclude_nega_table-qiime.qza --p-sampling-depth 38807 --m-metadata-file temp_metadata.txt --output-dir core-metrics-results_38807_rarefied
2.2.2 他のα多様性の算出 (Chao1, Simpson evenness, Pielou evenness)
qiime diversity alpha --i-table core-metrics-results_38807_rarefied/rarefied_table.qza --p-metric 'chao1' --o-alpha-diversity core-metrics-results_38807_rarefied/chao1_vector.qza

qiime diversity alpha --i-table core-metrics-results_38807_rarefied/rarefied_table.qza --p-metric 'simpson_e' --o-alpha-diversity core-metrics-results_38807_rarefied/simpson_e_vector.qza

qiime diversity alpha --i-table core-metrics-results_38807_rarefied/rarefied_table.qza --p-metric 'pielou_e' --o-alpha-diversity core-metrics-results_38807_rarefied/pielou_e_vector.qza

#2.2.3 α多様性を纏めたテーブルを作成する
qiime metadata tabulate --m-input-file temp_metadata.txt --m-input-file core-metrics-results_38807_rarefied/observed_features_vector.qza --m-input-file core-metrics-results_38807_rarefied/chao1_vector.qza --m-input-file core-metrics-results_38807_rarefied/shannon_vector.qza --m-input-file core-metrics-results_38807_rarefied/faith_pd_vector.qza --m-input-file core-metrics-results_38807_rarefied/pielou_e_vector.qza --m-input-file core-metrics-results_38807_rarefied/simpson_e_vector.qza --o-visualization exclude_nega_taxonomy_alpha_diversity.qzv

qiime tools view exclude_nega_taxonomy_alpha_diversity.qzv
# GUIで"Download metadata TSV file"をクリックしてtsvファイルに変換
#2.2.4 ASVのリードカウントテーブル
qiime tools export --input-path  core-metrics-results_38807_rarefied/rarefied_table.qza --output-path ./exclude_nega_asv_readcount_rarefied

biom convert -i exclude_nega_asv_readcount_rarefied/feature-table.biom -o exclude_nega_asv_readcount_rarefied.tsv --to-tsv

rm -r exclude_nega_asv_readcount_rarefied/ 
#2.2.5.1 種レベルのリードカウントテーブル
qiime taxa collapse --i-table core-metrics-results_38807_rarefied/rarefied_table.qza --i-taxonomy taxonomy-qiime.qza --p-level 7 --o-collapsed-table exclude_nega_collapsed_table_level7_rarefied.qza

qiime tools export --input-path  exclude_nega_collapsed_table_level7_rarefied.qza  --output-path ./exclude_nega_collapsed_table_level7_rarefied

biom convert -i exclude_nega_collapsed_table_level7_rarefied/feature-table.biom -o exclude_nega_collapsed_table_level7_rarefied.tsv --to-tsv

rm -r exclude_nega_collapsed_table_level7_rarefied/ 
#2.2.5.2 属レベルのリードカウントテーブル
qiime taxa collapse --i-table core-metrics-results_38807_rarefied/rarefied_table.qza --i-taxonomy taxonomy-qiime.qza --p-level 6 --o-collapsed-table exclude_nega_collapsed_table_level6_rarefied.qza

qiime tools export --input-path  exclude_nega_collapsed_table_level6_rarefied.qza  --output-path ./exclude_nega_collapsed_table_level6_rarefied

biom convert -i exclude_nega_collapsed_table_level6_rarefied/feature-table.biom -o exclude_nega_collapsed_table_level6_rarefied.tsv --to-tsv


# 相対値
qiime feature-table relative-frequency --i-table exclude_nega_collapsed_table_level6_rarefied.qza --o-relative-frequency-table  freq_exclude_nega_collapsed_table_level6_rarefied.qza --output-dir ./freq_exclude_nega_collapsed_table_level6_rarefied

qiime tools export --input-path  freq_exclude_nega_collapsed_table_level6_rarefied.qza  --output-path ./freq_exclude_nega_collapsed_table_level6_rarefied

biom convert -i ./freq_exclude_nega_collapsed_table_level6_rarefied/feature-table.biom -o freq_exclude_nega_collapsed_table_level6_rarefied.tsv --to-tsv
#2.2.6 PICRUSt2解析
# 代表配列をFASTA形式に変換
qiime tools export --input-path rep-seqs-qiime.qza --output-path rep-seqs-exported
# ASVのtableファイルをbiom形式に変換
qiime tools export --input-path core-metrics-results_38807_rarefied/rarefied_table.qza --output-path ./exported_asv


conda deactivate
conda activate picrust2

# KEGG Orthologyの予測
place_seqs.py -s rep-seqs-exported/dna-sequences.fasta -o picrust2_out_pipeline_rarefied/out.tre -p 16 \
--intermediate picrust2_out_pipeline_rarefied/intermediate/place_seqs

hsp.py -i 16S -t picrust2_out_pipeline_rarefied/out.tre -o picrust2_out_pipeline_rarefied/marker_predicted_and_nsti.tsv.gz -p 16 -n

hsp.py -i KO -t picrust2_out_pipeline_rarefied/out.tre -o picrust2_out_pipeline_rarefied/KO_predicted.tsv.gz -p 16

metagenome_pipeline.py -i picrust2_out_pipeline_rarefied/taxonomic_file.biom -m picrust2_out_pipeline_rarefied/marker_predicted_and_nsti.tsv.gz \
-f picrust2_out_pipeline_rarefied/KO_predicted.tsv.gz -o picrust2_out_pipeline_rarefied/KO_metagenome_out --strat_out

metagenome_pipeline.py -i exported_asv/feature-table.biom -m picrust2_out_pipeline_rarefied/marker_predicted_and_nsti.tsv.gz \
-f picrust2_out_pipeline_rarefied/KO_predicted.tsv.gz -o picrust2_out_pipeline_rarefied/KO_metagenome_out --strat_out

convert_table.py picrust2_out_pipeline_rarefied/KO_metagenome_out/pred_metagenome_contrib.tsv.gz \
-c contrib_to_legacy \
-o picrust2_out_pipeline_rarefied/KO_metagenome_out/pred_metagenome_contrib.legacy.tsv.gz

gzip -d picrust2_out_pipeline_rarefied/KO_metagenome_out/pred_metagenome_unstrat.tsv.gz

add_descriptions.py -i picrust2_out_pipeline_rarefied/KO_metagenome_out/pred_metagenome_unstrat.tsv -m KO \
-o picrust2_out_pipeline_rarefied/KO_metagenome_out/pred_metagenome_unstrat_descrip.tsv.gz

pathway_pipeline.py -i picrust2_out_pipeline_rarefied/KO_metagenome_out/pred_metagenome_unstrat.tsv \
--map ~/miniconda3/envs/picrust2/lib/python3.8/site-packages/picrust2/default_files/pathway_mapfiles/KEGG_pathways_to_KO.tsv -o picrust2_out_pipeline_rarefied/KEGG_pathways_out \
--no_regroup -p 16

gzip -d picrust2_out_pipeline_rarefied/KEGG_pathways_out/path_abun_unstrat.tsv.gz

rm -r exported_asv/
#3. 全てのデータ（希薄化しない）
#3.1 ASVのリードカウントテーブル
qiime tools export --input-path  exclude_nega_table-qiime.qza --output-path ./exclude_nega_asv_readcount

biom convert -i exclude_nega_asv_readcount/feature-table.biom -o exclude_nega_asv_readcount.tsv --to-tsv

rm -r exclude_nega_asv_readcount/ 
#3.2 種レベルのリードカウントテーブル
qiime taxa collapse --i-table exclude_nega_table-qiime.qza --i-taxonomy taxonomy-qiime.qza --p-level 7 --o-collapsed-table exclude_nega_collapsed_table_level7.qza

qiime tools export --input-path  exclude_nega_collapsed_table_level7.qza  --output-path ./exclude_nega_collapsed_table_level7

biom convert -i exclude_nega_collapsed_table_level7/feature-table.biom -o exclude_nega_collapsed_table_level7.tsv --to-tsv

rm -r exclude_nega_collapsed_table_level7/ 
#3.3 PICRUSt2解析
# ASVのtableファイルをbiom形式に変換
conda deactivate
conda activate qiime2-2022.2

qiime tools export --input-path exclude_nega_table-qiime.qza --output-path ./exported_asv


conda deactivate
conda activate picrust2

# KEGG Orthologyの予測
place_seqs.py -s rep-seqs-exported/dna-sequences.fasta -o picrust2_out_pipeline/out.tre -p 16 \
--intermediate picrust2_out_pipeline/intermediate/place_seqs

hsp.py -i 16S -t picrust2_out_pipeline/out.tre -o picrust2_out_pipeline/marker_predicted_and_nsti.tsv.gz -p 16 -n

hsp.py -i KO -t picrust2_out_pipeline/out.tre -o picrust2_out_pipeline/KO_predicted.tsv.gz -p 16

metagenome_pipeline.py -i picrust2_out_pipeline/taxonomic_file.biom -m picrust2_out_pipeline/marker_predicted_and_nsti.tsv.gz \
-f picrust2_out_pipeline/KO_predicted.tsv.gz -o picrust2_out_pipeline/KO_metagenome_out --strat_out

metagenome_pipeline.py -i exported_asv/feature-table.biom -m picrust2_out_pipeline/marker_predicted_and_nsti.tsv.gz \
-f picrust2_out_pipeline/KO_predicted.tsv.gz -o picrust2_out_pipeline/KO_metagenome_out --strat_out

convert_table.py picrust2_out_pipeline/KO_metagenome_out/pred_metagenome_contrib.tsv.gz \
-c contrib_to_legacy \
-o picrust2_out_pipeline/KO_metagenome_out/pred_metagenome_contrib.legacy.tsv.gz

gzip -d picrust2_out_pipeline/KO_metagenome_out/pred_metagenome_unstrat.tsv.gz

add_descriptions.py -i picrust2_out_pipeline/KO_metagenome_out/pred_metagenome_unstrat.tsv -m KO \
-o KO_metagenome_out/pred_metagenome_unstrat_descrip.tsv.gz

pathway_pipeline.py -i picrust2_out_pipeline/KO_metagenome_out/pred_metagenome_unstrat.tsv \
--map ~/miniconda3/envs/picrust2/lib/python3.8/site-packages/picrust2/default_files/pathway_mapfiles/KEGG_pathways_to_KO.tsv -o picrust2_out_pipeline/KEGG_pathways_out \
--no_regroup -p 16

gzip -d picrust2_out_pipeline/KEGG_pathways_out/path_abun_unstrat.tsv.gz

rm -r exported_asv/
#4.成果物ファイルを纏める
#4.1 希薄化成果物
m mv taxonomic_and_functional_alpha_diversity_table.tsv deliverable/kdir deliverable_rarefied

# 希薄化後成果物のディレクトリを作成して、そこにコピーする
cp ASV_table_rarefied.tsv taxonomy_table_level7_rarefied.tsv picrust2_out_pipeline_rarefied/KO_metagenome_out/pred_metagenome_unstrat.tsv picrust2_out_pipeline_rarefied/KEGG_pathways_out/path_abun_unstrat.tsv deliverable_rarefied/.
cd deliverable_rarefied

# 名前を変更する
mv path_abun_unstrat.tsv path_abun_unstrat_rarefied.tsv
mv pred_metagenome_unstrat.tsv pred_metagenome_unstrat_rarefied.tsv

# pythonを用いて、微生物とKOとPathwayの多様性のテーブルをマージする
python

import pandas as pd 

df_taxonomy_d = pd.read_table("exclude_nega_taxonomy_alpha_diversity.tsv", comment="#").set_index("id")

# 多様性指数のテーブルを作成する
# カラム名の変更
ASV_col = ["ASV_observed", "ASV_Chao1", "ASV_Shannon", "ASV_Faith_PD", "ASV_Pielou", "ASV_Simpson"]
df_taxonomy_d.columns = ASV_col
# Simpsonは消す
df_taxonomy_d = df_taxonomy_d.drop("ASV_Simpson", axis=1)
df_pathway_d = pd.read_table("KEGG_Pathway_alpha_diversity_table.tsv").set_index("Unnamed: 0")
df_ko_d = pd.read_table("KEGG_Orthology_alpha_diversity_table.tsv").set_index("Unnamed: 0")
df_pathway_d = df_pathway_d.drop(["path_abun_unstrat_rarefied_simpson", "path_abun_unstrat_rarefied_simpson_e"], axis=1)
df_ko_d = df_ko_d.drop(["pred_metagenome_unstrat_rarefied_simpson", "pred_metagenome_unstrat_rarefied_simpson_e"], axis=1)
Pathway_col = ["Pathway_observed", "Pathway_Chao1", "Pathway_Shannon", "Pathway_Pielou", "unweighted_PCI", "weighted_PCI", "Potential_compounds"]
KO_col = ["KO_observed", "KO_Chao1", "KO_Shannon", "KO_Pielou"]
df_pathway_d.columns = Pathway_col
df_ko_d.columns = KO_col
df_diversity = pd.concat([df_taxonomy_d, df_ko_d, df_pathway_d], axis=1)
df_diversity.to_csv("taxonomic_and_functional_alpha_diversity_table.tsv", sep="\t")

