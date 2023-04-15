#安装一个新的R包可以使用 install.packages() 函数：
#注意使用的标点符号均为英文标点
#从 CRAN 网站上获取包，以ggplot2这个包为例
install.packages("ggplot2")
#如果从外网获取包速度较慢的话，可以试试使用国内镜像，以使用清华源进行安装为例：
install.packages("ggplot2", repos = "https://mirrors.ustc.edu.cn/CRAN/")
#有时候我们想要的包可能不在CRAN网站上，这时候可以试试Bioconductor或者Github上 
#使用Bioconductor 安装：
install.packages("BiocManager")
library("BiocManager")
BiocManager::install("R包名")
#使用GitHub安装：
install.packages("devtools")
library(devtools)
install_github("库名/R包名")
#本地安装R包（可以解决网站上的R包被下架的情况）
#在CRAN网站的存档里找到需要的R包并下载到本地，网址：https://cran.r-project.org/src/contrib/Archive/
install.packages("下载路径/R包名", repos = NULL, type = "source")
#或者你也可以这样
package_url = "下载地址"
install.packages(package_url, repos = NULL, type = "source")

#安装的包需要每次先载入 R 编译环境中才可以使用，格式如下：
library("R包名")
#一些提高效率的小技巧
#安装多个R包
packages = c("包名1","包名2","包名3"..."包名n")
install.packages(packages)
#载入多个R包
inst = lapply(packages,library,character.only = TRUE)
