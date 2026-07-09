process CREATE_PARAMS_FILE {
    tag 'params_file'
    label 'process_single'

    input:
    val params_list

    output:

    path "${prefix}_params.yaml", emit: params_file
    // WARN: Please update version string when the module is updated.
    tuple val("${task.process}"), val('createparamsfile'), val('1.0'), topic: versions, emit: versions_createparamsfile

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix = task.ext.prefix ?: "pipeline"

    def params_file_content = params_list.join("\\n")

    """
    printf "$params_file_content" > ${prefix}_params.yaml
    """

    stub:
    prefix = task.ext.prefix ?: "pipeline"

    """
    touch ${prefix}_params.yaml
    """
}
