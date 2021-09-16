# replace_rsid_in_qcfiles
This is a tailored pipeline to replace QC file IDs in the exact same way as the pipeline vcf_reference_build_tools, and could easily be moved over there when ready.

Version 1.0.0

## quick start

# install nextflow using mamba (requires conda/mamba)
mamba create -n replace_rsid_in_qcfiles --channel bioconda \
  nextflow==20.10.0
  
# Activate environment
conda activate replace_rsid_in_qcfiles

# Run a single file
nextflow run replace_rsid_in_qcfile.nf --input 'data/runfile/runfile.txt' --outdir out

## Background and mapping strategy
A previous mapping has been done to the VCF file that produces the QC-file-that is being mapped again here

One approach is(Note that the code right now is doing something different, so after this commit I will delete this note and rewrite the pipeline according to the plan outlined below):
We can use the produced mapfiles and match on chromosome_position_ref_alt information. This require the steps:
1) Merge all mapfiles
2) Add rownumber to qc-file
3) sort both mapfile and qc file on chromosome_position_ref_alt
4) check that there are no duplicates of this index
5) use unix join to align the information
6) check that everything had a match
7) prepare final output using the updated rsid


## Dev section

### imputeQualityMetrics example data
MAF and the other stats will just be 0.1, 0.2, 0.3, etc (which should be fine as we intend to only modify column 3 the rsID)

```
echo -e "CHR POS ID REF ALT MAF AR2 DR2 Hwe DR2 Accuracy Score" > data/imputeQCmetrics/imputeQualityMetrics.txt
zcat data/mapfiles/GRCh37_example_data.vcf.map.gz | tail -n+2 | awk '{print $2, $3, $4, $5, $6, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7 }'  >> data/imputeQCmetrics/imputeQualityMetrics.txt

#zip it
gzip -c data/imputeQCmetrics/imputeQualityMetrics.txt > data/imputeQCmetrics/imputeQualityMetrics.txt.gz 

#inspect file
zcat data/imputeQCmetrics/imputeQualityMetrics.txt.gz | head


```

### SNP_QC example data




