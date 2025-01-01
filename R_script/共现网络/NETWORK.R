rm(list = ls())

library(igraph) 
library(psych)
library(WGCNA)
otu = read.csv("cecum.SB.0.01.csv",head=T,row.names=1) # 读取otu-sample矩阵，行为sample，列为otu
otu = t(otu)
# 计算OTU间两两相关系数矩阵
# 数据量小时可以用psych包corr.test求相关性矩阵，数据量大时，可应用WGCNA中corAndPvalue, 但p值需要借助其他函数矫正
occor = corr.test(otu,use="pairwise",method="spearman",adjust="fdr",alpha=.05)
occor.p = occor$p # 取相关性矩阵p值
write.table(occor.p,"cecumP.csv",row.names = T,col.names=T,sep=",")
occor.r = occor$r # 取相关性矩阵R值
write.table(occor.r,"cecumR.csv",row.names = T,col.names=T,sep=",")


# 确定物种间存在相互作用关系的阈值，将相关性R矩阵内不符合的数据转换为0
occor.r[occor.p>0.01|abs(occor.r)<0.9] = 0 
# 构建igraph对象
igraph = graph_from_adjacency_matrix(occor.r,mode="undirected",weighted=TRUE,diag=FALSE)# 构建igraph对象

# NOTE:可以设置weighted=NULL,但是此时要注意此函数只能识别相互作用矩阵内正整数，所以应用前请确保矩阵正确。
# 可以按下面命令转换数据
# occor.r[occor.r!=0] = 1
# igraph = graph_from_adjacency_matrix(occor.r,mode="undirected",weighted=NULL,diag=FALSE)

# remove isolated nodes，即去掉和所有otu均无相关性的otu 可省略，是否去掉孤立顶点，根据自己实验而定
#bad.vs = V(igraph)[degree(igraph) == 0]
#igraph = delete.vertices(igraph, bad.vs)

igraph.weight = E(igraph)$weight# 将igraph weight属性赋值到igraph.weight
E(igraph)$weight = NA# 做图前去掉igraph的weight权重，因为做图时某些layout会受到其影响

# 简单出图
# 设定随机种子数，后续出图都从同一随机种子数出发，保证前后出图形状相对应
set.seed(123)
plot(igraph,layout=layout.fruchterman.reingold,vertex.frame.color=NA,vertex.label=NA,edge.width=1,
     vertex.size=5,edge.lty=1,edge.curved=TRUE,margin=c(0,0,0,0))
# 按正负相关设置边颜色
sum(igraph.weight>0)# number of postive correlation
sum(igraph.weight<0)# number of negative correlation
# set edge color，postive correlation 设定为red, negative correlation设定为blue#228B22
E.color = igraph.weight
E.color = ifelse(E.color>0, "#3FAB5C",ifelse(E.color<0, "#8C00BF","grey"))
E(igraph)$color = as.character(E.color)

#按相关性设置边宽度
# 可以设定edge的宽 度set edge width，例如将相关系数与edge width关联
#E(igraph)$width = abs(igraph.weight)*4
# 改变edge宽度后出图
#set.seed(123)
#plot(igraph,main="Co-occurrence network",vertex.frame.color=NA,vertex.label=NA,vertex.size=5,edge.lty=1,edge.curved=TRUE,margin=c(0,0,0,0))

#设置点的颜色和大小属性对应物种和丰度
# 添加OTU注释信息，如分类单元和丰度
# 另外可以设置vertices size, vertices color来表征更多维度的数据
otu_pro = read.csv("cecumnode.csv",head=T,row.names=1)
# set vertices size
igraph.size = otu_pro[V(igraph)$name,] # 筛选对应OTU属性
igraph.size1 = log((igraph.size$abundance)/50)
V(igraph)$size = igraph.size1
#出图，调整node大小
set.seed(123)
plot(igraph,vertex.frame.color="black",vertex.label=NA,vertex.color = "#BEBEBE",
     edge.lty=1,edge.curved=FALSE,edge.width = 1,margin=c(0,0,0,0))

# set vertices color
igraph.col = otu_pro[V(igraph)$name,]
igraph.col$phylum = as.factor(igraph.col$phylum)
levels(igraph.col$phylum)
levels(igraph.col$phylum) = c("#FFD684","#3364B3","#BA9BC9","#ED977B","#AEC78D") # 直接修改levles可以连值全部对应替换
V(igraph)$color = as.character(igraph.col$phylum)
V(igraph)$shape = "circle"

set.seed(123)
plot(igraph,vertex.label=NA,
     edge.lty=1,edge.curved=T,edge.width = 0.25,margin=c(0,0,0,0))

#将图片保存成PDF格式#

##########################################不做##########
#按模块着色
# 模块性 modularity
fc = cluster_fast_greedy(igraph,weights =NULL)# cluster_walktrap cluster_edge_betweenness, cluster_fast_greedy, cluster_spinglass
modularity = modularity(igraph,membership(fc))
# 按照模块为节点配色
comps = membership(fc)
colbar = rainbow(max(comps))
V(igraph)$color = colbar[comps]

set.seed(123)
plot(igraph,vertex.frame.color=NA,vertex.label=NA,
     edge.lty=1,edge.curved=TRUE,margin=c(0,0,0,0))
##########################################不做##########


# network property
# 边数量 The size of the graph (number of edges)
num.edges = length(E(igraph)) # length(curve_multiple(igraph))
num.edges

# 顶点数量 Order (number of vertices) of a graph
# remove isolated nodes，即去掉和所有otu均无相关性的otu 可省略，是否去掉孤立顶点，根据自己实验而定
bad.vs = V(igraph)[degree(igraph) == 0]
igraph2 = delete.vertices(igraph, bad.vs)
num.vertices = length(V(igraph2))# length(diversity(igraph, weights = NULL, vids = V(igraph)))
num.vertices
write.table(degree(igraph),"cecumD.csv",row.names = T,col.names=T,sep=",")
# 连接数(connectance) 网络中物种之间实际发生的相互作用数之和（连接数之和）占总的潜在相互作用数（连接数）的比例，可以反映网络的复杂程度
connectance = edge_density(igraph,loops=FALSE)# 同 graph.density;loops如果为TRUE,允许自身环（self loops即A--A或B--B）的存在
connectance
# 平均度(Average degree)
average.degree = mean(igraph::degree(igraph))# 或者为2M/N,其中M 和N 分别表示网络的边数和节点数。
average.degree
# 平均路径长度(Average path length)
average.path.length = average.path.length(igraph) # 同mean_distance(igraph) # mean_distance calculates the average path length in a graph
average.path.length
# 直径(Diameter)
diameter = diameter(igraph, directed = FALSE, unconnected = TRUE, weights = NULL)
diameter
# 群连通度 edge connectivity / group adhesion
edge.connectivity = edge_connectivity(igraph)
edge.connectivity
# 聚集系数(Clustering coefficient)：分局域聚类系数和全局聚集系数，是反映网络中节点的紧密关系的参数，也称为传递性。整个网络的全局聚集系数C表征了整个网络的平均的“成簇性质”。
clustering.coefficient = transitivity(igraph)
clustering.coefficient
no.clusters = no.clusters(igraph)
no.clusters
# 介数中心性(Betweenness centralization)
centralization.betweenness = centralization.betweenness(igraph)$centralization
centralization.betweenness
# 度中心性(Degree centralization)
centralization.degree = centralization.degree(igraph)$centralization
centralization.degree


