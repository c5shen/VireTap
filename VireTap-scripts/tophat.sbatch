#!/bin/bash
#SBATCH -t 48:00:00
#SBATCH -p RM
#SBATCH -N 1
##SBATCH --mem=120GB
#SBATCH --ntasks-per-node 28
#SBATCH --output tophat.%j.log
#
# what modules to load
module load gcc/5.3.0
module load perl/5.18.4-threads
module load java/jdk8u73
module load cufflinks
module load tophat
module load bowtie2/2.2.7
module load samtools/1.3
#module load jellyfish2/2.2.6
#module load salmon/0.9.1
#module load blat/v35
#module load trinity/2.8.4
#
# Index folder
INDEX=$1
# paired or not
PAIRED=$2
# no suffix file name
FILE=$3
# define where to read in data and where to output
INDIR=$4
OUTDIR=$4
# define how many cores to use
CORE=$5
set -x
#
date
#DIR=`echo $FILE | cut -d "_" -f 1`
echo "Now tophat starts"
cd $LOCAL
if [ ! -d "$OUTDIR/$FILE\_tophat" ]; then
	mkdir $OUTDIR/$FILE\_tophat
fi
# set a timer to see how long this run
SECONDS=0
if [ "$PAIRED" == 0 ]; then
	tophat -p $CORE -o $OUTDIR/$FILE\_tophat $INDEX "$INDIR/$FILE.fastq"
else
	tophat -p $CORE -o $OUTDIR/$FILE\_tophat $INDEX $INDIR/$FILE\_1.fastq $INDIR/$FILE\_2.fastq
fi
#
duration=$SECONDS
# output the runtime
echo "overall runtime: $(($duration / 60)) minutes and $(($duration % 60 )) seconds."
