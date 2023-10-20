#!/bin/bash

for i in 06_GO_enrichment/*ls; do

    FILENAME="$(basename $i)" &&
    
    # create a directory to store results for each analysis
    mkdir 06_GO_enrichment/"${FILENAME/.ls/_GOenrich}" &&
    
    # run the R script for DE
    Rscript scripts/10_topGO_classic_elim.Rscript $i 06_GO_enrichment/normalized_read_counts_eggnog.tsv &&
    
    # move DE results to the corresponding directory
    mv 06_GO_enrichment/*txt 06_GO_enrichment/"${FILENAME/.ls/_GOenrich}"
    
done