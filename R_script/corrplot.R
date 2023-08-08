library(tidyverse)
library(corrplot)
library(ggplot2)
library(ggpubr)
getwd()
dat <- read.csv('dat.csv')
data <- cor (dat, method="pearson")
corrplot(data)
corrplot(data, method = "circle", 
         tl.col = "black", tl.cex = 1.0, tl.srt =100)



corrplot(data, method = "ellipse", 
         type = "upper",
         tl.col = "black", tl.cex = 0.8, tl.srt = 45
)
corrplot(data, method = "ellipse", type = "upper",
         tl.col = "black", tl.cex = 0.8, tl.srt = 45,tl.pos = "lt")
corrplot(data, method = "number", type = "lower",
         tl.col = "n", tl.cex = 0.8, tl.pos = "n",
         add = T)
corrplot(data, method = "pie", type = "upper",col = addcol(100), 
         tl.col = "black", tl.cex = 0.8, tl.srt = 45,
         tl.pos = "lt")
corrplot(data, method = "number", type = "lower",col = addcol(100), 
         tl.col = "n", tl.cex = 0.8, tl.pos = "n",
         add = T)

#以下部分函数名冲突存疑
testRes = cor.mtest(tf, method="pearson",conf.level = 0.95)
corrplot(data, method = "color", col = addcol(100), 
         tl.col = "black", tl.cex = 0.8, tl.srt = 45,tl.pos = "lt",
         p.mat = testRes$p, diag = T, type = 'upper',
         sig.level = c(0.001, 0.01, 0.05), pch.cex = 1.2,
         insig = 'label_sig', pch.col = 'grey20', order = 'AOE')
corrplot(data, method = "number", type = "lower",col = addcol(100), 
         tl.col = "n", tl.cex = 0.8, tl.pos = "n",order = 'AOE',
         add = T)
