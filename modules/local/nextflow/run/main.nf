process NEXTFLOW_RUN {

    // directives:
    tag "$pipeline_name"

    input:
    val pipeline_name     // String
    val nextflow_opts     // String
    val params_file       // pipeline params-file
    val samplesheet       // pipeline samplesheet
    val additional_config // custom configs
    val cache_dir         // cache directory
    val run_name          // run name for Tower

    output:
    path "results", emit: output
    val stdout, emit: log

    when:
    task.ext.when == null || task.ext.when

    exec:
    // Set cache directory so workflow can `-resume`
    def cache_path = file(cache_dir)
    assert cache_path.mkdirs()

    def parent_env = System.getenv()
        .collect { k, v -> "${k}=${v}" }

    file("$task.workDir/parent_env.txt").text = parent_env

    // NXF_* env vars inherited from a Tower/Seqera Platform launch break the nested run - see #6.
    // Excluded so the nested run falls back to its own defaults, except shared, namespaced
    // storage locations we still want it to reuse.
    def environment_variables_to_unset = [
        'NXF_IGNORE_RESUME_HISTORY', // Error: "Missing workflow run name"
        'NXF_SCM_FILE',              // Is an ephemeral file that is no longer available when the child pipeline is called.
        'TOWER_WORKFLOW_ID',         // turns on reporting and makes the child act as the parent run
        'TOWER_REFRESH_TOKEN',       // parent's launch refresh token
        'TOWER_CONFIG_BASE64',       // parent's tower.yml
        'TOWER_CONFIG_FILE',
        'TOWER_REPORTS_FILE',
        // Testing not tracking with Tower
        'TOWER_API_ENDPOINT',
        'TOWER_ACCESS_TOKEN'
    ]
    def child_env = System.getenv()
        .findAll { k, v -> !(k in environment_variables_to_unset) }
        .collect { k, v -> "${k}=${v}" }

    file("$task.workDir/child_env.txt").text = child_env

    // Create timestamp for an unique run name
    def timestamp = new Date().format("yyyy-MM-dd_HH-mm-ss")
    // Construct nextflow command
    def nxf_cmd = [
        'nextflow',
            '-log .nextflow.log',
            'run',
            pipeline_name,
            nextflow_opts,
            "-name ${run_name}_${timestamp}",
            params_file ? "-params-file $params_file" : '',
            additional_config ? "-c $additional_config" : '',
            samplesheet ? "--input $samplesheet" : '',
            "--outdir ${task.workDir}/results",
    ].join(" ")
    // Copy command to shell script in work dir for reference/debugging.
    file("$task.workDir/nf-cmd.sh").text = nxf_cmd
    // Run nextflow command locally in cache directory
    def process = nxf_cmd.execute(child_env, cache_path.toFile())
    // Print process output to stdout and stderr
    process.consumeProcessOutput(System.out, System.err)
    process.waitFor()
    stdout = process.text
    // Copy nextflow log to work directory
    cache_path.resolve(".nextflow.log").copyTo("${task.workDir}/nextflow.log")
    assert process.exitValue() == 0: stdout
}
