#! /bin/bash 

# load inStrain environment
export PATH=/home/GLBRCORG/emcdaniel/anaconda3/bin:$PATH
unset PYTHONPATH
source activate inStrain
PYTHONPATH=''


# arguments
sam=$1
outfolder=$(basename $sam -mapping.sorted.bam)-quick-profile

# cd to mapping results folder

cd /home/GLBRCORG/emcdaniel/EBPR/obscurePOS/metagenomes/finalBins/strains

# inStrain quick profile command

inStrain quick_profile -p 2 -s /home/GLBRCORG/emcdaniel/MicDiv/datasets/POB/POS-scaffolds-to-bins.stb -o /home/GLBRCORG/emcdaniel/MicDiv/datasets/POB/inStrain/quick_profiles/$outfolder $sam /home/GLBRCORG/emcdaniel/MicDiv/datasets/POB/refGenomes/all-POB-genomes.fasta