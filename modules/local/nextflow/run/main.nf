process NEXTFLOW_RUN {
    // directives:
    tag "${pipeline_name}"

    input:
    val pipeline_name     // String
    val nextflow_opts     // String
    val params_file       // pipeline params-file
    val samplesheet       // pipeline samplesheet
    val additional_config // custom configs
    val cache_dir         // cache directory

    output:
    path "results", emit: output

    exec:
    // Set cache directory so workflow can `-resume`
    def cache_path = file(cache_dir)
    assert cache_path.mkdirs()

    //
    // Prepare environment for running the child pipeline
    //

    // When starting the parent pipeline, environment variables are set - both nextflow and tower related -
    // which point specifically to settings of the parent pipeline and are incompatible with nested runs of child pipelines.
    // Therefore, a set of environment variables need to be unset for the child pipeline to run correctly.

    def parent_env = System.getenv()
        .collect { k, v -> "${k}=${v}" }

    def environment_variables_to_skip = [
        // Nextflow variables
        'NXF_UUID',                  // Points to parent session ID
        'NXF_WORK',                  // Points to parent's work directory
        'NXF_LOG_FILE',              //
        'NXF_OUT_FILE',              //
        'NXF_TML_FILE',              // Points to parent's paths
        'NXF_SCM_FILE',              // One-time ephemeral file that is no longer available when the child pipeline is called (required)
        'NXF_IGNORE_RESUME_HISTORY', // Error: "Missing workflow run name" (required)
        'NXF_PRERUN_BASE64',         // Points to parent's pre-run script
        'NXF_POSTRUN_BASE64',        // Points to parent's post-run script

        // Tower variables
        'TOWER_WORKFLOW_ID',         // The presence of this variable activates reporting to Tower which  (required)
        'TOWER_REFRESH_TOKEN',       // parent's launch refresh token
        'TOWER_CONFIG_BASE64',       // parent's tower.yml
        'TOWER_CONFIG_FILE',
        'TOWER_REPORTS_FILE',
    ]
    def child_env = System.getenv()
        .findAll { k, v -> !(k in environment_variables_to_skip) }
        .collect { k, v -> "${k}=${v}" }

    // Construct nextflow command
    def nxf_cmd = [
        'nextflow',
            '-log .nextflow.log',
            'run',
            pipeline_name,
            nextflow_opts,
            params_file ? "-params-file ${params_file}" : '',
            additional_config ? "-c ${additional_config}" : '',
            samplesheet ? "--input ${samplesheet}" : '',
            "--outdir ${task.workDir}/results",
    ].join(" ")

    // Copy command to shell script in work dir for reference/debugging.
    file("${task.workDir}/nf-cmd.sh").text = nxf_cmd

    // Run nextflow command locally in cache directory
    def process = nxf_cmd.execute(child_env, cache_path.toFile())
    // Print process output to stdout and stderr
    process.consumeProcessOutput(System.out, System.err)
    process.waitFor()

    // Copy nextflow log to work directory
    cache_path.resolve(".nextflow.log").copyTo("${task.workDir}/nextflow.log")
    assert process.exitValue() == 0:
        """
        ============================================================
        PIPELINE FAILED: ${pipeline_name}
        Exit Code: ${process.exitValue()}
        Pipeline Log: ${task.workDir}/nextflow.log
        ============================================================
        """.stripIndent()

    // Clean cache of failed tasks
    def clean_cmd = ["/usr/bin/env", "bash", "-c", "nextflow clean -f -before last && find work -type d -empty -delete"]
    def clean_process = clean_cmd.execute(child_env, cache_path.toFile())
    // clean_process.consumeProcessOutput(System.out, System.err)
    clean_process.waitFor()
    assert clean_process.exitValue() == 0:
        """
        ============================================================
        CACHE CLEAN FAILED: ${pipeline_name}
        Exit Code: ${clean_process.exitValue()}
        ============================================================
        """.stripIndent()
}
