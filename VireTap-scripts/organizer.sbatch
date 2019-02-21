#!/bin/bash
#BATCH -t 10:00:00
#SBATCH -p RM
#SBATCH -N 1
##SBATCH --mem=120GB
#SBATCH --ntasks-per-node 28
#SBATCH --output organizer.%j.log
#
A_NUM=$1
job=$*
data=$A_NUM\_data
#set -x
# if no [accession]_data folder created, create it
if [ ! -d $data ]; then
        mkdir $data
fi
cd $data
# move log files
mkdir logs
cd ..
for f in $job; do
        if [ -f *.$f\.log ]; then
                mv *.$f\.log $data/logs/
        fi
done
# move all other related files to $data
for f in `compgen -G "$A_NUM*"`; do
        if [ "$f" = "$data" ]; then
                continue
        elif [ -d f ]; then
                mkdir $data/$f
                mv $f/* $data/$f/
        else
                mv $f $data/
        fi
done
