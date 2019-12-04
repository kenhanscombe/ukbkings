# ukbkings: a KCL interface to UKB project data on Rosalind HPC

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build status](https://travis-ci.org/kenhanscombe/ukbkings.svg?branch=master)](https://travis-ci.org/kenhanscombe/ukbkings)
<!-- badges: end -->

`ukbkings` includes a few basic tools to access UK Biobank (UKB) project data on
Rosalind HPC, for UKB-approved King's College London (KCL) researchers and
collaborators on a project-by-project basis. Access to a particular project is
restricted to named KCL researchers and collaborators, approved by the UKB for a
particular study.

***

**NOTE: This package is only useful for UKB-approved KCL reasearchers and their
collaborators, with an account on Rosalind HPC, and access to the particular
project's associated data.**

***

## Installation

To install

``` r
devtools::install_github("kenhanscombe/ukbkings", dependencies = TRUE)
```
