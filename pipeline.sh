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

    RPHI="03_mappings/01_rphi_transcriptome/Rphi.cds.fna"
    tmp="${i#*/}" && ACC="${tmp%_*}" &&

    # map reads
    bowtie2 -x $RPHI \
    -1 "$i"/"$ACC"_1_paired.fastq.gz -2 "$i"/"$ACC"_2_paired.fastq.gz \
    -S 03_mappings/"$ACC".mapped.sam --no-discordant -p 30 \
    2> 03_mappings/"$ACC".mapped.log &&
    
    # conert sam to bam
    samtools view -b 03_mappings/"$ACC".mapped.sam > 03_mappings/"$ACC".mapped.bam &&
    
    # remove sam
    rm 03_mappings/"$ACC".mapped.sam &&

    # sort and filter bam file
    samtools sort -@ 30 03_mappings/"$ACC".mapped.bam |\
    samtools view -t $RPHI -F 4 -h -@ 30 -b > 03_mappings/"$ACC".mapped.sorted.filtered.bam &&

    # get raw counts statistics
    samtools index 03_mappings/"$ACC".mapped.sorted.filtered.bam &&
    samtools idxstats 03_mappings/"$ACC".mapped.sorted.filtered.bam > 03_mappings/"$ACC".rawmapping.stats.tsv &&

    echo "$ACC": OK
    
done

# merge all raw mapping files into one 
for i in 03_mappings/SRR28*tsv; do

    TMP="03_mappings/TMP"

    if [ ! -e $TMP ]; then

        awk '{print $1"\t"$3}' $i | head -n -1 > $TMP
        continue

    else

        if [ -e 03_mappings/ALL.rawmapping.stats.tsv ]; then

            rm 03_mappings/ALL.rawmapping.stats.tsv

        fi

        awk '{print $1"\t"$3}' $i | head -n -1 | join -j 1 -t $'\t' $TMP - > 03_mappings/ALL.rawmapping.stats.tsv &&
        cp 03_mappings/ALL.rawmapping.stats.tsv $TMP

    fi

done

rm 03_mappings/TMP