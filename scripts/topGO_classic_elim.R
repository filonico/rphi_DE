#!/usr/bin/env Rscript

if (!requireNamespace("BiocManager", quietly=TRUE))
  install.packages("BiocManager")

if (!requireNamespace("topGO", quietly=TRUE))
  BiocManager::install("topGO")

library(topGO)

args = commandArgs(trailingOnly=TRUE)

# args1 genes of interest
# args2 gene universe


############################
##### DATA PREPARATION #####
############################


# load gene universe GO annotation and get list of features
geneID2GO <- readMappings(file = args[2])
geneNames <- names(geneID2GO)

# load the list of genes of interest and get the relative vector
int_genes <- read.table(args[1], header = FALSE, sep = "\t")
gene_int_list <- as.vector(int_genes$V1)

# get a factor list of interesting/not interesting genes 
geneList <- factor(as.integer(geneNames %in% gene_int_list))
names(geneList) <- geneNames


#########################
##### GO ENRICHMENT #####
#########################


# function to perform GO enrichment and generate summary tables
performGOEnrichment <- function(ontology, algorithm) {
  
  # create topGOdata object
  GOdata <- new("topGOdata", ontology = ontology, allGenes = geneList, annot = annFUN.gene2GO, gene2GO = geneID2GO)
  
  # perform GO enrichment
  result <- runTest(GOdata, algorithm = algorithm, statistic = "fisher")
  
  # get summary table
  Res <- GenTable(GOdata, classicFisher = result, ranksOf = "classicFisher", topNodes = 100)
  
  return(Res)
}

# define GO ontologies
ontologies <- c("BP", "MF", "CC")

# define algorithms
algorithms <- c("classic", "elim")

# perform GO enrichment and generate summary tables for each ontology and each method
for (ontology in ontologies) {
  
  for (algorithm in algorithms) {
    
    result <- performGOEnrichment(ontology, algorithm)
    
    file_name <- paste0("06_GO_enrichment/topGO_", ontology, "_", algorithm, ".txt")
    
    write.table(result, file = file_name, quote = FALSE, row.names = FALSE, sep = "\t")
  }
}