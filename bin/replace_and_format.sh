file1=$1

#1-106792422-G-A rs12568304 31 1 106792422 rs12568304 G A 0,1 0,2 0,3 0,4 0,5 0,6 0,7

awk '
    NR==1{printf "%s", $3; for(i=4; i<NF; i++){printf "%s%s", OFS, $i};printf "\n"}
    NR>1{$6=$2; printf "%s", $3; for(i=4; i<NF; i++){printf "%s%s", OFS, $i; };printf "\n"}
  ' $file1

