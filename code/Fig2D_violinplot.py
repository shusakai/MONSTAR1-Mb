# load library
import math
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import statistics
from scipy import stats
import os
from skbio.stats.composition import closure


def to_proportion_table(df):
    return pd.DataFrame(closure(df), index=df.index, columns=df.columns)
    

# read the microbiota data
def up_taxonomy_level(df):
    '''
    df: pd.DataFrame
    '''
    df_out = df.copy()
    df_out.columns = [";".join(i.split(";")[:-1]) for i in df.columns]

    df_out = df_out.T.reset_index().groupby("index").sum().T
    df_out.columns.name = "Taxonomy"
    
    return df_out


# genus
df_taxonomy = pd.read_table("path/to/level7.tsv")
df_taxonomy = df_taxonomy.rename(columns = {"#OTU ID": "Taxonomy"})
df_taxonomy = df_taxonomy.set_index("Taxonomy").T.reset_index().rename(columns = {"index": "#SampleID"}).set_index("#SampleID")
df_taxonomy_s = df_taxonomy
df_taxonomy_g = up_taxonomy_level(df_taxonomy_s)
df_taxonomy_g = df_taxonomy_g.reset_index()


# Extract top 24 genera from Atarashi et al. 2018
oral_ls = list(set([i.split(" ")[0] for i in pd.read_table("path/to/oral_bactaria_top24_atarashi_et_al.txt", header=None)[0]]))


# conversion
df_taxonomy_g = df_taxonomy_g.set_index("#SampleID")
df_taxonomy_g_comp = df_taxonomy_g.loc[[i for i in df_taxonomy_g.T.columns if df_taxonomy_g.T[i].sum() != 0], :]
df_taxonomy_g_comp = to_proportion_table(df_taxonomy_g_comp)

# calculation of oral bacteria proportion
df_oral_sum = pd.DataFrame(
    df_taxonomy_g_comp.loc[:, [i for i in df_taxonomy_g_comp.columns if i.split(";")[-1][3:] in oral_ls]].sum(axis=1), 
    columns=["oral_proportion"]
)

# read metadata of cohort1
df_metadata_cohort1 = pd.read_table("path/to/metadata_landscape_20220715.txt", index_col=0)

# annotation of oral bacteria proportion
df_metadata_cohort1 = pd.merge(df_metadata_cohort1, df_oral_sum, left_on="#SampleID", right_index=True, how="left")

# translate the name of cancer type
df_metadata_cohort1.癌種 = df_metadata_cohort1.癌種.replace(
    {"胃癌": "Gastric cancer", 
     "食道癌": "Esophageal cancer", 
     "腎盂・尿管・膀胱癌": "Urothelial cancer", 
     "頭頸部癌": "Head and neck cancer", 
     "乳癌": "Breast cancer", 
     "腎細胞癌": "Renal cell carcinoma", 
     "膵癌": "Pancreatic cancer", 
     "結腸・直腸癌": "Colorectal cancer", 
     "胆道癌": "Biliary tract cancer", 
     "卵巣癌・卵管癌・腹膜癌": "Ovarian cancer", 
     "前立腺癌": "Prostate cancer", 
     "悪性黒色腫": "Malignant melanoma", 
     "肝細胞癌": "Hepatocellular carcinoma", 
     "子宮体癌": "Endometrial cancer", 
     "消化器原発神経内分泌腫瘍/癌": "NET"
    }
)

# extract cancer more of 10 sample
cancer_type = df_metadata_cohort1.癌種.value_counts()[df_metadata_cohort1.癌種.value_counts() > 10].index.tolist()

# create labels
temp = df_metadata_cohort1.癌種.value_counts().index + " (N=" + df_metadata_cohort1.癌種.value_counts().astype(str).values + ")"
df_metadata_cohort1.cancer_type_label = df_metadata_cohort1.癌種.replace(
    {i.split(" (")[0]: i for i in temp.tolist()}
)

# list of upper GI cancer
uppergi = [
    'Pancreatic cancer',
    'Biliary tract cancer',
    'Gastric cancer',
    'Hepatocellular carcinoma'
]

df_metadata_cohort1["cancer_type_label"] = df_metadata_cohort1.cancer_type_label

# create labels
df_metadata_cohort1["cancer_n"] = [int(i.split(" (N=")[-1][:-1]) for i in df_metadata_cohort1.cancer_type_label]
df_metadata_cohort1 = df_metadata_cohort1.sort_values("cancer_n", ascending=False)


# add to label
for i in df_metadata_cohort1.index:
    if df_metadata_cohort1.loc[i, "癌種"] in uppergi:
        df_metadata_cohort1.loc[i, "upper-GI"] = "Upper-GI cancer (N=296)"
        
    else:
        df_metadata_cohort1.loc[i, "upper-GI"] = "Non-upper-GI cancer (N=512)"

# count each group
df_metadata_cohort1["upper-GI"].value_counts()

# Plot
fig, ax = plt.subplots(1, 4,  figsize=(17, 7), 
                      gridspec_kw=dict(width_ratios=[1, 4, 1, 10], height_ratios=[1], wspace=0.1), tight_layout=True)

# label rotation
fig.autofmt_xdate()
sns.violinplot(x=df_metadata_cohort1[df_metadata_cohort1["upper-GI"] == "Upper-GI cancer (N=296)"]["upper-GI"].tolist(), 
                   y=df_metadata_cohort1[df_metadata_cohort1["upper-GI"] == "Upper-GI cancer (N=296)"]["oral_proportion"].tolist(), ax=ax[0])

# ylim
ax[0].set_ylim(-0.1, 0.7)

sns.violinplot(x=df_metadata_cohort1[df_metadata_cohort1.癌種.isin(
                        set(uppergi)
                    )].cancer_type_label.tolist(), 
                   y=df_metadata_cohort1[df_metadata_cohort1.癌種.isin(
                       set(uppergi)
                   )]["oral_proportion"].tolist(), ax=ax[1], color="white"
)
# ylim
ax[1].set_ylim(-0.1, 0.7)

sns.violinplot(x=df_metadata_cohort1[df_metadata_cohort1["upper-GI"] == "Non-upper-GI cancer (N=512)"]["upper-GI"].tolist(), 
                   y=df_metadata_cohort1[df_metadata_cohort1["upper-GI"] == "Non-upper-GI cancer (N=512)"]["oral_proportion"].tolist(), ax=ax[2]
)
# ylim
ax[2].set_ylim(-0.1, 0.7)

sns.violinplot(x=df_metadata_cohort1[df_metadata_cohort1.癌種.isin(
                        set(cancer_type) - set(uppergi)
                    )].cancer_type_label.tolist(), 
                   y=df_metadata_cohort1[df_metadata_cohort1.癌種.isin(
                       set(cancer_type) - set(uppergi)
                   )]["oral_proportion"].tolist(), ax=ax[3], color="white"
)
# ylim
ax[3].set_ylim(-0.1, 0.7)

# remove ticklabels
ax[3].set_yticklabels([])
ax[2].set_yticklabels([])
ax[1].set_yticklabels([])

#plt.tight_layout()
fig.subplots_adjust(bottom=0.43, left=0.2)

# save
plt.savefig(f"path/to/Fig2D.png", dpi=500)