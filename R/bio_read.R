
utils::globalVariables(c("ukb_type", "basket", "field", "path", "name",
                         "data", "df", "."))


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


#' Reads and writes phenotype data for a subset of fields
#'
#' Reads supplied fields from UKB project data and writes a serialized
#' dataframe to a .rds file.
#'
#' @param project_dir Path to the enclosing directory of a UKB project.
#' @param field_subset_file A path to a one-per-line text file of fields (no header).
#' @param out Name of phenotype subset file. Default "ukb_phenotype_subset", writes ukb_phenotype_subset.rds to the current directory.
#'
#' @details Read the serialized dataframe with readRDS("<name_of_phenotype_subset_file>.rds")
#'
#' @importFrom data.table fread getDTthreads
#' @importFrom dplyr pull filter group_by mutate
#' @importFrom stringr str_detect str_c str_interp
#' @importFrom tidyr nest
#' @importFrom purrr map reduce
#' @export
bio_phen <-
  function(project_dir, field_subset_file, out = "ukb_phenotype_subset") {

    field_finder <- bio_field(project_dir)
    field_subset <- data.table::fread(field_subset_file, header = FALSE) %>%
      dplyr::pull(1)

    # field_subset_index <- match(field_subset, field_finder$field)
    # field_cut <- stringr::str_c(field_subset_index, collapse = ",")
    # field_awk <- stringr::str_c(
    #   stringr::str_c("$", field_subset_index), collapse = ",")

    field_selection <- field_finder %>%
      dplyr::filter(
        stringr::str_detect(
          field, stringr::str_c(
            stringr::str_c("^", field_subset), collapse = "|")))

    bio_reader <- function(data) {
      p <- dplyr::pull(data, path)[1]
      f <- dplyr::pull(data, "field")
      t <- dplyr::pull(data, "r_type")
      names(t) <- f

      data.table::fread(
        p, header = TRUE, select = c("eid", f), data.table = FALSE,
        colClasses = c("integer", t),
        na = c("", "NA"), nThread = data.table::getDTthreads())

      # cmd = stringr::str_interp("cut -d',' -f${field_cut} ${p}"),
      # header = TRUE, data.table = FALSE,
      # na = c("", "NA"), nThread = data.table::getDTthreads())

      # cmd = stringr::str_interp("awk -FS',' '{print ${field_awk}}' ${p}"),
      # header = TRUE, data.table = FALSE,
      # na = c("", "NA"), nThread = data.table::getDTthreads())
    }


    field_selection_nested <- field_selection %>%
      dplyr::filter(!stringr::str_detect(name, "eid")) %>%
      dplyr::group_by(basket) %>%
      tidyr::nest() %>%
      dplyr::mutate(csv = purrr::map(data, bio_reader))

    field_selection_nested

    field_selection_nested$csv %>%
      purrr::reduce(full_join) %>%
      saveRDS(file = stringr::str_c(out, ".rds"))
  }



#' Adds \strong{field} column entries from a dataframe to a file
#'
#' @param data A dataframe with obligatory column \strong{field}. (Ideally the output of \code{\link{bio_field}}.)
#' @param out Field subset file name (including path). Default "ukb_field_subset", writes or appends fields one per line to "ukb_field_subset" in the current directory.
#'
#' @return A file with one field per line (no header). If the file exists, the additional fields are appended.
#'
#' @importFrom dplyr pull
#' @export
bio_field_add <- function(data, out = "ukb_field_subset.txt") {
  data %>%
    dplyr::pull(field) %>%
    {
      if(file.exists(out)) {
        cat(., file = out, sep = "\n", append = TRUE)
      } else {
        cat(., file = out, sep = "\n")
      }
    }
}


#' Reads the primary care data
#'
#' Detailed patient level diagnoses, prescriptions, etc. Only available if these data have been requested for the particular project you have access to.
#'
#' @param project_dir Path to the enclosing directory of a UKB project.
#' @param record A string specifying which primary care records are required: "clinical", "registrations", "scripts".
#'
#' @return A dataframe. \strong{Note}. clinical data has 123,669,371 rows and 8 columns; registrations data has 361,841 rows and 4 columns; scripts data has 57,709,810 rows and 8 columns.
#'
#' @export
bio_gp <- function(project_dir, record) {
  if (record == "clinical") {
    data.table::fread(file.path(project_dir, "raw/gp_clinical.txt"),
                      header = TRUE)
  }

  if (record == "registrations") {
    data.table::fread(file.path(project_dir, "raw/gp_registrations.txt"),
                      header = TRUE)
  }

  if (record == "scripts") {
    data.table::fread(file.path(project_dir, "raw/gp_scripts.txt"),
                      header = TRUE)
  }
}


# bio_field_showcase() {
#   browseURL
# }


#' Reads the UKB showcase codings for categorical variables
#'
#' @param project_dir Path to the enclosing directory of a UKB project.
#'
#' @return A dataframe with header Coding, Value, Meaning
#'
#' @importFrom data.table fread
#' @export
bio_code <- function(project_dir) {
  data.table::fread(file.path(project_dir, "resources/Codings_Showcase.csv"),
                    sep = ",", header = TRUE)
}
