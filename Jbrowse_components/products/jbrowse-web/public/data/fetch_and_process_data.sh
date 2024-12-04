#!/bin/bash
# ========================================================================
# # Genome and Annotation Fetching Script
# ========================================================================
# ## Refer to user_guide.md for libary and package requirements 
# ## Run script in Jbrowse_components/products/jbrowse-web/public/data 
# ## To run script: ./fetch_and_process_data.sh in terminal 
# ------------------------------------------------------------------------

# reference genome and annotation URL's from NCBI GenBank 
HIV1_reference_genome="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/864/765/GCF_000864765.1_ViralProj15476/GCF_000864765.1_ViralProj15476_genomic.fna.gz"
HIV1_annotations="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/864/765/GCF_000864765.1_ViralProj15476/GCF_000864765.1_ViralProj15476_genomic.gff.gz"

HIV2_reference_genome="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/856/385/GCF_000856385.1_ViralProj14991/GCF_000856385.1_ViralProj14991_genomic.fna.gz"
HIV2_annotations="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/856/385/GCF_000856385.1_ViralProj14991/GCF_000856385.1_ViralProj14991_genomic.gff.gz"

SIV_reference_genome="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/863/925/GCF_000863925.1_ViralProj15501/GCF_000863925.1_ViralProj15501_genomic.fna.gz"
SIV_annotations="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/863/925/GCF_000863925.1_ViralProj15501/GCF_000863925.1_ViralProj15501_genomic.gff.gz"

# create data directories 
mkdir -p hiv1_data hiv2_data siv_data jbrowse_out

# fetches and downloads NCBI Genbank files 
wget -O hiv1_data/hiv1_genome.fna.gz "$HIV1_reference_genome"
wget -O hiv1_data/hiv1_annotations.gff.gz "$HIV1_annotations"

wget -O hiv2_data/hiv2_genome.fna.gz "$HIV2_reference_genome"
wget -O hiv2_data/hiv2_annotations.gff.gz "$HIV2_annotations"

wget -O siv_data/siv_genome.fna.gz "$SIV_reference_genome"
wget -O siv_data/siv_annotations.gff.gz "$SIV_annotations"

# unzipps reference genome files 
gunzip -f hiv1_data/hiv1_genome.fna.gz
gunzip -f hiv2_data/hiv2_genome.fna.gz
gunzip -f siv_data/siv_genome.fna.gz

# indexing referene genome files 
samtools faidx hiv1_data/hiv1_genome.fna
samtools faidx hiv2_data/hiv2_genome.fna
samtools faidx siv_data/siv_genome.fna

#unzips, sorts, compresses, and indexes annotation files 
gunzip -c hiv1_data/hiv1_annotations.gff.gz > hiv1_data/hiv1_annotations.gff
jbrowse sort-gff hiv1_data/hiv1_annotations.gff > hiv1_data/hiv1_sorted_annotations.gff
bgzip -c hiv1_data/hiv1_sorted_annotations.gff > hiv1_data/hiv1_sorted_annotations.gff.gz
tabix hiv1_data/hiv1_sorted_annotations.gff.gz

gunzip -c hiv2_data/hiv2_annotations.gff.gz > hiv2_data/hiv2_annotations.gff
jbrowse sort-gff hiv2_data/hiv2_annotations.gff > hiv2_data/hiv2_sorted_annotations.gff
bgzip -c hiv2_data/hiv2_sorted_annotations.gff > hiv2_data/hiv2_sorted_annotations.gff.gz
tabix hiv2_data/hiv2_sorted_annotations.gff.gz


gunzip -c siv_data/siv_annotations.gff.gz > siv_data/siv_annotations.gff
jbrowse sort-gff siv_data/siv_annotations.gff > siv_data/siv_sorted_annotations.gff
bgzip -c siv_data/siv_sorted_annotations.gff > siv_data/siv_sorted_annotations.gff.gz
tabix siv_data/siv_sorted_annotations.gff.gz

# removes unnecssary files
rm hiv1_data/hiv1_annotations.gff
rm hiv1_data/hiv1_annotations.gff.gz
rm hiv1_data/hiv1_sorted_annotations.gff
rm hiv2_data/hiv2_annotations.gff
rm hiv2_data/hiv2_annotations.gff.gz
rm hiv2_data/hiv2_sorted_annotations.gff
rm siv_data/siv_annotations.gff
rm siv_data/siv_annotations.gff.gz
rm siv_data/siv_sorted_annotations.gff

#runs JBrowse text indexing 
jbrowse text-index --out jbrowse_out


echo "All files processed and indexed successfully."
