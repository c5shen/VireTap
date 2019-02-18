#!/bin/bash
#SBATCH -t 10:00:00
#SBATCH -p RM
#SBATCH -N 1
##SBATCH --mem=20GB
#SBATCH --ntasks-per-node 28
#SBATCH --output trinity.%j.log
#
# what modules to load
module load gcc/5.3.0
module load perl/5.18.4-threads
module load java/jdk8u73
module load bowtie2/2.2.7
module load samtools/1.3
module load jellyfish2/2.2.6
module load salmon/0.9.1
module load blat/v35
module load trinity/2.8.4
#
# define where to read in data and where to output
INDIR=`pwd`
OUTDIR=`pwd`
# no suffix file name
FILE=$1
set -x
#
date
echo "Now trinity starts"
cd $LOCAL
# set a timer to see how long this run
SECONDS=0
Trinity --no_version_check --seqType fq --max_memory 16G --CPU 4 \
  --output $OUTDIR/$FILE\_trinity \
  --single $INDIR/$FILE.fastq \
#
duration=$SECONDS
# output the runtime
echo "overall runtime: $(($duration / 60)) minutes and $(($duration % 60 )) seconds."
