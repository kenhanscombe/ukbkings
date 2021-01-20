# ukbkings (development version)

**20.01.2020 Ken B. Hanscombe**

* Added `exact` argument to `bio_phen`, default value is `exact = FALSE` which 
gives previous behaviour, i.e., matches all fields beginning `31`.
Setting `exact = TRUE` will return only exact matches for fields supplied, e.g.,
`31` in the field subset file will match only field `31`, not `3159`, `3160` etc.

* `bio_record` returns either a character vector of available
record-level data, a [disk.frame](https://diskframe.com/), or,
if a subset of samples for whom record-level data are required is
supplied, a dataframe of all data. As the disk.frame
data are "on-disk", to query the data a relatively low-memory (1G)
slurm session is sufficient.

* `bio_record_map` applies a summary function (e.g. names, str, glimpse)
to a vector of record level data (default is to apply the function to
all available record-level data)

**12.10.2020 Ken B. Hanscombe**

* `bio_phen` accepts fields specified as either *field*-*index*.*array*
(as used in the `ukbconv` conversion to csv) or
f.*field*.*index*.*array* (as used in the `ukbconv` conversion to r/tab)

***

**Note. All paths mentioned in the Changelog are relative to
/scratch/datasets/ukbiobank/\<*project_dir*\>/.**

<br>

# ukbkings 0.2

**12.10.2020 Ken B. Hanscombe**

* Removed all project setup to
[ukbproject](https://github.com/kenhanscombe/ukbproject)

*New/updated functionality*

* `bio_covid` now also reads "Primary Care Data for COVID-19 Research":
TPP and EMIS prescriptions and GP (clinical) data

* `bio_gen_ls` lists project genetic directory contents

* `bio_code` updated path to resources/, which includes
Codings_Showcase.csv

# ukbkings 0.1

**24.09.2020 Ken B. Hanscombe**

* Updated documentation for project setup and data access can be found
under the Articles tab on the
[ukbkings page](https://kenhanscombe.github.io/ukbkings/). These can
also be read as vignettes within the installed R package

*New/updated functionality*

* `bio_covid` now returns additional codings (corresponding to new
columns in the results data), and the new blood group dataset.

* `bio_hesin` reads HES in-patient record-level data if available for
the project.

* `bio_death` reads death record data if available for the project.

*Genetic data*

* Symlinks to genotyped and imputed genetic data are included in
genotyped/ and imputed/ respectively. Project managers can add symlinks
to fam, sample and relatedness files with link.py (see
`python ./link.py --help` and the Article "Setup a UKB project on
Rosalind").

* resources/ now includes a the UKB program `ukbgene` used to retrieve
UKB "link" files (.fam, .sample) and relatedness data.
