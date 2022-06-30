
#!/bin/bash
#Paula Robles López, 2022

ayuda () {
echo -e "ABOUT THIS SCRIPT:"
echo -e "A HISAT2-StringTie pipeline to be used with RNAseq results (forward and reverse)."
echo -e 'HISAT2 is used to align reads, which are later assembled into transcripts using StringTie.'
echo -e 'It also prepares a gene count matrix to be used as input in DESeq2 for the Differential '
echo -e 'Expression Genes analysis, using the script prepDE.py provided by StringTie (must be in the'
echo -e ' same directory as this script).\n\n'
echo -e 'In the current directory you must NOT have a folder named "ballgown".'
echo -e 'In the current directory you MUST have: \n\t1. the prepDE.py script, \n\t2. this script, \n\t3. the following data input'
echo -e '\n\n'
echo -e '\tUSAGE: genecount.sh <input_folder> <genoma_ref.fa> <genome_annot>\n'
echo -e '\t\tinput_folder:\t folder containing all folders resulting from the RNAseq'
echo -e '\t\t\t\t E.g. the mother folder "SHH" which contains three folders of samples: "S1", "S2" and "S3".'
echo -e '\t\t\t\t In each sample folder we can find the forward and the reverse sequence for said sample.'
echo -e '\t\tgenoma_ref.fa:\t a fasta/multifasta containing all chromosomes of the reference organism'
echo -e '\t\tgenome_annot:\t the reference genome annotation file'
echo -e '\n\n'
}

#arguments assignation
directory=$1
genome_ref=$2
genome_annot=$3


#Controls help message
#if there is only one argument and it is -h or -help
#then we summon ayuda
#else then we get an error not enough arguments
echo -e "\n"
if (( $#==1 )); then
	case "$1" in
		"-h") ayuda; exit 0;;
		"-help") ayuda; exit 0;;
		*) echo -e "Error! Not enough arguments.\n"; ayuda; exit 0;;
	esac
fi

if (( $#<2 )); then
	echo -e "Error! Not enough arguments.\n"
	ayuda
	exit 0
fi

if [[ -e ballgown ]]; then
	echo -e "Warning! The ballgown folder already exists. Deleting..."
	rm -r ballgown
fi

mkdir ballgown

echo -e "\n****************************************\n\tWELCOME FELLOW HUMAN! :]\n****************************************\n"
echo -e "You are performing a RNAseq analysis to obtain a gene count matrix"
echo -e "to be used as input for the DESeq2's Differential Expressed Genes analysis."
echo -e "Good luck!"
echo -e "\nCreating the index for HISAT2 using $2..."
(hisat2-build $2 ref_index 1>>1.log 2>>2.log)


ls $1 | while read folder;do
	echo -e "\n\nPerforming HISAT2 analysis on $folder..."
	#hisat2	
	ls $1/$folder > archivos_fq.txt
	forward=$(sed -n '1p' archivos_fq.txt)
	reverse=$(sed -n '2p' archivos_fq.txt)
	
	echo -e "Creating the sorted BAM file of the alligned reads $folder..."
	hisat2 -x ref_index -1 $1/$folder/$forward -2 $1/$folder/$reverse | samtools sort -o $1/$folder/${folder}sorted.bam -
	
	#indexing
	echo -e "Indexing the sorted BAM file..."
	samtools index $1/$folder/${folder}sorted.bam
	
	#stringtie
	echo -e "Building the annotated transcriptome for $folder..."
	stringtie -e -o $1/$folder/${folder}.gtf -G $3 $1/$folder/${folder}sorted.bam
		
	#we copy all the gtf files to the same folder
	mkdir ballgown/$folder	
	cp $1/$folder/${folder}.gtf  ballgown/$folder
done

rm archivos_fq.txt

echo -e "Generating count matrices for genes and transcripts..."

python prepDE.py -i ballgown

echo -e "\n\n***************\nDone!\n***************\n"
