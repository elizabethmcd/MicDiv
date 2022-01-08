#! /bin/bash 

export PATH=/home/GLBRCORG/emcdaniel/bin
unset PYTHONPATH
PYTHONPATH=''

# Each SRA experiment queued from the metadata file
srr=$1
directory=$2

# cd into the directory to store

cd $directory 

# download the SRAs with fastq dump 

fastq-dump --split-3 --readids --dumpbase --outdir ./ $srr 