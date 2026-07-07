# Clinical-Genomics/oncoflow: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.0.0dev - [date]

Initial release of Clinical-Genomics/oncoflow, created with the [nf-core](https://nf-co.re/) template.

### `Added`

- [#2](https://github.com/Clinical-Genomics/oncoflow/pull/2) Added `NEXTFLOW_RUN` local module based on `mahesh-panchal/nf-cascade`.
- [#3](https://github.com/Clinical-Genomics/oncoflow/pull/3) Added `NFCORE_ONCOANALYSER` using the `NEXTFLOW_RUN` local module to run the `nf-core/oncoanalyser` pipeline.
- [#3](https://github.com/Clinical-Genomics/oncoflow/pull/3) Added input parameters for running `nf-core/oncoanalyser`: `oncoanalyser_config`, `oncoanalyser_nextflow_opts`, `oncoanalyser_params_file` and `oncoanalyser_samplesheet`.

### `Changed`

- [#3](https://github.com/Clinical-Genomics/oncoflow/pull/3) Updated `.nftignore` to ignore `pipeline_info` and `multiqc` files for all pipelines.
- [#3](https://github.com/Clinical-Genomics/oncoflow/pull/3) Updated `.nftignore` to ignore gzipped output files from `oncoanalyser` due to https://github.com/nf-core/oncoanalyser/issues/299.
- [#3](https://github.com/Clinical-Genomics/oncoflow/pull/3) Updated `.nftignore` to ignore `*.command.*` output files from `oncoanalyser` since several files include the run directory and platform information which changes for each run and therefore cannot be snapshot.
- [#3](https://github.com/Clinical-Genomics/oncoflow/pull/3) Changed default test to not capture `pipeline_info` files for all pipelines.

### `Fixed`

### `Dependencies`

### `Deprecated`
