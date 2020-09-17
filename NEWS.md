ukbkings
===

All paths mentioned below are relative to /scratch/datasets/ukbiobank/\<*project_dir*\>/.

<br>

## v0.1 - 16.09.2020

*Ken B. Hanscombe*

* Updated documentation for project setup and data access can be found under the Articles tab on the [ukbkings page](https://kenhanscombe.github.io/ukbkings/). These can also be read as vignettes within the installed R package

* Symlinks to genotyped and imputed genetic data are included in genotyped/ and imputed/ respectively. Symlinks to fam, sample and relatedness files can be added with link.py.

* Project setup with project.py now also copies the UKB program `ukbgene` to the project directory resources/.

**New functionality**

* `bio_hesin` reads HES in-patient record-level data if available for the project.
