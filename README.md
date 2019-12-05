# ukbkings: KCL R interface to UKB data on Rosalind

<!-- badges: start -->
[![Travis build status](https://travis-ci.org/kenhanscombe/ukbkings.svg?branch=master)](https://travis-ci.org/kenhanscombe/ukbkings)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

***

**NOTE: This package is only useful for UKB-approved KCL reasearchers and their collaborators, with an account on the Rosalind HPC cluster.**

***

`ukbkings` includes functions to access UK Biobank (UKB) project data on the Rosalind High Performance Computing (HPC) cluster, for UKB-approved King's College London (KCL) researchers and collaborators. Access to data for a particular project is restricted to named collaborators on the project.

## Installation

To install

``` r
devtools::install_github("kenhanscombe/ukbkings", dependencies = TRUE)
```
