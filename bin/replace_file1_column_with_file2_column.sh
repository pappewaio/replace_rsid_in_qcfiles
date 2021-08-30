file1=$1
coln1=$2
file2=$3
coln2=$4

awk -vcoln1=${coln1} -vcoln2=${coln2} -vfile1=${file1} '
{replacer=$(coln2); getline file1; $(coln1)=replacer; print $0}
' ${file2}

