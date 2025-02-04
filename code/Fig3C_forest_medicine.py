import pandas as pd
import numpy as np
from lifelines import CoxPHFitter

df_forest = pd.read_csv("path/to/sawada_medine_ASV.txt",sep="\t")

antibio_survey=df_forest[df_forest['antibiotics_survey_01'].isin([0,1])][['antibiotics_survey_01','PFSmonth','Pdevent']]
antibio_EDC=df_forest[df_forest['antibiotics_EDC'].isin(['0','1'])][['antibiotics_EDC','PFSmonth','Pdevent']]
PPI_survey=df_forest[df_forest['PPI'].isin(['0','1'])][['PPI','PFSmonth','Pdevent']]
PPI_EDC=df_forest[df_forest['PPI_EDC'].isin(['0','1'])][['PPI_EDC','PFSmonth','Pdevent']]
Acetaminophen=df_forest[df_forest['アセトアミノフェン'].isin(['0','1'])][['アセトアミノフェン','PFSmonth','Pdevent']]
Intestinal_regulator=df_forest[df_forest['整腸剤'].isin(['0','1'])][['整腸剤','PFSmonth','Pdevent']]
Steroid=df_forest[df_forest['steroid_EDC'].isin(['0','1'])][['steroid_EDC','PFSmonth','Pdevent']]

subgroup_ls = [antibio_survey,antibio_EDC,PPI_survey,PPI_EDC,Acetaminophen,Intestinal_regulator,Steroid]
subgroup_label_ls = ["Antibiotics Survey","Antibiotics EDC","PPI Survey","PPI EDC","Acetaminophen","Intestinal regulator","Steroid"]

df_forest_res = []
for i, s in zip(subgroup_ls, subgroup_label_ls):
    cph = CoxPHFitter()
    cph.fit(i,duration_col='PFSmonth', event_col='Pdevent')
    temp_line = [np.log(cph.hazard_ratios_).values[0], cph.variance_matrix_.values[0][0]]
    temp_count = i.iloc[:,0].value_counts()
    temp_per = str(round(temp_count[1]/(temp_count[0]+temp_count[1])*100,1))
    temp_line += [s,str(temp_count[1])+" ("+temp_per+")"]
    df_forest_res += [temp_line]

df_forest_table = pd.DataFrame(df_forest_res, columns=["yi" ,"vi", "subgroup", "patient"]).set_index("subgroup")
df_forest_table.to_csv("forest_out.txt", sep="\t")
