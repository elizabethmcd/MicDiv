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
r2_file=$(basename $reads _1.fastq.qced.ref.modf.fastq)_2.fastq.qced.ref.modf.fastq
samplename=$(basename $reads _1.fastq.qced.ref.modf.fastq)

# paths 
project_path="/home/GLBRCORG/emcdaniel/MicDiv/datasets"
dataset_path="${project_path}/Tanganyika" #dataset specific
reads_path="${dataset_path}/reformatted_reads"
mapping_path="${dataset_path}/mappingResults"
ref_path="${dataset_path}/ref_genomes/bt2/all-tangy-bins.fasta" #dataset specific
profile_path="${dataset_path}/profiles"
stb_path="${dataset_path}/ref_genomes/tangy-stb.tsv" #dataset specific
fasta_path="${dataset_path}/ref_genomes/all-tangy-bins.fasta" #dataset specific

# go to mapping folder
cd ${mapping_path}

# mapping command
/opt/bifxapps/bowtie2-2.3.5.1/bowtie2 --threads 8 --very-sensitive -x $ref_path -1 ${reads_path}/${r1_file} -2 ${reads_path}/${r2_file} > $samplename.sam

# BAM, sort, index
samtools view -S -b  $samplename.sam > $samplename.bam
samtools sort  $samplename.bam -o $samplename.sorted.bam
samtools index $samplename.sorted.bam $samplename.sorted.bam.bai

# deactivate and activate inStrain for profiling each sorted BAM sample file
source deactivate

export PATH=/home/GLBRCORG/emcdaniel/anaconda3/bin:$PATH
unset PYTHONPATH
source activate inStrain
PYTHONPATH=''

# profile command 

inStrain quick_profile -p 2 -s ${stb_path} -o ${profile_path}/${samplename}-quick-profile $samplename.sorted.bam ${fasta_path}

cd ${profile_path}/${samplename}-quick-profile

mv genomeCoverage.csv ${samplename}-genomeCoverage.csv

source deactivate
