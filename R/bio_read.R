
utils::globalVariables(c("ukb_type", "basket"))

#' Reads project-specific UKB field codes
#'
#' The field code lookup table associates with each field id, a desciptive name (which includes the field id, array, index), ukb_type, r_type, basket and the path to the csv file containing the field data.
#'
#' @param project_dir Path to the enclosing directory of a UKB project
#'
#' @return A dataframe with columns: ukb_type, r_type, path
#'
#' @import stringr dplyr
#' @importFrom data.table fread
#' @importFrom rlang set_names
#' @importFrom purrr map
#' @importFrom magrittr "%>%"
#'
#' @export
bio_field <- function(project_dir) {

  if(!dir.exists(project_dir)) {
    stop("Invalid project directory path.", call. = FALSE)
  }

  field_files <- list.files(project_dir, pattern = "ukb.*field_finder.txt",
                            full.names = TRUE)

  baskets <- gsub(
      stringr::str_interp("/|${project_dir}|phenotypes|_field_finder.txt"),
      "", field_files)

  col_type <- c(
    "Sequence" = "integer",
    "Integer" = "integer",
    "Categorical (single)" = "integer",
    "Categorical (multiple)" = "integer",
    "Continuous" = "double",
    "Text" = "character",
    "Date" = "Date",
    "Time" = "character",
    "Compound" = "character",
    "Binary object" = "character",
    "Records" = "character",
    "Curve" = "character"
  )

  field_finder <- purrr::map(field_files, ~ data.table::fread(.)) %>%
    rlang::set_names(baskets) %>%
    dplyr::bind_rows(.id = "basket") %>%
    dplyr::mutate(
      r_type = col_type[ukb_type],
      path = file.path(project_dir, stringr::str_c(basket, ".csv")))

  as.data.frame(field_finder)
  }
