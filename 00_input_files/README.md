## Files in this repository

Here you can find all the necessary input files for the analyses.

| File | Description |
| --- | --- |
| [<code>contaminants2trimm.fa</code>](contaminants2trimm.fa) | A collection of Illumina adapters. Use it in the trimming step. |
| [<code>readsToDownload.ls</code>](readsToDownload.ls) | The list of accession numbers of RNA-seq experiments used for the analysis. Use it to download all the sra files from NCBI. |
| [<code>readsToDownload.tsv</code>](readsToDownload.tsv) | A parsable version of metadata of each RNA-seq run (<code>Ff</code>: females from a female-biased family; <code>Fm</code>: females from a male-biased family; <code>Mf</code>: males from a female-biased family; <code>Mm</code>: males from a male-biased family) |
| [<code>Rphi.cds.eggnogAnn.tsv</code>](Rphi.cds.eggnogAnn.tsv) | GO annotation used for the GO enrichment analysis. Produced via the [eggNOG-mapper](http://eggnog-mapper.embl.de/) online tool (accessed on Sept 9, 2023). |
| [<code>Rphi.cds.gna</code>](Rphi.cds.fna) | Transcriptome to which reads were mapped. |
| [<code>tech_replicates.tsv</code>](tech_replicates.tsv) | Information about technical replicates of the original experiments (each lines has technical replicates; <code>Ff</code>: females from a female-biased family; <code>Fm</code>: females from a male-biased family; <code>Mf</code>: males from a female-biased family; <code>Mm</code>: males from a male-biased family). |