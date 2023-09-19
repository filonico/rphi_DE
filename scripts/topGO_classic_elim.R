#!/usr/bin/env Rscript

# based on a script by Mariangela Iannello

args = commandArgs(trailingOnly=TRUE)

#args1 genes of interest
#args2 gene universe

if (!requireNamespace("BiocManager", quietly=TRUE))
 install.packages("BiocManager")

if (!requireNamespace("topGO", quietly=TRUE))
 BiocManager::install("topGO")

library(topGO)

geneID2GO = readMappings(file=args[2])

geneNames <- names(geneID2GO)
int_genes= read.table(args[1], header = FALSE, sep = "\t")
gene_int_list <- as.vector(int_genes$V1)
geneList <- factor(as.integer(geneNames %in% gene_int_list))
names(geneList) <- geneNames

GOdata_BP <- new("topGOdata", ontology = "BP", allGenes = geneList, annot = annFUN.gene2GO, gene2GO = geneID2GO)
GOdata_MF <- new("topGOdata", ontology = "MF", allGenes = geneList, annot = annFUN.gene2GO, gene2GO = geneID2GO)
GOdata_CC <- new("topGOdata", ontology = "CC", allGenes = geneList, annot = annFUN.gene2GO, gene2GO = geneID2GO)

resultFis_BP <- runTest(GOdata_BP, algorithm = "classic", statistic = "fisher")
resultFis_MF <- runTest(GOdata_MF, algorithm = "classic", statistic = "fisher")
resultFis_CC <- runTest(GOdata_CC, algorithm = "classic", statistic = "fisher")

resultFis_BP_elim <- runTest(GOdata_BP, algorithm = "elim", statistic = "fisher")
resultFis_MF_elim <- runTest(GOdata_MF, algorithm = "elim", statistic = "fisher")
resultFis_CC_elim <- runTest(GOdata_CC, algorithm = "elim", statistic = "fisher")

Res_BP <- GenTable(GOdata_BP, classicFisher = resultFis_BP,ranksOf = "classicFisher", topNodes = 100)
Res_MF <- GenTable(GOdata_MF, classicFisher = resultFis_MF,ranksOf = "classicFisher", topNodes = 100)
Res_CC <- GenTable(GOdata_CC, classicFisher = resultFis_CC,ranksOf = "classicFisher", topNodes = 100)


Res_BP_elim <- GenTable(GOdata_BP, classicFisher = resultFis_BP_elim, ranksOf = "classicFisher", topNodes = 100)
Res_MF_elim <- GenTable(GOdata_MF, classicFisher = resultFis_MF_elim, ranksOf = "classicFisher", topNodes = 100)
Res_CC_elim <- GenTable(GOdata_CC, classicFisher = resultFis_CC_elim, ranksOf = "classicFisher", topNodes = 100)

write.table(Res_BP,file="topGO_BP.txt", quote=FALSE, row.names=FALSE, sep = "\t")
write.table(Res_MF,file="topGO_MF.txt", quote=FALSE, row.names=FALSE, sep = "\t")
write.table(Res_CC,file="topGO_CC.txt", quote=FALSE, row.names=FALSE, sep = "\t")

write.table(Res_BP_elim,file="topGO_BP_elim.txt", quote=FALSE, row.names=FALSE, sep = "\t")
write.table(Res_MF_elim,file="topGO_MF_elim.txt", quote=FALSE, row.names=FALSE, sep = "\t")
write.table(Res_CC_elim,file="topGO_CC_elim.txt", quote=FALSE, row.names=FALSE, sep = "\t")