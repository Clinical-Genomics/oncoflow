process CREATE_ONCOANALYSER_PARAMS_FILE {
    tag 'oncoanalyser'
    label 'process_single'

    input:
    val mode
    val genome
    val create_stub_placeholders
    val outdir

    output:

    path "oncoanalyser_params.yaml", emit: params_file
    // WARN: Please update version string when the module is updated.
    tuple val("${task.process}"), val('createoncoanalyserparamsfile'), val('1.0'), topic: versions, emit: versions_createoncoanalyserparamsfile

    when:
    task.ext.when == null || task.ext.when

    script:

    def oncoanalyser_params_file =
        [
            "mode: ${mode}",
            "genome: ${genome}",
            "create_stub_placeholders: ${create_stub_placeholders}"
        ].join("\\n")

    """
    printf "$oncoanalyser_params_file" > oncoanalyser_params.yaml
    """

    stub:
    """
    touch oncoanalyser_params.yaml
    """
}
