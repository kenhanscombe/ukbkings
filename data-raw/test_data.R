# Make unit test data

# Used for unit tests and example data

library("tidyverse")
library("ukbtools")


# Use tab testdata from ukbtools
testdata_ukbtools <- system.file("extdata", package = "ukbtools")
testdata_fields <- ukbtools::ukb_df_field("ukbxxxx", testdata_ukbtools)

# Convert tab file to csv with quotes and missing values to match
# default ukbconv created csv file
tab <- read.delim(file.path(testdata_ukbtools, "ukbxxxx.tab"))

tab %>%
    dplyr::rename_all(
        ~ {
            stringr::str_replace(
                stringr::str_replace(., "f\\.", ""), "\\.", "-"
            )
        }
    ) %>%
    dplyr::mutate_all(as.character) %>%
    write.csv(
        "inst/testdata/ukb12345.csv",
        row.names = FALSE,
        quote = TRUE,
        na = ""
    )

# Associated "field finder" from tab names and types.
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

testdata_fields$field.tab <- stringr::str_replace(
    stringr::str_replace(testdata_fields$field.tab, "f\\.", ""), "\\.", "-"
)

f <- data.frame(
    field = testdata_fields$field.tab,
    name = testdata_fields$col.name,
    ukb_type = testdata_fields$col.type
) %>%
    dplyr::mutate(r_type = col_type[ukb_type])

f %>%
    write.table(
        "inst/testdata/ukb12345_field_finder.txt",
        sep = "\t",
        row.names = FALSE,
        quote = FALSE
    )

# A field subset data.frame
field_subset <- as.character(c(31, 6142, 21000))

f %>%
    dplyr::filter(
        stringr::str_detect(
            field,
            stringr::str_c(
                stringr::str_c("^", field_subset),
                collapse = "|"
            )
        )
    ) %>%
    dplyr::select(field) %>%
    write.table(
        "inst/testdata/ukb12345_field_subset.txt",
        sep = ",",
        row.names = FALSE,
        col.names = FALSE,
        quote = FALSE
    )
