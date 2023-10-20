#!/bin/bash


#########################
#     DOWNLOAD READS    #
#########################

# create a directory to store raw reads and quality control results
mkdir -p 01_raw_reads/01_fastqc

# download reads
# REQUIRES sra-tool and fastqc
python3 scripts/01_download_reads.py -i 00_input_files/readsToDownload.ls

# aggregate fastqc report into a single html file
multiqc -o 01_raw_reads/01_fastqc/ 01_raw_reads/01_fastqc/


######################
#     TRIM READS     #
######################

# create a directory to store trimmed reads and quality control results
mkdir -p 02_trimmed_reads/01_fastqc

# trim reads
# REQUIRES trimmomatic and fastqc
for i in 01_raw_reads/SRR*; do python3 scripts/02_trim_reads.py -d $i -adapt 00_input_files/contaminants2trimm.fa; done

# aggregate fastqc report into a single html file
multiqc -o 02_trimmed_reads/01_fastqc 02_trimmed_reads/01_fastqc

# merge reads from technical replicates into single files
mkdir 03_merged_reads

bash scripts/03_merge_tech_reps.sh


#####################
#     MAP READS     #
#####################

# create a directory to store mapping results and indexed transcriptome
mkdir -p 04_mappings/01_rphi_transcriptome

# copy the reference transcriptome in the newly created directory
cp 00_input_files/Rphi.cds.fna 04_mappings/01_rphi_transcriptome

# map reads
# REQUIRES bowtie2
for i in 03_merged_reads/SRR*; do python3 scripts/04_map_reads.py -d $i -ref 04_mappings/01_rphi_transcriptome/Rphi.cds.fna; done

# merge all raw mapping files into one
bash scripts/05_merge_rawmappings.sh


#######################
#     DE ANALYSIS     #
#######################

# create a directory to store input and output files of DE analysis
mkdir 05_DE/

# execute Rscript for DE analysis
Rscript scripts/06_DE.noiseq.Rscript 04_mappings/ALL.rawmapping.stats.tsv 00_input_files/tech_replicates.tsv


#########################
#     GO enrichment     #
#########################

# create a directory to store input and output files of GO enrichment
mkdir 06_GO_enrichment

# get GO annotation for gene universe (genes with mapping filtered reads)
bash scripts/07_get_GO_geneUniverse.sh

# get the list of DE genes
bash scripts/08_get_DEgene_list.sh

# perform GO enrichment for M and F experiments
bash scripts/09_run_GOenrich.sh