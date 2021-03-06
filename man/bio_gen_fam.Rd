% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/genotype.R
\name{bio_gen_fam}
\alias{bio_gen_fam}
\title{Read the project-specific fam file}
\usage{
bio_gen_fam(project_dir)
}
\arguments{
\item{project_dir}{Path to the enclosing directory of a UKB project.}
}
\value{
A dataframe of the project specific fam file, with a header
}
\description{
Reads the latest project-specific fam file (withdrawals will have
negative IDs).
}
