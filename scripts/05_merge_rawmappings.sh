#!/bin/bash

if [ -e conditions.tsv ]; then
    
    rm conditions.tsv

fi


for i in 04_mappings/SRR28*tsv; do

    TMP="04_mappings/TMP" &&
    ACC="$(echo "${i#*/}" | awk -F "." '{print $1"."$2}')" &&
    COND="$(grep $ACC 00_input_files/tech_replicates.tsv | awk '{print $NF}')" &&

    # create a table with the list of experiment conditions in the reading order (we will use this for DE analysis with NOIseq)
    # NB: this file is the same as 00_input/tech_replicates.tsv, but experiments are in the order that is expected for the DE analysis (i.e., the same of the columns in the rawcount table) 
    echo -e $ACC'\t'$COND >> conditions.tsv &&

    if [ ! -e $TMP ]; then

        # select just the column of mapped reads
        awk '{print $1"\t"$3}' $i | sed -E "1i gene\t$ACC" | head -n -1 > $TMP &&
        continue

    else

        if [ -e 04_mappings/ALL.rawmapping.stats.tsv ]; then

            rm 04_mappings/ALL.rawmapping.stats.tsv

        fi

        awk '{print $1"\t"$3}' $i | sed -E "1i gene\t$ACC" | head -n -1 | join -j 1 -t $'\t' $TMP - > 04_mappings/ALL.rawmapping.stats.tsv &&
        cp 04_mappings/ALL.rawmapping.stats.tsv $TMP

    fi

done

rm 04_mappings/TMP
