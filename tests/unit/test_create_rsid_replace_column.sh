#!/usr/bin/env bash

set -euo pipefail

test_script="create_rsid_replace_column"
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
  if ! diff ${obs} ${exp} &> ./difference; then
    echo "- [FAIL] ${curr_case}"
    cat ./difference 
    exit 1
  fi

}

function _run_script {

  "${test_script}.sh" ./input.tsv ./observed-result1.tsv

  _check_results ./observed-result1.tsv ./expected-result1.tsv

  echo "- [OK] ${curr_case}"

  cd "${initial_dir}"
}

echo ">> Test ${test_script}"

#=================================================================================
# Cases
#=================================================================================

#---------------------------------------------------------------------------------
# Check that the final output is what we think it is

_setup "simple case"

cat <<EOF > ./input.tsv
ROWINDEX CHR POS ID REF ALT CHROM_GRCh38 POS_GRCh38 ID_dbSNP151 REF_dbSNP151 ALT_dbSNP151
10 10 104573936 . T C NA NA NA NA NA
12 10 10616485 . T C 10 10616485 rs2025468 T C
15 10 108131461 . C A 10 108131461 rs1409409 C A
EOF

cat <<EOF > ./expected-result1.tsv
ROWINDEX NEWRSID
10 10_104573936_T_C if_rsid_not_in_dbsnp_or_original
12 rs2025468 if_not_in_original_but_exists_in_dbsnp_chrom_ref_alt_are_same
15 rs1409409 if_not_in_original_but_exists_in_dbsnp_chrom_ref_alt_are_same
EOF

_run_script

#---------------------------------------------------------------------------------
# Next case

_setup "a collection of cases"

cat <<EOF > ./input.tsv
ROWINDEX CHR POS ID REF ALT CHROM_GRCh38 POS_GRCh38 ID_dbSNP151 REF_dbSNP151 ALT_dbSNP151
10 10 104573936 rs12345 T C NA NA NA NA NA
12 10 10616485 rs11111 T C 10 10616485 rs2025468 T C
15 10 108131461 . C A 10 108131461 rs1409410 G T
15 10 108131461 . C G 10 108131461 rs1409411 G T
10 10 104573936 . T C NA NA NA NA NA
15 10 108131461 . C G 11 108131461 rs1409411 G T
EOF

cat <<EOF > ./expected-result1.tsv
ROWINDEX NEWRSID
10 rs12345 if_not_in_dbsnp_but_exists_in_original
12 rs2025468 if_exists_in_original_and_exists_in_dbsnp_chrom_ref_alt_are_same
15 rs1409410 if_not_in_original_but_exists_in_dbsnp_ref_alt_not_same
15 rs1409411 if_not_in_original_but_exists_in_dbsnp_ref_alt_not_same
10 10_104573936_T_C if_rsid_not_in_dbsnp_or_original
15 10_108131461_C_G if_not_in_original_but_exists_in_dbsnp_chrom_not_same
EOF

_run_script

