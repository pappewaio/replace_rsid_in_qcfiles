#!/usr/bin/env bash

set -euo pipefail

test_script="replace_and_format"
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

  "${test_script}.sh" ./input.tsv > ./observed-result1.tsv

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
1-104654614-G-A rs12067399 30 1 104654614 rs12067399 G A 0,1 0,2 0,3 0,4 0,5 0,6 0,7
1-10593296-G-T rs2480782 4 1 10593296 rs2480782 G T 0,1 0,2 0,3 0,4 0,5 0,6 0,7
1-106792422-G-A rs12568304 31 1 106792422 rs12568304 G A 0,1 0,2 0,3 0,4 0,5 0,6 0,7
1-108097237-A-C rs17019427 32 1 108097237 rs17019427 A C 0,1 0,2 0,3 0,4 0,5 0,6 0,7
1-109357456-C-A rs10494099 33 1 109357456 rs10494099 C A 0,1 0,2 0,3 0,4 0,5 0,6 0,7
EOF

cat <<EOF > ./expected-result1.tsv
30 1 104654614 rs12067399 G A 0,1 0,2 0,3 0,4 0,5 0,6
4 1 10593296 rs2480782 G T 0,1 0,2 0,3 0,4 0,5 0,6
31 1 106792422 rs12568304 G A 0,1 0,2 0,3 0,4 0,5 0,6
32 1 108097237 rs17019427 A C 0,1 0,2 0,3 0,4 0,5 0,6
33 1 109357456 rs10494099 C A 0,1 0,2 0,3 0,4 0,5 0,6
EOF

_run_script

#---------------------------------------------------------------------------------
# Next case


