#!/bin/bash

tail -n +1 05_DE/normalized_read_counts.tsv |\
awk -F "\t" '{print $1}' |\
grep -f - 00_input_files/Rphi.cds.eggnogAnn.tsv |\
grep -v "#" |\
awk -F "\t" '{print $1"\t"$10}' > 06_GO_enrichment/normalized_read_counts_eggnog.tsv