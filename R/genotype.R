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
    cat(gsub(
        "//", "/",
        stringr::str_interp("${project_dir}/genotyped/")
    ), "\n")
    system(stringr::str_interp("ls -1 --color ${project_dir}/genotyped/"))
    cat("\n")

    cat("imputed:", "\n")
    cat(gsub(
        "//", "/",
        stringr::str_interp("${project_dir}/imputed/")
    ), "\n")
    system(stringr::str_interp("ls -1 --color ${project_dir}/imputed/"))
    cat("\n")
}


#' Read the project-specific fam file
#'
#' Reads the latest project-specific fam file (withdrawals will have
#' negative IDs).
#'
#' @return A dataframe of the project specific fam file, with a header
#'
#' @param project_dir Path to the enclosing directory of a UKB project.
#'
#' @importFrom data.table fread
#' @importFrom rlang set_names
#' @export
bio_gen_fam <- function(project_dir) {
    genotyped <- file.path(project_dir, "genotyped")
    fam_files <- list.files(genotyped, pattern = "fam$", full.names = TRUE)

    data.table::fread(
        fam_files[which.max(file.mtime(fam_files))],
        header = FALSE,
        data.table = FALSE
    ) %>%
        rlang::set_names(c("fid", "iid", "pid", "mid", "sex", "batch"))
}


#' Read the sample quality control file
#'
#' Reads the generic quality control file and inserts the
#' project-specific pseudo-IDs as column `eid`.
#'
#' @return A dataframe of the generic sample QC file, with header, and
#' additional project-specific pseudo-ID column `eid`.
#'
#' @param project_dir Path to the enclosing directory of a UKB project.
#'
#' @importFrom data.table fread
#' @importFrom rlang set_names
#' @importFrom dplyr mutate select bind_cols
#' @export
bio_gen_sqc <- function(project_dir) {
    imputed <- file.path(project_dir, "imputed")

    sqc_col_names <- c(
        "affymetrix.1", "affymetrix.2", "genotyping.array", "Batch",
        "Plate.Name", "Well", "Cluster.CR", "dQC", "Internal.Pico..ng.uL.",
        "Submitted.Gender", "Inferred.Gender", "X.intensity", "Y.intensity",
        "Submitted.Plate.Name", "Submitted.Well", "sample.qc.missing.rate",
        "heterozygosity", "heterozygosity.pc.corrected",
        "het.missing.outliers", "putative.sex.chromosome.aneuploidy",
        "in.kinship.table", "excluded.from.kinship.inference",
        "excess.relatives", "in.white.British.ancestry.subset",
        "used.in.pca.calculation", stringr::str_c("pc", 1:40),
        "in.Phasing.Input.chr1_22", "in.Phasing.Input.chrX",
        "in.Phasing.Input.chrXY"
    ) %>%
        tolower()

    sqc <- data.table::fread(
        file.path(imputed, "ukb_sqc_v2.txt"),
        header = FALSE
    ) %>%
        rlang::set_names(sqc_col_names)

    fam <- bio_gen_fam(project_dir) %>%
        dplyr::mutate(index = seq_len(nrow(.)))

    stopifnot(nrow(sqc) == nrow(fam))

    fam %>%
        dplyr::select("eid" = fid) %>%
        dplyr::bind_cols(sqc)
}


#' Read the project-specific relatedness file
#'
#' @return A dataframe of relatedness with project-specific pseudo-IDS.
#'
#' @param project_dir Path to the enclosing directory of a UKB project.
#'
#' @importFrom data.table fread
#' @export
bio_gen_related <- function(project_dir) {
    imputed <- file.path(project_dir, "imputed")

    data.table::fread(
        list.files(imputed, pattern = ".*rel.*.dat", full.names = TRUE),
        data.table = FALSE
    )
}


#' Assigns 1000 Genomes super populations
#'
#' Assigns 1000 genomes super population after ancestry-specific QC. For
#' QC details, see Ollie Pain's
#' [Ancestry Specific Quality Control](https://opain.github.io/UKB-GenoPrep/quality_control.html)
#' documentation.
#'
#' @param project_dir Path to the enclosing directory of a UKB project.
#'
#' @importFrom dplyr mutate select bind_rows
#' @importFrom purrr map reduce
#' @importFrom data.table fread
#' @importFrom stringr str_c
#' @importFrom rlang set_names
#' @export
bio_gen_ancestry <- function(project_dir) {
    fam <- bio_gen_fam(project_dir) %>%
        dplyr::mutate(index = seq_len(nrow(.)))

    sqc <- bio_gen_sqc(project_dir) %>%
        dplyr::mutate(index = seq_len(nrow(.)))

    ancestry_dir <- file.path(dirname(project_dir), "ancestry")
    super_pop <- c("AFR", "AMR", "EAS", "EUR", "SAS")
    pop <- purrr::map(
        super_pop,
        ~ data.table::fread(
            file.path(ancestry_dir, stringr::str_c("UKB.postQC.", ., ".keep")),
            header = FALSE
        )
    ) %>%
        rlang::set_names(super_pop) %>%
        dplyr::bind_rows(.id = "pop") %>%
        rlang::set_names(c("pop", "index", "index2")) %>%
        dplyr::select(c("pop", "index"))

    list(
        fam,
        pop,
        dplyr::select(sqc, index, inferred.gender)
    ) %>%
        purrr::reduce(left_join, by = "index") %>%
        dplyr::select("eid" = fid, pop)
}
