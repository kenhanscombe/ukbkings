
utils::globalVariables(c("ukb_type", "basket", "field", "path", "name",
                         "data", "df", ".", "withdraw", "eid",
                         "results_column", "coding", "meaning", "value"))


#' Reads project-specific UKB field codes
#'
#' The field code lookup table associates with each field id, a
#' desciptive name (which includes the field id, array, index),
#' ukb_type, r_type, basket and the path to the csv file containing the
#' field data.
#'
#' @param project_dir Path to the enclosing directory of a UKB project
#' @param pheno_dir Path to the enclosing directory of the phenotype
#' data.
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
bio_field <- function(project_dir, pheno_dir = "phenotypes") {

    if(!dir.exists(project_dir)) {
        stop("Invalid project directory path.", call. = FALSE)
    }

    finder_paths <- list.files(file.path(project_dir, pheno_dir),
                               pattern = "ukb.*field_finder.txt",
                               full.names = TRUE)
    finder_names <- list.files(file.path(project_dir, pheno_dir),
                               pattern = "ukb.*field_finder.txt")

    baskets <- stringr::str_remove("_field_finder.txt", finder_names)

    col_type <- c(
        "Sequence" = "integer",
        "Integer" = "integer",
        "Categorical (single)" = "character",
        "Categorical (multiple)" = "character",
        "Continuous" = "double",
        "Text" = "character",
        "Date" = "character",
        "Time" = "character",
        "Compound" = "character",
        "Binary object" = "character",
        "Records" = "character",
        "Curve" = "character"
    )

    field_finder <- purrr::map(finder_paths, ~ data.table::fread(.)) %>%
        rlang::set_names(baskets) %>%
        dplyr::bind_rows(.id = "basket") %>%
        dplyr::mutate(
            r_type = col_type[ukb_type],
            path = file.path(project_dir, pheno_dir,
                             stringr::str_c(basket, ".csv"))
        )

    f <- as.data.frame(field_finder) 
    dups <- f$field[duplicated(f$field)]
    dups <- dups[!(dups %in% "eid")]
    dups <- unique(dups)

    f$duplicated <- f$field %in% dups

    f %>%
        tidyr::unite(field_basket, field, basket, remove = FALSE) %>%
        rowwise() %>%
        mutate(field_unique = ifelse(duplicated, field_basket, field)) %>%
        select(-field_basket, -duplicated) %>%
        as.data.frame()
}


#' Reads and writes phenotype data for a subset of fields
#'
#' Reads supplied fields from UKB project data and writes a serialized
#' dataframe to a .rds file.
#'
#' @param project_dir Path to the enclosing directory of a UKB project.
#' @param field_subset_file A path to a one-per-line text file of
#' fields (no header). Fields can be specified as
#' f.\emph{field.index.array}, or \emph{field-index.array}.
#' @param pheno_dir Path to the enclosing directory of the phenotype
#' data.
#' @param out Name of phenotype subset file. Default
#' "ukb_phenotype_subset", writes ukb_phenotype_subset.rds to the
#' current directory.
#'
#' @details Read the serialized dataframe with
#' readRDS("<name_of_phenotype_subset_file>.rds")
#'
#' @importFrom data.table fread getDTthreads
#' @importFrom dplyr pull filter group_by mutate na_if
#' @importFrom readr read_csv
#' @importFrom stringr str_detect str_c str_interp
#' @importFrom tidyr nest
#' @importFrom purrr map map_df map_chr reduce
#' @export
bio_phen <- function(project_dir, field_subset_file,
                     pheno_dir = "phenotypes", out = "ukb_phenotype_subset") {

    bio_reader <- function(data) {
      p <- dplyr::pull(data, path)[1]
      f <- c("eid", dplyr::pull(data, "field"))
      t <- c("integer", dplyr::pull(data, "r_type"))
      names(t) <- f

      data.table::fread(
        p, header = TRUE, data.table = FALSE, na = c("", "NA"),
        nThread = data.table::getDTthreads(), select = f, colClasses = t
      )
    }


    field_finder <- bio_field(project_dir, pheno_dir)

    field_subset <- data.table::fread(field_subset_file, header = FALSE) %>%
        dplyr::pull(1)

    field_subset <- purrr::map_chr(field_subset,
        ~ {
            ifelse(
                str_detect(., "f\\."), 
                str_remove(., pattern = "^f\\.") %>%
                str_replace(pattern = "\\.", replacement = "-"),
                .
            )
        }
    )

    field_selection <- field_finder %>%
      dplyr::filter(
        stringr::str_detect(
          field, stringr::str_c(
            stringr::str_c("^", field_subset), collapse = "|")))

    n_baskets <- field_selection %>%
      distinct(basket) %>%
      nrow()

    message("Reading data from ", n_baskets, " baskets ...")

    field_selection_nested <- field_selection %>%
      dplyr::filter(!stringr::str_detect(name, "eid")) %>%
      dplyr::group_by(basket) %>%
      tidyr::nest() %>%
      dplyr::mutate(csv = purrr::map(data, bio_reader))

    message("Merging baskets ...")

    df <- field_selection_nested$csv %>%
      purrr::reduce(full_join)

    # withdrawals
    withdraw_files <- list.files("raw", pattern = "^w.*csv", full.names = TRUE)

    if (length(withdraw_files) > 0) {
      withdraw_ids <- purrr::map_df(
        withdraw_files, ~readr::read_csv(., col_names = "withdraw")) %>%
        dplyr::pull(withdraw)

      withdraw_data <- pull(df, eid) %in% withdraw_ids

      message("Removing withdrawn participant data ...")
      df[withdraw_data, names(df) != "eid"] <- NA

      message("Writing data to ", out, ".rds ...")
      df %>%
        saveRDS(file = stringr::str_c(out, ".rds"))
    } else {
      message("Writing data to ", out, ".rds ...")
      df %>%
        saveRDS(file = stringr::str_c(out, ".rds"))
    }
}



#' Adds \strong{field} column entries from a dataframe to a file
#'
#' @param data A dataframe with obligatory column \strong{field}.
#' (Ideally the output of \code{\link{bio_field}}.)
#' @param out Field subset file name (including path). Default
#' "ukb_field_subset", writes or appends fields one per line to
#' "ukb_field_subset" in the current directory.
#'
#' @return A file with one field per line (no header). If the file
#' exists, the additional fields are appended.
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


#' Updates column names
#'
#' Renames a dataframe with UKB fields as column names with descriptive
#' names.
#'
#' @param data A dataframe with UKB fields as column names. See
#' \code{\link{bio_phen}}.
#' @param field_finder A dataframe including a column of UKB fields and
#' a column of descriptive names. See \code{\link{bio_field}}.
#'
#' @return A dataframe with UKB field column names replaced with
#' descriptive column names.
#' @importFrom dplyr filter rename
#' @seealso \code{\link{bio_phen}}, \code{\link{bio_field}}
#' @export
bio_rename <- function(data, field_finder) {

  field_subset <- names(data)
  field_finder <- dplyr::filter(field_finder, field %in% field_subset)
  name_old_new <- field_finder$field
  names(name_old_new) <- field_finder$name
  dplyr::rename(df, name_old_new)
}


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

  codings_showcase <- file.path(normalizePath(code_dir),
                                "Codings_Showcase.csv")

  if(!file.exists(codings_showcase)) {
    stop(
      stringr::str_interp(c("Required file ${codings_showcase} ",
                            "does not exist.")), call. = FALSE)
  }

  data.table::fread(codings_showcase, sep = ",", header = TRUE)
}


#' Reads the primary care data
#'
#' Detailed patient level diagnoses, prescriptions, etc. Only available
#' if these data have been requested for the particular project you
#' have access to.
#'
#' @param project_dir Path to the enclosing directory of a UKB project.
#' @param gp_dir Path to the enclosing directory of the primary care
#' data.
#' @param record A string specifying which primary care records are
#' required: "clinical", "registrations", "scripts".
#'
#' @return A dataframe. \strong{Note}. clinical data has 123,669,371
#' rows and 8 columns; registrations data has 361,841 rows and 4
#' columns; scripts data has 57,709,810 rows and 8 columns.
#'
#' @seealso
#' \href{http://biobank.ndph.ox.ac.uk/showcase/label.cgi?id=3001}{Category 3001},
#' \href{http://biobank.ndph.ox.ac.uk/showcase/refer.cgi?id=591}{Resource 591},
#' \href{http://biobank.ndph.ox.ac.uk/showcase/refer.cgi?id=592}{Resource 592}
#'
#' @export
bio_gp <- function(project_dir, record, gp_dir = "raw/") {

  if (length(list.files(file.path(project_dir, gp_dir), pattern = "^gp_")) != 3) {
    stop("GP data is not available for this project.", call. = FALSE)
  }

  if (record == "clinical") {
    data.table::fread(file.path(project_dir, gp_dir, "gp_clinical.txt"),
                      header = TRUE)
  }

  if (record == "registrations") {
    data.table::fread(file.path(project_dir, gp_dir, "gp_registrations.txt"),
                      header = TRUE)
  }

  if (record == "scripts") {
    data.table::fread(file.path(project_dir, gp_dir, "gp_scripts.txt"),
                      header = TRUE)
  }
}


#' Reads the COVID-19 data
#'
#' @description Record-level information for COVID-19 testing. Only
#' available if these data have been requested for the particular
#' project you have access to.
#'
#' @param project_dir Path to the enclosing directory of a UKB project.
#' @param data A string specifying data required: "results", "misc",
#' "tppscripts", "tppclinical", "emisscripts", "emisclinical", "codes".
#' @param covid_dir Path to the enclosing directory of the
#' covid19_results.txt
#' @param code_dir Path to the enclosing directory of the data coding
#' files described in the UKB showcase notes under
#' \href{http://biobank.ndph.ox.ac.uk/showcase/field.cgi?id=40100}{data field 40100}.
#'
#' @return Returns a dataframe of either the COVID-19 testing results,
#' blood group, or codes associated with fields in the results
#' dataframe, depending on the value of argument `data`.
#'
#' @details  UKB showcase documentation for
#' \href{http://biobank.ndph.ox.ac.uk/showcase/field.cgi?id=40100}{data field 40100}
#' describes the categorical columns of the COVID-19 results dataframe
#' as follows:
#' \describe{
#'   \item{\bold{spectype}}{Coding 1853: COVID19 test locations. Locations/methods used to generate samples for COVID19 testing.}
#'   \item{\bold{result}}{Coding 1854: Test result. Result of a binary test.}
#'   \item{\bold{origin}}{Coding 1855: Origin of test sample. Indicates where a participant was believed to be (or be doing) when their sample was taken.}
#'   \item{\bold{laboratory}}{Coding 1856: COVID19 testing laboratories. Laboratories performing tests for COVID19.}
#'   \item{\bold{reqorg}}{Coding 3311: Requesting organisation. Organisations responsible for requesting blood tests.}
#'   \item{\bold{acute}}{Coding 12: ACE boolean. True/False boolean value.}
#'   \item{\bold{hosaq}}{Coding 21: Yes No or Unknown. Artificial coding, generated after data collection.}
#' }
#' 
#' The \code{data} option returns various parts of the COVID-19 data:
#' "results" returns COVID-19 test results; "misc" returns blood group
#' extracted from imputed genotype; "tppscripts" and "emisscripts"
#' return information on the issuing of prescription medication for the
#' TPP and EMIS suppliers respectively; "tppclinical" and
#' "emisclinical" return data on primary care events, such as
#' consultations, diagnoses, history, symptoms, procedures, laboratory
#' tests and administrative information for the TPP and EMIS suppliers
#' respectively; "codes" returns the code meanings for the categorical
#' variables.
#' 
#' For details of the structure of the data, the various GP coding systems,
#' and UKB categorical codes used for each variable see
#' \href{https://biobank.ndph.ox.ac.uk/ukb/refer.cgi?id=3151}{Resource 3151},
#' Primary Care Data for COVID-19 Research.
#'
#' @seealso
#' \href{http://biobank.ndph.ox.ac.uk/showcase/field.cgi?id=40100}{Data field 40100},
#' \href{http://biobank.ndph.ox.ac.uk/showcase/exinfo.cgi?src=COVID19_tests}{COVID-19 test results data}
#'
#' @importFrom data.table fread
#' @importFrom lubridate parse_date_time
#' @importFrom stringr str_replace_all
#' @importFrom dplyr mutate case_when select arrange
#' @importFrom purrr map_df
#' @export
bio_covid <- function(project_dir, data = "results", covid_dir = "raw/",
                      code_dir = "raw/") {

  if(!file.exists(
    file.path(project_dir, covid_dir, "covid19_result.txt"))) {
    stop("COVID-19 data is not available for this project.", call. = FALSE)
  }

  if (data == "results") {
    covid_results <- file.path(project_dir, covid_dir, "covid19_result.txt")
    df <- data.table::fread(covid_results, header = TRUE, data.table = FALSE)
    df$specdate <- lubridate::parse_date_time(df$specdate,
                                              orders = "%d-%m-%Y")
  }

  if (data == "misc") {
    covid_results <- file.path(project_dir, covid_dir, "covid19_misc.txt")
    df <- data.table::fread(covid_results, header = TRUE, data.table = FALSE)
  }
  
  if (data == "tppscripts") {
    covid_results <- file.path(project_dir, covid_dir,
                               "covid19_tpp_gp_scripts.txt")
    df <- data.table::fread(covid_results, header = TRUE, data.table = FALSE,
                            colClasses = c(dmd_code = "character"))
  }
  
  if (data == "tppclinical") {
    covid_results <- file.path(project_dir, covid_dir,
                               "covid19_tpp_gp_clinical.txt")
    df <- data.table::fread(covid_results, header = TRUE, data.table = FALSE)
  }
  
  if (data == "emisscripts") {
    covid_results <- file.path(project_dir, covid_dir,
                               "covid19_emis_gp_scripts.txt")
    df <- data.table::fread(covid_results, header = TRUE, data.table = FALSE)
  }
  
  if (data == "emisclinical") {
    covid_results <- file.path(project_dir, covid_dir,
                               "covid19_emis_gp_clinical.txt")
    df <- data.table::fread(covid_results, header = TRUE, data.table = FALSE)
  }
  
  if (data == "codes") {
    coding_files <- list.files(path = file.path(project_dir, code_dir),
                               pattern = "coding", full.names = TRUE)
    f <- function(path) {
      code <- stringr::str_replace_all(basename(path), "coding|.tsv", "") %>%
        as.integer()

      data.table::fread(path, sep = "\t", header = TRUE, colClasses = "ic") %>%
        dplyr::mutate(
          code = code,
          results_column = dplyr::case_when(
            code == 1853 ~ "spectype",
            code == 1854 ~ "result",
            code == 1855 ~ "origin",
            code == 1856 ~ "laboratory",
            code == 3311 ~ "reqorg",
            code == 12 ~ "acute",
            code == 21 ~ "hosaq"
          )
        ) %>%
        dplyr::select(code, results_column, value = coding, meaning) %>%
        dplyr::arrange(code, value)
    }

    df <- purrr::map_df(coding_files, f)
  }

  return(df)
}


#' Reads record-level HES in-patient data
#'
#' @description Record-level hospital episode statistics (HES)
#' in-patient information.
#'
#' @param project_dir Path to the enclosing directory of a UKB project.
#' @param record A string specifying which HES records are required:
#' "critical", "delivery", "diag", "maternity", "oper", "psych",
#' "hesin".
#' @param hesin_dir Path to the enclosing directory of the primary care
#' data.
#'
#' @return A dataframe of the requested record-level data.
#'
#' @seealso
#' \href{https://biobank.ndph.ox.ac.uk/showcase/label.cgi?id=2000}{Category 2000},
#' \href{https://biobank.ndph.ox.ac.uk/showcase/label.cgi?id=2006}{Category 2006},
#' \href{https://biobank.ndph.ox.ac.uk/showcase/refer.cgi?id=138483}{Resource 138483},
#' \href{https://biobank.ndph.ox.ac.uk/showcase/refer.cgi?id=141140}{Resource 141140}
#'
#' @importFrom data.table fread
#' @export
bio_hesin <- function(project_dir, record, hesin_dir = "raw/") {

  if (record == "critical") {
    df <- data.table::fread(file.path(project_dir, hesin_dir, "hesin_critical.txt"),
                      header = TRUE, data.table = FALSE)
  }

  if (record == "delivery") {
    df <- data.table::fread(file.path(project_dir, hesin_dir, "hesin_delivery.txt"),
                      header = TRUE, data.table = FALSE)
  }

  if (record == "diag") {
    df <- data.table::fread(file.path(project_dir, hesin_dir, "hesin_diag.txt"),
                      header = TRUE, data.table = FALSE)
  }

  if (record == "maternity") {
    df <- data.table::fread(file.path(project_dir, hesin_dir, "hesin_maternity.txt"),
                      header = TRUE, data.table = FALSE)
  }

  if (record == "oper") {
    df <- data.table::fread(file.path(project_dir, hesin_dir, "hesin_oper.txt"),
                      header = TRUE, data.table = FALSE)
  }

  if (record == "psych") {
    df <- data.table::fread(file.path(project_dir, hesin_dir, "hesin_psych.txt"),
                      header = TRUE, data.table = FALSE)
  }

  if (record == "hesin") {
    df <- data.table::fread(file.path(project_dir, hesin_dir, "hesin.txt"),
                      header = TRUE, data.table = FALSE)
  }

  return(df)
}


#' Reads death records
#'
#' @param project_dir Path to the enclosing directory of a UKB project.
#' @param record A string specifying which death data are required:
#' "death" (default) includes date of death, "cause" includes ICD-10
#' cause of death.
#' @param death_dir Path to the enclosing directory of the death data.
#'
#' @return A dataframe of including either the date of death, or cause
#' of death.
#'
#' @seealso
#' \href{https://biobank.ctsu.ox.ac.uk/crystal/label.cgi?id=100093}{Category 100093},
#' \href{https://biobank.ctsu.ox.ac.uk/crystal/refer.cgi?id=134993}{Resource 134993}
#'
#' @importFrom data.table fread
#' @export
bio_death <- function(project_dir, record = "death", death_dir = "raw/") {
  if (record == "death") {
    df <- data.table::fread(file.path(project_dir, death_dir, "death.txt"),
                          header = TRUE, data.table = FALSE)
  }

  if (record == "cause") {
    df <- data.table::fread(file.path(project_dir, death_dir, "death_cause.txt"),
                            header = TRUE, data.table = FALSE)
  }

  return(df)
}


# Genetic data:


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
