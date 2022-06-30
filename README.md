# bash_countmatrix
A bash script which performs a HISAT2-StringTie pipeline to get count matrixes from RNAseq data. These can be later used to perform a Differently Expressed Genes (DEG) analysis with either DESeq2 or edgeR.

**genecount.sh:** the automated HISAT2-StringTie pipeline script that generates sorted.bam, .bai and .gtf files for each sample. It also creates the ...count_matrix.csv from the .gtf transcriptomes of all samples (via the **prepDE.py*+ script provided by StringTie). It requires the following input arguments:
- The name of the folder hosting all folders obtained from RNAseq, i.e.: the name of the folder containing the folders of the respective samples (sample1, sample2, sample3...). It is assumed that each sample_folder contains one forward and one reverse file. *Example samples not provided due to their remarkable size*.
- The name of the complete genome. *The Arabidopsis genome TAIR10_chr_all.fas is provided as an example*.
- The name of the genome annotation: *The Arabidopsis annotation TAIR10_GFF3_genes.fa is provided as an example*.
- Inputs must be in the same directory as genecount.sh

**prepDE.py:** script provided by StringTie (https://ccb.jhu.edu/software/stringtie/index.shtml?t=manual#deseq) to obtain count matrixes from the RNAseq .gtf files. These can be later used to perform a Differently Expressed Genes (DEG) analysis with either DESeq2 or edgeR. It must be in the same directory as **genecount.sh**.



\
Results of this pipeline on my work project are available: **gene_count_matrix.csv** y **transcript_count_matrix.csv**.
