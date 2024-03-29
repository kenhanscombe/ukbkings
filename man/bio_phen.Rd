% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/phenotype.R
\name{bio_phen}
\alias{bio_phen}
\title{Reads and writes phenotype data for a subset of fields}
\usage{
bio_phen(
  project_dir,
  field_subset_file,
  pheno_dir = "phenotypes",
  out = "ukb_phenotype_subset",
  exact = FALSE
)
}
\arguments{
\item{project_dir}{Path to the enclosing directory of a UKB project.}

\item{field_subset_file}{A path to a one-per-line text file of
fields (no header). Fields can be specified as
f.\emph{field.index.array}, or \emph{field-index.array}.}

\item{pheno_dir}{Path to the enclosing directory of the phenotype
data.}

\item{out}{Name of phenotype subset file. Default
"ukb_phenotype_subset", writes ukb_phenotype_subset.rds to the
current directory.}

\item{exact}{Setting \code{exact = TRUE} will return all -\emph{index}.\emph{array}
entries for only exact matches of fields in \code{field_subset_file},e.g.,
\code{31}, would return all 31_-index.array_, but not for fields \code{3159},
\code{3160} etc. Default \code{FALSE}. \strong{Note}: Do not set \code{exact = TRUE} if
you have supplied full field names (i.e., including \emph{index} and
\emph{array}) in your field subset file, e.g., 31-0.0 or 31.0.0}
}
\description{
Reads supplied fields from UKB project data and writes a serialized
dataframe to a .rds file.
}
\details{
Read the serialized dataframe with
readRDS("<name_of_phenotype_subset_file>.rds").

Periodically, the UKB will update some subset of the data, e.g.,
hospital episode statistics. When this happens, the datafame created
will include all duplicates with the basket ID as suffix
("\emph{<basket_id>"). Decide which to keep, larger basket numbers
correspond to more recent data. To use \code{\link{bio_rename}},
to update the numeric field names to more descriptive names, first
drop duplicates you do not want and rename the remaining fields by
deleting the "}<basket_id>" suffix.
}
\seealso{
\code{\link{bio_field}} \code{\link{bio_rename}}
}
