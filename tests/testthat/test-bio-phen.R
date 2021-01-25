context("phenotypes")

test_that("bio_field_add writes field subset to file", {
    testdata_path <- system.file("testdata", package = "ukbkings")
    tmp <- tempfile()
    field_subset <- as.character(c(31, 6142, 21000))
    df <- ukbkings::bio_field(testdata_path, pheno_dir = "")

    df %>%
        dplyr::filter(
            stringr::str_detect(
                field,
                stringr::str_c(
                    stringr::str_c("^", field_subset),
                    collapse = "|"
                )
            )
        ) %>%
        ukbkings::bio_field_add(out = tmp)

    d1 <- read.csv(tmp, header = FALSE) %>%
        digest::digest()
    d2 <- read.csv(
        file.path(testdata_path, "ukb12345_field_subset.txt"),
        header = FALSE
    ) %>%
        digest::digest()
    expect_equal(d1, d2)
})


test_that("bio_phen reads and writes a field subset", {
    tmp <- tempfile()
    tmpdir <- tempdir()
    testdata_path <- system.file("testdata", package = "ukbkings")
    field_subset <- as.character(c(31, 6142, 21))
    readr::write_lines(field_subset, tmp)

    df1 <- data.table::fread(
        file.path(testdata_path, "ukb12345.csv"),
        data.table = FALSE
    ) %>%
        select("eid", starts_with(field_subset))

    # Argument exact = FALSE
    bio_phen(
        testdata_path,
        field_subset_file = tmp,
        pheno_dir = "",
        out = file.path(tmpdir, "df2")
    )

    df2 <- readRDS(file.path(tmpdir, "df2.rds"))
    expect_equal(class(df2), "data.frame")
    expect_equal(names(df1), names(df2))


    # Argument exact = TRUE
    bio_phen(
        testdata_path,
        field_subset_file = tmp,
        pheno_dir = "",
        out = file.path(tmpdir, "df3"),
        exact = TRUE
    )

    df3 <- readRDS(file.path(tmpdir, "df3.rds"))
    df3_partial_matched_names <- df3 %>%
        select(starts_with("21")) %>%
        names()
    testthat::expect_length(df3_partial_matched_names, 0)
})


test_that("bio_phen drops withdrawals", {
})