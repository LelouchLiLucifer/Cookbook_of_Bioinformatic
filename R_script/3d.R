library(plot3D)
library(tidyverse)
library(RColorBrewer)
library(scales)
getwd()

data <- read.csv('dr.csv')
pmar <- par(mar = c(4.1, 3.1, 2.1, 6.1)) 
with(data, scatter3D(x = age, y = knowledge, z = drink,
                     pch = 21, cex = 1.5,col="black",bg="#F57446",
                     xlab = "age",
                     ylab = "knowledge",
                     zlab = "drink", 
                     ticktype = "detailed",bty = "f",box = TRUE,
                     theta = 30, phi = 20, d=3,
                     colkey = FALSE)
)

data = data %>% mutate(quan = ntile(sex,2))
colormap <- colorRampPalette(rev(brewer.pal(3,'RdYlGn')))(2)

with(data, scatter3D(x = age, y = knowledge, z = drink,
                     pch = 21, cex = rescale(data$health, c(.5, 4)),col="black",bg=colormap[data$sex],
                     xlab = "age",
                     ylab = "knowledge",
                     zlab = "drink", 
                     ticktype = "detailed",bty = "f",box = TRUE,
                     theta = 30, phi = 20, d=3,
                     colkey = FALSE))
breaks =1:6
legend("bottomright",title =  "disease",legend=breaks,pch=21,
       pt.cex=rescale(breaks, c(.5, 4)),y.intersp=1.6,
       pt.bg = colormap[3:8],bg="white",bty="n")

legend("bottomleft",title =  "sex",legend=c("m","f"),pch=21,
       pt.cex=3,y.intersp=1.6,
       pt.bg = colormap[1:2],bg="white",bty="n")