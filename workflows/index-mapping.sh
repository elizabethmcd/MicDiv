#! /bin/bash

# Append genome name to scaffolds file for each bin, combine into one file
for file in *.fna; do GENOME=`basename ${file%.fna}`; sed -i "s|^>|>${GENOME}~|" $file; done
cat *.fna > all-bins.fasta

# call genes with Prodigal and output proteins
# individual and concatenated genes files for later queues
for file in *.fna; do
    N=$(basename $file .fa);
    prodigal -i $file -d $N.genes.fna -a $N.faa;
done

# bowtie index 
# index the combined reference file
mkdir bt2
bowtie2-build bins.fasta bt2/combined-bins.fasta

# queue mapping 
# for many metagenomes create a submit job where each job is the metagenome and the output the BAM, SAM, and indexed files
# create file with list of complete paths of each metagenome files, second column the output destination
# If have just a few metagenomes, can write a script of a for loop such as 

for file in ~/EBPR/coassembly/metagenomes/cleaned_fastqs/*.qced.fastq; do
	name=$(basename $file .qced.fastq);
	bowtie2 -p 4 -x bt2/R1R2-EBPR-bins-index.fasta -q $file > mapping/$name-mapping.sam;
done

# from these mapping files calculate the coverage with inStrain profile and the relative abundance with coverM with the relative_abundance method

