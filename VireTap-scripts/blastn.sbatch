#!/bin/bash
#SBATCH -t 10:00:00
#SBATCH -p RM-shared
#SBATCH -N 1
##SBATCH --mem=120GB
#SBATCH --ntasks-per-node 10
#SBATCH --output blastn.%j.log
#
# what modules to load
module load samtools
module load blast
#
OUTDIR=$4
QUERY=$1
OUTFMT=$2
FILE=$3
script=$5
set -x
date
echo "Start blast on $1 with default database nt"
SECONDS=0
blastn -query $QUERY -out $OUTDIR/$FILE\_blast_output.txt -outfmt $OUTFMT -gilist sequence.gi -db nt
#
# brief overview of all the hits
#awk '/^>/ {print $0}' $OUTDIR/$FILE\_blast_output.txt > $FILE\_blast_overview.txt
# overview of data by ranking of E-value/Scores (by Shubhakar)
if [[ `pip list | grep "tabulate" | wc -l` == 0 ]]; then
	pip install --user tabulate
fi
python $script/parse_output.py $OUTDIR/$FILE\_blast_output.txt $OUTDIR/$FILE\_blast_overview.txt
duration=$SECONDS
echo "overall runtime: $(($duration / 60)) minutes and $(($duration % 60)) seconds."
