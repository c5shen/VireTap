# VireTap
### A pipline for general viral transcriptome detection in homo sapien RNA-seq data
A 03-713 Bioinformatics Practicum project. It is focused on virus detections of a given diseased model using RNA-seq data, and some further analyses including SNP analysis etc (not complete yet).

**WARNING:** This program needs to run on computers that have `slurm` activated (i.e. on PSC server, clustering servers).

### Download
Download the latest release to your local folder (adapted from [steinwaywhw's github blog](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8)).
```bash
curl -s https://github.com/c5shen/VireTap/releases/latest \
| grep browser_download_url \
| grep linux64 \
| cut -d '"' -f 4 \
| wget -qi -
```

Default way to run this code after download:
```bash
./viretap [ACCESSION]
```
Where `[ACCESSION]` refers to the accession number from NCBI for the particular RNA-seq dataset you are using.

#### Example
```bash
./viretap SRR5787177
```
