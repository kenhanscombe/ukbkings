
utils::globalVariables(c(
    "ukb_type", "basket", "field", "path", "name",
    "data", "df", ".", "withdraw", "eid", "r_type",
    "results_column", "coding", "meaning", "value",
    "field_basket", "column_names", "fid", "index",
    "inferred.gender", "ID1", "ID2", "Kinship",
    "Pair"
))


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
#' @import dplyr
#' @importFrom stringr str_remove str_c
#' @importFrom data.table fread
#' @importFrom rlang set_names
#' @importFrom purrr map
#' @importFrom magrittr "%>%"
#' @export
bio_field <- function(project_dir, pheno_dir = "phenotypes") {
    if (!dir.exists(project_dir)) {
        stop("Invalid project directory path.", call. = FALSE)
    }

    finder_paths <- list.files(file.path(project_dir, pheno_dir),
        pattern = "ukb.*field_finder.txt",
        full.names = TRUE
    )
    finder_names <- list.files(file.path(project_dir, pheno_dir),
        pattern = "ukb.*field_finder.txt"
    )

    baskets <- stringr::str_remove(finder_names, "_field_finder.txt")

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
            path = file.path(
                project_dir, pheno_dir,
                stringr::str_c(basket, ".csv")
            )
        )

    # as.data.frame(field_finder)
    f <- as.data.frame(field_finder)
    dups <- f$field[duplicated(f$field)]
    dups <- dups[!(dups %in% "eid")]
    dups <- unique(dups)

    f$duplicated <- f$field %in% dups

    f %>%
        tidyr::unite(field_basket, field, basket, remove = FALSE) %>%
        rowwise() %>%
        mutate(field_unique = ifelse(duplicated, field_basket, field)) %>%
        ungroup() %>%
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
#' @param exact Setting `exact = TRUE` will return all -_index_._array_
#' entries for only exact matches of fields in `field_subset_file`,e.g.,
#' `31`, would return all 31_-index.array_, but not for fields `3159`,
#' `3160` etc. Default `FALSE`. __Note__: Do not set `exact = TRUE` if
#' you have supplied full field names (i.e., including _index_ and
#' _array_) in your field subset file, e.g., 31-0.0 or 31.0.0
#'
#' @details Read the serialized dataframe with
#' readRDS("<name_of_phenotype_subset_file>.rds").
#' 
#' Periodically, the UKB will update some subset of the data, e.g.,
#' hospital episode statistics. When this happens, the datafame created
#' will include all duplicates with the basket ID as suffix
#' ("_<basket_id>"). Decide which to keep, larger basket numbers
#' correspond to more recent data. To use \code{\link{bio_rename}},
#' to update the numeric field names to more descriptive names, first
#' drop duplicates you do not want and rename the remaining fields by
#' deleting the "_<basket_id>" suffix.
#' 
#' @import dplyr stringr
#' @importFrom data.table fread getDTthreads
#' @importFrom readr read_csv
#' @importFrom tidyr nest
#' @importFrom purrr map map_df map_chr reduce
#' @seealso \code{\link{bio_field}} \code{\link{bio_rename}}
#' @export
bio_phen <- function(project_dir, field_subset_file,
                     pheno_dir = "phenotypes", out = "ukb_phenotype_subset",
                     exact = FALSE) {
    bio_reader <- function(data, column_names) {
        p <- dplyr::pull(data, path)[1]
        f <- dplyr::pull(data, field)
        t <- dplyr::pull(data, r_type)
        names(t) <- f

        data.table::fread(
            p,
            header = TRUE, data.table = FALSE, na = c("", "NA"),
            nThread = data.table::getDTthreads(), select = f, colClasses = t,
            col.names = column_names
        )
    }

    # Read field finder and retrieve unique names
    field_finder <- bio_field(project_dir, pheno_dir)

    # Read user supplied fields subset
    field_subset <- data.table::fread(field_subset_file, header = FALSE) %>%
        dplyr::pull(1) %>%
        unique()
    # %>%
    # c("eid"[!"eid" %in% .], .)

    # Translate fields specified as f.field.index.array
    field_subset <- purrr::map_chr(field_subset, ~ {
        ifelse(
            stringr::str_detect(., "f\\."),
            stringr::str_remove(., pattern = "^f\\.") %>%
                stringr::str_replace(pattern = "\\.", replacement = "-"),
            .
        )
    })

    if (exact) {
        field_subset <- field_subset[!field_subset %in% "eid"]
        field_subset <- stringr::str_c("^", field_subset, "-\\d+\\.\\d+$")
        field_subset <- c("eid"[!"eid" %in% field_subset], field_subset)
    } else {
        field_subset <- c("eid"[!"eid" %in% field_subset], field_subset)
        field_subset <- stringr::str_c("^", field_subset)
    }

    field_selection <- field_finder %>%
        dplyr::filter(stringr::str_detect(
            field,
            stringr::str_c(field_subset, collapse = "|")
        ))

    n_baskets <- field_selection %>%
        dplyr::group_by(basket) %>%
        tidyr::nest() %>%
        dplyr::filter(dim(data[[1]])[1] > 1) %>%
        nrow()

    message("Reading data from ", n_baskets, " baskets ...")

    field_selection_nested <- field_selection %>%
        dplyr::group_by(basket) %>%
        tidyr::nest() %>%
        dplyr::filter(dim(data[[1]])[1] > 1) %>%
        dplyr::mutate(
            column_names = map(data, ~ as.data.frame(.) %>%
                pull(field_unique))
        ) %>%
        dplyr::mutate(csv = purrr::map2(data, column_names, bio_reader))

    message("Merging baskets ...")

    df <- field_selection_nested$csv %>%
        purrr::reduce(full_join, by = "eid") %>%
        dplyr::mutate_if(is.character, list(~ na_if(., "")))

    # withdrawals
    withdraw_files <- list.files(paste(project_dir, "raw", sep="/"), pattern = "^w.*csv", full.names = TRUE)

    if (length(withdraw_files) > 0) {
        withdraw_ids <- purrr::map_df(
            withdraw_files, ~ readr::read_csv(., col_names = "withdraw", show_col_types=FALSE)
        ) %>%
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
            if (file.exists(out)) {
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
#' @details __Note__: Before using `bio_rename`, if duplicate fields
#' exist, they will have a basket ID suffix. Drop the duplicates you do
#' not want, and rename the remaining fields by dropping the
#' `_<basket_id>` suffix.
#' @importFrom dplyr filter select distinct rename
#' @seealso \code{\link{bio_phen}}, \code{\link{bio_field}}
#' @export
bio_rename <- function(data, field_finder) {
    field_subset <- names(data)
    field_finder <- dplyr::filter(field_finder, field %in% field_subset) %>%
        dplyr::select(field, name) %>%
        dplyr::distinct()
    name_old_new <- field_finder$field
    names(name_old_new) <- field_finder$name
    dplyr::rename(data, name_old_new)
}
