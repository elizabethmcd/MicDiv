#! /bin/bash

###################
# Filtering metagenomic samples with fastp
# For use on WEI GLBRC servers running HT Condor
# Elizabeth McDaniel
##################

# set path where fastp is installed in local home directory bin
FASTPATH=/home/GLBRCORG/emcdaniel/bin/

# queueing r1 r2 metagenomic reads and output folder/file names
file1=$1
file2=$2
out1=$3
out2=$4
samplename=$(basename $out2 _2.fastq)

$FASTPATH/fastp -i $file1 -I $file2 -o $out1 -O $out2 --cut_tail -h $samplename.html