#!/bin/bash

# Genome and Annotation Fetching Script

# Ensure all libraries and packages are installed! 
    ##refer to user_guide.md for relevent installations
# Ensure in jbrowse-web/public directory 
    ## /Jbrowse_components/products/jbrowse-web/public 
# Run script in terminal: ./fetch_and_process_data.sh
# ------------------------------------------------------------------------

# checks in correct directory
cd "$(dirname "$0")"


# reference genome and annotation URL's from NCBI GenBank 
HIV1_reference_genome="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/864/765/GCF_000864765.1_ViralProj15476/GCF_000864765.1_ViralProj15476_genomic.fna.gz"
HIV1_annotations="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/864/765/GCF_000864765.1_ViralProj15476/GCF_000864765.1_ViralProj15476_genomic.gff.gz"

HIV2_reference_genome="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/856/385/GCF_000856385.1_ViralProj14991/GCF_000856385.1_ViralProj14991_genomic.fna.gz"
HIV2_annotations="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/856/385/GCF_000856385.1_ViralProj14991/GCF_000856385.1_ViralProj14991_genomic.gff.gz"

SIV_reference_genome="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/863/925/GCF_000863925.1_ViralProj15501/GCF_000863925.1_ViralProj15501_genomic.fna.gz"
SIV_annotations="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/863/925/GCF_000863925.1_ViralProj15501/GCF_000863925.1_ViralProj15501_genomic.gff.gz"


#checks if data directories already exist, if not download and process data
if [[ -d "data/hiv1_data" && -d "data/hiv2_data" && -d "data/siv_data" ]]; then
    echo "data already downloaded and processed." 
else   
    # create data directories
    mkdir -p ./data/hiv1_data ./data/hiv2_data ./data/siv_data

    # fetches and downloads NCBI Genbank files 
    wget -O ./data/hiv1_data/hiv1_genome.fna.gz "$HIV1_reference_genome"
    wget -O ./data/hiv1_data/hiv1_annotations.gff.gz "$HIV1_annotations"

    wget -O ./data/hiv2_data/hiv2_genome.fna.gz "$HIV2_reference_genome"
    wget -O ./data/hiv2_data/hiv2_annotations.gff.gz "$HIV2_annotations"

    wget -O ./data/siv_data/siv_genome.fna.gz "$SIV_reference_genome"
    wget -O ./data/siv_data/siv_annotations.gff.gz "$SIV_annotations"

    # unzipps reference genome files 
    gunzip -f ./data/hiv1_data/hiv1_genome.fna.gz
    gunzip -f ./data/hiv2_data/hiv2_genome.fna.gz
    gunzip -f ./data/siv_data/siv_genome.fna.gz

    # indexing referene genome files 
    samtools faidx ./data/hiv1_data/hiv1_genome.fna
    samtools faidx ./data/hiv2_data/hiv2_genome.fna
    samtools faidx ./data/siv_data/siv_genome.fna

    #unzips, sorts, compresses, and indexes annotation files

    #hiv1 annotation processing 
    gunzip -c ./data/hiv1_data/hiv1_annotations.gff.gz > ./data/hiv1_data/hiv1_annotations.gff
    jbrowse sort-gff ./data/hiv1_data/hiv1_annotations.gff > ./data/hiv1_data/hiv1_sorted_annotations.gff
    bgzip -c ./data/hiv1_data/hiv1_sorted_annotations.gff > ./data/hiv1_data/hiv1_sorted_annotations.gff.gz
    tabix ./data/hiv1_data/hiv1_sorted_annotations.gff.gz

    #hiv2 annotation processing 
    gunzip -c ./data/hiv2_data/hiv2_annotations.gff.gz > ./data/hiv2_data/hiv2_annotations.gff
    jbrowse sort-gff ./data/hiv2_data/hiv2_annotations.gff > ./data/hiv2_data/hiv2_sorted_annotations.gff
    bgzip -c ./data/hiv2_data/hiv2_sorted_annotations.gff > ./data/hiv2_data/hiv2_sorted_annotations.gff.gz
    tabix ./data/hiv2_data/hiv2_sorted_annotations.gff.gz

    #siv annotation processing 
    gunzip -c ./data/siv_data/siv_annotations.gff.gz > ./data/siv_data/siv_annotations.gff
    jbrowse sort-gff ./data/siv_data/siv_annotations.gff > ./data/siv_data/siv_sorted_annotations.gff
    bgzip -c ./data/siv_data/siv_sorted_annotations.gff > ./data/siv_data/siv_sorted_annotations.gff.gz
    tabix ./data/siv_data/siv_sorted_annotations.gff.gz

    # removes unnecssary files
    rm ./data/hiv1_data/hiv1_annotations.gff
    rm ./data/hiv1_data/hiv1_annotations.gff.gz
    rm ./data/hiv1_data/hiv1_sorted_annotations.gff
    rm ./data/hiv2_data/hiv2_annotations.gff
    rm ./data/hiv2_data/hiv2_annotations.gff.gz
    rm ./data/hiv2_data/hiv2_sorted_annotations.gff
    rm ./data/siv_data/siv_annotations.gff
    rm ./data/siv_data/siv_annotations.gff.gz
    rm ./data/siv_data/siv_sorted_annotations.gff
fi
#creates text index for Jbrowse 
jbrowse text-index --target ./ --force
echo "All done!"

