#! /bin/bash

# setup environment for samtools dependencies to work 

export PATH=/home/GLBRCORG/emcdaniel/anaconda3/bin:$PATH
unset PYTHONPATH
source activate coverM
PYTHONPATH=''

# arguments
reads=$1
samplename=$(basename $reads .QCed.fastq)

cd /home/GLBRCORG/emcdaniel/MicDiv/datasets/Zymo_Synthetic/mappingResults

# mapping command
/opt/bifxapps/bowtie2-2.3.5.1/bowtie2 --threads 4 -x /home/GLBRCORG/emcdaniel/MicDiv/datasets/Zymo_Synthetic/ref_genomes/bt2/all-zymo-genomes.fasta --interleaved $reads > $samplename.sam


# BAM, sort, index
samtools view -S -b  $samplename.sam >  $samplename.bam
samtools sort  $samplename.bam -o  $samplename.sorted.bam
samtools index $samplename.sorted.bam $samplename.sorted.bam.bai