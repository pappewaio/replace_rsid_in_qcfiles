# install nextflow using mamba (requires conda/mamba)
mamba create -n replace_rsid_in_qcfiles --channel bioconda \
  nextflow==20.10.0
  
# Activate environment
conda activate replace_rsid_in_qcfiles

# Run a single file
nextflow run replace_rsid_in_qcfile.nf --input 'data/runfile/runfile.txt' --outdir out


