cat config-3 | while read id
        do grep -v '^Chr' /fsx/CCA-output/annovar/${id}.SNP.filter-AF0.1.txt | awk -v T=${id} -v N=${id:0:5}_germline '{print $0"\t"T"\t"N}'  > ${id}.somatic.SNP-01.txt
	done
head -1 /fsx/CCA-output/annovar/20S06043299.somatic.SNP.hg38_multianno.txt  > /data/home/demo/CCA_shell/annovar-mutect/header-1
head -1 /data/home/demo/CCA_shell/annovar-mutect/header-1 | sed 's/$/\tTumor_Sample_Barcode\tMatched_Norm_Sample_Barcode/'> /data/home/demo/CCA_shell/annovar-mutect/header
cat /data/home/demo/CCA_shell/annovar-mutect/header  *.somatic.SNP-01.txt  > /data/home/demo/CCA_shell/annovar-mutect/CCA.sum.maf.filter.txt
rm -r *.somatic.SNP-01.txt #/whg5/Product/w/annovar/header /whg5/Product/w/annovar/header-1
