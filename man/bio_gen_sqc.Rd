% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/genotype.R
\name{bio_gen_sqc}
\alias{bio_gen_sqc}
\title{Read the sample quality control file}
\usage{
bio_gen_sqc(project_dir)
}
\arguments{
\item{project_dir}{Path to the enclosing directory of a UKB project.}
}
\value{
A dataframe of the generic sample QC file, with header, and
additional project-specific pseudo-ID column \code{eid}.
}
\description{
Reads the generic quality control file and inserts the
project-specific pseudo-IDs as column \code{eid}.
}
