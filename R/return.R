#' Reads returned data
#'
#' @param project_dir Path to the enclosing directory of a UKB project.
#' @param return A integer indicating which UKB return to read, e.g.,
#' `3388` for PGxPOP returned allele and phenotype calls.
#'
#' @return For return `3388` a data frame of
#' [PGxPOP](https://github.com/PharmGKB/PGxPOP)
#' called diplotypes and phenotypes, for both the imputed and integrated
#' (imputed plus exome) data. See [McInnes et al (2020) Pharmacogenetics
#' at scale: An analysis of the UK Biobank](https://pubmed.ncbi.nlm.nih.gov/33237584/)
#'
#' @importFrom readr read_delim read_csv
#' @importFrom dplyr full_join left_join select
#' @export
bio_return <- function(project_dir, return = NULL) {
    return_path <- file.path(project_dir, "returns")

    if (is.null(return)) {
        message("For PGxPOP calls use `return = 3388`")
    } else if (return == 3388) {
        bridge_path <- Sys.glob(file.path(return_path, "*bridge33722.txt"))

        if (identical(bridge_path, character(0))) {
            stop(
                "Does your application have access to Return 3388?",
                call. = FALSE
            )
        }

        bridge_df <- readr::read_delim(bridge_path,
            delim = " ",
            col_names = c("application_id", "return_id"),
            col_type = c("ii")
        )

        imputed_path <- file.path(
            return_path, "FFR_33722_1",
            "pgx_calls.imputed_callset_DAedit.csv"
        )
        integrated_path <- file.path(
            return_path, "FFR_33722_1",
            "pgx_calls.integrated_callset_DAedit.csv"
        )

        imputed_df <- readr::read_csv(imputed_path, col_type = c("iccc"))
        integrated_df <- readr::read_csv(integrated_path, col_type = c("iccc"))

        dplyr::full_join(
            imputed_df, integrated_df,
            by = c("sample_id", "gene"),
            suffix = c("_imputed", "_integrated")
        ) %>%
            dplyr::left_join(bridge_df, by = c("sample_id" = "return_id")) %>%
            dplyr::select(
                "eid" = "application_id",
                "gene", "diplotype_imputed", "diplotype_integrated",
                "phenotype_presumptive_imputed",
                "phenotype_presumptive_integrated"
            )
    }
}