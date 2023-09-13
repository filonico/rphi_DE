# README
Here you can find the pipeline of the differential-expression analysis on *Ruditapes philippinarum*. RNA-seq experiments come from gonads of females belonging to sex-biased families.

The original publication that produced the data is:
> Ghiselli, F., Milani, L., Chang, P. L., Hedgecock, D., Davis, J. P., Nuzhdin, S. V., & Passamonti, M. (2012). De novo assembly of the Manila clam *Ruditapes philippinarum* transcriptome provides new insights into expression bias, mitochondrial doubly uniparental inheritance and sex determination. *Molecular biology and evolution*, *29*(2), 771-786. doi: https://doi.org/10.1093/molbev/msr248

The accession numbers of RNA-seq runs are in the following table. Technical replicates are grouped in each line.

| Run | Sex | Family |
| --- | --- | --- |
| [SRR280988](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR280988&display=metadata) + [SRR280989](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR280989&display=metadata) | female | male-biased |
| [SRR280990](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR280990&display=metadata) + [SRR280991](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR280991&display=metadata) | female | male-biased |
| [SRR280992](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR280992&display=metadata) + [SRR280993](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR280993&display=metadata) | female | male-biased |
| [SRR280915](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR280915&display=metadata) + [SRR280916](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR280916&display=metadata) | female | female-biased |
| [SRR280917](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR280917&display=metadata) + [SRR280918](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR280918&display=metadata) | female | female-biased |
| [SRR280986](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR280986&display=metadata) + [SRR280987](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR280987&display=metadata) | female | female-biased |
| [SRR281061](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR281061&display=metadata) + [SRR281062](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR281062&display=metadata) | male | male-biased |
| [SRR281063](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR281063&display=metadata) + [SRR281064](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR281064&display=metadata) | male | male-biased |
| [SRR281065](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR281065&display=metadata) + [SRR281066](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR281066&display=metadata) | male | male-biased |
| [SRR280842](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR280842&display=metadata) + [SRR280910](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR280910&display=metadata) | male | female-biased |
| [SRR280911](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR280911&display=metadata) + [SRR280912](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR280912&display=metadata) | male | female-biased |
| [SRR280913](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR280913&display=metadata) + [SRR280914](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR280914&display=metadata) | male | female-biased |

## Files in this repository
* [<code>contaminants2trimm.fa</code>](/contaminants2trimm.fa) contains a collection of Illumina adapters; it is used in the trimming step.
* [<code>pipeline.sh</code>](/pipeline.sh) contains all the commands used to run the analysis.
* [<code>readsToDownload.ls</code>](/readsToDownload.ls) contains the list of accession numbers of RNA-seq experiments that have been used for the analysis.