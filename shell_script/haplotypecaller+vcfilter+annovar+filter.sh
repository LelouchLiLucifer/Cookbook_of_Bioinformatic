sample=sample
sample_fsx_path=/path/to/sample
ref=/path/to/ref_file
output_dir=/path/to/outputdir
outdir=/path/to/outputdir/annovar
#gatk=/path/to/gatk
#annovar=/path/to/annovar

######haplotypecaller-vcf 过滤
echo `date` : hard-filter started !!!!!!!!!!!!!!!!!!!!!!!!!!!!...
#为${sample}.germline.vcf.gz添加过滤标记不满足QD < 2.0的被注释为QD_2；不满足FS > 60.0的被注释为FS_60;不满足MQ < 40 的被注释为MQ_40;不满足MQRankSum < -12.5的被注释为MQRS_12.5；不满足ReadPosRankSum < -8.0的被注释为RPRS_8;不满足SOR > 3.0的被注释为SOR_3
${gatk} --java-options '-Xmx5g' VariantFiltration -V ${sample_fsx_path}/${sample}_HaplotypeCaller_out.vcf.gz  -O ${output_dir}/${sample}.HC_calls.filtered.vcf.gz  -filter "(vc.hasAttribute('QD')&&QD < 2.0)" --filter-name "QD2" -filter "(vc.hasAttribute('FS')&&FS > 60.0)" --filter-name "FS60" -filter "(vc.hasAttribute('SOR')&&SOR > 3.0)" --filter-name "SOR3"  -filter "(vc.hasAttribute('ReadPosRankSum')&&ReadPosRankSum < -8.0)" --filter-name "ReadPosRankSum-8" -filter "QUAL < 30.0" --filter-name "QUAL30"

ls -l annovar/
echo `date` : hard-filter finished ...

#######annovar注释
echo `date` : start annovar ...
#对文件${sample}.HC_calls.filtered.vcf.gz进行注释，/home/data/t0302024/data/database/annovar-database为数据库路径，-buildver指定参考序列版本为hg38，输出文件为${sample}.somatic.SNP，-remove删掉程序运行过程中产生的中间文件，–protocol指定调用的数据库的名称，-operation：对应顺序的数据库的类型（g代表gene-based、r代表region-based、f代表filter-based），-nastring .表示缺省值用.表示，-vcfinput表示输入文件为vcf格式，polish表示对基因组进行修复
${annovar} ${output_dir}/${sample}.HC_calls.filtered.vcf.gz /home/ynwang/biosoft/annovar/humandb/  -buildver hg38 -out ${output_dir}/${sample}.germline -remove -protocol refGene,exac03,avsnp150,dbnsfp35a,1000g2015aug_all,esp6500siv2_all,clinvar_20210501,ALL.sites.2015_08,EAS.sites.2015_08,cosmic70 -operation g,f,f,f,f,f,f,f,f,f -nastring . -vcfinput -polish

ls -l ${outdir}/
#将${sample}.germline.hg38_multianno.txt第5列值为Alt或值非<NON_REF>的行输出到${sample}.germline.txt
awk -F '\t' '$5 == "Alt" || $5!==<NON_REF> {print}'  ${output_dir}/${sample}.germline.hg38_multianno.txt  >${outdir}/${sample}.germline.txt

echo `date` : ... end annovar
#########过滤annovar注释文件
echo `date` : start annovar_filter ...
#逐步按照条件过滤
#将{sample}.germline.txt 的12列为"ExAC_ALL"或小于等于0.01的输出到${outdir}/${sample}.SNP-02.txt，分隔符为“、t”
awk -F '\t' '$12 == "ExAC_ALL" || $12<=0.01 {print}'  ${outdir}/${sample}.germline.txt  >${outdir}/${sample}.SNP-02.txt
awk -F '\t' '$137 == "1000g2015aug_all" || $137<=0.01 {print}' ${outdir}/${sample}.SNP-02.txt >${outdir}/${sample}.SNP-03.txt
awk -F '\t' '$20 == "esp6500siv2_all" || $20<=0.01 {print}' ${outdir}/${sample}.SNP-03.txt >${outdir}/${sample}.SNP-04.txt
awk -F '\t' '$21 == "EAS.sites.2015_08" || $21<=0.01 {print}' ${outdir}/${sample}.SNP-04.txt > ${outdir}/${sample}.SNP-05.txt
awk -F '\t' '$136 == "ALL.sites.2015_08" || $136<=0.01 {print}' ${outdir}/${sample}.SNP-05.txt >${outdir}/${sample}.germline.filter.txt
awk -F '\t' '{print$NF}' ${outdir}/${sample}.SNP-06.txt >${outdir}/${sample}.SNP-06-NF.txt
awk -F '[,:]' '{print$3}'  ${outdir}/${sample}.SNP-06-NF.txt >   ${outdir}/${sample}.SNP-06-NF-01.txt
cat -n ${outdir}/${sample}.SNP-06-NF-01.txt > ${outdir}/${sample}.SNP-06-NF-02.txt
awk -F '\t' '$1==1 || $NF > 10 {print}' ${outdir}/${sample}.SNP-06-NF-02.txt > ${outdir}/${sample}.SNP-06-NF-03.txt
awk -F '\t' '{print$1}' ${outdir}/${sample}.SNP-06-NF-03.txt > ${outdir}/${sample}.line
cat ${outdir}/${sample}.line | while read i; do nl ${outdir}/${sample}.SNP-06.txt |sed -n "$i"p >>${outdir}/${sample}.HC.filter-AD10-pre.txt; done
cut -f2-152 ${outdir}/${sample}.HC.filter-AD10-pre.txt > ${outdir}/${sample}.HC.filter-AD10.txt
ls -l annovar/
echo `date` : ... end annovar_filter ...
rm -rf ${outdir}/${sample}.SNP-02.txt ${outdir}/${sample}.SNP-03.txt ${outdir}/${sample}.SNP-04.txt ${outdir}/${sample}.SNP-05.txt ${outdir}/${sample}.SNP-06-NF.txt ${outdir}/${sample}.SNP-06-NF-01.txt ${outdir}/${sample}.SNP-06-NF-02.txt ${outdir}/${sample}.SNP-06-NF-03.txt ${outdir}/${sample}.line ${outdir}/${sample}.HC.filter-AD10-pre.txt
ls -l annovar/
