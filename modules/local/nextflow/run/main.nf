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
    def process = nxf_cmd.execute(null, cache_path.toFile())
    // Print process output to stdout and stderr
    process.consumeProcessOutput(System.out, System.err)
    process.waitFor()
    stdout = process.text
    // Copy nextflow log to work directory
    cache_path.resolve(".nextflow.log").copyTo("${task.workDir}/nextflow.log")
    assert process.exitValue() == 0: stdout
}
