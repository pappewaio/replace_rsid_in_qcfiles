infile=$1
col=$2

LC_ALL=C sort -u -k${col} ${infile}


