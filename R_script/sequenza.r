library(sequenza)
Z101.data.file <-  "/demo/HPV/sequenza/Z101.small.seqz.gz"
chromosome.list <- paste0("chr", c(1:22))
Z101 <- sequenza.extract(Z101.data.file,chromosome.list=chromosome.list)
CP <- sequenza.fit(Z101)
sequenza.results(sequenza.extract = Z101,
    cp.table = CP, sample.id = "Z101",
    out.dir="/demo/HPV/sequenza/Z101")
