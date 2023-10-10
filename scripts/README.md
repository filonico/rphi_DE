## Files in this repository

Here you can find additional scripts used for the analyses. Scripts are ordered according to their appearence in the [pipeline](../pipeline.sh).

| File | Description |
| --- | --- |
| [<code>01_download_reads.py</code>](./01_download_reads.py) | Download reads and perform quality check. |
| [<code>02_trim_reads.py</code>](./02_trim_reads.py) | Trim reads and perform quality check. |
| [<code>03_map_reads</code>](./03_map_reads.py) | Map reads against the reference transcriptome and get ra count statistics. |
| [<code>04_DE.noiseq.Rscript</code>](./04_DE.noiseq.Rscript) | Rscript to perform the differential gene expression analysis with [NOISeq](https://www.bioconductor.org/packages/release/bioc/html/NOISeq.html). |
| [<code>05_topGO_classic_elim.Rscript</code>](./05_topGO_classic_elim.Rscript) | Rscript to perform the GO enrichment of differntially expressed genes with [topGO](https://bioconductor.org/packages/release/bioc/html/topGO.html). |