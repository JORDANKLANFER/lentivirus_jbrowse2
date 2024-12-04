# User Guide

## Prerequisites
- Node.js and Yarn installed.
- Access to the project repository.

## Setup Instructions
1. Clone the shared github repository
2. Navigate to Jbrowse-components
3. Install dependencies: (will put all commands in before we are done,   and non mac ones as well)- we can seee if we can streamline this for deplyoment instructions 
    - Run yarn install
    - bash (most likely already on your computer)
    - install wget 
    - install rm (most likely already on computer)
    - install wget tabix : brew install wget tabix
    - make sure gzip is in your wget libray 
    - ensure all jbrowse tools installed : npm install -g @jbrowse/cli
    - install samtools: brew install samtools
    - install bgzip and tabix: brew install htslib

5. Go to Jbrowse_componenets/products/jbrowse-web/public and run data download script in your terminal
    - ./fetch_and_process_data.sh 
    - MAKE SURE YOU ARE IN THE public directory 
    - this will populate the data folders as well as create a trix folder in the public directory that is used for text indexing
    - shoulnt need to run script agin, if you need to make sure to delete all data subfolders and trix folder 
    - the data and trix files will not be pushed to github because the script is meant to fetch them
6.  Navigate to jbrowse-components/products/jbrowse-web
7.  In terminal: yarn start
8. Now your JBrowse window should pop up at: http://localhost:3000