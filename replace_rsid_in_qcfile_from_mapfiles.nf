nextflow.enable.dsl=2

// Add rownumber to files
process add_rowindex_and_sortindex {
    publishDir "${params.outdir}/intermediates/${id}", mode: 'rellink', overwrite: true
    publishDir "${params.outdir}/nr_checks/${id}", mode: 'copy', overwrite: true, pattern: '*.linecount'
    input:
      tuple val(id), path(qcin), path(map)
    output:
      tuple val(id), path("unzipped_rowindexed_qcin_${id}"), path("unzipped_rowindexed_map_${id}"), path("merged_header_${id}")
      path("*.linecount")
    script:
      """
      # remove the header, which can be added later again
      paste -d" " <(zcat ${map} | head -n1 | awk '{print "sortindex", \$12}' ) <(zcat ${qcin} | head -n1 | awk '{print 1, "sortindex", \$0}' ) > merged_header_${id}
      gunzip -c ${map} | awk 'NR>1{print \$2"-"\$3"-"\$5"-"\$6, \$12}' > unzipped_rowindexed_map_${id}
      gunzip -c ${qcin} | awk 'NR>1{print NR, \$1"-"\$2"-"\$4"-"\$5, \$0}' > unzipped_rowindexed_qcin_${id}
      wc -l unzipped_rowindexed_map_${id} > unzipped_rowindexed_map_${id}.linecount
      wc -l unzipped_rowindexed_qcin_${id} > unzipped_rowindexed_qcin_${id}.linecount
      """
}

// Sort files on chrpos
process sort_on_chrpos_refalt {
    publishDir "${params.outdir}/intermediates/${id}", mode: 'rellink', overwrite: true
    publishDir "${params.outdir}/nr_checks/${id}", mode: 'copy', overwrite: true, pattern: '*.linecount'
    input:
      tuple val(id), path(qcin), path(map), path(mergedheader)
    output:
      tuple val(id), path("sorted_rowindexed_qcin_${id}"), path("sorted_rowindexed_map_${id}"), path(mergedheader)
      path("*.linecount")
    script:
      """
      LC_ALL=C sort -k1,1 ${map} > sorted_rowindexed_map_${id}
      LC_ALL=C sort -k2,2 ${qcin} > sorted_rowindexed_qcin_${id}
      wc -l sorted_rowindexed_map_${id} > sorted_rowindexed_map_${id}.linecount
      wc -l sorted_rowindexed_qcin_${id} > sorted_rowindexed_qcin_${id}.linecount
      """
}

process check_index_duplicates {
    publishDir "${params.outdir}/intermediates/${id}", mode: 'rellink', overwrite: true
    publishDir "${params.outdir}/nr_checks/${id}", mode: 'copy', overwrite: true, pattern: '*.linecount'
    input:
      tuple val(id), path(qcin), path(map), path(mergedheader)
    output:
      tuple val(id), path("check_rowindex_dups_qcin_${id}"), path("check_rowindex_dups_map_${id}")
      path("*.linecount")
    script:
      """
      check_index_duplicates.sh "${map}" "1,1" > check_rowindex_dups_map_${id}
      check_index_duplicates.sh "${qcin}" "2,2" > check_rowindex_dups_qcin_${id}
      wc -l check_rowindex_dups_map_${id} > check_rowindex_dups_map_${id}.linecount
      wc -l check_rowindex_dups_qcin_${id} > check_rowindex_dups_qcin_${id}.linecount
      """
}

process join_sortindex {
    publishDir "${params.outdir}/intermediates/${id}", mode: 'rellink', overwrite: true
    publishDir "${params.outdir}/nr_checks/${id}", mode: 'copy', overwrite: true, pattern: '*.linecount'
    input:
      tuple val(id), path(qcin), path(map), path(mergedheader)
    output:
      tuple val(id), path("joined_sortindex_${id}")
      path("*.linecount")
    script:
      """
      cat $mergedheader | cut -d" " -f1,2,3,5- > joined_sortindex_${id}
      LC_ALL=C join -1 1 -2 2 ${map} ${qcin} >> joined_sortindex_${id}
      wc -l joined_sortindex_${id} | awk '{\$1=\$1-1;print \$0}' > joined_sortindex_${id}.linecount
      """
}

process replace_rsid_and_reformat {
    publishDir "${params.outdir}/intermediates/${id}", mode: 'rellink', overwrite: true
    publishDir "${params.outdir}/nr_checks/${id}", mode: 'copy', overwrite: true, pattern: '*.linecount'
    input:
      tuple val(id), path(qcin)
    output:
      tuple val(id), path("reformatted_${id}")
      path("*.linecount")
    script:
      """
      replace_and_format.sh ${qcin} > reformatted_${id}
      #remove header line count using awk
      wc -l reformatted_${id} | awk '{\$1=\$1-1;print \$0}' > reformatted_${id}.linecount
      """
}

// Go back to original sorting
process original_sorting {
    publishDir "${params.outdir}/updated_qc_files", mode: 'copy', overwrite: false
    publishDir "${params.outdir}/nr_checks/${id}", mode: 'copy', overwrite: true, pattern: '*.linecount'
    input:
      tuple val(id), path("qcin")
    output:
      tuple val(id), path("${id}")
      path("*.linecount")
    script:
      """
      LC_ALL=C sort -k1,1 -n qcin | cut -d ' ' -f2- > ${id}
      wc -l ${id} | awk '{\$1=\$1-1;print \$0}' > ${id}.linecount
      """
}

process compare_bp_new_and_original {
    publishDir "${params.outdir}/intermediates/${id}", mode: 'rellink', overwrite: true
    publishDir "${params.outdir}/diff_checks/${id}", mode: 'copy', overwrite: true, pattern: '*.diff'
    input:
      tuple val(id), path(updatedqcin), path(qcin), path(map)
    output:
      tuple val(id), path("${id}")
      path("*.diff")
      path("*_bp")
    script:
      """
      zcat ${qcin} | awk '{print \$2}' > qcin_bp
      cat ${updatedqcin} | awk '{print \$2}' > updatedqcin_bp
      diff -s qcin_bp updatedqcin_bp > matched_bp_old_and_new_${id}.diff
      """
}

workflow {

  // read in metafile
  Channel
   .fromPath("${params.input}")
   .splitCsv( header:false, sep:" " )
   .map { it1, it2 -> tuple(file(it1).getBaseName(),file(it1),file(it2)) }
   .set { init_file_tracker }

  // Replace input
  add_rowindex_and_sortindex(init_file_tracker)
  sort_on_chrpos_refalt(add_rowindex_and_sortindex.out[0])
  check_index_duplicates(add_rowindex_and_sortindex.out[0])
  join_sortindex(sort_on_chrpos_refalt.out[0])
  replace_rsid_and_reformat(join_sortindex.out[0])
  original_sorting(replace_rsid_and_reformat.out[0])

  original_sorting.out[0]
    .join(init_file_tracker)
    .set { compare_bp_ch}

  compare_bp_new_and_original(compare_bp_ch)

}


