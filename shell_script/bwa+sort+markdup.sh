sample=$1
fq1=$2
fq2=$3 	
outdir=$4	
cd $outdir 
###在log文件中输出日期时间和提示信息
echo "$(date) bwa.sh started..."	
bwa_index=/path/hg38.fa
###bwa比对
bwa mem -M -t 5 -R "@RG\tID:${sample}\tPL:ILLUMINA\tLB:library\tSM:${sample}" ${bwa_index} $fq1 $fq2 | samtools view -S -b >$outdir/${sample}.bam 

##对bam文件排序
samtools sort -@ 5 $outdir/${sample}.bam > $outdir/${sample}_sorted.bam 
##已经使用bam文件生成了排序后的bam文件，后续操作用不到未排序的bam文件，删除掉未排序的bam文件
rm- f $outdir/${sample}.bam   
###在log文件中输出日期时间和提示信息
echo "$(date) bwa+sort finished"   
echo "$(date) mkdup.sh started..." 
##在BAM的FLAG信息中标记出来,以便在变异检测的时候识别到它们，并进行忽略
${gatk}  MarkDuplicates -I $outdir/${sample}_sorted.bam -M $outdir/${sample}_marked_dup_metrics.txt -O $outdir/${sample}_sorted_dedup.bam  --ASSUME_SORT_ORDER "coordinate" --VALIDATION_STRINGENCYSILENT --OPTICAL_DUPLICATE_PIXEL_DISTANCE 2500 --CREATE_MD5_FILE true   && \  
#对标记重复后的bam文件创建索引文件
${samtools} index  $outdir/${sample}_sorted_dedup.bam
echo "$(date) mkdup.sh finished"

  
