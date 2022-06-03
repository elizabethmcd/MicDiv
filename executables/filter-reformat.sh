#! /bin/bash

# arguments from queue file 
fastq_file=$1
samplename=$(basename $fastq_file _1.fastq)
r1=$(basename $fastq_file)
r2=$(basename $fastq_file _1.fastq)_2.fastq 
out1="${r1}_qced_1.fastq"
out2="${r2}_qced_2.fastq"
dir=$(dirname $fastq_file)

# set path where fastp is installed in local home directory bin
FASTPATH=/home/GLBRCORG/emcdaniel/bin/

# cd to filtered folder
cd ${dir}
cd ../cleaned_reads

# filter with fastp 
$FASTPATH/fastp -i ${dir}/${r1} -I ${dir}/${r2} -o $out1 -O $out2 --cut_tail -h $samplename.html

# rename the fastq PE headers 
python /home/GLBRCORG/emcdaniel/MicDiv/scripts/fastq-pair-headers.py $out1 ${r1}_qced_ref_R1.fastq
python /home/GLBRCORG/emcdaniel/MicDiv/scripts/fastq-pair-headers.py $out2 ${r2}_qced_ref_R2.fastq 



