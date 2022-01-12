#! /bin/bash 

# load inStrain environment
export PATH=/home/GLBRCORG/emcdaniel/anaconda3/bin:$PATH
unset PYTHONPATH
source activate inStrain
PYTHONPATH=''


# arguments
sam=$1
outfolder=$(basename $sam .fastq.sorted.bam)-quick-profile

# cd to mapping results folder

cd /home/GLBRCORG/emcdaniel/MicDiv/datasets/Zymo_Synthetic/mappingResults

# inStrain quick profile command

inStrain quick_profile -p 2 -s /home/GLBRCORG/emcdaniel/MicDiv/datasets/Zymo_Synthetic/ref_genomes/zymo-scaffolds-to-genomes.tsv -o /home/GLBRCORG/emcdaniel/MicDiv/datasets/Zymo_Synthetic/inStrain/quick_profiles/$outfolder $sam /home/GLBRCORG/emcdaniel/MicDiv/datasets/Zymo_Synthetic/ref_genomes/all-zymo-genomes.fa