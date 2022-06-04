#! /bin/bash 

# setup environment for samtools dependencies to work 
export PATH=/home/GLBRCORG/emcdaniel/anaconda3/bin:$PATH
unset PYTHONPATH
source activate coverM
PYTHONPATH=''

# feed a metadata file of names of the R1 fastq files
# arguments
reads=$1
r1_file=$(basename $reads)
r2_file=$(basename $reads _1.fastq_qced_ref_R1.fastq)_2.fastq_qced_ref_R2.fastq
samplename=$(basename $reads _1.fastq_qced_ref_R1.fastq)

# paths 
project_path="/home/GLBRCORG/emcdaniel/MicDiv/datasets"
dataset_path="${project_path}/Guayamas_Dombrowski" #dataset specific
reads_path="${dataset_path}/reformatted_reads"
mapping_path="${dataset_path}/mappingResults"
ref_path="${dataset_path}/ref_genomes/bt2/all-guayamas-bins.fasta" #dataset specific
profile_path="${dataset_path}/profiles"
stb_path="${dataset_path}/ref_genomes/guayamas-stb.tsv" #dataset specific
fasta_path="${dataset_path}/ref_genomes/all-guayamas-bins.fasta" #dataset specific

# go to mapping folder
cd ${mapping_path}

# mapping command
/opt/bifxapps/bowtie2-2.3.5.1/bowtie2 --threads 8 --very-sensitive -x $ref_path -1 ${reads_path}/${r1_file} -2 ${reads_path}/${r2_file} > $samplename.sam

# BAM, sort, index
samtools view -S -b  $samplename.sam > $samplename.bam
samtools sort  $samplename.bam -o $samplename.sorted.bam
samtools index $samplename.sorted.bam $samplename.sorted.bam.bai

# cleanup
mv *.sorted.bam ../sorted_bams
mv *.sorted.bam.bai ../sorted_bams
rm -rf *.bam
rm -rf *.sam

# deactivate and activate inStrain for profiling each sorted BAM sample file
source deactivate

export PATH=/home/GLBRCORG/emcdaniel/anaconda3/bin:$PATH
unset PYTHONPATH
source activate inStrain
PYTHONPATH=''

# move to sorted bams folder
cd ../sorted_bams 

# profile command 

inStrain quick_profile -p 2 -s ${stb_path} -o ${profile_path}/${samplename}-quick-profile $samplename.sorted.bam ${fasta_path}

cd ${profile_path}/${samplename}-quick-profile

mv genomeCoverage.csv ${samplename}-genomeCoverage.csv

source deactivate
