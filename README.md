# ukbkings: the KCL interface to UKB data on Rosalind

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build status](https://travis-ci.org/kenhanscombe/ukbkings.svg?branch=master)](https://travis-ci.org/kenhanscombe/ukbkings)
<!-- badges: end -->

`ukbkings` includes a includes functions to access UK Biobank (UKB) project data
on the Rosalind High Performance Computing (HPC) cluster, for UKB-approved
King's College London (KCL) researchers and collaborators. Access to data for a
particular project is restricted to named collaborators on the project.

***

**NOTE: This package is only useful for UKB-approved KCL reasearchers and their
collaborators, with an account on Rosalind, and access to the particular
project's associated data.**

***

## Installation

To install

``` r
devtools::install_github("kenhanscombe/ukbkings", dependencies = TRUE)
```
