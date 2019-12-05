context("Field finder")

# Copied test tab data created for ukbtools. tab file converted to csv
# with quotes and missing values to match default ukbconv created csv file.
#
# tab <- read_tsv("tests/testthat/ukbxxxx.tab")
#
# tab %>%
#   mutate_all(as.character) %>%
#   write.csv(
#     "tests/testthat/ukb12345.csv",
#     row.names = FALSE,
#     quote = TRUE,
#     na = ""
#   )
#
# Associated field finder (header: field, name, ukb_type) created
#
# f <- data.frame(
#   field = names(tab),
#   name = str_c("var_", 1:ncol(tab)),
#   ukb_type = c(
#     "Integer", "Integer", "Integer", "Text", "Text",
#     "Continuous", "Integer", "Text", "Text", "Text",
#     "Text", "Text", "Text", "Text", "Text",
#     "Text", "Text", "Text", "Text", "Text",
#     "Text", "Text", "Text", "Text", "Text",
#     "Text", "Text", "Integer", "Text", "Text",
#     "Integer", "Text", "Text"
#   )
# )
#
# f %>%
#   write_tsv("tests/testthat/ukb12345_field_finder.txt")



test_that("bio_field stops and prints error for invalid path", {
  expect_error(bio_field("invalid/path"), "Invalid project directory path.")
})

test_that("bio_field creates valid path to csv", {
  df <- bio_field("./")

  expect_match(df$basket[1], "^ukb[0-9]+$")
  expect_true(file.exists(df$path[1]))
})
