library(stats)
getwd()

data <- read.csv("dr.csv")
ta <- xtabs(~diease+ drink,data = data)
ta
kruskal.test(diease~drink,data = ta)
chisq.test(ta)