sample=$1
input=/mnt/sde/demo/CCA/annovar
output3=/mnt/sde/demo/CCA/AD3
output5=/mnt/sde/demo/CCA/AD5
awk -F '\t' '{print$NF}' ${input}/${sample}.SNP.filter-AF0.1.txt >${input}/${sample}.SNP-06-NF.txt
awk -F '[,:]' '{print$3}'  ${input}/${sample}.SNP-06-NF.txt >   ${input}/${sample}.SNP-06-NF-01.txt
cat -n ${input}/${sample}.SNP-06-NF-01.txt > ${input}/${sample}.SNP-06-NF-02.txt

awk -F '\t' '$1==1 || $NF > 3  {print}' ${input}/${sample}.SNP-06-NF-02.txt > ${output3}/${sample}.SNP-06-NF-03.txt
awk -F '\t' '{print$1}' ${output3}/${sample}.SNP-06-NF-03.txt > ${output3}/${sample}.line
cat ${output3}/${sample}.line | while read i; do nl ${input}/${sample}.SNP.filter-AF0.1.txt |sed -n "$i"p >> ${output3}/${sample}.SNP.filter-AF0.1-AD3-pre.txt; done
cut -f2-152 ${output3}/${sample}.SNP.filter-AF0.1-AD3-pre.txt > ${output3}/${sample}.SNP.filter-AF0.1-AD3.txt
rm -rf ${output3}/${sample}.SNP.filter-AF0.1-AD3-pre.txt

awk -F '\t' '$1==1 || $NF > 5  {print}' ${input}/${sample}.SNP-06-NF-02.txt > ${output5}/${sample}.SNP-06-NF-03.txt
awk -F '\t' '{print$1}' ${output5}/${sample}.SNP-06-NF-03.txt > ${output5}/${sample}.line
cat ${output5}/${sample}.line | while read i; do nl ${input}/${sample}.SNP.filter-AF0.1.txt |sed -n "$i"p >> ${output5}/${sample}.SNP.filter-AF0.1-AD5-pre.txt; done
cut -f2-152 ${output5}/${sample}.SNP.filter-AF0.1-AD5-pre.txt > ${output5}/${sample}.SNP.filter-AF0.1-AD5.txt
rm -rf ${output5}/${sample}.SNP.filter-AF0.1-AD5-pre.txt
