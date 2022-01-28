#! /usr/bin/env python

# Fixing FASTQ files downloaded from SRA that have matching paired end reads but header names between pairs don't match exactly. Bowtie2 and downstream programs then don't recognize the paired-end reads. With fastq-dump only paired-end reads that pass in both _1 and _2 files are deposited, singletons are put into a different file or thrown out. This script assumes same number of reads in the files
#
# The read counts are also the same in each FASTQ.
# -------
# Example
# -------
# Read 1
# @@SRR12324253.1001.1 A00351:194:HMVL5DSXX:4:1101:18891:1517 length=150
#
# Becomes
# @SRR12324253.1001 1:N:0
#
# Matches closer to what comes directly off Illumina HiSeq for headers in interleaved file such as
# @A00887:333:H2YJMDSX2:1:1101:1199:1031 1:N:0:TCACCTAG+CGTAGGTT
# @A00887:333:H2YJMDSX2:1:1101:1199:1031 2:N:0:TCACCTAG+CGTAGGTT

# Where quality score header is just a + but this script changes the header format to be consistent between the sequence header and the quality score header

# Clock at approximately 10 minutes for a medium size FASTQ file (~25GB)
# Feed to repair.sh in BBtools for interleaving the two paired end files for easier distribution downstream

import argparse
import gzip

def parse_args():
    """
    Parses the command line arguments.
    """
    parser = argparse.ArgumentParser(description='Fix fastq headers.')
    parser.add_argument('input', type=str, help='Input FASTQ - gzip accepted')
    parser.add_argument('output', type=str, help='Output FASTQ')

    return parser.parse_args()

def open_file(path):
    """
    Obtain file handle if gzipped or normal text file.
    """
    if path.endswith('.gz'):
        return gzip.open(path, 'rt')

    return open(path, 'r')

def is_read1(file_path):
    """
    Infer read from file name. Files named _1 or _2 for paired end reads.
    """
    return "read1" in file_path

def main():
    args = parse_args()
    read1 = '_1' in (args.input)

    with open_file(args.input) as f:
        with open(args.output, "w") as w:
            for line in f:
                new_line = line

                if line.startswith("@"):
                    data = line.strip().split(".", 3)
                    del data[-1]                   
                    new_line = ".".join(data)

                    if read1:
                        new_line = new_line + " 1:N:0"
                    else:
                        new_line = new_line + " 2:N:0"

                    new_line = new_line + "\n"
                    
                elif line.startswith("+"):
                    data = line.strip().split(".",3)
                    del data[-1]
                    new_line = ".".join(data)
                    	
                    if read1:
                    	new_line = new_line + " 1:N:0"
                    else: 
                    	new_line = new_line + " 2:N:0"
                    	
                    new_line = new_line + "\n"

                w.write(new_line)
              			

if __name__ == "__main__":
    main()