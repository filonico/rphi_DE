#!/bin/bash

######################
### DOWNLOAD READS ###
######################

# create a directory to store raw reads
mkdir 01_rawreads

# put the readsToDownload.ls file inside the newly created directory
# download the .sra files
prefetch --option-file 01_rawreads/readsToDownaload.ls -O 01_rawreads/ &

