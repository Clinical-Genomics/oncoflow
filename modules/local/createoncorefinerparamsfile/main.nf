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
    def oncoanalyser_output_dir = file(outdir).resolve("oncoanalyser/${oncoanalyser_results_dir}")

    def snv_vcf_path    = oncoanalyser_output_dir.resolve("${subject_id}/purple/${subject_id}.tumor.purple.somatic.vcf.gz")
    def sv_vcf_path     = oncoanalyser_output_dir.resolve("${subject_id}/purple/${subject_id}.tumor.purple.sv.vcf.gz")
    def bam_tumor_path  = oncoanalyser_output_dir.resolve("${subject_id}/alignments/dna/${subject_id}.normal.redux.bam")
    def bai_tumor_path  = oncoanalyser_output_dir.resolve("${subject_id}/alignments/dna/${subject_id}.normal.redux.bam.bai")
    def bam_normal_path = oncoanalyser_output_dir.resolve("${subject_id}/alignments/dna/${subject_id}.normal.redux.bam")
    def bai_normal_path = oncoanalyser_output_dir.resolve("${subject_id}/alignments/dna/${subject_id}.normal.redux.bam.bai")

    def oncorefiner_params_file =
        [
            "case_id: ${case_id}",
            "sample_id_tumor: ${sample_id_tumor}",
            "sample_id_normal: ${sample_id_normal}",
            "sex: ${sex}",
            "snv_vcf: ${snv_vcf_path}",
            "sv_vcf: ${sv_vcf_path}",
            "bam_tumor: ${bam_tumor_path}",
            "bai_tumor: ${bai_tumor_path}",
            "bam_normal: ${bam_normal_path}",
            "bai_normal: ${bai_normal_path}"
        ].join("\\n")

    """
    printf "$oncorefiner_params_file" > oncorefiner_params.yaml
    """

    stub:
    """
    touch oncorefiner_params.yaml
    """
}
