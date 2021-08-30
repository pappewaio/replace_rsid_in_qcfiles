infile=$1
outfile=$2


#Input looks like this
#12 10 10616485 . T C 10 10616485 rs2025468 T C
#1  2  3        4 5 6 7  8        9        10 11
awk '
BEGIN{print "ROWINDEX","NEWRSID"};
NR>1{
  # if rsid not in dbsnp or original, use orignal chr_pos_ref_alt marker
  if($9=="NA" && $4=="."){
    full=$2"_"$3"_"$5"_"$6
    type="if_rsid_not_in_dbsnp_or_original"
  # if not in dbsnp, but exists in original, use orignal rsid
  }else if($9=="NA" && $4!="."){
    full=$4
    type="if_not_in_dbsnp_but_exists_in_original"
  # if not in original, but exists in dbsnp, make some extra checks before using it
  }else if($9!="NA" && $4=="."){
    # if chr not same in dbsnp and original, use orignal chr_pos_ref_alt marker
    if($2!=$7){
      full=$2"_"$3"_"$5"_"$6
      type="if_not_in_original_but_exists_in_dbsnp_chrom_not_same"
    # if ref and alt not same in dbsnp and original, report, but use dbsnp rsid
    }else if($5$6!=$10$11){
      full=$9
      type="if_not_in_original_but_exists_in_dbsnp_ref_alt_not_same"
    }else{
    # use dbsnp rsid
      full=$9
      type="if_not_in_original_but_exists_in_dbsnp_chrom_ref_alt_are_same"
    }
  # if exists in original and exists in dbsnp, make some extra checks before using it
  }else if($9!="NA" && $4!="."){
    # if chr not same in dbsnp and original, use orignal chr_pos_ref_alt marker
    if($2!=$7){
      full=$2"_"$3"_"$5"_"$6
      type="if_exists_in_original_and_exists_in_dbsnp_chrom_not_same"
    # if ref and alt not same in dbsnp and original, report, but use dbsnp rsid
    }else if($5$6!=$10$11){
      full=$9
      type="if_exists_in_original_and_exists_in_dbsnp_ref_alt_not_same"
    }else{
    # use dbsnp rsid (as it probably has the more recent rsid for that position)
      full=$9
      type="if_exists_in_original_and_exists_in_dbsnp_chrom_ref_alt_are_same"
    }
  }else{
    # if nothing above applies, use orignal chr_pos_ref_alt marker
    full=$2"_"$3"_"$5"_"$6
    type="not_covered_logic"
  }

  # print the result
  print $1, full, type
}' ${infile} >> ${outfile}

