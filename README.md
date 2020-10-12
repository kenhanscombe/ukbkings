ukbkings <img src='man/figures/logo.png' align="right" alt = "" width="123.5" />
===

<!-- badges: start -->
[![Lifecycle: maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![Travis build status](https://travis-ci.com/kenhanscombe/ukbkings.svg?branch=master)](https://travis-ci.com/kenhanscombe/ukbkings)
[![Codecov test coverage](https://codecov.io/gh/kenhanscombe/ukbkings/branch/master/graph/badge.svg)](https://codecov.io/gh/kenhanscombe/ukbkings?branch=master)
<!-- badges: end -->

**Important: This package is a KCL R interface to UKB data on Rosalind.
It is only useful for UKB-approved KCL reasearchers and their
collaborators, with an account on the Rosalind HPC cluster.**


## Overview

The ukbkings package includes functions to access UK Biobank (UKB)
project data on the Rosalind High Performance Computing (HPC) cluster,
for UKB-approved King's College London (KCL) researchers and
collaborators. Access to data for a particular project is restricted to
named collaborators on the project.

## Installation

Install this development version from github with:

``` r
devtools::install_github("kenhanscombe/ukbkings", dependencies = TRUE, force = TRUE)
```

## Project data

Project-specific data are in
/scratch/datasets/ukbiobank/\<*project_dir*\>/. The structure of a
project directory setup for use with ukbkings is documented in the
project setup tool,
[ukbproject](https://github.com/kenhanscombe/ukbproject). This is
mainly intended for project owners/ managers. Access to project data
for individual researchers is described in the **Access UKB data on
Rosalind** article.

**Note. Any additional downloads (e.g. data baskets and associated
keys, data downloads from the UKB data portal) should be stored in the
subdirectory raw/. (Do not create further subdirectories within this
folder)**
