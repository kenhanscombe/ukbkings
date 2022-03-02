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
#' For return `1701` a list of two dataframes: `calls` and `sumstats`.
#' CNV calls for the full UK Biobank analysed with Affymetrix
#' Powertools, followed by PennCNV. For methods see Kendall et al.,
#' Biol Psychiatry, 2017. `sumstats` column `Filter` indicates
#' whether a person passed (1) or failed (0) filtering criteria:
#' call_rate>0.96 & NumCNV<31 & WF>-0.03 & WF<0.03 & LRR_SD <0.35
#'
#' `calls` includes:
#' - f.eid: the ID (specific to project 14421)
#' - chr: chromosome number (only autosomes are included)
#' - start / end: position on the chromosome in bp, according to hg19.
#' - Type: copy number (0,1 = deletions, 3,4 = duplications)
#' - Size: length of the CNV in base pairs
#' - Probe: number of SNP probes within the CNV (we have retained only CNVs covered with 10 or more probes)
#' - Conf: confidence call for the CNV, according to PennCNV
#' - Pathogenic_CNVs: CNVs in 92 regions described in the Supplementary material (Supplementary Table 1) of Owen D, Bracher-Smith M, Kendall KM, Rees E, Einon M, Escott-Price V, Owen MJ, O'Donovan MC, Kirov G. Effects of pathogenic CNVs on physical traits in participants of the UK Biobank. BMC Genomics. 2018 Dec 4;19(1):867. doi: 10.1186/s12864-018-5292-7. PMID: 30509170. The calls have been checked manually and the criteria for accepting a CNV are listed in the same paper: Supplementary Table 2 (typically >50% of the critical interval).
#' - N_genes_hit: the number of genes within the CNV (can be intronic)
#' - Call_rate / LRR_SD / WF / Num_CNV: indicate the quality control measures for the individual carrying the CNV, identical to those in the “Summary_statistics.dat” file.
#' - Density: indicates the number of base pairs per probe within the CNV. We recommend no more than 20,000bp per probe for a CNV to be accepted.
#' - Filter: CNVs are filtered out (0) if they were called on good arrays (call_rate>0.96 & NumCNV<31 & WF>-0.03 & WF<0.03 & LRR_SD <0.35) and had a density of <20,000bp.
#'
#' @importFrom readr read_delim read_csv
#' @importFrom dplyr full_join left_join select
#' @export
bio_return <- function(project_dir, return = NULL) {
    return_path <- file.path(project_dir, "returns")

    if (is.null(return)) {
        message("For PGxPOP calls use `return = 3388`. For CNV calls use `return = 1701`.")
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
    } else if (return == 1701) {
        bridge_path <- Sys.glob(file.path(return_path, "*bridge14421.txt"))

        if (identical(bridge_path, character(0))) {
            stop(
                "Does your application have access to Return 1701?",
                call. = FALSE
            )
        }

        bridge_df <- readr::read_delim(bridge_path,
            delim = " ",
            col_names = c("application_id", "return_id"),
            col_type = c("ii")
        )

        cnv_path <- file.path(
            return_path, "Files for Retman",
            "All_CNVs_for_UKBB.dat"
        )
        sumstats_path <- file.path(
            return_path, "Files for Retman",
            "Summary_statistics.dat"
        )

        cnv_df <- readr::read_tsv(cnv_path, col_type = c("iiiiiiiidcidddidc"))
        sumstats_df <- readr::read_tsv(sumstats_path, col_type = c("iidddii"))

        list("calls" = cnv_df, "sumstats" = sumstats_df)
    }
}