library(vegan)
library(ggplot2)
library(plyr)
setwd("D:\\demo\\R\\R4\\190122-R的vegan包进行微生物群落主坐标分析（PCoA）及ggplot2作图示例\190122-R的vegan包进行微生物群落主坐标分析（PCoA）及ggplot2作图示例")
##读入文件
#OTU 丰度表
otu <- read.delim('otu_table.txt', row.names = 1, sep = '\t', stringsAsFactors = F, check.names = F)
otu <- data.frame(t(otu))
#或者现有的距离矩阵
dis <- read.delim('bray.txt', row.names = 1, sep = '\t', stringsAsFactors = F, check.names = F)

#样本分组文件
group <- read.delim('group.txt', sep = '\t', stringsAsFactors = F)

##PCoA 排序
#排序（基于 OTU 丰度表）
distance <- vegdist(otu, method = 'bray')
pcoa <- cmdscale(distance, k = (nrow(otu) - 1), eig = T)
#或者（基于现有的距离矩阵）
pcoa <- cmdscale(as.dist(dis), k = (nrow(dis) - 1), eig = T)

#可简要查看结果
ordiplot(scores(pcoa)[ ,c(1, 2)], type = 't')
#或者查看排序简要
summary(pcoa)

#查看主要排序轴的特征值和各样本在各排序轴中的坐标值
pcoa$eig
point <- data.frame(pcoa$point)

#可使用 wascores() 计算物种坐标
species <- wascores(pcoa$points[,1:2], otu)

#对于上述计算得到的样本间距离 distance，可转换为矩阵格式后输出，例如输出为 csv 格式
write.csv(as.matrix(distance), 'distance.csv', quote = F)
#可将样本坐标转化为数据框后导出，例如导出为 csv 格式
write.csv(point, 'pcoa.sample.csv')
#可将物种坐标转化为数据框后导出，例如导出为 csv 格式
write.csv(species, 'pcoa.otu.csv')

##ggplot2 作图

#坐标轴解释量（前两轴）
pcoa_eig <- (pcoa$eig)[1:2] / sum(pcoa$eig)

#提取样本点坐标（前两轴）
sample_site <- data.frame({pcoa$point})[1:2]
sample_site$names <- rownames(sample_site)
names(sample_site)[1:2] <- c('PCoA1', 'PCoA2')

#为样本点坐标添加分组信息
sample_site <- merge(sample_site, group, by = 'names', all.x = T)
#可选输出，例如输出为 csv 格式
write.csv(sample_site, 'sample_site.csv', quote = F)

#使用 ggplot2 绘制 PCoA 排序图
sample_site$site <- factor(sample_site$site, levels = c('A', 'B', 'C', 'D'))
sample_site$deal <- factor(sample_site$deal, levels = c('low', 'high'))
sample_site$time <- factor(sample_site$time, levels = c('1', '2', '3', '4'))
group_border <- ddply(sample_site, 'site', function(df) df[chull(df[[2]], df[[3]]), ]) #注：group_border 作为下文 geom_polygon() 的做图数据使用

pcoa_plot <- ggplot(sample_site, aes(PCoA1, PCoA2, group = site)) +
theme(panel.grid = element_line(color = 'gray', linetype = 2, size = 0.1), panel.background = element_rect(color = 'black', fill = 'transparent'), legend.key = element_rect(fill = 'transparent')) + #去掉背景框
geom_vline(xintercept = 0, color = 'gray', size = 0.4) + 
geom_hline(yintercept = 0, color = 'gray', size = 0.4) +
geom_polygon(data = group_border, aes(fill = site)) + #绘制多边形区域
geom_point(aes(color = time, shape = deal), size = 1.5, alpha = 0.8) + #可在这里修改点的透明度、大小
scale_shape_manual(values = c(17, 16)) + #可在这里修改点的形状
scale_color_manual(values = c('yellow', 'orange', 'red', 'red4')) + #可在这里修改点的颜色
scale_fill_manual(values = c('#C673FF2E', '#73D5FF2E', '#49C35A2E', '#FF985C2E')) + #可在这里修改区块的颜色
guides(fill = guide_legend(order = 1), shape = guide_legend(order = 2), color = guide_legend(order = 3)) + #设置图例展示顺序
labs(x = paste('PCoA axis1: ', round(100 * pcoa_eig[1], 2), '%'), y = paste('PCoA axis2: ', round(100 * pcoa_eig[2], 2), '%')) +
#可通过修改下面四句中的点坐标、大小、颜色等，修改“A、B、C、D”标签
annotate('text', label = 'A', x = -0.31, y = -0.15, size = 5, colour = '#C673FF') +
annotate('text', label = 'B', x = -0.1, y = 0.3, size = 5, colour = '#73D5FF') +
annotate('text', label = 'C', x = 0.1, y = 0.15, size = 5, colour = '#49C35A') +
annotate('text', label = 'D', x = 0.35, y = 0, size = 5, colour = '#FF985C')

#ggsave('PCoA.pdf', pcoa_plot, width = 6, height = 5)
ggsave('PCoA.png', pcoa_plot, width = 6, height = 5)
