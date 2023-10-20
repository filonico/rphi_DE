#!/bin/bash

while read j; do

    rep1="$(echo $j | awk '{print $1}' | awk -F "." '{print $1}')" &&
    rep2="$(echo $j | awk '{print $1}' | awk -F "." '{print $2}')" &&
    
    mkdir 03_merged_reads/"$rep1"."$rep2" &&
    
    for i in {1,2}; do
    
        zcat 02_trimmed_reads/"$rep1"_trimmed/"$rep1"_"$i"_paired.fastq.gz \
        02_trimmed_reads/"$rep2"_trimmed/"$rep2"_"$i"_paired.fastq.gz \
        > 03_merged_reads/"$rep1"."$rep2"/"$rep1"."$rep2"_"$i"_paired.fastq &&
        
        gzip -9 03_merged_reads/"$rep1"."$rep2"/"$rep1"."$rep2"_"$i"_paired.fastq
        
    done
done <00_input_files/tech_replicates.tsv