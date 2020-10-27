#' Lists project genetic directory contents
#'
#' @description The listed files in genotyped/ and imputed/ are
#' symlinks to the central KCL UKB genetic data. Symlinks to the sample
#' information files .fam and .sample are included in the genotyped/
#' and imputed/ directories respectively. Relatedness and sample QC
#' files are included the imputed/ directory.
#'
#' @param project_dir Path to the enclosing directory of a UKB project.
#'
#' @importFrom stringr str_interp
#' @export
bio_gen_ls <- function(project_dir) {
  cat("-------------------------", "\n", "\n")
  cat("Paths to UKB genetic data", "\n")
  cat("-------------------------", "\n", "\n")

  cat("genotyped:", "\n")
  cat(gsub("//", "/",
           stringr::str_interp("${project_dir}/genotyped/")), "\n")
  system(stringr::str_interp("ls -1 --color ${project_dir}/genotyped/"))
  cat("\n")

  cat("imputed:", "\n")
  cat(gsub("//", "/",
           stringr::str_interp("${project_dir}/imputed/")), "\n")
  system(stringr::str_interp("ls -1 --color ${project_dir}/imputed/"))
  cat("\n")
}
