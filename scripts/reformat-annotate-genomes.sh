#! /bin/bash
# Reformat and call genes on all sequences, outputting the protein files
# Run the script from the refGenomes directory, where subdirectories fastas and annotations can be made and then go into genbank/archaea and genbank/bacteria

# Make directories
mkdir -p fastas annotations

# archaea folder first
cd genbank/archaea

# unzip downloaded files
gunzip */*.gz
echo Unzipped all files

# rename based on directory name
for filename in */*.fna; do mv $filename ${filename%/*}/${filename%/*}.fna; done
echo Renamed all files

# make .fa and adjust headers with genome filename appended
for filename in */*.fna; do name=$(basename $filename .fna).fa; mv $filename $name; done
for file in *.fa; do GENOME=`basename ${file%.fa}`; sed -i "s|^>|>${GENOME}~|" $file; done
echo Reformatted files

# call genes with Prodigal and output proteins
for file in *.fa; do 
    N=$(basename $file .fa);
    prodigal -i $file -d $N.genes.fna -a $N.faa;
done
echo Annotated files

# move files to the fastas and annotations directories
mv *.fa ../../fastas
mv *.fna ../../annotations
mv *.faa ../../annotations

echo Finished with Archaea directory!

# cd into the bacteria folder
cd ../bacteria

# do all the above steps
# unzip downloaded files
gunzip */*.gz
echo Unzipped all files

# rename based on directory name
for filename in */*.fna; do mv $filename ${filename%/*}/${filename%/*}.fna; done
echo Renamed all files

# make .fa and adjust headers with genome filename appended
for filename in */*.fna; do name=$(basename $filename .fna).fa; mv $filename $name; done
for file in *.fa; do GENOME=`basename ${file%.fa}`; sed -i "s|^>|>${GENOME}~|" $file; done
echo Reformatted files

# call genes with Prodigal and output proteins
for file in *.fa; do
    N=$(basename $file .fa);
    prodigal -i $file -d $N.genes.fna -a $N.faa;
done
echo Annotated files

# move files to the fastas and annotations directories
mv *.fa ../../fastas
mv *.fna ../../annotations
mv *.faa ../../annotations

echo Finished with Bacteria directory!

echo Finished reformatting and annotating all reference genomes!
