#! /bin/bash
# Reformat and call genes on all sequences, outputting the protein files

# unzip downloaded files
gunzip */*.gz
echo Unzipped all files

# rename based on directory name
for filename in */*.fna; do mv $filename ${filename%/*}/${filename%/*}.fna; done
echo Renamed all files

# make .fa
for filename in */*.fna; do name=$(basename $filename .fna).fa; mv $filename $name; done
echo Reformatted files

# call genes with Prodigal and output proteins
for file in *.fa; do 
    N=$(basename $file .fa);
    prodigal -i $file -d $N.genes.fna -a $N.faa;
done
echo Annotated files

# move files up to ref_genomes directory
mv */* ../../.

echo Finished!
