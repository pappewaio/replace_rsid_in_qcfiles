nextflow.enable.dsl=2

// Add rownumber to files
process add_rowindex_and_sortindex {
    publishDir "${params.outdir}/intermediates/${id}", mode: 'rellink', overwrite: true
    input:
      tuple val(id), path(qcin), path(map)
    output:
      tuple val(id), path("unzipped_rowindexed_qcin_${id}"), path("unzipped_rowindexed_map_${id}")
    script:
      """
      gunzip -c ${map} | awk '{print \$2"-"\$3"-"\$5"-"\$6, \$4}' > unzipped_rowindexed_map_${id}
      gunzip -c ${qcin} | awk '{print NR, \$1"-"\$2"-"\$4"-"\$5, \$0}' > unzipped_rowindexed_qcin_${id}
      """
}

// Sort files on chrpos
process sort_on_chrpos_refalt {
    publishDir "${params.outdir}/intermediates/${id}", mode: 'rellink', overwrite: true
    input:
      tuple val(id), path(qcin), path(map)
    output:
      tuple val(id), path("sorted_rowindexed_qcin_${id}"), path("sorted_rowindexed_map_${id}")
    script:
      """
      LC_ALL=C sort -k1,1 ${map} > sorted_rowindexed_map_${id}
      LC_ALL=C sort -k2,2 ${qcin} > sorted_rowindexed_qcin_${id}
      """
}

process check_index_duplicates {
    publishDir "${params.outdir}/intermediates/${id}", mode: 'rellink', overwrite: true
    input:
      tuple val(id), path(qcin), path(map)
    output:
      tuple val(id), path("check_rowindex_dups_qcin_${id}"), path("check_rowindex_dups_map_${id}")
    script:
      """
      LC_ALL=C sort -k1,1 -u ${map} > check_rowindex_dups_map_${id}
      LC_ALL=C sort -k2,2 -u ${qcin} > check_rowindex_dups_qcin_${id}
      """
}

process join_sortindex {
    publishDir "${params.outdir}/intermediates/${id}", mode: 'rellink', overwrite: true
    input:
      tuple val(id), path(qcin), path(map)
    output:
      tuple val(id), path("joined_sortindex_${id}")
    script:
      """
      LC_ALL=C join -1 1 -2 2 ${map} ${qcin} > joined_sortindex_${id}
      """
}

process replace_rsid_and_reformat {
    publishDir "${params.outdir}/intermediates/${id}", mode: 'rellink', overwrite: true
    input:
      tuple val(id), path(qcin)
    output:
      tuple val(id), path("reformatted_${id}")
    script:
      """
      replace_and_format.sh ${qcin} > reformatted_${id}
      """
}

// Go back to original sorting
process original_sorting {
    publishDir "${params.outdir}/updated_qc_files", mode: 'copy', overwrite: false
    input:
      tuple val(id), path("qcin")
    output:
      tuple val(id), path("${id}")
    script:
      """
      LC_ALL=C sort -k1,1 -n qcin | cut -d ' ' -f2- > ${id}
      """
}

process compare_bp_new_and_original {
    publishDir "${params.outdir}/intermediates/${id}", mode: 'rellink', overwrite: true
    input:
      tuple val(id), path(updatedqcin), path(qcin), path(map)
    output:
      tuple val(id), path("${id}")
    script:
      """
      LC_ALL=C join -1 2 -2 2 <(zcat ${qcin}) ${updatedqcin} > matched_bp_old_and_new_${id}
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
  sort_on_chrpos_refalt(add_rowindex_and_sortindex.out)
  check_index_duplicates(add_rowindex_and_sortindex.out)
  join_sortindex(sort_on_chrpos_refalt.out)
  replace_rsid_and_reformat(join_sortindex.out)
  original_sorting(replace_rsid_and_reformat.out)

  original_sorting.out
    .join(init_file_tracker)
    .set { compare_bp_ch}

  compare_bp_new_and_original(compare_bp_ch)

}


