#!/bin/bash

for i in 05_DE/*DE*tsv; do

    FILENAME="$(basename $i)" &&
    
    tail -n +2 $i |\
    awk '{print $1}' > 06_GO_enrichment/"${FILENAME/tsv/ls}"
    
done