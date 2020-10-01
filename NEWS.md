# ukbkings (development version)

**Note. All paths mentioned in the Changelog are relative to /scratch/datasets/ukbiobank/\<*project_dir*\>/.**

* `bio_gen_ls` lists project genetic directory contents

* `bio_code` updated path to resources/, which includes Codings_Showcase.csv


# ukbkings 0.1

**24.09.2020 Ken B. Hanscombe**

* Updated documentation for project setup and data access can be found under the Articles tab on the [ukbkings page](https://kenhanscombe.github.io/ukbkings/). These can also be read as vignettes within the installed R package

*New/updated functionality*

* `bio_covid` now returns additional codings (corresponding to new columns in the results data), and the new blood group dataset.

* `bio_hesin` reads HES in-patient record-level data if available for the project.

* `bio_death` reads death record data if available for the project.

*Genetic data*

* Symlinks to genotyped and imputed genetic data are included in genotyped/ and imputed/ respectively. Project managers can add symlinks to fam, sample and relatedness files with link.py (see `python ./link.py --help` and the Article "Setup a UKB project on Rosalind").

* resources/ now includes a the UKB program `ukbgene` used to retrieve UKB "link" files (.fam, .sample) and relatedness data.
