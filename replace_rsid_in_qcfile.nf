nextflow.enable.dsl=2

// Use same replace column as in the vcf_reference_build_tools
process create_rsid_replace_column {
    publishDir "${params.outdir}/intermediates/${id}", mode: 'rellink', overwrite: true
    input:
      tuple val(id), path(qcin), path(map)
    output:
      tuple val(id), path(qcin), path("map_replace_col_${id}")
    script:
      """
      gunzip -c ${map} | awk '{print NR, \$0}' > unzipped_map 
      create_rsid_replace_column.sh unzipped_map map_replace_col_${id}
      """
}

process replace_file1_column_with_file2_column {
    publishDir "${params.outdir}/updated_qc_files", mode: 'copy', overwrite: false
    input:
      tuple val(id), path("qcin"), path("map_replace_col")
    output:
      tuple val(id), path("${id}.txt")
    script:
      """
      #remember to gzip and put in final out folder, not intermediates
      replace_file1_column_with_file2_column.sh qcin 3 map_replace_col 2 > ${id}.txt
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
  create_rsid_replace_column(init_file_tracker)
  replace_file1_column_with_file2_column(create_rsid_replace_column.out)

}

