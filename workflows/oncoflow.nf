/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { CREATE_ONCOREFINER_PARAMS_FILE                } from "../modules/local/createoncorefinerparamsfile/main"
include { NEXTFLOW_RUN as CLINICAL_GENOMICS_ONCOREFINER } from '../modules/local/nextflow/run'
include { NEXTFLOW_RUN as NFCORE_ONCOANALYSER           } from "../modules/local/nextflow/run/main"
include { softwareVersionsToYAML                        } from '../subworkflows/nf-core/utils_nfcore_pipeline'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow ONCOFLOW {

    take:
    val_case_id                    // string: [mandatory] Case ID
    val_oncoanalyser_config        // string: [optional]  Config file for oncoanalyser pipeline
    val_oncoanalyser_nextflow_opts // string: [mandatory] Nextflow options for oncoanalyser pipeline
    val_oncoanalyser_params_file   // string: [mandatory] Parameters file for oncoanalyser pipeline
    val_oncoanalyser_samplesheet   // string: [mandatory] Samplesheet file for oncoanalyser pipeline
    val_oncorefiner_config         // string: [optional]  Config file for oncorefiner pipeline
    val_oncorefiner_nextflow_opts  // string: [mandatory] Nextflow options for oncorefiner pipeline
    val_sample_id_tumor            // string: [mandatory] Sample ID of the tumor sample
    val_sample_id_normal           // string: [mandatory] Sample ID of the normal sample
    val_subject_id                 // string: [mandatory] Subject ID
    val_sex                        // string: [mandatory] Sex of the patient
    outdir                         // string: [mandatory] The output directory where the results will be saved

    main:

    def ch_versions = channel.empty()

    NFCORE_ONCOANALYSER(
        'Clinical-Genomics/oncoanalyser',
        val_oncoanalyser_nextflow_opts,
        val_oncoanalyser_params_file,
        val_oncoanalyser_samplesheet,
        val_oncoanalyser_config,
        workflow.workDir.resolve('nf-core/oncoanalyser').toUriString(),
    )

    CREATE_ONCOREFINER_PARAMS_FILE(
        val_case_id,
        val_subject_id,
        val_sample_id_tumor,
        val_sample_id_normal,
        val_sex,
        NFCORE_ONCOANALYSER.out.output,
        outdir
        )

    CLINICAL_GENOMICS_ONCOREFINER(
        'Clinical-Genomics/oncorefiner',
        val_oncorefiner_nextflow_opts,
        CREATE_ONCOREFINER_PARAMS_FILE.out.params_file,
        '',
        val_oncorefiner_config,
        workflow.workDir.resolve('Clinical-Genomics/oncorefiner').toUriString(),
    )

    //
    // Collate and save software versions
    //
    def topic_versions = channel.topic("versions")
        .distinct()
        .branch { entry ->
            versions_file: entry instanceof Path
            versions_tuple: true
        }

    def topic_versions_string = topic_versions.versions_tuple
        .map { process, tool, version ->
            [ process[process.lastIndexOf(':')+1..-1], "  ${tool}: ${version}" ]
        }
        .groupTuple(by:0)
        .map { process, tool_versions ->
            tool_versions.unique().sort()
            "${process}:\n${tool_versions.join('\n')}"
        }

    def ch_collated_versions = softwareVersionsToYAML(ch_versions.mix(topic_versions.versions_file))
        .mix(topic_versions_string)
        .collectFile(
            storeDir: "${outdir}/pipeline_info",
            name:  'oncoflow_software_'  + 'versions.yml',
            sort: true,
            newLine: true
        )

    emit:
    oncoanalyser_output     = NFCORE_ONCOANALYSER.out.output                 // channel: [path(analysis_output_directory)]
    oncorefiner_params_file = CREATE_ONCOREFINER_PARAMS_FILE.out.params_file // channel: [path(yaml)]
    oncorefiner_output      = CLINICAL_GENOMICS_ONCOREFINER.out.output       // channel: [path(analysis_output_directory)]
    versions                = ch_versions                                    // channel: [path(versions.yml)]
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
