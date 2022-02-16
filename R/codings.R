#' Reads the UKB showcase codings for categorical variables
#'
#' @param code_dir Path to the enclosing directory of the
#' Codings_Showcase.csv.
#'
#' @return A dataframe with header Coding, Value, Meaning
#'
#' @importFrom data.table fread
#' @export
bio_code <- function(code_dir = "/scratch/datasets/ukbiobank/resources") {
    codings_showcase <- file.path(
        normalizePath(code_dir),
        "Codings.csv"
    )

    if (!file.exists(codings_showcase)) {
        stop(
            stringr::str_interp(c(
                "Required file ${codings_showcase} ",
                "does not exist."
            )),
            call. = FALSE
        )
    }

    data.table::fread(
        cmd = str_interp("sed 's:\\\\\"::g' ${codings_showcase}"),
        sep = ",",
        header = TRUE
    )
}


#' Reads UKB reference data: primary care maps and lookups
#'
#' @param project_dir Path to the enclosing directory of a UKB project.
#' @param lkp A character vector naming the required table. To see all
#' available primary care coding tables, set `lkp = NULL` (default).
#'
#' @return If `lkp = NULL` (default) a data frame of available primary
#' care lookup tables. If a value from the `table` column is supplied
#' to `lkp`, a data frame of the named primary care lookup table:
#'
#' @importFrom readxl excel_sheets read_excel
#' @importFrom tidyr drop_na
#' @importFrom dplyr select
#' @importFrom rlang set_names
#' @export
bio_code_primary_care <- function(project_dir, lkp = NULL) {
    pc_codings_path <- file.path(
        dirname(project_dir),
        "resources/primarycare_codings/all_lkps_maps_v3.xlsx"
    )

    if (is.null(lkp)) {
        tables <- base::setdiff(
            readxl::excel_sheets(pc_codings_path),
            c("Description", "Contents")
        )

        contents <- readxl::read_excel(pc_codings_path, sheet = "Contents") %>%
            dplyr::select(1) %>%
            tidyr::drop_na()

        tibble::tibble(tables, contents) %>%
            rlang::set_names(c("table", "description"))
    } else {
        readxl::read_excel(pc_codings_path, sheet = lkp)
    }
}