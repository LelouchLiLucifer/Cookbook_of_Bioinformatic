#变量赋值
sample="demo"
fq1="/home/data/t0302024/data/DN2104103236-1/210520_SEQ024_FP100002459TR_L01_SP2104280296/FP100002459TR_L01_91_1_part.fq.gz"
fq2="/home/data/t0302024/data/DN2104103236-1/210520_SEQ024_FP100002459TR_L01_SP2104280296/FP100002459TR_L01_91_2_part.fq.gz"	
outdir="/home/data/t0302024/demo/fastqc_out_dir"	
#转到outdir路径下
cd $outdir 
###在log文件中输出日期时间和提示信息
echo "$(date) bwa.sh started..."	
bwa_index=/home/data/t0302024/data/database/gatk-database/hg38.fa
###bwa比对
#使用bwa的mem比对，-t设置线程数为5，-M 表示将 shorter split hits 标记为次优，以兼容 Picard’s markDuplicates 软件。-R 设置完整的read group的头部为@RG\tID:${sample}\tPL:ILLUMINA\tLB:library\tSM:${sample}，设置ref.fq为${bwa_index}，将fq1和fq2作为paired reads进行比对（fq1 和 fq2 中的 i-th reads 组成一个read对 (a read pair)）
#使用samtools的view功能进行将sam和bam文件进行格式互换的操作，-S指定一个单一的输入文件格式，-b表示输出文件格式为bam，设置输出文件绝对路径为$outdir/${sample}.bam
bwa mem -M -t 5 -R "@RG\tID:${sample}\tPL:ILLUMINA\tLB:library\tSM:${sample}" ${bwa_index} $fq1 $fq2 | samtools view -S -b >$outdir/${sample}.bam 

##对bam文件排序
#使用samtools的sort功能对比对后的bam文件$outdir/${sample}.bam进行排序，默认按coordinate进行排序， @设置排序和压缩所用线程的数量为5，输出的文件结果为$outdir/${sample}_sorted.bam 
samtools sort -@ 5 $outdir/${sample}.bam > $outdir/${sample}_sorted.bam 
##已经使用bam文件生成了排序后的bam文件，后续操作用不到未排序的bam文件，删除掉未排序的bam文件
#强制删除$outdir/${sample}.bam 
rm -f $outdir/${sample}.bam && \
###在log文件中输出日期时间和提示信息
echo "$(date) bwa+sort finished"   
echo "$(date) mkdup.sh started..." 
##在BAM的FLAG信息中标记出来,以便在变异检测的时候识别到它们，并进行忽略
#对输入文件$outdir/${sample}_sorted.bam进行MarkDuplicates处理，识别重复的reads,O指定将标记的记录输出到文件$outdir/${sample}_sorted_dedup.bam中，M指定所生成的指示单端读取和成对读取的重复项数的指标文件$outdir/${sample}_marked_dup_metrics.txt ，--ASSUME_SORT_ORDER指定假设排序顺序为coordinate，设定验证严格性为SILENT(可以提高性能，其中可变长度的数据（读数、质量、标签）不需要被解码。),设置光学重复像素距离为2500(两个重复簇之间的最大偏移量，以便将其视为光学重复。默认值适用于Illumina平台的非模式化版本。对于模式化的流式细胞模型，2500是比较合适的。对于其他平台和模型，用户应该通过实验来找到最适合的方法)，CREATE_MD5_FILE创建生成文件的MD5文件
gatk MarkDuplicates -I $outdir/${sample}_sorted.bam -O $outdir/${sample}_sorted_dedup.bam -M $outdir/${sample}_marked_dup_metrics.txt --ASSUME_SORT_ORDER coordinate --VALIDATION_STRINGENCY SILENT --OPTICAL_DUPLICATE_PIXEL_DISTANCE 2500 --CREATE_MD5_FILE true && \  
#对标记重复后的bam文件创建索引文件
samtools index  $outdir/${sample}_sorted_dedup.bam
echo "$(date) mkdup.sh finished"

  
