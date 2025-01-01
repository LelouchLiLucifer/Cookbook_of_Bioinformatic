library(ggstream)
library(ggplot2)
library(RColorBrewer)
library(dplyr)
library(tidyverse)
setwd("E:/streamchart")
data1 <- read.csv("tax_count.G.norm.csv")
data2 <- data1[c(grep("Meth",colnames(data1)))]
data3 <- arrange(data2,desc(Meth_Pre001))[1:10,]
#平均值
d <- c(NULL)
for (i in 1:40) {
  e <- c(rep(i,5))
  d <- c(d,e)
  
}
group <- matrix(d,nrow = 10 ,byrow = TRUE)
f <- as.matrix(data.frame(data3)[,2:21])
g <- tapply(f,group,mean)
g2 <- matrix(g,nrow = 10,byrow = TRUE)
g2 <- as.data.frame(g2)
data3 <- cbind(data3[,1],g2)
colnames(data3) <- c("Meth_Sal_Name","Meth_Acq","Meth_Ext","Meth_Pre","Meth_Rein")

name <- data3$Meth_Sal_Name
pre <- colnames(data3[c(grep("Pre",colnames(data3)))])
acq <- colnames(data3[c(grep("Acq",colnames(data3)))])
ext <- colnames(data3[c(grep("Ext",colnames(data3)))])
rein <- colnames(data3[c(grep("Rein",colnames(data3)))])
time_list <- c(pre,acq,ext,rein)
df = data.frame()
for( i in 1:10){
  for (j in 1:4){
    df2 = data.frame(CPP_phase  = j,name = name[i],genus = data3[i,time_list[j]])
    df = rbind(df,df2)
  }
}
df$name <- factor(df$name,levels = unique(df$name))
windowsFonts(A = windowsFont("Arial"))
#绘图
p <- ggplot(df,aes(x = CPP_phase,y = genus,fill = name )) + geom_stream(extra_span=5,bw=0.55,type = c("ridge")) + theme_bw() +
  theme(panel.grid.major = element_line(colour=NA),
        panel.background = element_rect(fill = "transparent",colour = NA),
        plot.background = element_rect(fill = "transparent",colour = NA),
        panel.grid.minor = element_blank(),
        text = element_text(family="A",face="bold",size = 8),
        axis.text.x = element_text(angle=90, hjust=1, vjust=1)) +
scale_x_continuous(breaks = df$CPP_phase,labels = rep(time_list,times = 10)) +
  labs(fill="")
p