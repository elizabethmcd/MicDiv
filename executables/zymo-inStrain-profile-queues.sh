#! /bin/bash 

# load inStrain environment
export PATH=/home/GLBRCORG/emcdaniel/anaconda3/bin:$PATH
unset PYTHONPATH
source activate inStrain
PYTHONPATH=''

# arguments

genome=$1
mapping=$2

sampleName=$(basename $mapping .fastq.sorted.bam)
genomeName=$(basename $genome .fa)
resultName=$genomeName-vs-$sampleName.IS

fasta=/home/GLBRCORG/emcdaniel/MicDiv/datasets/Zymo_Synthetic/ref_genomes/annotations/$genomeName.fa
genes=/home/GLBRCORG/emcdaniel/MicDiv/datasets/Zymo_Synthetic/ref_genomes/annotations/$genomeName.genes.fna

# cd to mapping folder

cd /home/GLBRCORG/emcdaniel/MicDiv/datasets/Zymo_Synthetic/mappingResults

# profile command

inStrain profile --pairing_filter all_reads $mapping $fasta -o /home/GLBRCORG/emcdaniel/MicDiv/datasets/Zymo_Synthetic/inStrain/$resultName -p 8 -g $genes -s /home/GLBRCORG/emcdaniel/MicDiv/datasets/Zymo_Synthetic/ref_genomes/zymo-scaffolds-to-genomes.tsv