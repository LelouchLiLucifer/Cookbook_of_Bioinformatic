#该脚本用于Linux下提取某一文件夹下所有文件的名称
#!/bin/bash

path=$1
files=$(ls $path)
for filesname in $files
do
    echo $filesname >> filesname.txt
done
#文件名将被打印到filesname.txt文件中