# install nextflow using mamba (requires conda/mamba)
mamba create -n vcf_reference_build_tools_env --channel bioconda \
  nextflow==20.10.0 \
  bcftools=1.9 \
  tabix

# Activate environment
conda activate vcf_reference_build_tools_env

# Run a single file
nextflow replace_id.nf --input 'data/1kgp/GRCh37/GRCh37_example_data.vcf.gz' --mapfile 'path/to'
