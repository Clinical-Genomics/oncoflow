# Clinical-Genomics/oncoflow: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.0.0dev - [date]

Initial release of Clinical-Genomics/oncoflow, created with the [nf-core](https://nf-co.re/) template.

### `Added`

- [#2](https://github.com/Clinical-Genomics/oncoflow/pull/2) `NEXTFLOW_RUN` local module based on `mahesh-panchal/nf-cascade`.
- [#3](https://github.com/Clinical-Genomics/oncoflow/pull/3) Added `NFCORE_ONCOANALYSER` using the `NEXTFLOW_RUN` local module to run the `nf-core/oncoanalyser` pipeline.

### `Changed`

- [#3](https://github.com/Clinical-Genomics/oncoflow/pull/3) Updated `.nftignore` to also ignore `pipeline_info`, `multiqc`, and `vep` files for all pipelines.
- [#3](https://github.com/Clinical-Genomics/oncoflow/pull/3) Changed default test to not capture `pipeline_info` files for run pipelines.

### `Fixed`

### `Dependencies`

### `Deprecated`
