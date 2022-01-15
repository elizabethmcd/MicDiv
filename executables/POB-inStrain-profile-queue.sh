#! /bin/bash 

# load inStrain environment
export PATH=/home/GLBRCORG/emcdaniel/anaconda3/bin:$PATH
unset PYTHONPATH
source activate inStrain
PYTHONPATH=''

# arguments

genome=$1
mapping=$2

sampleName=$(basename $mapping -mapping.sorted.bam)
genomeName=$(basename $genome .fa)
resultName=$genomeName-vs-$sampleName.IS

fasta=/home/GLBRCORG/emcdaniel/MicDiv/datasets/POB/annotations/$genomeName.fa
genes=/home/GLBRCORG/emcdaniel/MicDiv/datasets/POB/annotations/$genomeName.genes.fna

# cd to mapping folder

cd /home/GLBRCORG/emcdaniel/EBPR/obscurePOS/metagenomes/finalBins/strains

# profile command

inStrain profile --pairing_filter all_reads $mapping $fasta -o /home/GLBRCORG/emcdaniel/MicDiv/datasets/POB/inStrain/$resultName -p 8 -g $genes -s /home/GLBRCORG/emcdaniel/MicDiv/datasets/POB/POS-scaffolds-to-bins.stb