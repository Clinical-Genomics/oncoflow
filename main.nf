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
    val_outdir                     // string: [mandatory] The output directory where the results will be saved

    main:

    //
    // WORKFLOW: Run pipeline
    //
    ONCOFLOW (
        val_case_id,
        val_oncoanalyser_config,
        val_oncoanalyser_nextflow_opts,
        val_oncoanalyser_params_file,
        val_oncoanalyser_samplesheet,
        val_oncorefiner_config,
        val_oncorefiner_nextflow_opts,
        val_sample_id_tumor,
        val_sample_id_normal,
        val_subject_id,
        val_sex,
        val_outdir
    )

    emit:
    oncoanalyser_output     = ONCOFLOW.out.oncoanalyser_output     // channel: [path(analysis_output_directory)]
    oncorefiner_output      = ONCOFLOW.out.oncorefiner_output      // channel: [path(analysis_output_directory)]
    oncorefiner_params_file = ONCOFLOW.out.oncorefiner_params_file // channel: [path(yaml)]
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
        params.case_id,
        params.oncoanalyser_config,
        params.oncoanalyser_nextflow_opts,
        params.oncoanalyser_params_file,
        params.oncoanalyser_samplesheet,
        params.oncorefiner_config,
        params.oncorefiner_nextflow_opts,
        params.sample_id_tumor,
        params.sample_id_normal,
        params.subject_id,
        params.sex,
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
    oncoanalyser_output     = CLINICALGENOMICS_ONCOFLOW.out.oncoanalyser_output
    oncorefiner_output      = CLINICALGENOMICS_ONCOFLOW.out.oncorefiner_output
    oncorefiner_params_file = CLINICALGENOMICS_ONCOFLOW.out.oncorefiner_params_file
}

output {
    oncoanalyser_output {
        path "oncoanalyser"
    }
    oncorefiner_output {
        path "oncorefiner"
    }
    oncorefiner_params_file {
        path "oncorefiner"
    }
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
