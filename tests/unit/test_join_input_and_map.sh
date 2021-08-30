#!/usr/bin/env bash

set -euo pipefail

test_script="join_input_and_map"
initial_dir=$(pwd)"/${test_script}"
curr_case=""

mkdir "${initial_dir}"
cd "${initial_dir}"

#=================================================================================
# Helpers
#=================================================================================

function _setup {
  mkdir "${1}"
  cd "${1}"
  curr_case="${1}"
}

function _check_results {
  obs=$1
  exp=$2
  if ! diff -u ${obs} ${exp} &> ./difference; then
    echo "- [FAIL] ${curr_case}"
    cat ./difference 
    exit 1
  fi

}

function _run_script {

  "${test_script}.sh" ./input1.vcf.gz ./input2.vcf.gz ./observed-result1.vcf.gz

#echo "----"
#gunzip -c ./observed-result1.vcf.gz 
#echo "----"
#gunzip -c ./expected-result1.vcf.gz
#echo "----"

  _check_results <( gunzip -c ./observed-result1.vcf.gz | grep -v bcftools_annotate ) <( gunzip -c ./expected-result1.vcf.gz )

  # I haven't figured out how to compared .tbi files
  #_check_results ./observed-result1.vcf.gz.tbi ./expected-result1.vcf.gz.tbi

  echo "- [OK] ${curr_case}"

  cd "${initial_dir}"
}

echo ">> Test ${test_script}"

#=================================================================================
# Cases
#=================================================================================

#---------------------------------------------------------------------------------
# Check that the final output is what we think it is

_setup "check simple diff and missing values"

cat <<EOF > ./tmp0
##fileformat=VCFv4.3
##FILTER=<ID=PASS,Description="All filters passed">
##fileDate=20210505
##source=exampleTestData
##INFO=<ID=AN,Number=1,Type=Integer,Description="Total number of alleles in called genotypes">
##contig=<ID=1>
##contig=<ID=2>
#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO
EOF

cat <<EOF | awk -vOFS="\t" '{$1=$1; print}' | sort -t "$(printf '\t')" -k1,1 -k2,2n > ./tmp
1       7845695 rs228729        T       C       .       PASS	AN=5096
1       8473813 rs12754538      C       T       .       PASS	AN=5096
1       10593296        rs2480782       G       T       .       PASS	AN=5096
1       18420144        rs12565367      A       G       .       PASS	AN=5096
1       20614452        rs12139607      C       T       .       PASS	AN=5096
1       21959590        rs0000000       T       C       .       PASS	AN=5096
1       24947948        rs4649005       C       T       .       PASS	AN=5096
1       39079150        rs3011199        A       C       .       PASS	AN=5096
2       27374218        rs537951       G       A       .       PASS	AN=5096
EOF
cat ./tmp0 ./tmp | bgzip -c > ./input1.vcf.gz
tabix -p vcf input1.vcf.gz

## This is the prepared mapfile in vcf format
# missing row - rs3011199
# missing snp - .
# name that differs - rs9999999
cat <<EOF | awk -vOFS="\t" '{$1=$1; print}' | sort -t "$(printf '\t')" -k1,1 -k2,2n > ./tmp
1       7845695 rs228729        T       C       .       PASS	AN=5096
1       8473813 rs12754538      C       T       .       PASS	AN=5096
1       10593296        rs2480782       G       T       .       PASS	AN=5096
1       18420144        .      A       G       .       PASS	AN=5096
1       20614452        rs12139607      C       T       .       PASS	AN=5096
1       21959590        rs9999999       T       C       .       PASS	AN=5096
1       24947948        rs4649005       C       T       .       PASS	AN=5096
2       27374218        rs537951        G       A       .       PASS	AN=5096
EOF
cat ./tmp0 ./tmp | bgzip -c > ./input2.vcf.gz
tabix -p vcf input2.vcf.gz

cat <<EOF | awk -vOFS="\t" '{$1=$1; print}' | sort -t "$(printf '\t')" -k1,1 -k2,2n > ./tmp
1       7845695 rs228729        T       C       .       PASS	AN=5096
1       8473813 rs12754538      C       T       .       PASS	AN=5096
1       10593296        rs2480782       G       T       .       PASS	AN=5096
1       18420144        rs12565367      A       G       .       PASS	AN=5096
1       20614452        rs12139607      C       T       .       PASS	AN=5096
1       21959590        rs9999999       T       C       .       PASS	AN=5096
1       24947948        rs4649005       C       T       .       PASS	AN=5096
1       39079150        rs3011199       A       C       .       PASS	AN=5096
2       27374218        rs537951        G       A       .       PASS	AN=5096
EOF
cat ./tmp0 ./tmp | bgzip -c > ./expected-result1.vcf.gz
tabix -p vcf expected-result1.vcf.gz

_run_script

#---------------------------------------------------------------------------------
# Next case

