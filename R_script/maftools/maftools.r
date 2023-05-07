#文档：https://www.bioconductor.org/packages/devel/bioc/vignettes/maftools/inst/doc/maftools.html
library(maftools)
laml <- annovarToMaf(annovar = "D:\\2021-2\\test\\sum.somatic.SNP.txt", 
                        refBuild = 'hg38',
                        tsbCol = 'Tumor_Sample_Barcode', 
                        table = 'refGene',
                        MAFobj = T)
plotmafSummary(maf = laml,rmOutlier = TRUE, addStat = 'median', dashboard = TRUE, titvRaw = FALSE)
write.table(laml@data, file="D:\\2021-2\\test\\maf.txt",sep = '\t')
oncoplot(maf = laml, top = 10)
oncoplot(maf = laml, top = 30)##看前三十
driverGene.file <- read.table("D:\\2021-2\\lungcancer\\Double_nodules\\IntOGen-DriverGenes_LUAD.tsv",header = TRUE)##需要去IntOGen网站下载所研究的癌的tsv，这里以LUAD为例
##网站链接：https://www.intogen.org/search
drive_genes = driverGene.file $Symbol
oncoplot(
  maf = laml,
  genes = drive_genes,
  sampleOrder=sampeOrder
)
