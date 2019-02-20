#!/bin/bash
#SBATCH -t 10:00:00
#SBATCH -p RM
#SBATCH -N 1
##SBATCH --mem=120GB
#SBATCH --ntasks-per-node 28
#SBATCH --output tt_preprocess.%j.log
#
# load module
module load samtools
INDIR=$3
#
date
#
FILE=$1
PAIRED=$2
script=$4
samtools fastq $INDIR/$FILE\_tophat/unmapped.bam > temp.fastq
# haven't decide if it's necessary
if [ "$PAIRED" == 0 ]; then
	awk '{ if (NR % 4 == 1) print $0 "/1"; else print $0}' temp.fastq > $FILE\_unmapped.fastq
	rm temp.fastq
# if paired end tophat, then split unmapped to two files
else
	mv temp.fastq $FILE\_unmapped.fastq
	$INDIR/$script/bbmap/reformat.sh in=$FILE\_unmapped.fastq out1=$FILE\_unmapped_1.fastq out2=$FILE\_unmapped_2.fastq
fi
