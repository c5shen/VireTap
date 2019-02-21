#!/bin/bash
#SBATCH -t 10:00:00
#SBATCH -p RM
#SBATCH -N 1
##SBATCH --mem=120GB
#SBATCH --ntasks-per-node 28
#SBATCH --output VireTap.%j.log
#
#
CORE=8
MEM_TRINITY=60
index="GRCh38_cdna_index" 
#
# check for '-h' or '--help'
if [[ $1 == '-h' ]] || [[ $1 == '--help' ]]; then
	printf "\nWelcome to VireTap program. VireTap allows you to find viral transcriptomes in human RNA-seq data.\n"
	printf "\n\tDefault syntax:\t\t./viretap [ACCESSION #]\n"
	printf "\tExample:\t\t./viretap SRR5787177\n"
	printf "\nPlease read the info below, and refer to README for a more detailed pipline description and software prerequisites.\n"
	printf "\n\tDefault parameters for VireTap:\n"
	printf "\t>Default SLURM Node"
	printf "\tMax memory: 128GB, Max tasks: 28\n"
	printf "\t>Tophat"
	printf "\t\t\tCores used: $CORE, Max runtime: 48h\n"
	printf "\t>Trinity"
	printf "\t\tCores used: $CORE, Max memory: "$MEM_TRINITY"GB, Max runtime: 24h\n"
	printf "\t>Blast"
	printf "\t\t\tMax runtime: 10h\n"
	printf "\n\t-i|--index <string>\tSpecify index folder for Tophat.\n"
	printf "\t-a|--accession <string>\tSpecify the accession number.\n"
	printf "\t--num-cores <int>\tSpecify number of cores to use on node.\n"
	printf "\t--mem-trinity <int>\tNumber of GBs memory to use for Trinity.\n"
	printf "\nMore parameter modules will be coming soon.\n"
	exit 1
fi
POSITIONAL=()
if [[ $# == 1 ]]; then
	A_NUM="$1"
else
	while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
	-i|--index)
	index="$2"
	shift
	shift
	;;
	--num-cores)
	CORE="$2"
	shift
	shift
	;;
	--mem-trinity)
	MEM_TRINITY="$2"
	shift
	shift
	;;
	-a|--accession)
	A_NUM="$2"
	shift
	shift
	;;
	*)
	POSITIONAL+=("$1")
	shift
	;;
	esac
	done
fi
# restore positional parameters
set -- "${POSITIONAL[@]}"
# readlink for index folder
index=`readlink -f $index`
printf "\nRunning with these parameters:\n\tAccession number: $A_NUM\n\tIndex folder: $index\n\tTrinity memory(GB): $MEM_TRINITY\n\tNumber of cores: $CORE\n\n"
# record cur directory
DIR=`pwd`
printf "Working directory is $DIR\n\n"
# check for scripts
script="VireTap-scripts"
if [ ! -d "$script" ]; then
	echo "Scripts folder not found in current folder... Searching for installation..."
	# if not found locally, check in installed directory
	script="/usr/local/etc/VireTap-scripts"
	if [ ! -d "$script" ]; then
		echo "Couldn't find installation! Please redownload the latest release for scripts (namely VireTap-scripts)."
		exit 1
	fi
fi
# accession number (without suffix)
if [ -z "$A_NUM" ]; then
	printf "No accession number specified!\n"
	printf "syntax:\t./viretap [accession number]\n"
	printf "\t\tor\n\t./viretap -[options] -a [accession number]\n"
	exit 1
fi
# by default, we consider the reads to be paired
PAIRED=1
# module loading
module load sra-toolkit
#
#
# STEP 1: download data (if data already exists, skip this step)
if [ $(compgen -G "$A_NUM*.fastq" | wc -l) -gt 0 ]; then
	echo "$A_NUM fastq format already exists."
	echo "Please make sure they are complied to the Trinity input format."
	if [ ! -f $A_NUM*\_2.fastq ]; then
		PAIRED=0
	fi
else
	prefetch $A_NUM
	echo -e "\033[33;5mDownloading the fastq file(s) of $A_NUM \033[0m"
	fastq-dump --defline-seq '@$sn[_$rn]/$ri' --split-files $A_NUM
	# check if failed to download
	if [ ! -f $A_NUM* ]; then
		echo "Cannot download data from the server! Please contact the server admin for details."
		exit 1
	fi
	if [ ! -f $A_NUM\_2.fastq ]; then
		PAIRED=0
		mv $A_NUM\_1.fastq $A_NUM.fastq
	fi
	echo "Download completed."
fi
echo -e
case $PAIRED in
	1)
	echo "Data is paired."
	;;
	0)
	echo "Data is not paired."
	;;
esac
sleep 2
#
#
# STEP 1.5: download GRCh38 cdna index files
if [[ `compgen -G "$index/*.bt2" | wc -l` == 0 ]]; then
	echo "Did not find index files at given directory."
	echo "Download Homo sapiens cDNA indexes? (y/n)"
	read choice
	case $choice in
	y|Y|yes|Yes)
	;;
	*)
	echo "Exiting program..."
	exit 1
	;;
	esac
	curl -c /tmp/cookies -s "https://drive.google.com/uc?export=download&id=1s-8Mf-a4oOsDy_bmA9mSZIsM4ha66AWn" > tmp.html
	echo -e "Downloading index files from google drive..."
	sleep 1
	curl -L -b /tmp/cookies "https://drive.google.com$(cat tmp.html | grep -Po 'uc-download-link" [^>]* href="\K[^"]*' | sed 's/\&amp;/\&/g')" > GRCh38_cdna_index.tar.gz
	if [ -f tmp.html ]; then
		rm tmp.html
	fi
	echo "Download completed. Decompressing..."
	mkdir $index
	tar -xvzf GRCh38_cdna_index.tar.gz -C $index
	rm GRCh38_cdna_index.tar.gz
	if [ `ls $index | wc -l` -eq 0 ]; then
		echo "No indexes found in index folder!"
		exit 1
	fi
	index="$index/homo_sapien_GRCh38_index"
else
	echo "Index files detected. Hopefully they are good to use!"
	for i in $(compgen -G "$index/*.bt2"); do
		prefix="${i%.*.[A-Za-z0-9]*}"
		index="$prefix"
		echo "Index prefix is $index" 
		break
	done
fi
sleep 2
#
#
# STEP 2: run tophat alignment based on single/paired reads
# parameters: [paired or not] [accession] [directory]
tophat_job=`sbatch "$script/tophat.sbatch" $index $PAIRED $A_NUM $DIR $CORE`
# the job number storage
tophat_job=`echo $tophat_job | cut -d " " -f 4`
echo "Tophat job number is $tophat_job"
sleep 2
#
#
# STEP 2.5: preprocess the alignment data (unmapped)
# parameters: [accession] [paired or not] [directory] [script folder name]
prep_job=`sbatch --dependency afterany:"$tophat_job" "$script/tt_preprocess.sbatch" $A_NUM $PAIRED $DIR $script`
prep_job=`echo $prep_job | cut -d " " -f 4`
echo "Preprocessing job number is $prep_job"
sleep 2
#
#
# STEP 3: run trinity on the unmapped fastq file
# parameters: [accession]_unmapped [directory] [paired or not]
trinity_job=`sbatch --dependency afterany:"$prep_job" "$script/trinity.sbatch" $A_NUM\_unmapped $DIR $PAIRED $CORE $MEM_TRINITY`
trinity_job=`echo $trinity_job | cut -d " " -f 4`
echo "Trinity job number is $trinity_job"
sleep 2
#
#
# STEP 3.5: download sequence.gi (gilist) from google drive
echo "Downloading virus GI list..."
wget -q --no-check-certificate 'https://docs.google.com/uc?export=download&id=1B9c-jwMf_rp-McLFtZgcPIv9OHTr_dhV' -O sequence.gi
echo "Download completed."
sleep 2
#
#
# STEP 4: run blast on Trinity result
# parameters: [Trinity.fasta location] [accession] [directory]
blast_job=`sbatch --dependency afterany:"$trinity_job" "$script/blastn.sbatch" $A_NUM\_unmapped\_trinity/Trinity.fasta 0 $A_NUM $DIR`
blast_job=`echo $blast_job | cut -d " " -f 4`
echo "Blast job number is $blast_job"
sleep 2
#
#
# STEP 5: organize the files
# parameters: [accession] [all job numbers]
job="$tophat_job $prep_job $trinity_job $blast_job"
organizer_job=`sbatch --dependency afterany:"$blast_job" "$script/organizer.sbatch" $A_NUM $job`
organizer_job=`echo $organizer_job | cut -d " " -f 4`
echo "Organizer job number is $organizer_job"
sleep 2
echo -e
echo "Please check on your job status by the IDs provided above. After the last job finished (BLAST), you will get a output file at current directory, named blast_output."
