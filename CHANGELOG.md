# Clinical-Genomics/oncoflow: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.0.0dev - [date]

Initial release of Clinical-Genomics/oncoflow, created with the [nf-core](https://nf-co.re/) template.

### `Added`

- [#2](https://github.com/Clinical-Genomics/oncoflow/pull/2) Added `NEXTFLOW_RUN` local module based on `mahesh-panchal/nf-cascade`.
- [#3](https://github.com/Clinical-Genomics/oncoflow/pull/3) Added `NFCORE_ONCOANALYSER` using the `NEXTFLOW_RUN` local module to run the `nf-core/oncoanalyser` pipeline in `ONCOFLOW` workflow.
- [#3](https://github.com/Clinical-Genomics/oncoflow/pull/3) Added input parameters for running `nf-core/oncoanalyser`: `oncoanalyser_config`, `oncoanalyser_nextflow_opts`, `oncoanalyser_params_file` and `oncoanalyser_samplesheet`.
- [#5](https://github.com/Clinical-Genomics/oncoflow/pull/5) and [#10](https://github.com/Clinical-Genomics/oncoflow/pull/10) Added `CREATE_PARAMS_FILE` local module.
- [#9](https://github.com/Clinical-Genomics/oncoflow/pull/9) `CREATE_ONCOANALYSER_PARAMS_FILE` using `CREATE_PARAMS_FILE` to `ONCOFLOW` workflow.
- [#9](https://github.com/Clinical-Genomics/oncoflow/pull/9) Added input parameters `oncoanalyser_create_stub_placeholders`, `oncoanalyser_genome` and `oncoanalyser_mode` necessary for creating the `oncoanalyser` params file using the `CREATE_ONCOANALYSER_PARAMS_FILE` local module.
- [#9](https://github.com/Clinical-Genomics/oncoflow/pull/9) `getOncoanalyserParamsList` function to produce the list of parameters necessary for `CREATE_ONCOANALYSER_PARAMS_FILE`.
- [#5](https://github.com/Clinical-Genomics/oncoflow/pull/5) and [#10](https://github.com/Clinical-Genomics/oncoflow/pull/10) Added `CREATE_ONCOREFINER_PARAMS_FILE` using `CREATE_PARAMS_FILE` to `ONCOFLOW` workflow.
- [#5](https://github.com/Clinical-Genomics/oncoflow/pull/5) Added metadata parameters `case_id`, `sample_id_tumor`, `sample_id_normal`, `subject_id` and `sex`, necessary for creating the `oncorefiner` params file using the `CREATE_ONCOREFINER_PARAMS_FILE` local module.
- [#10](https://github.com/Clinical-Genomics/oncoflow/pull/10) Added `getOncorefinerParamsList` function to produce the list of parameters necessary for `CREATE_ONCOREFINER_PARAMS_FILE`.
- [#4](https://github.com/Clinical-Genomics/oncoflow/pull/4) Added `CLINICAL_GENOMICS_ONCOREFINER` using the `NEXTFLOW_RUN` local module to run the `Clinical-Genomics/oncorefiner` pipeline in `ONCOFLOW` workflow.
- [#4](https://github.com/Clinical-Genomics/oncoflow/pull/4) Added input parameters for running `Clinical-Genomics/oncorefiner`: `oncorefiner_config` and `oncorefiner_nextflow_opts`.

### `Changed`

- [#3](https://github.com/Clinical-Genomics/oncoflow/pull/3) Changed default test to not capture `pipeline_info` files for all pipelines.
- [#3](https://github.com/Clinical-Genomics/oncoflow/pull/3) and [#4](https://github.com/Clinical-Genomics/oncoflow/pull/4) Updated `.nftignore` to ignore `pipeline_info`, `multiqc` and `vep` files for all pipelines.
- [#3](https://github.com/Clinical-Genomics/oncoflow/pull/3) Updated `.nftignore` to ignore gzipped output files from `oncoanalyser` due to https://github.com/nf-core/oncoanalyser/issues/299.
- [#3](https://github.com/Clinical-Genomics/oncoflow/pull/3) Updated `.nftignore` to ignore `*.command.*` output files from `oncoanalyser` since several files include the run directory and platform information which changes for each run and therefore cannot be snapshot.
- [#8](https://github.com/Clinical-Genomics/oncoflow/pull/8) Changed `NFCORE_ONCOANALYSER` to run forked fixed `Clinical-Genomics/oncoanalyser` instead, due to bug https://github.com/nf-core/oncoanalyser/issues/301.
- [#8](https://github.com/Clinical-Genomics/oncoflow/pull/8) Changed test config to run the above with revision `2.2.0-with-purple-tbi-fix` which includes the fix for https://github.com/nf-core/oncoanalyser/issues/301 and `nf-core/oncoanalyser` version 2.2.0 since this was the version used for previous test runs.

### `Fixed`

### `Dependencies`

### `Deprecated`
