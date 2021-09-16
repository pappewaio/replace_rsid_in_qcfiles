file1=$1
coln1=$2
file2=$3
coln2=$4

nf="$(head -n1 ${file2} | awk '{print NF}')"

paste -d " " ${file2} ${file1} | 
  awk -vcoln1=${coln1} -vcoln2=${coln2} -vnf=${nf} '
    NR==1{printf "%s", $1; for(i=2; i<=nf; i++){printf "%s%s", OFS, $i};printf "\n"}
    NR>1{$(coln2)=$(coln1+nf); printf "%s", $1; for(i=2; i<=nf; i++){printf "%s%s", OFS, $i; };printf "\n"}
  '

