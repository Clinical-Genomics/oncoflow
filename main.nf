#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Clinical-Genomics/oncoflow
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/Clinical-Genomics/oncoflow
----------------------------------------------------------------------------------------
*/

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS / WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { ONCOFLOW                } from './workflows/oncoflow'
include { PIPELINE_INITIALISATION } from './subworkflows/local/utils_nfcore_oncoflow_pipeline'
include { PIPELINE_COMPLETION     } from './subworkflows/local/utils_nfcore_oncoflow_pipeline'
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOWS FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// WORKFLOW: Run main analysis pipeline depending on type of input
//
workflow CLINICALGENOMICS_ONCOFLOW {

    take:
    oncoanalyser_additional_config // string: [optional]  Additional config file for oncoanalyser pipeline
    oncoanalyser_nextflow_opts     // string: [mandatory] Nextflow options for oncoanalyser pipeline
    oncoanalyser_params_file       // string: [mandatory] Parameters file for oncoanalyser pipeline
    oncoanalyser_samplesheet       // string: [mandatory] Samplesheet file for oncoanalyser pipeline
    outdir                         // string: [mandatory] The output directory where the results will be saved

    main:

    //
    // WORKFLOW: Run pipeline
    //
    ONCOFLOW (
        oncoanalyser_additional_config,
        oncoanalyser_nextflow_opts,
        oncoanalyser_params_file,
        oncoanalyser_samplesheet,
        outdir
    )

    emit:
    oncoanalyser_output = ONCOFLOW.out.oncoanalyser_output // channel: [ path(analysis_output_directory) ]
    oncorefiner_output = ONCOFLOW.out.oncorefiner_output   // channel: [path(oncorefiner_output_directory)]
}
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {

    main:



    //
    // SUBWORKFLOW: Run initialisation tasks
    //
    PIPELINE_INITIALISATION (
        params.version,
        params.validate_params,
        params.monochrome_logs,
        args,
        params.outdir,
        params.help,
        params.help_full,
        params.show_hidden
    )

    //
    // WORKFLOW: Run main workflow
    //
    CLINICALGENOMICS_ONCOFLOW (
        params.oncoanalyser_additional_config,
        params.oncoanalyser_nextflow_opts,
        params.oncoanalyser_params_file,
        params.oncoanalyser_samplesheet,
        params.outdir
    )

    //
    // SUBWORKFLOW: Run completion tasks
    //
    PIPELINE_COMPLETION (
        params.email,
        params.email_on_fail,
        params.plaintext_email,
        params.outdir,
        params.monochrome_logs,
    )

    publish:
    oncoanalyser_output = CLINICALGENOMICS_ONCOFLOW.out.oncoanalyser_output
    oncorefiner_output  = CLINICALGENOMICS_ONCOFLOW.out.oncorefiner_output
}

output {
    oncoanalyser_output {
        path "oncoanalyser"
    }
    oncorefiner_output {
        path "oncorefiner"
    }
}



/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
