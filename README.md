# VireTap
### A pipline for general viral transcriptome detection in homo sapien RNA-seq data
A 03-713 Bioinformatics Practicum project. It is focused on virus detections of a given diseased model using RNA-seq data, and some further analyses including SNP analysis etc (not complete yet).

**WARNING:** This program needs to run on computers that have `slurm` activated (i.e. on PSC server, clustering servers).

### Download
Download the latest release to your local folder.

(Optional) Using shell script to download:
```bash
$ wget "https://github.com/c5shen/VireTap/releases/latest" \
wget "https://github.com$(egrep 'archive.*tar\.gz' latest | cut -d '"' -f 2)"
rm latest
```

### Installation
To install, extract files from the downloads.
```bash
$ tar -cvf [download].tar.gz
```
Then, `cd` into the newly made directory and `make` the binary executable.
```bash
$ make
```
This will output a binary executable `viretap` to the directory.

### Run VireTap
To run the program, execute the binary with the data access number you desire to perform viral transcriptome detection (for now, we only support human cell RNA-seq data).
```bash
$ ./viretap [ACCESSION]
```
Where `[ACCESSION]` refers to the accession number from NCBI for the particular RNA-seq dataset you are using.

#### Example
```bash
$ ./viretap SRR5787177
```

### Output
VireTap will download the **GRCh38 homo sapien cdna index** files from shared google drive, as well as a GI list of viruses for blast search.
VireTap will run `tophat`, `Trinity`, and `blastn` in sequence to find viral transcriptome in provided RNA-seq data. Then, it will construct a folder named `[ACCESSION]_data`, where all intermediate files are stored. A final blast output named `[ACCESSION]_blast_output.txt` will also be in that folder.
