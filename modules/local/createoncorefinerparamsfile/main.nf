process CREATE_ONCOREFINER_PARAMS_FILE {
    tag 'oncorefiner'
    label 'process_single'

    input:
    val case_id
    val subject_id
    val sample_id_tumor
    val sample_id_normal
    val sex
    path oncoanalyser_results_dir
    val outdir

    output:

    path "oncorefiner_params.yaml", emit: params_file
    // WARN: Please update version string when the module is updated.
    tuple val("${task.process}"), val('createoncorefinerparamsfile'), val('1.0'), topic: versions, emit: versions_createoncorefinerparamsfile

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    def oncoanalyser_output_dir = file(outdir).resolve("oncoanalyser/${oncoanalyser_results_dir}")

    def path_snv_vcf    = oncoanalyser_output_dir.resolve("${subject_id}/purple/${subject_id}.tumor.purple.somatic.vcf.gz")
    def path_sv_vcf     = oncoanalyser_output_dir.resolve("${subject_id}/purple/${subject_id}.tumor.purple.sv.vcf.gz")
    def path_bam_tumor  = oncoanalyser_output_dir.resolve("${subject_id}/alignments/dna/${sample_id_tumor}.normal.redux.bam")
    def path_bai_tumor  = oncoanalyser_output_dir.resolve("${subject_id}/alignments/dna/${sample_id_tumor}.normal.redux.bam.bai")
    def path_bam_normal = oncoanalyser_output_dir.resolve("${subject_id}/alignments/dna/${sample_id_normal}.normal.redux.bam")
    def path_bai_normal = oncoanalyser_output_dir.resolve("${subject_id}/alignments/dna/${sample_id_normal}.normal.redux.bam.bai")

    def oncorefiner_params_file =
        [
            "\"case_id: ${case_id}",
            "sample_id_tumor: ${sample_id_tumor}",
            "sample_id_normal: ${sample_id_normal}",
            "sex: ${sex}",
            "snv_vcf: ${path_snv_vcf}",
            "sv_vcf: ${path_sv_vcf}",
            "bam_tumor: ${path_bam_tumor}",
            "bai_tumor: ${path_bai_tumor}",
            "bam_normal: ${path_bam_normal}",
            "bai_normal: ${path_bai_normal}\""
        ].join("\\n")

    """
    echo $args

    printf $oncorefiner_params_file > oncorefiner_params.yaml
    """

    stub:
    def args = task.ext.args ?: ''

    """
    echo $args

    touch oncorefiner_params.yaml
    """
}
