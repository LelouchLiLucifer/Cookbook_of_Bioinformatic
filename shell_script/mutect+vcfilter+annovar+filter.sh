sample=sample
sample_fsx_path=/path/to/sample
ref=/path/to/reffile
output_dir=/path/to/outputdir
outdir=/path/to/outputdir/annovar

echo `date` : start SelectVariants 
#####mutect-vcf过滤
# -Xmx来指定分配内存大小为5g，参考为{ref}，SelectVariants提取SNP单核苷酸多态性输出MC_calls.snps.vcf.gz
gatk --java-options '-Xmx5g' SelectVariants -R ${ref} -V ${sample_fsx_path}/filtered.vcf.gz -select-type SNP -O ${output_dir}/${sample}.MC_calls.snps.vcf.gz

# -Xmx来指定分配内存大小为5g，参考为{ref}，SelectVariants提取INDEL插入缺失标记MC_calls.snps.vcf.gz
gatk --java-options '-Xmx5g' SelectVariants -R ${ref} -V ${sample_fsx_path}/filtered.vcf.gz  -select-type INDEL -O ${output_dir}/${sample}.MC_calls.indels.vcf.gz

# VariantFiltration给${sample}.MC_calls.snps.vcf.gz加过滤注释，QualByDepth(QD): 变异位点可信度除以未过滤的非参考read数
#FisherStrand (FS): Fisher精确检验评估当前变异是strand bias的可能性，这个值在0-60间
#RMSMappingQuality (MQ): 所有样本中比对质量的平方根
#MappingQualityRankSumTest (MQRankSum): 根据REF和ALT的read的比对质量来评估可信度
#ReadPosRankSumTest (ReadPosRankSum) : 通过变异在read的位置来评估变异可信度，通常在read的两端的错误率比较高
#StrandOddsRatio (SOR) : 综合评估strand bias的可能性
#过滤标准有：不满足QD < 2.0的被注释为QD_2；不满足FS > 60.0的被注释为FS_60;不满足MQ < 40 的被注释为MQ_40;不满足MQRankSum < -12.5的被注释为MQRS_12.5；不满足ReadPosRankSum < -8.0的被注释为RPRS_8;不满足SOR > 3.0的被注释为SOR_3
gatk --java-options '-Xmx5g' VariantFiltration -R ${ref} -V ${output_dir}/${sample}.MC_calls.snps.vcf.gz --filter-expression "(vc.hasAttribute('QD')&&QD < 2.0)" --filter-name "QD_2"  --filter-expression "(vc.hasAttribute('FS')&&FS > 60.0)" --filter-name "FS_60" --filter-expression "(vc.hasAttribute('MQ')&&MQ < 40.0)" --filter-name "MQ_40" --filter-expression "(vc.hasAttribute('MQRankSum')&&MQRankSum < -12.5)" --filter-name "MQRS_12.5" --filter-expression "(vc.hasAttribute('ReadPosRankSum')&&ReadPosRankSum < -8.0)" --filter-name "RPRS_8" --filter-expression "(vc.hasAttribute('SOR')&&SOR > 3.0)" --filter-name "SOR_3"  -O ${output_dir}/${sample}.MC_calls.snps.filtered.vcf.gz

# 给MC_calls.indels.vcf.gz加过滤注释不满足QD < 2.0的被注释为QD_2；不满足FS >200.0的被注释为FS_200;不满足ReadPosRankSum < -20.0的被注释为RPRS_20;
gatk --java-options '-Xmx5g' VariantFiltration -R ${ref} -V ${output_dir}/${sample}.MC_calls.indels.vcf.gz --filter-expression "(vc.hasAttribute('QD')&&QD < 2.0)" --filter-name "QD_2" --filter-expression "(vc.hasAttribute('FS')&&FS > 200.0)" --filter-name "FS_200" --filter-expression "(vc.hasAttribute('ReadPosRankSum')&&ReadPosRankSum < -20.0)" --filter-name "RPRS_20"  -O ${output_dir}/${sample}.MC_calls.indels.filtered.vcf.gz
# MergeVcfs对相同样本数据集的变异结果进行合并，将${sample}.MC_calls.snps.filtered.vcf.gz以及${sample}.MC_calls.indels.filtered.vcf.gz合成文件${sample}.MC_calls.filtered.vcf.gz
gatk --java-options '-Xmx5g' MergeVcfs -I ${output_dir}/${sample}.MC_calls.snps.filtered.vcf.gz -I ${output_dir}/${sample}.MC_calls.indels.filtered.vcf.gz -O ${output_dir}/${sample}.MC_calls.filtered.vcf.gz

# SelectVariants提取出过滤中通过的数据，输出${sample}.MC_calls.filtered.PASS.vcf.gz
gatk --java-options '-Xmx5g' SelectVariants -R ${ref} -V ${output_dir}/${sample}.MC_calls.filtered.vcf.gz -O ${output_dir}/${sample}.MC_calls.filtered.PASS.vcf.gz  --exclude-filtered
#ls -l ${output_dir}/
echo `date` : hard-filter finished ...

rm -r ${output_dir}/${sample}.MC_calls.snps.vcf.gz  ${output_dir}/${sample}.MC_calls.snps.vcf.gz.tbi ${output_dir}/${sample}.MC_calls.indels.vcf.gz ${output_dir}/${sample}.MC_calls.indels.vcf.gz.tbi ${output_dir}/${sample}.MC_calls.snps.filtered.vcf.gz ${output_dir}/${sample}.MC_calls.snps.filtered.vcf.gz.tbi ${output_dir}/${sample}.MC_calls.indels.filtered.vcf.gz ${output_dir}/${sample}.MC_calls.indels.filtered.vcf.gz.tbi ${output_dir}/${sample}.MC_calls.filtered.vcf.gz ${output_dir}/${sample}.MC_calls.filtered.vcf.gz.tbi
#######annovar注释
echo `date` : start annovar ...
#对文件${sample}.HC_calls.filtered.vcf.gz进行注释，/home/data/t0302024/data/database/annovar-database为数据库路径，-buildver指定参考序列版本为hg38，输出文件为${sample}.somatic.SNP，-remove删掉程序运行过程中产生的中间文件，–protocol指定调用的数据库的名称，-operation：对应顺序的数据库的类型（g代表gene-based、r代表region-based、f代表filter-based），-nastring .表示缺省值用.表示，-vcfinput表示输如文件为vcf格式，polish表示对基因组进行修复

/home/data/t0302024/mlt/annovar/table_annovar.pl ${output_dir}/${sample}.MC_calls.filtered.PASS.vcf.gz  /home/data/t0302024/data/database/annovar-database -buildver hg38 -out ${output_dir}/${sample}.somatic.SNP -remove -protocol refGene,SAS.sites.2015_08,exac03,esp6500siv2_all,EAS.sites.2015_08,dbnsfp42a,cosmic70,clinvar_20220320,avsnp150,ALL.sites.2015_08,1000g2015aug_all -operation g,f,f,f,f,f,f,f,f,f,f -nastring . -vcfinput -polish
echo `date` : ... end annovar
echo `date` : start annovar_filter ...
#####annovar注释结果过滤
#将${sample}.somatic.SNP.hg38_multianno.txt的147列为"Otherinfo5"或"PASS"的输出到${sample}.SNP-01.txt，分隔符为“、t”
awk -F '\t' '$147 == "Otherinfo5" || $147 == "PASS" {print}' ${output_dir}/${sample}.somatic.SNP.hg38_multianno.txt > ${output_dir}/${sample}.SNP-01.txt
#进一步将12列为"ExAC_ALL"或小于等于0.01的输出${sample}.SNP-02.txt,分隔符为“、t”
awk -F '\t' '$12 == "ExAC_ALL" || $12<=0.01 {print}'  ${outdir}/${sample}.SNP-01.txt >${output_dir}/${sample}.SNP-02.txt
#进一步将137列为"500g2015aug_all"或小于等于0.01的输出${sample}.SNP-03.txt,分隔符为“、t”
awk -F '\t' '$137 == "500g2015aug_all" || $137<=0.01 {print}' ${outdir}/${sample}.SNP-02.txt >${outdir}/${sample}.SNP-03.txt
#进一步筛选
awk -F '\t' '$20 == "esp6500siv2_all" || $20<=0.01 {print}' ${outdir}/${sample}.SNP-03.txt >${outdir}/${sample}.SNP-04.txt
#进一步筛选
awk -F '\t' '$21 == "EAS.sites.2015_08" || $21<=0.01 {print}' ${outdir}/${sample}.SNP-04.txt > ${outdir}/${sample}.SNP-05.txt
#进一步筛选
awk -F '\t' '$136 == "ALL.sites.2015_08" || $136<=0.01 {print}' ${outdir}/${sample}.SNP-05.txt >${outdir}/${sample}.SNP-06.txt
#进一步将最后一列输出${outdir}/${sample}.SNP-06-NF.txt
awk -F '\t' '{print$NF}' ${outdir}/${sample}.SNP-06.txt >${outdir}/${sample}.SNP-06-NF.txt
#进一步将第三列输出${outdir}/${sample}.SNP-06-NF-01.txt,分隔符变为“，和：”
awk -F '[,:]' '{print$3}'  ${outdir}/${sample}.SNP-06-NF.txt >   ${outdir}/${sample}.SNP-06-NF-01.txt
#由 1 开始对所有输出的行数编号
cat -n ${outdir}/${sample}.SNP-06-NF-01.txt > ${outdir}/${sample}.SNP-06-NF-02.txt
#将第一列为1或最后一列为5的输出${sample}.SNP-06-NF-03.txt
awk -F '\t' '$1==1 || $NF > 5 {print}' ${outdir}/${sample}.SNP-06-NF-02.txt > ${outdir}/${sample}.SNP-06-NF-03.txt
#输出第一列到${sample}.line
awk -F '\t' '{print$1}' ${outdir}/${sample}.SNP-06-NF-03.txt > ${outdir}/${sample}.line
#按照${sample}.line中的值将${sample}.SNP-06.txt排序输出${sample}.SNP.filter-AD5-pre.txt;
cat ${outdir}/${sample}.line | while read i; do nl ${outdir}/${sample}.SNP-06.txt |sed -n "$i"p >> ${outdir}/${sample}.SNP.filter-AD5-pre.txt; done
#显示${sample}.SNP.filter-AD5-pre.txt2到152列输出${sample}.SNP.filter-AD5.txt
cut -f2-152 ${outdir}/${sample}.SNP.filter-AD5-pre.txt > ${outdir}/${sample}.SNP.filter-AD5.txt
ls -l annovar/
#cut -f3-153
rm -rf ${outdir}/${sample}.SNP-01.txt ${outdir}/${sample}.SNP-02.txt ${outdir}/${sample}.SNP-03.txt ${outdir}/${sample}.SNP-04.txt ${outdir}/${sample}.SNP-05.txt ${outdir}/${sample}.SNP-06.txt ${outdir}/${sample}.SNP-06-NF.txt ${outdir}/${sample}.SNP-06-NF-01.txt ${outdir}/${sample}.SNP-06-NF-02.txt ${outdir}/${sample}.SNP-06-NF-03.txt ${outdir}/${sample}.line ${outdir}/${sample}.SNP.filter-AD5-pre.txt
echo `date` : ... end annovar_filter ...
