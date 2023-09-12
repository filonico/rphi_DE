#!/bin/bash

######################
### DOWNLOAD READS ###
######################

# create a directory to store raw reads
mkdir 01_rawreads

# put the readsToDownload.ls file inside the newly created directory
# download the .sra files
prefetch --option-file 01_rawreads/readsToDownaload.ls -O 01_rawreads/ &

# download .fastq files
for i in 01_rawreads/SRR28*/*sra; do

    DIR="${i%SRR*}"

    fastq-dump --defline-seq '@$sn[_$rn]/$ri' --split-files "$i" -O $DIR &&
    
    # execute quality check
    fastqc "$DIR"/*fastq -o "$DIR" -f fastq &&

    # gzip .fastq files
    gzip -9 "$DIR"/*fastq &&
    rm $i
done