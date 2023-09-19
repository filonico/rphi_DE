#!/bin/bash


#########################
##### READ DOWNLOAD #####
#########################


# create a directory to store raw reads and quality control results
mkdir -p 01_raw_reads/01_fastqc

# copy readsToDownload.ls in the newly created directory
cp 00_input_files/readsToDownload.ls 01_raw_reads/

# download the .sra files
prefetch --option-file 01_raw_reads/readsToDownload.ls -O 01_raw_reads/ &

# if the previous doesn't work, try the following
# while read j; do prefetch $j -O 01_raw_reads/; done <01_raw_reads/readsToDownload.ls

for i in 01_raw_reads/SRR28*/*sra*; do

    DIR="${i%/*}"

    # download fastq files
    fastq-dump --defline-seq '@$sn[_$rn]/$ri' --split-files "$i" -O $DIR &&
    
    # execute quality check
    fastqc "$DIR"/*fastq -o 01_raw_reads/01_fastqc -f fastq &&

    # gzip fastq files
    gzip -9 "$DIR"/*fastq &&

    # remove sra files
    rm $i

done

# aggregate fastqc report into a single html file
multiqc -o 01_raw_reads/01_fastqc/ 01_raw_reads/01_fastqc/


#########################
##### READ TRIMMING #####
#########################


# create a directory to store trimmed reads and quality control results
mkdir -p 02_trimmed_reads/01_fastqc

# copy contaminants2trimm.fa in the newlycreated directory
cp 00_input_files/contaminants2trimm.fa 02_trimmed_reads/

for i in 01_raw_reads/SRR*; do
    
    ACC="${i#*/}" &&
    TRIMDIR="02_trimmed_reads/"$ACC"_trimmed" &&
    
    mkdir "$TRIMDIR" &&
    
    # trim reads
    trimmomatic PE -threads 15 -phred33 \
    "$i"/"$ACC"*1.fastq.gz "$i"/"$ACC"*2.fastq.gz \
    "$TRIMDIR"/"$ACC"_1_paired.fastq.gz "$TRIMDIR"/"$ACC"_1_unpaired.fastq.gz \
    "$TRIMDIR"/"$ACC"_2_paired.fastq.gz "$TRIMDIR"/"$ACC"_2_unpaired.fastq.gz \
    ILLUMINACLIP:02_trimmed_reads/contaminants2trimm.fa:2:30:10 LEADING:5 TRAILING:5 SLIDINGWINDOW:4:15 MINLEN:65 &&
    
    # execute quality check
    fastqc "$TRIMDIR"/*_paired*gz -o 02_trimmed_reads/01_fastqc -f fastq
    
done

# aggregate fastqc report into a single html file
multiqc -o 01_raw_reads/01_fastqc/ 01_raw_reads/01_fastqc/

# merge reads from technical replicates into single files
mkdir 03_merged_reads

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


########################
##### READ MAPPING #####
########################


# create a directory to store mapping results and indexed transcriptome
mkdir -p 04_mappings/01_rphi_transcriptome

# copy the reference transcriptome in the newly created directory
cp 00_input_files/Rphi.cds.fna 04_mappings/01_rphi_transcriptome

# index transcriptome
bowtie2-build 04_mappings/01_rphi_transcriptome/Rphi.cds.fna 04_mappings/01_rphi_transcriptome/Rphi.cds.fna

for i in 03_merged_reads/SRR*; do

    RPHI="04_mappings/01_rphi_transcriptome/Rphi.cds.fna"
    ACC="$(echo $i | sed -E 's/^.+\///; s/_.+$//')" &&

    # map reads
    bowtie2 -x $RPHI \
    -1 "$i"/"$ACC"_1_paired.fastq.gz -2 "$i"/"$ACC"_2_paired.fastq.gz \
    -S 04_mappings/"$ACC".mapped.sam --no-discordant -p 30 \
    2> 04_mappings/"$ACC".mapped.log &&
    
    # conert sam to bam
    samtools view -b 04_mappings/"$ACC".mapped.sam > 04_mappings/"$ACC".mapped.bam &&
    
    # remove sam
    rm 04_mappings/"$ACC".mapped.sam &&

    # sort and filter bam file
    samtools sort -@ 30 04_mappings/"$ACC".mapped.bam |\
    samtools view -t $RPHI -F 4 -h -@ 30 -b > 04_mappings/"$ACC".mapped.sorted.filtered.bam &&

    # get raw counts statistics
    samtools index 04_mappings/"$ACC".mapped.sorted.filtered.bam &&
    samtools idxstats 04_mappings/"$ACC".mapped.sorted.filtered.bam > 04_mappings/"$ACC".rawmapping.stats.tsv &&

    echo "$ACC": OK
    
done

if [ -e conditions.tsv ]; then
    
    rm conditions.tsv

fi

# merge all raw mapping files into one
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


#######################
##### DE ANALYSIS #####
#######################


# create a directory to store input and output files of DE analysis
mkdir 05_DE/

# copy the R script, the rawcount table and the condition table in the newly created directory
cp scripts/DE.noiseq.Rscript 05_DE/
cp 04_mappings/ALL.rawmapping.stats.tsv 05_DE/
mv conditions.tsv 05_DE/

# execute Rscript for DE analysis
Rscript 05_DE/DE.noiseq.Rscript 05_DE/ALL.rawmapping.stats.tsv 05_DE/conditions.tsv


#########################
##### GO enrichment #####
#########################


# create a directory to store input and output files of GO enrichment
mkdir 06_GO_enrichment

# copy the R script in the newly created directory
cp scripts/topGO_classic_elim.R 06_GO_enrichment/

# get GO annotation for gene universe (genes with mapping filtered reads)
tail -n +1 05_DE/normalized_read_counts.tsv |\
awk -F "\t" '{print $1}' |\
grep -f - 00_input_files/Rphi.cds.eggnogAnn.tsv |\
grep -v "#" |\
awk -F "\t" '{print $1"\t"$10}' > normalized_read_counts_eggnog.tsv

# get the list of DE genes
for i in 05_DE/*DE*tsv; do

    FILENAME="$(basename $i)" &&
    
    tail -n +2 $i |\
    awk '{print $1}' |\
    head > 06_GO_enrichment/"${FILENAME/tsv/ls}"
    
done

# perform DE for M and F experiments
for i in 06_GO_enrichment/*ls; do

    FILENAME="$(basename $i)" &&
    
    mkdir 06_GO_enrichment/"${FILENAME/.ls/_GOenrich}" &&
    
    Rscript 06_GO_enrichment/topGO_classic_elim.R $i 06_GO_enrichment/normalized_read_counts_eggnog.tsv &&
    
    mv 06_GO_enrichment/*txt 06_GO_enrichment/"${FILENAME/.ls/_GOenrich}"
    
done