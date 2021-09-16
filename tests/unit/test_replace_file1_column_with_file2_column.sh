#!/usr/bin/env bash

set -euo pipefail

test_script="replace_file1_column_with_file2_column"
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
  coln1=$1
  coln2=$2
  "${test_script}.sh" ./file1.txt ${coln1} ./file2.txt ${coln2} > ./observed-result1.tsv

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

cat <<EOF > ./file1.txt
ROWINDEX NEWRSID
2 rs228729 if_exists_in_original_and_exists_in_dbsnp_chrom_not_same
3 8_1_rs12754538_C if_exists_in_original_and_exists_in_dbsnp_chrom_not_same
4 rs2480782 if_exists_in_original_and_exists_in_dbsnp_chrom_not_same
5 10_1_rs12565367_A if_exists_in_original_and_exists_in_dbsnp_chrom_not_same
EOF

cat <<EOF > ./file2.txt
CHR POS ID REF ALT MAF AR2 DR2 Hwe DR2 Accuracy Score
1 7845695 rs228729 T C 0,1 0,2 0,3 0,4 0,5 0,6 0,7
1 8473813 rs12754538 C T 0,1 0,2 0,3 0,4 0,5 0,6 0,7
1 10593296 rs2480782 G T 0,1 0,2 0,3 0,4 0,5 0,6 0,7
1 18420144 rs12565367 A G 0,1 0,2 0,3 0,4 0,5 0,6 0,7
EOF

cat <<EOF > ./expected-result1.tsv
CHR POS ID REF ALT MAF AR2 DR2 Hwe DR2 Accuracy Score
1 7845695 rs228729 T C 0,1 0,2 0,3 0,4 0,5 0,6 0,7
1 8473813 8_1_rs12754538_C C T 0,1 0,2 0,3 0,4 0,5 0,6 0,7
1 10593296 rs2480782 G T 0,1 0,2 0,3 0,4 0,5 0,6 0,7
1 18420144 10_1_rs12565367_A A G 0,1 0,2 0,3 0,4 0,5 0,6 0,7
EOF

_run_script 2 3

#---------------------------------------------------------------------------------
# Next case

