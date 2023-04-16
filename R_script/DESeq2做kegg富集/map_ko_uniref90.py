import pandas
import pandas as pd
# 创建uniref和k的关系字典
uniref = open("map_ko_uniref90.txt")
txt = uniref.readlines()
dict_uniref90 = {}
for i in txt:
    k = i.strip("\n").split("\t")
    for j in range(1,len(k)):
        dict_uniref90[k[j]] = k[0]
# # 创建KO_path字典，转化为ko
ko_path = pandas.read_table("KO_path.list")
ko2name = pd.DataFrame({"ko":[],"name":[]})
for i in range(len(ko_path)):
    try:
        str = ko_path["pathway"][i]
        name = str.split("[")[0]
        ko = str.strip("]").split(":")[1]
        ko2name = ko2name.append(pd.DataFrame({ "ko":[ko],"name":[name]}), ignore_index=True)
    except:
        continue
ko2name.drop_duplicates('ko',inplace = True)

ko2name.to_csv('ko2name.csv', index=False)
#转化kegg 这个是背景基因
data = pd.read_table("genefamilies_cpm_unstratified.tsv")
UniRef90 = data['Gene Family']

gene2ko = pd.DataFrame({"ko":[],"gene":[]})
for i in UniRef90:
    try:
        K = dict_uniref90[i]
        map = ko_path[ko_path['KO']==K]['pathway'].tolist()
        for j in map:
            ko = j.strip("]").split(":")[1]
            gene2ko = gene2ko.append(pd.DataFrame({ "gene":[i],"ko":[ko]}), ignore_index=True)
    except:
        continue
gene2ko.to_csv('kegg.csv', index=False)




