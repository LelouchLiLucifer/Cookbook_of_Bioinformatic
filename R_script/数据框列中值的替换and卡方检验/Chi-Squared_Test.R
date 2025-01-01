setwd("输入你的文件路径")
data <- read.table("输入你的文件路径\\data.csv",
                 header = TRUE,row.names = "序号",sep = ",")
# 创建睡眠质量标签向量
score_labels <- c("Excellent", "Good", "Normal", "Poor")

# 使用cut()函数对"总分"列进行处理，生成新列"睡眠质量_处理后"
data$睡眠质量_处理后 <- cut(data$总分, breaks = c(0, 5, 10, 15, 21),
                     labels = score_labels, include.lowest = TRUE)
df <- data.frame(data$睡眠质量_处理)

data$平均学习时间_处理后 <- ifelse(data$平均学习时间 < 3.5, 1,
                          ifelse(data$平均学习时间 < 7, 2,
                                 ifelse(data$平均学习时间 < 10.5, 3,
                                        ifelse(data$平均学习时间 < 14, 4, NA))))
df <- cbind(df,data$平均学习时间_处理后,data$X11.您睡前使用手机的时间约为)
# 创建新的列名向量
new_column_names <- c("睡眠质量", "平均学习时间", "屏幕时间")

# 设置新的列名
colnames(df) <- new_column_names
#构建联表
table_1 <- xtabs(~平均学习时间 + 睡眠质量,data = df)
#计算卡方
chisq.test(table_1)
#处理方法同table_1
table_2 <- xtabs(~屏幕时间 + 睡眠质量,data = df)
chisq.test(table_2)
