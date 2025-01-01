library(DESeq2)
library(ggplot2)
library(org.Mm.eg.db)
library(clusterProfiler)
setwd("E:/")
ncol <- max(count.fields("map_ko_uniref90.txt", sep = "\t"))
mapko <- read.table("map_ko_uniref90.txt", fill = TRUE, header = FALSE,sep = "\t",
                    col.names = paste0("V", seq_len(ncol)))
kopath <- read.table("KO_path.list", fill = TRUE, header = T,sep = "\t")
CountData <-  read.table("genefamilies_cpm_unstratified.tsv", header=T, sep="\t")
CountData <- CountData[3:283831,]
countData <- as.matrix(CountData[,2:41])
rownames(countData) <- unlist(CountData[,1])
countData <- countData[rowMeans(countData)>1,]  
condition <- factor(c(rep("Meth_Acq",5),rep("Meth_Ext",5),rep("Meth_Pre",5),rep("Meth_Rein",5),rep("Sal_Acq",5),rep("Sal_Ext",5),rep("Sal_Pre",5),rep("Sal_Rein",5)))
colData <- data.frame(row.names=colnames(countData), condition)
dds <- DESeqDataSetFromMatrix(countData = round(countData), colData = colData, design = ~ condition)
dds <- DESeq(dds)
#计算，设置padj为0.05
res= results(dds,alpha = 0.01)
#查看离散度估计的曲线图来检查模型与我们的数据的匹配性
plotDispEsts(dds)
dim(res)
summary(res)
diff_gene_deseq2 <- subset(res,padj < 0.05 & abs(log2FoldChange) >1)
dim(diff_gene_deseq2)
summary(diff_gene_deseq2)
write.csv(diff_gene_deseq2,file = "diff_gene_deseq2.csv")
diffgene <- read.csv("diff_gene_deseq2.csv")
kegg <- read.csv("kegg.csv")
ko2gene <- data.frame(kegg$ko,kegg$gene)
ko2name <- data.frame(kegg$ko,kegg$name)
gene_list<- diffgene[,1]
kk <- enricher(gene_list,TERM2GENE=ko2gene,TERM2NAME=ko2name,pvalueCutoff= 1,qvalueCutoff = 1)
head(kk)
kk[1:30]
dotplot(kk,showCategory = 25, title="The KEGG enrichment analysis of all DEGs")+
  scale_size(range=c(2, 12))+
  scale_x_discrete(labels=function(kk) str_wrap(kk,width = 25))
