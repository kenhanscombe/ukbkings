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
#' @param project_dir Path to the enclosing directory of a UKB project.
#'
#' @return A dataframe of relatedness with project-specific pseudo-IDS.
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


#' Find relatives to remove
#'
#' @description Uses [GreedyRelated](https://gitlab.com/choishingwan/GreedyRelated)
#' to maximize sample size by removing one member of each pair with
#' relatedness above a specified threshold.
#'
#' @param project_dir Path to the enclosing directory of a UKB project.
#' @param  greedy_related Path to the
#' [GreedyRelated](https://gitlab.com/choishingwan/GreedyRelated)
#' binary.
#' @param thresh KING kinship coefficient threshold. One member of each
#' pair exceeding this threshold is returned in a dataframe to be
#' removed from further analyses. (default = `0.044`)
#' @param keep An optional vector of samples on which to perform relative
#' removal, e.g., samples with data on a phenotype of interest.
#' GreedyRelated ignores samples not included in `keep`. (default =
#' `NULL`, i.e., all samples are considered).
#' @param seed Seed used for the random number generator (default = `1234`).
#'
#' @details Re. the KING robust kinship estimator, from
#' [KING documentation](https://people.virginia.edu/~wc9c/KING/manual.html):
#' A negative kinship coefficient estimation indicates an unrelated
#' relationship. The reason that a negative kinship coefficient is not
#' set to zero is a very negative value may indicate the population
#' structure between the two individuals. Close relatives can be
#' inferred fairly reliably based on the estimated kinship coefficients
#' as shown in the following simple algorithm: an estimated kinship
#' coefficient range >0.354, \[0.177, 0.354\], \[0.0884, 0.177\] and
#' \[0.0442, 0.0884\] corresponds to duplicate/MZ twin, 1st-degree,
#' 2nd-degree, and 3rd-degree relationships respectively.
#'
#' From [PLINK 2.0 documentation](https://www.cog-genomics.org/plink/2.0/distance#make_king):
#' Note that KING kinship coefficients are scaled such that duplicate
#' samples have kinship 0.5, not 1. First-degree relations
#' (parent-child, full siblings) correspond to ~0.25, second-degree
#' relations correspond to ~0.125, etc. It is conventional to use a
#' cutoff of ~0.354 (the geometric mean of 0.5 and 0.25) to screen for
#' monozygotic twins and duplicate samples, ~0.177 to add first-degree
#' relations, etc.
#'
#' @returns A data frame of samples to remove.
#'
#' @import dplyr
#' @importFrom readr write_delim
#' @importFrom processx run
#' @importFrom rlang set_names
#' @importFrom utils read.table
#' @importFrom tibble tibble
#' @export
bio_gen_related_remove <- function(project_dir, greedy_related,
                                   thresh = 0.044, keep = NULL, seed = 1234) {
    message(c(
        "Using:",
        system(paste(greedy_related, "2>&1 | head -n 3"), intern = TRUE)
    ))

    tmp_rel <- tempfile()

    rel <- bio_gen_related(project_dir) %>%
        dplyr::mutate(Pair = seq_len(nrow(.)))

    dplyr::bind_rows(
        dplyr::select(rel, ID = ID1, Pair, Factor = Kinship),
        dplyr::select(rel, ID = ID2, Pair, Factor = Kinship)
    ) %>%
        dplyr::arrange(Pair) %>%
        readr::write_delim(tmp_rel)

    greedy_args <- c("-r", tmp_rel, "-t", thresh, "-s", seed)

    if (!is.null(keep)) {
        tmp_keep <- tempfile()
        greedy_args <- c(greedy_args, "-k", tmp_keep)
        tibble::tibble(keep) %>%
            readr::write_delim(tmp_keep, col_names = FALSE)
    }

    greedy_out <- processx::run(greedy_related, greedy_args)

    utils::read.table(text = greedy_out$stdout, sep = "\t") %>%
        dplyr::select(1) %>%
        rlang::set_names("eid")
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
#' @return A dataframe of project-specific pseudo-IDs and 1000 Genomes super
#' population
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


#' Writes a two-column dataframe of IDs for PLINK input
#'
#' @param data Either a vector of sample IDs, or a dataframe with
#' sample IDs in column 1.
#' @param out Full file path to write PLINK input sample list to.
#'
#' @importFrom dplyr select
#' @importFrom readr write_delim
#' @importFrom tibble tibble
#' @export
bio_gen_write_plink_input <- function(data, out) {
    if (is.data.frame(data)) {
        data %>%
            dplyr::select("fid" = 1, "iid" = 1) %>%
            readr::write_delim(out, col_names = FALSE)
    } else if (is.vector(data)) {
        tibble::tibble("fid" = data, "iid" = data) %>%
            readr::write_delim(out,
                col_names = FALSE
            )
    } else {
        stop("Supply a vector of samples, or a dataframe with samples in column 1.")
    }
}
