#!/bin/bash
#SBATCH -t 10:00:00
#SBATCH -p RM
#SBATCH -N 1
##SBATCH --mem=120GB
#SBATCH --ntasks-per-node 28
#SBATCH --output blastn.%j.log
#
# what modules to load
module load samtools
module load blast
#
QUERY=$1
OUTFMT=$2
FILE=$3
set -x
date
echo "Start blast on $1 with default database nt"
SECONDS=0
blastn -query $QUERY -out ./$FILE\_blast_output.txt -outfmt $OUTFMT -gilist sequence.gi -db nt
#
duration=$SECONDS
echo "overall runtime: $(($duration / 60)) minutes and $(($duration % 60)) seconds."
