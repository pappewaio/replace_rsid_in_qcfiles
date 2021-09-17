#!/usr/bin/env bash

set -euo pipefail

test_script="check_index_duplicates"
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
  col=$1

  "${test_script}.sh" ./input.tsv ${col} > ./observed-result1.tsv

  _check_results ./observed-result1.tsv ./expected-result1.tsv

  echo "- [OK] ${curr_case}"

  cd "${initial_dir}"
}

echo ">> Test ${test_script}"

#=================================================================================
# Cases
#=================================================================================

#---------------------------------------------------------------------------------
# Check the case when there are no duplicates

_setup "simple case"

cat <<EOF > ./input.tsv
1-104654614-G-A rs12067399
1-10593296-G-T rs2480782
1-106792422-G-A rs12568304
1-108097237-A-C rs17019427
1-109357456-C-A rs10494099
EOF

cat <<EOF > ./expected-result1.tsv
1-104654614-G-A rs12067399
1-10593296-G-T rs2480782
1-106792422-G-A rs12568304
1-108097237-A-C rs17019427
1-109357456-C-A rs10494099
EOF

_run_script 1

#---------------------------------------------------------------------------------
# Check the case with some duplicates

_setup "three duplicates, start, middle, end"

cat <<EOF > ./input.tsv
1-104654614-G-A rs12067399
1-104654614-G-A rs12067399
1-10593296-G-T rs2480782
1-106792422-G-A rs12568304
1-106792422-G-A rs12568304
1-108097237-A-C rs17019427
1-109357456-C-A rs10494099
1-109357456-C-A rs10494099
EOF

cat <<EOF > ./expected-result1.tsv
1-104654614-G-A rs12067399
1-10593296-G-T rs2480782
1-106792422-G-A rs12568304
1-108097237-A-C rs17019427
1-109357456-C-A rs10494099
EOF

_run_script 1

