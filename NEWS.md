# ukbkings (development version)

**16.02.2022 Ken B. Hanscombe**

*New/updated functionality*

* `bio_return` reads UKB returns. With argument `return = 3388`
reads PGxPOP returned allele and metabolizing phenotype calls and
assigns application specific pseudo IDs.

* `bio_code_primary_care` reads UKB primary care prescription and
diagnosis codings maps and lookups (From UKB download
primarycare_codings.zip)

*New datasets*

* Added datasets `drug_pharmgkb`, `drug_gwas`, `drug_dmd_antidep`

***

**Note. All paths mentioned in the Changelog are relative to
the project-specific data folder.**

<br>

# ukbkings 0.2.1

**03.02.2020 Ken B. Hanscombe**

* Added `bio_gen_related_remove` which uses
[GreedyRelated](https://gitlab.com/choishingwan/GreedyRelated)
to returns a minimum sample list to remove in order to remove all
relationships at a given relatedness threshold, retaining the maximum
amount of samples.

* Added `bio_gen_write_plink_input` which take either a vector of sample
IDs, or a dataframe with sample IDs in the first column, and writes
these to the first two columns of a white-space separated file, with no
header.

**22.01.2020 Ken B. Hanscombe**

* Added convenience read functions: `bio_gen_fam` returns
project-specific fam (with header), `bio_gen_sqc` returns
generic sample QC with header and addtional column containing
project-specific pseudo-IDs (`eid`), `bio_gen_related` returns
project-specific relatedness

* Added `bio_gen_ancestry` which returns a dataframe with
project-specific pseudo-ID (`eid`), and 1000 genomes
super population (`pop`). For QC and super population assignment details
see Ollie's
[Ancestry Specific Quality Control](https://opain.github.io/UKB-GenoPrep/quality_control.html) documentation.

**20.01.2020 Ken B. Hanscombe**

* Added `exact` argument to `bio_phen`, default value is `exact = FALSE` which
gives previous behaviour, i.e., matches all fields beginning `31`.
Setting `exact = TRUE` will return only exact matches for fields supplied, e.g.,
`31` in the field subset file will return all *-index.array* entries for field
`31`, and not `3159`, `3160` etc.

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

* resources/ now includes a the UKB program `ukbgene` used to retrieve
UKB "link" files (.fam, .sample) and relatedness data.
