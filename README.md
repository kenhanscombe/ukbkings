ukbkings <img src='man/figures/logo.png' align="right" alt = "" width="123.5" />
===

<!-- badges: start -->
[![Lifecycle: maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![codecov](https://codecov.io/gh/kenhanscombe/ukbkings/branch/master/graph/badge.svg?token=90dtoi0RvG)](https://codecov.io/gh/kenhanscombe/ukbkings)
[![R build status](https://github.com/kenhanscombe/ukbkings/workflows/R-CMD-check/badge.svg)](https://github.com/kenhanscombe/ukbkings/actions)
<!-- badges: end -->

**Important: This package is a KCL R interface to UKB data on Rosalind/CREATE.
It is only useful for UKB-approved KCL reasearchers and their
collaborators, with an account on the Rosalind/CREATE HPC cluster.**

## Overview

The ukbkings package includes functions to access UK Biobank (UKB)
project data on the Rosalind/CREATE High Performance Computing (HPC) cluster,
for UKB-approved King's College London (KCL) researchers and
collaborators. Access to data for a particular project is restricted to
named collaborators on the project.

## Installation

Install this development version from github with:

``` r
devtools::install_github("kenhanscombe/ukbkings", dependencies = TRUE, force = TRUE)
```

## Project data

Project-specific phenotype data and genetic link files (.fam, .sample,
.dat) are in project-specific folders. The structure of a
project directory setup for use with ukbkings is documented in the
project setup tool,
[ukbproject](https://github.com/kenhanscombe/ukbproject).

**Note. Any additional downloads (e.g. data baskets and associated
keys, data downloads from the UKB data portal) should be stored in the
subdirectory raw/. (Do not create further subdirectories within this
folder)**
