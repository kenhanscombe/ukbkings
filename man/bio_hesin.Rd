% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/record.R
\name{bio_hesin}
\alias{bio_hesin}
\title{Reads record-level HES in-patient data}
\usage{
bio_hesin(project_dir, record, hesin_dir = "raw/")
}
\arguments{
\item{project_dir}{Path to the enclosing directory of a UKB project.}

\item{record}{A string specifying which HES records are required:
"critical", "delivery", "diag", "maternity", "oper", "psych",
"hesin".}

\item{hesin_dir}{Path to the enclosing directory of the primary care
data.}
}
\value{
A dataframe of the requested record-level data.
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#deprecated}{\figure{lifecycle-deprecated.svg}{options: alt='[Deprecated]'}}}{\strong{[Deprecated]}}

This function has been deprecated in favour of a single function to
read all record-level data. Use \code{\link[=bio_record]{bio_record()}} to retrieve data.
Summarize/ inspect record-level data with \code{\link[=bio_record_map]{bio_record_map()}}.

Record-level hospital episode statistics (HES)
in-patient information.
}
\seealso{
\href{https://biobank.ndph.ox.ac.uk/showcase/label.cgi?id=2000}{Category 2000},
\href{https://biobank.ndph.ox.ac.uk/showcase/label.cgi?id=2006}{Category 2006},
\href{https://biobank.ndph.ox.ac.uk/showcase/refer.cgi?id=138483}{Resource 138483},
\href{https://biobank.ndph.ox.ac.uk/showcase/refer.cgi?id=141140}{Resource 141140}
}
\keyword{internal}
