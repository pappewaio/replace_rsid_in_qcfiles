# install nextflow using mamba (requires conda/mamba)
mamba create -n replace_rsid_in_qcfiles --channel bioconda \
  nextflow==20.10.0
  
# Activate environment
conda activate replace_rsid_in_qcfiles

# Run a single file
nextflow replace_id.nf --input 'data/1kgp/GRCh37/GRCh37_example_data.vcf.gz' --mapfile 'path/to'
