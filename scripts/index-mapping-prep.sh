#! /bin/bash

# Usage ./index-mapping-prep.sh $datasetname
# Example bash index-mapping-prep.sh tanganyika

name=$1
fasta=all-$name-bins.fasta
scaffolds=$name-stb.tsv

# Concatenate all genomes in the fastas directory (already reformatted with genome name appended)

cat fastas/*.fa > $fasta

# make list of scaffold-to-bins pairings
# for use with InStrain's genome_wide workflow to profile genome wide SNPs and covg
grep '>' $fasta | sed 's|[<>,]||g' | awk -F '~' '{print $1"~"$2"\t"$1}' > $scaffolds

# index the combined reference file with bowtie2
mkdir bt2
bowtie2-build $fasta bt2/$fasta
