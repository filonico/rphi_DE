#!/bin/bash


#########################
##### READ DOWNLOAD #####
#########################


# create a directory to store raw reads and quality control results
mkdir -p 01_rawreads/01_fastqc

# move readsToDownload.ls in the newly created directory
mv readsToDownload.ls 01_rawreads/

# download the .sra files
prefetch --option-file 01_rawreads/readsToDownload.ls -O 01_rawreads/ &

# if the previous doesn't work, try the following
# while read j; do prefetch $j -O 01_rawreads/; done <01_rawreads/readsToDownload.ls

for i in 01_rawreads/SRR28*/*sra*; do

    DIR="${i%/*}"

    # download fastq files
    fastq-dump --defline-seq '@$sn[_$rn]/$ri' --split-files "$i" -O $DIR &&
    
    # execute quality check
    fastqc "$DIR"/*fastq -o 01_rawreads/01_fastqc -f fastq &&

    # gzip fastq files
    gzip -9 "$DIR"/*fastq &&

    # remove sra files
    rm $i

done

# aggregate fastqc report into a single html file
multiqc -o 01_rawreads/01_fastqc/ 01_rawreads/01_fastqc/


#########################
##### READ TRIMMING #####
#########################


# create a directory to store trimmed reads and quality control results
mkdir -p 02_trimmed_reads/01_fastqc

for i in 01_rawreads/SRR*; do
    
    ACC="${i#*/}" &&
    TRIMDIR="02_trimmed_reads/"$ACC"_trimmed" &&
    
    mkdir "$TRIMDIR" &&
    
    # trim reads
    trimmomatic PE -threads 15 -phred33 \
    "$i"/"$ACC"*1.fastq.gz "$i"/"$ACC"*2.fastq.gz \
    "$TRIMDIR"/"$ACC"_1_paired.fastq.gz "$TRIMDIR"/"$ACC"_1_unpaired.fastq.gz \
    "$TRIMDIR"/"$ACC"_2_paired.fastq.gz "$TRIMDIR"/"$ACC"_2_unpaired.fastq.gz \
    ILLUMINACLIP:contaminants2trimm.fa:2:30:10 LEADING:5 TRAILING:5 SLIDINGWINDOW:4:15 MINLEN:65 &&
    
    # execute quality check
    fastqc "$TRIMDIR"/*_paired*gz -o 02_trimmed_reads/01_fastqc -f fastq
    
done

# aggregate fastqc report into a single html file
multiqc -o 01_rawreads/01_fastqc/ 01_rawreads/01_fastqc/


########################
##### READ MAPPING #####
########################

# create a directory to store mapping results and indexed transcriptome
mkdir -p 03_mappings/01_rphi_transcriptome

# move the reference transcriptome in the newly created directory
mv Rphi.cds.fna 03_mappings/01_rphi_transcriptome

# index transcriptome
bowtie2-build 03_mappings/01_rphi_transcriptome/Rphi.cds.fna 03_mappings/01_rphi_transcriptome/Rphi.cds.fna

for i in 02_trimmed_reads/SRR*; do

    tmp="${i#*/}" && ACC="${tmp%_*}" &&

    bowtie2 -x 03_mappings/01_rphi_transcriptome/Rphi.cds.fna \
    -1 "$i"/"$ACC"_1_paired.fastq.gz -2 "$i"/"$ACC"_2_paired.fastq.gz \
    -S 03_mappings/"$ACC".mapped.bt2.sam --no-discordant -p 30 \
    2> 03_mappings/"$ACC".mapped.bt2.log &&
    
    samtools view -b 03_mappings/"$ACC".mapped.bt2.sam > 03_mappings/"$ACC".mapped.bt2.bam &&
    
    rm 03_mappings/"$ACC".mapped.bt2.sam &&

    echo "$ACC": OK
    
done